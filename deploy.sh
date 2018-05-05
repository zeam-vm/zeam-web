#!/bin/bash

cd build
git add -A
git commit -m "deploy `date "+%Y%m%d-%H%M%S"`"
git push
cd ..

