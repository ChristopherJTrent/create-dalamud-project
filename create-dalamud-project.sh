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
    PROJECT_NAME=$1
    echo $PROJECT_NAME
    CONTINUE=1
}

cleanupSetup () {
    echo "KSP:$KEEPSAMPLEPROJECT, EC:$EXIT_CODE, FCU:$FORCECLEANUP"
    if [ $KEEPSAMPLEPROJECT -a !$FORCECLEANUP ]; then
        echo "Keeping sample project for future runs. "
    else
        FORCECLEANUP=1
    fi
    if [ $FORCECLEANUP ]; then
        echo "Removing unused setup files."
        rm -rf ./SamplePlugin
    fi
    if [ $EXIT_CODE ]; then 
        exit $EXIT_CODE
    else 
        exit 0
    fi
}

while getopts h:-help:d:-dalamud:n:-name:k:c: flag 
do
    case "${flag}" in
        h) echoHelp;;
        -help) echoHelp;;
        d) setXLLocation ${OPTARG};;
        -dalamud) setXLLocation ${OPTARG};;
        n) setProjectName ${OPTARG};;
        -name) setProjectName ${OPTARG};;
        k) KEEPSAMPLEPROJECT=1;;
        c) FORCECLEANUP=1;;
    esac
done

if [ $CONTINUE ]; then
    dependencies=( dotnet code wget git );
    location="";

    for name in ${dependencies[@]}; do
        if [ $(command -v $name)  ]; then
            echo "Dependency $name found.";
        else
            echo "Dependency $name missing, please install it.";
            missingDependencies=1;
        fi
    done
    if [ $missingDependencies ]; then
        echo "check above output for missing dependencies.";
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
            #exit 1
        fi
    fi
    if [ -d "./SamplePlugin" ]; then
        echo "Using existing sample project at ./SamplePlugin"
        git -C ./SamplePlugin status -uno | grep -q "behind" && changes=1
        if [ $changes ]; then
            echo "Your branch is out of date. Would you like to update it? [Y/n]:"
            read response
            case $response in
            n) echo "Using out-of-date Sample Plugin." ;;
            no) echo "Using out-of-date Sample Plugin." ;;
            *) git -C ./SamplePlugin pull;
            git -C ./SamplePlugin restore *;;
            esac
        else 
            echo "Sample Project is up-to-date"
        fi
        KEEPSAMPLEPROJECT=1
    else 
        echo "Cloning sample project into temporary directory, pass -k to keep the sample project."
        git clone https://github.com/goatcorp/SamplePlugin.git
    fi    
    if [ -d ./$PROJECT_NAME ]; then
        echo "Project files already exist, aborting..."
        EXIT_CODE=1
        cleanupSetup
    else 
        mkdir "$PROJECT_NAME"
    fi
fi