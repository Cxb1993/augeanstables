#!/usr/bin/python

'''
@description
useful functions to generate the executables and
the pbs scripts to run the wall steady state simulations
'''


import os
import sys
import inspect
import subprocess
import math
import string
import shutil
import shlex
import time


#add the python files from ../sm_lg_automatization
cmd_subfolder = os.path.realpath(os.path.abspath(os.path.join(\
    os.path.split(
    inspect.getfile( inspect.currentframe() ))[0],
    "../sm_lg_domain_automatization")))
if cmd_subfolder not in sys.path:
    sys.path.insert(0, cmd_subfolder)

from automatization_csts import bc_size

from automatization_wall_st_csts import total_nb_files_default

from create_sm_lg_inputs import (get_parameter,
                                 create_sm_lg_inputs)

from library_sm_lg_results import (generate_exe,
                                   estimate_simulation_duration,
                                   estimate_wall_time,
                                   create_pbs_script,
                                   get_name_run,
                                   run_simulation)

from create_wall_nonst_inputs import create_wall_nonst_inputs

from library_wall_st_results import get_simulation_dir


# create the simulation
def create_simulation(destDir,
                      inputPath,
                      PBSnameRun):
    '''
    @description
    create the executable corresponding to the inputPath, save it
    to the destDir, create the PBS script to run the simulation
    and save it in the destDir
    '''

    #0) check that destDir exists
    if(not os.path.isdir(destDir)):
        print 'library_wall_nonst_results'
        print 'create_simulation'
        sys.exit('***directory '+destDir+' does not exist***')

    
    #1) create the executable corresponding to the inputPath
    exePath = generate_exe(inputPath)


    #2) move the executable to destDir
    if(not os.path.isfile(exePath)):
        print 'library_wall_nonst_results'
        print 'create_simulation'
        sys.exit('***exe file'+exePath+' does not exist***')

    newExePath = destDir
    newExePath+='/'+os.path.basename(exePath)
    shutil.move(exePath,newExePath)


    #3) create the PBS script
    simulation_duration = estimate_simulation_duration(inputPath)
    walltime = estimate_wall_time(simulation_duration,
                                  safety_ratio=2.0)

    pbsScriptPath = destDir+'/run_sim.job'

    create_pbs_script(
        pbsScriptPath,
        newExePath,
        nameRun=PBSnameRun,
        walltime=walltime)

    return [pbsScriptPath,PBSnameRun]


# create and run the simulation for test
def generate_wall_nonst_results(
    mainDir,
    model_input,
    PBSnameRun,
    simulation_duration,
    steady_state_ac                 = 0,
    temperature                     = 0.999,
    micro_contact_angle             = '90.0',
    phase_at_center                 = 'vapor',
    ratio_bubble_interface          = 2.0,
    gravity_ac                      = 0,
    gravity_amp                     = 0,
    wall_heat_source_choice         = 'no_heat_source',
    wall_maximum_heat_flux          = 0.0,
    wall_heat_source_center         = 0.0,
    wall_heat_source_variance       = 1.0 ,
    wall_extra_heat_source_choice   = 'no_heat_source',
    wall_maximum_extra_heat_flux    = 0.0,
    wall_extra_heat_source_center   = 0.0,
    wall_extra_heat_source_variance = 1.0,
    total_nb_files                  = total_nb_files_default):

    '''
    @description
    create the directory to save the simulation results,
    generate the input file needed to run the simulations
    of non steady drop/bubble at a wall,
    generate the executable,
    create the PBS scripts file, and
    run the simulation
    '''
    
    #1) test whether 'mainDir' can be used as a reference
    #   directory where the directory to save the simulation
    #   is created
    if(not os.path.isdir(mainDir)):
        print 'library_wall_nonst_results'
        print 'generate_wall_nonst_results'
        sys.exit('*** '+mainDir+' is not a directory***')


    #2) create the directory to save the simulation    
    destDir = get_simulation_dir(temperature,
                                 micro_contact_angle,
                                 phase_at_center,
                                 collapse_ratio               = ratio_bubble_interface,
                                 gravity_amp                  = gravity_amp,
                                 wall_maximum_heat_flux       = wall_maximum_heat_flux,
                                 wall_maximum_extra_heat_flux = wall_maximum_extra_heat_flux)
    destDir = os.path.join(mainDir,destDir)

    # if there is already an existing directory, the function
    # throws an error
    if(os.path.isdir(destDir)):
        print 'library_wall_nonst_results'
        print 'generate_wall_nonst_results'
        sys.exit('*** '+destDir+' already exists***')
    os.mkdir(destDir)
    
    
    #3) create the inputs for the simulation
    inputPath = 'inputs_wall.txt'

    # remove old input files
    if(os.path.isfile(inputPath)):
        os.remove(inputPath)

    #create input
    create_wall_nonst_inputs(
        model_input,
        simulation_duration,
        inputs_wall_modified            = inputPath,
        steady_state_ac                 = steady_state_ac,
        temperature                     = temperature,
        micro_contact_angle             = micro_contact_angle,
        phase_at_center                 = phase_at_center,
        gravity_ac                      = gravity_ac,
        gravity_amp                     = gravity_amp,
        ratio_bubble_interface          = ratio_bubble_interface,
        wall_heat_source_choice         = wall_heat_source_choice,
        wall_maximum_heat_flux          = wall_maximum_heat_flux,
        wall_heat_source_center         = wall_heat_source_center,
        wall_heat_source_variance       = wall_heat_source_variance,
        wall_extra_heat_source_choice   = wall_extra_heat_source_choice,
        wall_maximum_extra_heat_flux    = wall_maximum_extra_heat_flux,
        wall_extra_heat_source_center   = wall_extra_heat_source_center,
        wall_extra_heat_source_variance = wall_extra_heat_source_variance,
        total_nb_files                  = total_nb_files)

    #4) create dir, generate executable,
    #   create PBS script file
    [pbsScriptPath,nameRun] = create_simulation(destDir,
                                                inputPath,
                                                PBSnameRun)        

    #5) run the simulation
    run_simulation(pbsScriptPath)

    return [destDir,nameRun]


if __name__ == "__main__":

    print 'no main'