#!/bin/bash

#clean directory from previous compilation
#and data files
make cleanall
rm *.dat

#compile the test case for the interface
make test_bf_interface_dcr_update_prog2

#run the test case
./test_bf_interface_dcr_update_prog2

#run the visualization using python
folder_path=$(pwd)
pushd $augeanstables/scripts_py/scripts_erymanthianboar
python plot_test_bf_interface_dcr_update2.py -f $folder_path

#clean original directory
pushd
echo ''
echo 'Cleaning directory...'
make cleanall 1>/dev/null 2>&1
rm *.dat