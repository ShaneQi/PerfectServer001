if [[ `uname` == 'Darwin' ]]; then
	SCRIPT=`greadlink -f $0`
else
	SCRIPT=`readlink -f $0`
fi
SCRIPTPATH=`dirname $SCRIPT`
PROJPATH=`dirname $SCRIPTPATH`
docker run \
-d \
--name PerfectServer001 \
-v $PROJPATH:/PerfectServer001 \
-w /PerfectServer001 \
swift:3.1.0 \
/bin/sh -c \
"\
apt update;\
apt install uuid-dev;\
swift build;\
.build/debug/PerfectServer001;\
" 
