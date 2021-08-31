set -e


if [ -z $deepmd_root ]
then
    echo "not found envoriment variable : deepmd_root"
fi

source $deepmd_root/script/x86_64/env.sh
bash $deepmd_root/script/x86_64/build_deepmd.sh

mkdir -p ${INSTALL_PREFIX}
echo "Installing LAMMPS to ${INSTALL_PREFIX}"
NPROC=$(nproc --all)

#------------------

cd $lammps_root
mkdir -p $lammps_root/build
cd $lammps_root/build
cmake -C ../cmake/presets/all_off.cmake -D PKG_PLUGIN=ON -D PKG_KSPACE=ON -D BUILD_SHARED_LIBS=yes -D LAMMPS_INSTALL_RPATH=ON -D CMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} ../cmake

make -j${NPROC}
make install

#------------------
echo "Congratulations! LAMMPS has been installed at ${INSTALL_PREFIX}"

