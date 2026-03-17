#!/bin/bash

PULL_INTERVAL=1  # seconds
NOTE_FOLDER=./test  # should be global folder

echo "Running handler.sh with NOTE_FOLDER=${NOTE_FOLDER}"

if [[ -z "$(command -v entr)" ]]
then
	echo "ERROR: entr is not installed!"
	exit 1
fi

if [[ -z "$(command -v git)" ]]
then
	echo "ERROR: git is not installed!"
	exit 1
fi

react_to_change() {
	echo "Some files have changed in ${NOTE_FOLDER}"
}
export -f react_to_change

while sleep 0.5
do
	find ${NOTE_FOLDER} -type f | entr -d bash -c 'react_to_change'
done
