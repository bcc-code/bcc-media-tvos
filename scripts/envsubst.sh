#!/bin/sh

cd ./Library/Environment

envsubst < ./CI.swift > ./CI.swift.tmp

mv ./CI.swift.tmp ./CI.swift