#!/bin/bash

set -ex

export deepmd_root=$HOME/deepmd-kit
source $deepmd_root/script/x86_64/env.sh

export CUDA_VISIBLE_DEVICES=3

model_path=$deepmd_root/model/water

dp test -m $deepmd_root/model/water/graph-compress.pb -s ../data/data_3 -n 1

# python $deepmd_root/_skbuild/linux-x86_64-3.7/cmake-install/deepmd/tools/profiler_visualization_topk.py profiler 