from pytube import YouTube
from pytube.exceptions import PytubeError
import argparse

def download_video(url, folder_name, file_name, is_audio_only, resolution):
    """
    download video from youtube using provided code and pytube lib
    """
    try:
        # Create a YouTube object 
        yt = YouTube(url)
    except PytubeError as e:
        print(f"Failed to fetch video : {e}", end="")
        raise
    
    try:
        # video or audio
        if is_audio_only.lower() == 'true':
            # Filter to audio streams 
            stream = yt.streams.filter(only_audio=True).first()
        else:
            # Filter video stream with all filters values, select the first match
            stream = yt.streams.filter(res=resolution, file_extension='mp4').first()

        # Check if a valid stream is available
        if stream:
            # Download the stream to local system
            output_path = stream.download(output_path=folder_name, filename=file_name)
        else:
            print("Resolution availability Error.", end="")
    except PytubeError as e:
        print(f"Download failed: {e}", end="")
        raise

def parse_arguments():
    """
    parse the args, added help and defulte values for each args
    """
    parser = argparse.ArgumentParser(description='YouTube Downloader')
    parser.add_argument('url', type=str, help='URL of the YouTube video')
    parser.add_argument('folderpath', type=str, default='./', help='Folder path to save the downloaded video')
    parser.add_argument('filename', type=str, default='video.mp4', help='File name for the downloaded video')
    parser.add_argument('isaudio', type=str, default='false', help='Flag to specify if download should be audio only (true/false)')
    parser.add_argument('resolution', type=str, default='720p', help='Resolution of the video to download')
    return parser.parse_args()

def main():
    args = parse_arguments()
    download_video(args.url, args.folderpath, args.filename, args.isaudio, args.resolution)

if __name__ == "__main__":
    main()
