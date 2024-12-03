#!/bin/bash

source .env

YEAR=2024
day="$1"

if [ -z "${day}" ]; then
    day="$(date "+%-d")"
fi

if ! [ -f "day${day}.txt" ]; then
    curl -s -b "session=$AOC_SESSION" https://adventofcode.com/${YEAR}/day/${day}/input -o "day${day}.txt"
fi
