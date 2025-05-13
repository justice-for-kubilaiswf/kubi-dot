#!/usr/bin/env python3
import argparse
import logging
import sys
import json
import subprocess
import os

logger = logging.getLogger(__name__)

def parse_arguments():
    parser = argparse.ArgumentParser()
    
    parser.add_argument(
        '-t',
        '--trunclen',
        type=int,
        metavar='trunclen'
    )
    parser.add_argument(
        '-f',
        '--format',
        type=str,
        metavar='custom format',
        dest='custom_format'
    )
    parser.add_argument(
        '--font',
        type=str,
        metavar='the index of the font to use for the main label',
        dest='font'
    )
    parser.add_argument(
        '-q',
        '--quiet',
        action='store_true'
    )
    
    args = parser.parse_args()
    return args

def get_player_status():
    return subprocess.check_output(["playerctl", "status"]).decode("utf-8").strip()

def get_player_metadata():
    player_args = ["playerctl", "metadata"]
    
    title = ""
    artist = ""
    player_name = ""
    
    try:
        player_name = subprocess.check_output(["playerctl", "--player=playerctld", "metadata", "--format", "{{playerName}}"]).decode("utf-8").strip()
        title = subprocess.check_output(["playerctl", "--player=playerctld", "metadata", "--format", "{{title}}"]).decode("utf-8").strip()
        artist = subprocess.check_output(["playerctl", "--player=playerctld", "metadata", "--format", "{{artist}}"]).decode("utf-8").strip()
    except Exception:
        try:
            player_name = subprocess.check_output(["playerctl", "metadata", "--format", "{{playerName}}"]).decode("utf-8").strip()
            title = subprocess.check_output(["playerctl", "metadata", "--format", "{{title}}"]).decode("utf-8").strip()
            artist = subprocess.check_output(["playerctl", "metadata", "--format", "{{artist}}"]).decode("utf-8").strip()
        except Exception:
            pass
    
    return {"title": title, "artist": artist, "player_name": player_name.lower()}

def show_status(args):
    trunclen = args.trunclen or 35
    
    try:
        status = get_player_status()
        if status == 'Playing':
            metadata = get_player_metadata()
            title = metadata["title"]
            artist = metadata["artist"]
            
            output = ""
            if artist and title:
                output = f"{artist} - {title}"
            elif title:
                output = title
            else:
                output = "Playing"
            
            if len(output) > trunclen:
                output = output[:trunclen - 3] + "..."
            
            result = {
                "text": output,
                "class": "playing",
                "alt": metadata["player_name"]
            }
            print(json.dumps(result))
            return
        elif status == 'Paused':
            metadata = get_player_metadata()
            title = metadata["title"]
            artist = metadata["artist"]
            
            output = ""
            if artist and title:
                output = f"{artist} - {title}"
            elif title:
                output = title
            else:
                output = "Paused"
            
            if len(output) > trunclen:
                output = output[:trunclen - 3] + "..."
            
            result = {
                "text": f"[Paused] {output}",
                "class": "paused",
                "alt": metadata["player_name"]
            }
            print(json.dumps(result))
            return
    except Exception as e:
        if args.quiet:
            logger.error(f"Exception: {e}")
            result = {"text": "", "class": ""}
        else:
            logger.error(f"Error: {e}")
            result = {"text": "No player", "class": "no-player"}
        
        print(json.dumps(result))
        return

if __name__ == '__main__':
    args = parse_arguments()
    show_status(args)