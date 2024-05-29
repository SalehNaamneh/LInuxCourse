#!/bin/bash -e

is_audio="true"
playlist_file=".playlists.txt"

# Function to print help message
print_help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -u, --url          URL of the YouTube video"
    echo "  -f, --filename     File name for the downloaded video"
    echo "  -p, --folderPath   Folder path to save the downloaded video"
    echo "  -r, --resolution   Resolution of the video to download"
    echo "  -h, --help         Display this help message"
}

# Function to insert a new song into the playlists file
add_song_to_playlist() {
    local song_name="$1"
    local playlist_name="$2"
    local playlist_path="$3"
    local line_to_write="\t$song_name"

    if [ ! -f "$playlist_file" ]; then
        touch "$playlist_file"
    fi

    while IFS= read -r line; do
        if [[ "$line" == "$playlist_name "* ]]; then
            sed -i "/^$playlist_name.*/a\\$line_to_write" "$playlist_file"
            return
        fi
    done < "$playlist_file"

    printf "$playlist_name $playlist_path\n" >> "$playlist_file"
    printf "$line_to_write\n" >> "$playlist_file"
}


# Function to show contents of playlists
shows_playlists() {
    local playlist_names=("$@")
    
    if [ ${#playlist_names[@]} -eq 0 ]; then
        cat "$playlist_file"
    else
        print=1
        while IFS= read -r line; do
            if [[ ! "$line" =~ ^[[:space:]] ]]; then # not this if
                print=0
                for playlist_name in "${playlist_names[@]}"; do
                    if [[ "$line" =~ ^$playlist_name[[:space:]] ]]; then
                        print=1
                    fi
                done
            fi

            if [ $print -eq 1 ]; then
                echo "$line"
            fi
        done < "$playlist_file"
    fi
}

# Function to create the playlist file
create_playlist_file() {
    local playlist_names=("$@")
    if [ ${#playlist_names[@]} -eq 0 ]; then
        echo "[!] Error, you must provide a playlist to listen to"
        exit 4
    fi

    local playlist_file_name=""
    for playlist_name in "${playlist_names[@]}"; do
        playlist_file_name="${playlist_name}_${playlist_file_name}"
    done

    playlist_file_name="${playlist_name}_playlist.m3u"

    if [[ -f "$playlist_file_name" ]]; then
        rm "$playlist_file_name"
    fi
    touch $playlist_file_name

    while IFS= read -r line; do
        if [[ ! "$line" =~ ^[[:space:]] ]]; then
            add_to_playlist=0
            for playlist_name in "${playlist_names[@]}"; do
                if [[ "$line" =~ ^$playlist_name[[:space:]] ]]; then
                    add_to_playlist=1
                    path_to_file=$(echo "$line" | awk '{print $2}')
                fi
            done
        else
            if [ $add_to_playlist -eq 1 ]; then
                echo "${path_to_file}/${line:1}" >> "$playlist_file_name"
            fi
        fi
    done < "$playlist_file"

    echo "$playlist_file_name"
}

# Function to start the playlist using mpv
play_playlist() {
    local playlist_name="$1"
    mpv $playlist_name
}

# Function to create folder if it doesn't exist
create_folder() {
    local folderpath="$1"
    if [ ! -d "$folderpath" ]; then
        mkdir -p "$folderpath"
    fi
}

# Function to download a video
download_video() {
    local url="$1"
    local folderpath="$2"
    local filename="$3"
    local resolution="$4"
    echo  "[+] Downloading video from: $url to $folderpath with filename $filename and resolution $resolution"
    python3 ./youtubedownloader.py "$url" "$folderpath" "$filename" "$is_audio" "$resolution" 2>/dev/null &
    pid=$! # Process Id of the previous running command

    # Animation for the download
    spin_animation=('-' '\\' '|' '/')

    echo -n "[+] Downloading: ${spin_animation[0]}"
    while kill -0 $pid 2>/dev/null; do
    for i in "${spin_animation[@]}"; do
        echo -ne "\b$i"
        sleep 0.2
    done
    done
    echo -ne "\b"
    echo

    wait $pid
    python_exit_status=$?

    if [ $python_exit_status -ne 0 ]; then
        echo "[+] Error: Python script encountered an error."
        exit 3
    fi

    playlist_name=$(echo "$folderpath" | awk -F '/' '{print $NF}')
    add_song_to_playlist "$filename" "$playlist_name" "$folderpath"

}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --url | -u)
            url="$2"
            shift 2
            ;;
        --filename | -f)
            filename="$2"
            shift 2
            if [[ "$filename" == *.mp4 ]]; then
                is_audio="false"
            fi
            ;;
        --folderPath | -p)
            folderpath="$2"
            create_folder "$folderpath"
            shift 2
            ;;
        --resolution | -r)
            resolution="$2"
            shift 2
            ;;
        -–play | -pl)
            shift 1
            while [[ $# -gt 0 ]]; do
                if [[ $1 != -* ]]; then
                    playlist_args+=("$1")
                fi
                shift
            done
            playlist_file=$(create_playlist_file "${playlist_args[@]}")
            play_playlist "${playlist_file[@]}"
            exit
            ;;
        --list | -ls)
            shift 1
            while [[ $# -gt 0 ]]; do
                if [[ $1 != -* ]]; then
                    playlist_names+=("$1")
                else
                    break
                fi
                shift
            done

            shows_playlists "${playlist_names[@]}"
            exit
            ;;
        --help | -h)
            print_help
            exit 0
            ;;
        *)
            echo "[!] Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check if in venv, if not, create and activate one
if [[ -n "$VIRTUAL_ENV" ]]; then
    echo "[+] Creating Python virtual environment"
    python3 -m venv venv > /dev/null
    source venv/bin/activate

    echo "[+] Installing Python dependencies"
    pip3 install -r requirements.txt > /dev/null
fi

download_video "$url" "$folderpath" "$filename" "$resolution"

echo "[+] Download

