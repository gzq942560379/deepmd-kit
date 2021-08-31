#!/bin/bash

set -e

export deepmd_root=$HOME/deepmd-kit
source $deepmd_root/script/x86_64/env.sh
# bash $deepmd_root/script/x86_64/build_deepmd.sh


lmp -echo screen -in ../lmp/in.water_1