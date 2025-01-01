#!/bin/bash

# Create the 'output' directory if it does not exist
if [ ! -d "output" ]; then
  mkdir output
  echo "Directory 'output' created."
else
  echo "Directory 'output' already exists."
fi

# Run the make clean command
make -f simpleadder_make.make clean

make -f simpleadder_make.make full-sim
