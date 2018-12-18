#!/bin/bash

set -e

[ $# = 3 ]
image=$1
src=$2
dst=$3

id=$(docker create "$image")
trap 'docker rm "$id" >/dev/null' 0

docker cp "$id:$src" "$dst"
