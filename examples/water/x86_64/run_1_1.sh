#!/bin/bash

set -e

export deepmd_root=$HOME/deepmd-kit
source $deepmd_root/script/x86_64/env.sh


lmp -echo screen -in ../lmp/in.water_1