#!/bin/bash

PULL_INTERVAL=10  # seconds
NOTE_FOLDER=./test  # should be global folder

echo "Running handler.sh with NOTE_FOLDER=${NOTE_FOLDER}."

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

exit_peacefully() {
	# listen to Ctrl-C, propagate this to the background loop looking for
	# data to pull from remote by killing the process identified by PID.
	echo "Exiting peacefully."
	kill "${PULL_LOOP_PID}"
	exit 0
}
trap exit_peacefully SIGINT

react_to_local_change() {
	# On being called, check if there is a change relevant to git. Commit
	# and push.
	echo "$(date): Some files have changed in ${NOTE_FOLDER}."
	cd "${NOTE_FOLDER}" || return
	git add .
	if ! git diff --staged --quiet
	then
		git commit -m "Automatic commit in ${NOTE_FOLDER} at $(date)"
		git push origin main
		echo "Back to main loop."
	else
		echo "False alarm."
	fi
}
export NOTE_FOLDER
export -f react_to_local_change

pull_remote_change() {
	# this function is run in the current shell, not a subshell
	# hence we use `return` and `cd -` because we want to reset the global
	# state
	cd "${NOTE_FOLDER}" || return
	echo "$(date): checking for remote changes."	
	git fetch origin main >/dev/null 2>&1
	git rebase origin/main
	cd - >/dev/null || return
}
export -f pull_remote_change

while true
do
	pull_remote_change
	sleep "${PULL_INTERVAL}"
done &
# save the PID of this background loop so we can kill it later.
PULL_LOOP_PID=$!

# NOTE using `sleep` here would mean that a new entr subprocess is spawned regularly
# We actually want a new subprocess to start immediately, but only once the
# current one finishes!
# Also ignore git internals.
while true
do
	find ${NOTE_FOLDER} -type f \
		! -path "${NOTE_FOLDER}/.git/*" \
		| entr -dnr bash -c 'react_to_local_change'
done
