#!/bin/bash

mongod --dbpath ./data &>/dev/null &

pid=$!

while true
do
	npm start
done

kill $pid

