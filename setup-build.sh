#!/bin/bash

if [ ! -d ./build ]; then
	git clone git@github.com:zeam-vm/zeam-vm.github.io.git build
elif [ -d ./build/.git ]; then
	cd build
	git pull
	cd ..
else
	rm -rf ./build
	git clone git@github.com:zeam-vm/zeam-vm.github.io.git build
fi

