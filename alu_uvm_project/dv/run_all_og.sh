#!/bin/bash

# Create the 'output' directory if it does not exist
if [ ! -d "output" ]; then
  mkdir output
  echo "Directory 'output' created."
else
  echo "Directory 'output' already exists."
fi

if [ ! -d "coverage_closure" ]; then
  mkdir coverage_closure
  echo "Directory 'coverage_closure' created."
else
  echo "Directory 'coverage_closure' already exists."
fi

# Run the make clean command
make -f alu_make.make clean #cleans the entire vdb, daidir, coverage_closure directories

make -f alu_make.make TEST_NAME=RANDOM_TEST full-sim
make -f alu_make.make TEST_NAME=RANDOM_ERROR_INJECTION_TEST full-sim
make -f alu_make.make TEST_NAME=RANDOM_RESET_THRICE_TEST full-sim

make -f alu_make.make TEST_NAME1=RANDOM_TEST TEST_NAME2=RANDOM_RESET_THRICE_TEST TEST_NAME3=RANDOM_ERROR_INJECTION_TEST generate-reports

