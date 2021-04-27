#!/bin/bash

set -ex

if [ $deepmd_root == "" ]
then
    echo "not found envoriment variable : deepmd_root"
fi

if [ $lammps_root == "" ]
then
    echo "not found envoriment variable : lammps_root"
fi

source $deepmd_root/script/x86_64/env.sh

bash $deepmd_root/script/x86_64/build_deepmd.sh

export TF_PROFILE=1
export TF_INTRA_OP_PARALLELISM_THREADS=1
export TF_INTER_OP_PARALLELISM_THREADS=1

dp test -m ../model/graph.pb -s ../data -n 1
