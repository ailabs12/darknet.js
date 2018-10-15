#!/usr/bin/env bash
if [ ! -d darknet ]; then
		git clone https://github.com/pjreddie/darknet;

		if [ $? -ne 0 ]; then
				echo "Could not clone darknet repo";
				exit 1;
		fi
fi

# dive in the darknet folder and make
cd darknet

# look for exported variables for GPU and CUDNN
GPU="${DARKNET_BUILD_WITH_GPU:-0}";
CUDNN="${DARKNET_BUILD_WITH_CUDNN:-0}";
OPENCV="${DARKNET_BUILD_WITH_OPENCV:-0}";
OPENMP="${DARKNET_BUILD_WITH_OPENMP:-0}";

case "$GPU" in
		1|0);;
		*) echo "Interpreting DARKNET_BUILD_WITH_GPU=$GPU as 0"; GPU=0;;
esac

case "$CUDNN" in
		1|0);;
		*) echo "Interpreting DARKNET_BUILD_WITH_CUDNN=$CUDNN as 0"; CUDNN=0;;
esac

case "$OPENCV" in
		1|0);;
		*) echo "Interpreting DARKNET_BUILD_WITH_OPENCV=$OPENCV as 0"; OPENCV=0;;
esac

case "$OPENMP" in
		1|0);;
		*) echo "Interpreting DARKNET_BUILD_WITH_OPENMP=$OPENMP as 0"; OPENMP=0;;
esac

sed -i -e "s/GPU=[01]/GPU=${GPU}/g" ./Makefile
sed -i -e "s/CUDNN=[01]/CUDNN=${CUDNN}/g" ./Makefile
sed -i -e "s/OPENCV=[01]/OPENCV=${GPU}/g" ./Makefile
sed -i -e "s/OPENMP=[01]/OPENMP=${GPU}/g" ./Makefile

make

if [ $? -ne 0 ]; then
		echo "Could not compile darknet";
		exit 2;
fi

# copy lib
cp libdarknet* ..

# dive out
cd ..

# if macos make .dylib symlink
if [[ "$OSTYPE" == "darwin"* ]]; then
		ln -s libdarknet.so libdarknet.dylib
fi

cd $(dirname $0)

wget -nc https://pjreddie.com/media/files/yolov3-tiny.weights
wget -nc https://raw.githubusercontent.com/pjreddie/darknet/master/cfg/yolov3-tiny.cfg
wget -nc https://raw.githubusercontent.com/pjreddie/darknet/master/data/coco.names

wget -nc https://github.com/pjreddie/darknet/raw/master/data/dog.jpg
wget -nc https://github.com/pjreddie/darknet/raw/master/data/eagle.jpg
wget -nc https://github.com/pjreddie/darknet/raw/master/data/giraffe.jpg
