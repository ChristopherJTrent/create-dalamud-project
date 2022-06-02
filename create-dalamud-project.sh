#!/usr/bin/bash

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
    echo 'placeholder';
fi