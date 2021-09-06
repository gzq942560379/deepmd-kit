#!/bin/bash -e


if [ -z $deepmd_root ]
then
    echo "not found envoriment variable : deepmd_root"
fi

export tensorflow_root=$HOME/software/tensorflow-gpu-2.4
export lammps_root=$deepmd_root/lammps-patch_30Jul2021

spack load cmake
spack load openblas

# deeppmd path
export LD_LIBRARY_PATH=$deepmd_root/dp/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$deepmd_root/dp/lib64:$LD_LIBRARY_PATH
export CPATH=$deepmd_root/dp/include:$CPATH
export PATH=$deepmd_root/dp/bin:$PATH

# lammps path
# export PATH=$lammps_root/src:$PATH

# tensorflow path
source $tensorflow_root/env.sh

INSTALL_PREFIX=$deepmd_root/dp
DEEPMD_BUILD_DIR=$deepmd_root/source/build

export DP_VARIANT=cuda

export CUDA_VISIBLE_DEVICES=1

# export LD_PRELOAD=/data/home/guozhuoqiang/software/spack-0.16.2/opt/spack/linux-centos7-haswell/gcc-4.8.5/gcc-7.5.0-apfqefcs5zty75lid2nxwyh5f4uagvtp/lib64/libgomp.so.1
# # gcc
export CC="gcc -Ofast -fopenmp -lopenblas"
export CXX="g++ -Ofast -fopenmp -lopenblas"

