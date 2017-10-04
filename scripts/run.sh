#!/bin/bash
docker run \
-d \
--name PerfectServer001 \
-v `pwd`:/PerfectServer001 \
-w /PerfectServer001 \
swiftdocker/swift:latest \
/bin/sh -c \
"swift run"
