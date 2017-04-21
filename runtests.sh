#!/bin/bash

cd build
ctest -C Release --output-on-failure

$SHELL