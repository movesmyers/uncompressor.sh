#!/bin/sh

#
# uncompressor.sh
#
# Copyright (c) 2014 Richard Myers
# MIT licensed
#

VERSION="0.0.2"

function usage {
  echo "
    uncompressor version $VERSION
    Usage: uncompressor [--help] file [extraction directory]

    uncompressable file extensions:
      .zip
      .tar
      .tar.gz
      .tgz
      .tar.bz2
      .tbz

    If no directory is specified on the command line,
    files will be extracted into your current directory.
    "
  exit
}

function parse () {
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
  FILE="$1"
  if [ "$#" -eq "2" ]; then
    if [ -d "$2" ]; then
      DIR="$2"
    else
      echo "'$2' does not exist."
      echo "Setting output directory to `pwd`."
      DIR=`pwd`
    fi
  else
    DIR=`pwd`
  fi

  # parse filename to determine the command and options
  parse $FILE

  # the work
  if [ "$CMD" == "unzip" ]; then
    UNZIP=`which unzip`
    if [ -z "$UNZIP" ]; then
      echo "Could not find 'unzip' binary, exiting."
      exit 1
    else
      echo "Unzipping '$FILE' to '$DIR'..."
      $UNZIP $FILE -d $DIR
    fi
  elif [ "$CMD" == "tar" ]; then
    TAR=`which tar`
    if [ -z "$TAR" ]; then
      echo "Could not find 'tar' binary, exiting."
      exit 1
    else
      echo "Untarring '$FILE' to '$DIR'..."
      $TAR xv$OPTS -f $FILE -C $DIR
    fi
  fi
fi
