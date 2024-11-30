#!/bin/bash

#Global Variables
TEMP="/tmp/slackbuild"
CHANGELOG="/tmp/slackbuild/changelog"
PKG="/tmp/slackbuild/package"
ARG=$1
LOGDIR="/tmp/slackbuild/log/"
RED='\033[0;31m'
NC='\033[0m' # No Color
ARCH=`uname -m`

#Specific Variables
SLACKWARE_VERSION="15.0"
LOGFILE="slackbuild-run-"
TIME=`date +%s`

init(){
    #Create temp directory
    mkdir -p $TEMP
    mkdir -p $CHANGELOG
    mkdir -p $PKG
    mkdir -p $LOGDIR
    touch $LOGDIR$LOGFILE$TIME.log
    echo "---> Creating temporary directory"
    echo "### START ###" >> $LOGDIR$LOGFILE$TIME.log
}

search(){
    echo "---> Get ChangeLog"
    echo "### Searching Package ###" >> $LOGDIR$LOGFILE$TIME.log
    cd $CHANGELOG
#    wget https://slackbuilds.org/slackbuilds/$SLACKWARE_VERSION/ChangeLog.txt -a $LOGDIR$LOGFILE$TIME.log
    echo "---> Searching Package..."
    SEARCH=`cat ChangeLog.txt | grep "/$ARG:" | head -1 | cut -d: -f1`
    PACKAGE=`echo $SEARCH | cut -d/ -f2`
    if [ "$PACKAGE" = "$ARG" ]; then echo '---> The package was found'; else echo '---> The package not found' && exit 1; fi
}

get_pkg(){
    echo "---> Get Slackbuild Package"
    echo "### Get Slackbuild Package ###" >> $LOGDIR$LOGFILE$TIME.log
    cd $PKG
    wget https://slackbuilds.org/slackbuilds/$SLACKWARE_VERSION/$SEARCH.tar.gz -a $LOGDIR$LOGFILE$TIME.log
    PACKAGE=`echo $SEARCH | cut -d/ -f2`

    echo "---> Unziping Package"
    echo "### Unziping Package ###" >> $LOGDIR$LOGFILE$TIME.log
    tar xzvf $PACKAGE.tar.gz >> /dev/null 
    cd $PACKAGE
}

build(){
    echo "---> Get Source to Build"
    echo "### Get Source to Build ###" >> $LOGDIR$LOGFILE$TIME.log
    if [ "$ARCH" = "x86_64" ]; then DOWNLOAD="DOWNLOAD_x86_64"; else DOWNLOAD="DOWNLOAD"; fi
    SRC=`cat $PACKAGE.info | grep $DOWNLOAD | head -1 | cut -d= -f2 | cut -d\" -f2`
    if [ "$SRC" = "" ]; then DOWNLOAD="DOWNLOAD"; fi
    SRC=`cat $PACKAGE.info | grep $DOWNLOAD | head -1 | cut -d= -f2 | cut -d\" -f2`
    wget $SRC -a $LOGDIR$LOGFILE$TIME.log
#    cat $LOGDIR$LOGFILE$TIME.log

    echo "---> Building Package"
    echo "### Building Package ###" >> $LOGDIR$LOGFILE$TIME.log
    ./$PACKAGE.SlackBuild >> $LOGDIR$LOGFILE$TIME.log 
    [ $? -eq 0 ] && CHECK="OK" || CHECK="NOK" 
 #   CHECK=`tac $LOGDIR$LOGFILE$TIME.log | head -2 | cut -d" " -f4`
    #if [ "$CHECK" = "created." ]; then echo '---> The package was build with success'; else printf "${RED}---> The package not build with sucess. To more information see the file ${NC}$LOGDIR$LOGFILE$TIME.log" && exit 1; fi
    if [ "$CHECK" = "OK" ]; then echo '---> The package was build with success'; else printf "${RED}---> The package not build with sucess. To more information see the file ${NC}$LOGDIR$LOGFILE$TIME.log" && exit 1; fi
}


clean(){
    rm -rf $TEMP/*
    exit 0
}


install(){
    echo "---> Installing Package"
    echo "### Installing Package ###" >> $LOGDIR$LOGFILE$TIME.log

    INSTALL=`tac $LOGDIR$LOGFILE$TIME.log | head -2 | cut -d" " -f3`
    installpgk $INSTALL > $LOGDIR$LOGFILE$TIME.log 2>1
}



if [ "$ARG" = "clean" ]; then clean; fi


init
search
get_pkg
build
install
