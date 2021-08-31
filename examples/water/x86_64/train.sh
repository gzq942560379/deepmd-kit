#!/bin/bash

set -ex

source $deepmd_root/script/x86_64/env.sh
bash $deepmd_root/script/x86_64/build_deepmd.sh

mkdir -p ../model/double

dp train ../se_e2_a/input_double_100000.json
dp freeze -o ../model/double/graph.pb
dp test -m ../model/double/graph.pb -s ../data/data_3 -n 1
