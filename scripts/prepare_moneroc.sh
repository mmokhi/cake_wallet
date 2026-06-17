#!/bin/bash

set -x -e

cd "$(dirname "$0")"

if [[ ! -d "monero_c/.git" ]];
then
    rm -rf monero_c
    # CI-ONLY (nerva-ci): clone the nerva fork so the native build has the nerva
    # target before monero_c#188 merges. The PR branch keeps upstream mrcyjanek.
    git clone https://github.com/mmokhi/monero_c --branch nerva monero_c
    cd monero_c
else
    cd monero_c
fi

# NOTE: Make sure to update monero_c prebuilds link in workflow files
# https://github.com/MrCyjaneK/monero_c/releases/download/v0.18.4.6-RC2/release-bundle.zip
git fetch -a
git checkout a0140d5d56f8fcfe6786c85b5e3073d91abe9df5
git reset --hard
git submodule update --init --force --recursive

for coin in monero wownero zano nerva;
do
    if [[ ! -f "$coin/.patch-applied" ]];
    then
        ./apply_patches.sh $coin
    fi
done
cd ..

echo "monero_c source prepared".
