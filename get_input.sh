#!/bin/bash

source .env

YEAR=2024
day="$1"

mkdir -p .input
curl -s -b "session=$AOC_SESSION" https://adventofcode.com/${YEAR}/day/${day}/input -o "day${day}.txt"
