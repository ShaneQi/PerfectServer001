#!/bin/bash
docker run \
-d \
--name PerfectServer001 \
-v `pwd`:/PerfectServer001 \
--network GoldenArches \
-w /PerfectServer001 \
shaneqi/swift:4.0-DEVELOPMENT-SNAPSHOT-2017-09-30-a \
/bin/sh -c \
"swift run"
