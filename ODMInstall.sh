#!/bin/bash

CURRENT_DIR=`pwd`;

echo "$CURRENT_DIR"

. $CURRENT_DIR/tools/installODMCluster.properties

#Arguments for ODMInstall.sh
#c - cluster
#a - standalone
#s - sample

#Parameters for installODMCluster.sh
#c - center
#a - all
#s - server
#d - dmgr
#b - events


function usage(){
	echo "Usage: sh ODMInstall.sh -c params / sh ODMInstall.sh -a params / sh ODMInstall.sh -s params"
	echo "-c : Install in cluster mode"
	echo "-a : Install standalone mode ## IN PROGRESS ##"
	echo "-s : Install sample server ## IN PROGRESS ##"
	echo ""
	echo "params :"
	echo "a - all ( Installs all components => DMGR, Decision Center, Decision Server, Decision Events )"
	echo "c - center ( Installs the Decision Center component ONLY)"
	echo "s - server ( Installs the Decision Server component ONLY)"
	echo "b - events ( Installs the Decision Events component ONLY)"
	echo "d - dmgr ( Installs the Deployment Manager component ONLY)"
	
}


#Extracting and unzipping the installation files
#sh $CURRENT_DIR/tools/extractFiles.sh

while getopts ":c::a::s:" opt; do
  case $opt in
    c)
		echo "sh "$CURRENT_DIR"/tools/installODMCluster.sh -"$OPTARG
		sh $CURRENT_DIR/tools/installODMCluster.sh -$OPTARG
		;;
	a)
		#Standalone
		;;
	s)
		sh $CURRENT_DIR/tools/installODMCluster.sh -$OPTARG
		;;
	?)
		echo "Invalid option: -$OPTARG" 
		usage
		exit 1;
		;;
  esac
done

