#!/bin/bash

mongod --port 27018 --dbpath ./data &>/dev/null &

pid=$!

while true
do
	npm start
done

kill $pid

