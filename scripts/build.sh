#!/bin/sh

cd ./BCC\ Media\ tvOS

if [ $1 == 'pre' ]
then
    echo "Injecting environment variables into CI.swift"
    cp ./CI.swift ./CI.swift.tmp
    envsubst < ./CI.swift > ./CI.swift.replaced
    mv ./CI.swift.replaced ./CI.swift
elif [ $1 == 'post' ] 
then
    echo "Reverting injection to cleanup CI.swift";
    mv ./CI.swift.tmp ./CI.swift
fi