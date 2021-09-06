#!/bin/bash

set -ex

export deepmd_root=$HOME/deepmd-kit
source $deepmd_root/script/x86_64/env.sh

model_path=$deepmd_root/model/copper

mkdir -p $deepmd_root/model/copper/double

# dp train ../train/copper.json
dp freeze -o $deepmd_root/model/copper/double/graph.pb
dp test -m $deepmd_root/model/copper/double/graph.pb -s ../../../training-data/copper/init/cu.fcc.02x02x02/02.md/sys-0032/deepmd -n 1


# dp train ../train/input_v2_compat_train_float_2000.json
# dp freeze -o ../model/float/graph.pb
# dp test -m ../model/float/graph.pb -s ../data/init/cu.fcc.02x02x02/02.md/sys-0032/deepmd -n 1

