#!/usr/bin/bash

setXLLocation () {
    XLINSTALLDIR=$1;
    echo "\$XLINSTALLDIR set to $1";
}

echoHelp () {
    echo "create-dalamud-project help";
    echo "-h|--help: show this screen."
    echo "-d|--dalamud {directory}: sets the XIVLauncher installation directory to search for dalamud development files"
    echo "-n|--name {project name}: Required. sets the name of the project directory to be generated."
    EXITCODE=0
}

setProjectName () {
    PROJECT_NAME=$2
    CONTINUE=1
}

while getopts h:-help:d:-dalamud:n:-name: flag 
do
    case "${flag}" in
        h) echoHelp;;
        -help) echoHelp;;
        d) setXLLocation ${OPTARG};;
        -dalamud) setXLLocation ${OPTARG};;
        n) setProjectName ${OPTARG};;
        -name) setProjectName ${OPTARG};;
    esac
done

if [ $CONTINUE ]; then
    dependencies=( dotnet code wget );
    location="";

    for name in ${dependencies[@]}; do
        if [ $(command -v $name)  ]; then
            echo "Dependency $name found.";
        else
            echo "Dependency $name missing, please install it.";
            missingDependencies=1;
        fi
    done
    if [ $missingDependencies > 0 ]; then
        echo "check above output.";
        exit 1
    else 
        if [ $XLINSTALLDIR ]; then
            echo "Using environment XL location. \$XLINSTALLDIR is set to $XLINSTALLDIR";
            if [ -d "$XLINSTALLDIR/dalamud" ]; then
                XLINSTALLDIR="$XLINSTALLDIR/dalamud"
                DIRECTORY_UPDATED=1
            elif [ -d "$XLINSTALLDIR/addon" ]; then 
                XLINSTALLDIR="$XLINSTALLDIR/addon";
                DIRECTORY_UPDATED=1
            fi
            if [ -d "$XLINSTALLDIR/hooks" ]; then
                XLINSTALLDIR="$XLINSTALLDIR/hooks";
                DIRECTORY_UPDATED=1
            elif [ -d "$XLINSTALLDIR/Hooks" ]; then
                XLINSTALLDIR="$XLINSTALLDIR/Hooks";
                DIRECTORY_UPDATED=1
            fi
            if [ -d "$XLINSTALLDIR/dev" ]; then
                XLINSTALLDIR="$XLINSTALLDIR/dev";
                DIRECTORY_UPDATED=1
            fi
            if [ $DIRECTORY_UPDATED ]; then
                echo "Dalamud installation directory updated to $XLINSTALLDIR";
            fi
        elif [ -d ~/.xlcore/dalamud/Hooks/dev ]; then
            echo "Using Dalamud found at ~/.xlcore";
            XLINSTALLDIR=~/.xlcore/dalamud/Hooks/dev;
        else
            echo "Could not find XL installation location, please provide one using the -d flag."
        fi
    fi
fi