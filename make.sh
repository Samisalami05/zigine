#!/bin/bash

# A simple build script so that i dont have to remember
# the build command.
#
# It has two options:
# build - build the program
# run   - build and run the program
#
# Note: the script will clear the terminal
#

if [ "$1" = "" ]; then
	echo "Error: No command given"
	echo ""
	echo "available commands:"
	echo "run   - build and run the program"
	echo "build - only build the program"
	exit
fi

case "$1" in
    run)
		clear
        zig build --summary none --error-style minimal run
        ;;
    build)
		clear
        zig build --summary none --error-style minimal
        ;;
	*)
		echo "unknown command $1"
		;;
esac
