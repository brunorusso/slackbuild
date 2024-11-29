#!/bin/bash

#Global Variables
TEMP="/tmp/slackbuild"
CHANGELOG="/tmp/slackbuild/changelog"
PKG="/tmp/slackbuild/package"
NAME=$1
LOGDIR="/tmp/slackbuild/log/"
RED='\033[0;31m'
NC='\033[0m' # No Color
ARCH=`uname -m`

#Specific Variables
SLACKWARE_VERSION="15.0"
LOGFILE="slackbuild-run-"
TIME=`date +%s`


#printf "I ${RED}love${NC} Stack Overflow\n"


init(){
    #Create temp directory
    printf "---> Creating temporary directory"
    mkdir -p $TEMP
    mkdir -p $CHANGELOG
    mkdir -p $PKG
    mkdir -p $LOGDIR
}

search(){
    echo "---> Get ChangeLog"

    cd $CHANGELOG
    echo "### Searching Package ###" >> $LOGDIR$LOGFILE$TIME.log
    wget  https://slackbuilds.org/slackbuilds/$SLACKWARE_VERSION/ChangeLog.txt 2>> $LOGDIR$LOGFILE$TIME.log

#    cat $LOGDIR$LOGFILE$TIME.log
    echo "---> Searching Package..."

    SEARCH=`cat ChangeLog.txt | grep $NAME | head -1 | cut -d: -f1`

    PACKAGE=`echo $SEARCH | cut -d/ -f2`

    if [ "$PACKAGE" = "$NAME" ]; then echo '   > The package was found'; else echo '   > The package not found' && exit 1; fi
}

get_pkg(){
    echo "---> Get Slackbuild Package"
    cd $PKG
    echo "### Get Slackbuild Package ###" >> $LOGDIR$LOGFILE$TIME.log

    wget https://slackbuilds.org/slackbuilds/$SLACKWARE_VERSION/$SEARCH.tar.gz 2>> $LOGDIR$LOGFILE$TIME.log
    cat $LOGDIR$LOGFILE$TIME.log
    PACKAGE=`echo $SEARCH | cut -d/ -f2`

    echo "### Unziping Package ###" >> $LOGDIR$LOGFILE$TIME.log
    tar xzvf $PACKAGE.tar.gz  > $LOGDIR$LOGFILE$TIME.log 2>&1 
#    cat $LOGDIR$LOGFILE$TIME.log
    cd $PACKAGE


}

build(){
    echo "---> Get Source to Build"

    if [ "$ARCH" = "x86_64" ]; then DOWNLOAD="DOWNLOAD_x86_64"; else DOWNLOAD="DOWNLOAD"; fi
    SRC=`cat $PACKAGE.info | grep $DOWNLOAD | head -1 | cut -d= -f2 | cut -d\" -f2`
    echo "### Get Source to Build ###" >> $LOGDIR$LOGFILE$TIME.log

    wget $SRC 2>> $LOGDIR$LOGFILE$TIME.log
#    cat $LOGDIR$LOGFILE$TIME.log
    echo "---> Building Package"

    echo "### Building Package ###" >> $LOGDIR$LOGFILE$TIME.log

    ./$PACKAGE.SlackBuild > $LOGDIR$LOGFILE$TIME.log 2>&1 
    ./$PACKAGE.SlackBuild > $LOGDIR$LOGFILE$TIME.log
    CHECK=`tac $LOGDIR$LOGFILE$TIME.log | head -2 | cut -d" " -f4`
    if [ "$CHECK" = "created." ]; then echo '   > The package was build with success'; else printf "${RED}   > The package not build with sucess. To more information see the file ${NC}$LOGDIR$LOGFILE$TIME.log" && exit 1; fi

}

touch $LOGDIR$LOGFILE$TIME.log
echo "### START ###" >> $LOGDIR$LOGFILE$TIME.log

init
search
get_pkg
build

echo "---> Installing Package"

INSTALL=`tac $LOGDIR$LOGFILE$TIME.log | head -2 | cut -d" " -f3`

installpgk $INSTALL
