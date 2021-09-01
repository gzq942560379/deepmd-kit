#!/bin/bash -e

if [ -z $deepmd_root ]
then
    echo "not found envoriment variable : deepmd_root"
fi

source $deepmd_root/script/x86_64/env.sh

if [ "$DP_VARIANT" == "cuda" ]
then
  CUDA_ARGS="-DUSE_CUDA_TOOLKIT=TRUE"
fi
#------------------

mkdir -p ${INSTALL_PREFIX}
echo "Installing DeePMD-kit to ${INSTALL_PREFIX}"
NPROC=$(nproc --all)

#------------------

mkdir -p ${DEEPMD_BUILD_DIR}
cd ${DEEPMD_BUILD_DIR}
# cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -DINSTALL_TENSORFLOW=TRUE ${CUDA_ARGS} -DLAMMPS_VERSION=patch_30Jul2021 -DUSE_TTM=TRUE ..
cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -DINSTALL_TENSORFLOW=FALSE  -DTENSORFLOW_ROOT=$tensorflow_root ${CUDA_ARGS} -DLAMMPS_SOURCE_ROOT=$lammps_root -DUSE_TTM=TRUE ..
make -j${NPROC}
make install

#------------------
echo "Congratulations! DeePMD-kit has been installed at ${INSTALL_PREFIX}"


cd $deepmd_root

python ./setup.py install -j16