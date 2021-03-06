#!/usr/bin/python


import commands
import getopt

import os, sys, inspect
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.cm as cm
from pylab import *


cmd_subfolder = os.path.realpath(os.path.abspath(os.path.join(\
    os.path.split(inspect.getfile( inspect.currentframe() ))[0],"fortranfile-0.2.1")))
if cmd_subfolder not in sys.path:
    sys.path.insert(0, cmd_subfolder)

from fortranfile import *
from pylab import *

from library_plot_bf_layer import (manage_options,
                                   make_matrix_for_all_bf_layers_with_maps,
                                   plot_nodes_and_grdptid_with_all_bf_layers_with_maps)

if __name__ == "__main__":
    

    #manage the options
    [folder_path] = manage_options()
    print folder_path


    test_windows_title = ["Allocation test",
                          "Reallocation test",
                          "Merging test: before merging",
                          "Merging test: after merging",
                          "Neighbor copy test: N",
                          "Neighbor copy test: S",
                          "Neighbor copy test: E",
                          "Neighbor copy test: W"]

    nb_sublayers = 6


    #plot the tests
    for i in range(0,8):
        
    	#extract data for the interior points and the buffer layers
    	#-----------------------------------------------------------------
        test_index = str(i+1)

        #if(i==3):
        #    interior_size_filename      = folder_path+'/interior_sizes'+test_index+'.dat'
        #    interior_grdptsid_filename  = folder_path+'/interior_grdpts_id'+test_index+'.dat'
        #    interior_nodes_filename     = folder_path+'/interior_nodes'+test_index+'.dat'
        #else:
        interior_size_filename      = folder_path+'/interior_sizes.dat'
        interior_grdptsid_filename  = folder_path+'/interior_grdpts_id.dat'
        interior_x_map_filename     = folder_path+'/interior_x_map.dat'
        interior_y_map_filename     = folder_path+'/interior_y_map.dat'
        interior_nodes_filename     = folder_path+'/interior_nodes.dat'

    	suffix_size    = '_sizes'+test_index+'.dat'
        suffix_x_map   = '_x_map'+test_index+'.dat'
        suffix_y_map   = '_y_map'+test_index+'.dat'
    	suffix_nodes   = '_nodes'+test_index+'.dat'
    	suffix_grdptid = '_grdpt_id'+test_index+'.dat'
    	
    	[lm_x_map,
         lm_y_map,
         lm_nodes,
         lm_grdptid,
         margin] = make_matrix_for_all_bf_layers_with_maps(
            interior_size_filename,
            interior_grdptsid_filename,
            interior_x_map_filename,
            interior_y_map_filename,
            interior_nodes_filename,
            folder_path,
            nb_sublayers,
            suffix_size,
            suffix_x_map,
            suffix_y_map,
            suffix_nodes,
            suffix_grdptid,
            continuous=False)
         
        #display
        #-----------------------------------------------------------------
        fig, ax = plot_nodes_and_grdptid_with_all_bf_layers_with_maps(
            lm_x_map,
            lm_y_map,
            lm_nodes,
            lm_grdptid)

        fig.canvas.set_window_title(test_windows_title[i])

    
    #show all
    plt.show()
    
