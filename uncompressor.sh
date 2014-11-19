#!/bin/bash

#
# uncompressor.sh
#
# Copyright (c) 2014 Richard Myers
# MIT licensed
#

VERSION="0.0.5"

function usage {
  echo "
    uncompressor version $VERSION
    Usage: uncompressor [--help, --remove] file [extraction directory]

    uncompressable file extensions:
      .zip
      .tar
      .tar.gz
      .tgz
      .tar.bz2
      .tbz

    If an extraction directory is specified and does not exist, uncompressor
    will attempt to create it for you. If no directory is specified or the
    directory cannot be created, files will be extracted into your current
    working directory.

    Additional options are as follows:

      --help      Print this text.
      --remove    Remove the original file (without prompting) after successful 
                  decompression.
    "
  exit
}

function parse_filename () {
  FILE="$1"
  EXT="${FILE##*.}"
  if [ "$EXT" == "zip" ]; then
    CMD="unzip"
  elif [ "$EXT" == "tar" ]; then
    CMD="tar"
  elif [ "$EXT" == "tgz" ] || [ "$EXT" == "gz" ]; then
    CMD="tar"
    OPTS="z"
  elif [ "$EXT" == "tbz" ] || [ "$EXT" == "bz2" ]; then
    CMD="tar"
    OPTS="j"
  fi
  if [ -z "$CMD" ]; then
    echo "Could not determine how to uncompress '$FILE', exiting."
    exit 1
  fi
}

# main

if [ "$#" -lt "1" ] || [ "$1" == "--help" ]; then
  usage
else
  if [ "$1" == "--remove" ]; then
    SHOULD_REMOVE=1
    shift
  fi
  FILE="$1"
  if [ "$#" -eq "2" ]; then
    if [ -d "$2" ]; then
      DIR="$2"
    else
      mkdir -p "$2"
      if [ $? -eq 1 ]; then
        echo "Setting output directory to `pwd`"
        DIR=`pwd`
      else
        echo "Created '$2'"
        DIR="$2"
      fi
    fi
  else
    DIR=`pwd`
  fi

  # parse filename to determine the command and options
  parse_filename $FILE

  # the work
  if [ "$CMD" == "unzip" ]; then
    type unzip > /dev/null 2>&1 || {
      echo >&2 "Could not find 'unzip' binary, exiting."
      exit 1
    }
    echo "Unzipping '$FILE' to '$DIR'..."
    unzip $FILE -d $DIR
  elif [ "$CMD" == "tar" ]; then
    type tar > /dev/null 2>&1 || {
      echo >&2 "Could not find 'tar' binary, exiting."
      exit 1
    }
    echo "Untarring '$FILE' to '$DIR'..."
    tar xv$OPTS -f $FILE -C $DIR
  fi
  
  if [ $SHOULD_REMOVE ] && [ $? -eq "0" ]; then
    echo "Removing '$FILE'"
    rm $FILE 
  fi

fi
