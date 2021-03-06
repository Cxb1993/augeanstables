#!/usr/bin/python

'''
@description
script used to create the error graphs of the
study of the impact of the DIM open b.c in 2D

the results are obtained by comparing simulations
on small domains with an equivalent simulation on
a large domain where the perturbations do not have
time to reach the edges and to come back

1) temperature study
\f$ T \in [0.95,0.99,0.995,0.999]\f$ at \f$v=0.1\f$

2) flow mean velocity study
\f$ v \in [0.05, 0.1, 0.25, 0.5]\f$ at \f$T=0.99\f$

3) threshold study
threshold \in [0.0001, 0.001, 0.01, 0.1, 0.2, 0.3]
for \f$ T \in [0.95,0.99,0.995,0.999] \f$
and \f$ v \in [0.05, 0.1, 0.25, 0.5]  \f$

'''

import os

from library_sm_lg_results import\
    get_simulation_dir

from library_sm_lg_graph import\
    extract_max_error_in_time,\
    create_error_graph,\
    create_error_graph_with_location,\
    create_error_graph_perturbation,\
    grayscale_to_RGB


def create_err_paths(mainDir,temperature_dict,flow_velocity_dict):
    '''
    @description
    generate the paths to the folders containing the
    maximum of the error in time
    '''

    main_err_dirs = os.path.join(mainDir)
    err_dirs = []

    for temperature in [0.95,0.99,0.995,0.999]:

        # add a new array to store the flow velocity entries
        # at this temperature
        err_dirs.append([])
        T_i = temperature_dict[str(temperature)]

        for flow_velocity in [0.05,0.1,0.25,0.5]:

            # add a new array to store the md_threshold entries
            # at this flow velocity
            err_dirs[T_i].append([])

            v_i = flow_velocity_dict[str(flow_velocity)]

            for md_threshold in [0,0.05,0.1,0.2,0.3]:

                dir_name = get_simulation_dir(temperature,flow_velocity,md_threshold=md_threshold)
                err_dir  = os.path.join(main_err_dirs,dir_name,'error','error_max.nc')

                err_dirs[T_i][v_i].append(err_dir)

    return err_dirs


def generate_error_graph(
    err_dirs,
    temperature_array,
    velocity_array,
    md_threshold_array,
    temperature_dict,
    flow_velocity_dict,
    md_threshold_dict,
    legendPosition='best',
    legendParam='None',
    graphPties='None',
    width=3,
    figPath='None',
    show=True,
    logScale=True,
    plot_ylim='None'):
    '''
    @description
    generate the graph showing the maximum of the error
    as a function of time
    '''


    # extract the error data
    data = []        

    for md_threshold in md_threshold_array:
        for flow_velocity in flow_velocity_array:
            for temperature in temperature_array:

                # get the path to the error data
                T_i  = temperature_dict[str(temperature)]
                v_i  = flow_velocity_dict[str(flow_velocity)]
                md_i = md_threshold_dict[str(md_threshold)]

                errorPath = err_dirs[T_i][v_i][md_i]

                # extract the error data
                [time_rescaled,error] = extract_max_error_in_time(errorPath)
        
                # stored the error data for the graph
                data.append([time_rescaled,error])

    # create the graph
    create_error_graph(
        data,
        legendPosition=legendPosition,
        legendParam=legendParam,
        graphPties=graphPties,
        width=width,
        figPath=figPath,
        show=show,
        logScale=logScale,
        plot_ylim=plot_ylim)


def generate_error_position_graph(
    temperature,
    flow_velocity,
    md_threshold=0,
    width=3,
    figPath='None',
    show=True,
    logScale=False,
    plot_ylim='None'):
    '''
    @description
    generate the figure showing the maximum of the mass error
    and the y-position as functions of time
    '''

    
    T_i  = temperature_dict[str(temperature)]
    v_i  = flow_velocity_dict[str(flow_velocity)]
    md_i = md_threshold_dict[str(0)]
    
    errorPath = err_dirs[T_i][v_i][md_i]
    
    data = extract_max_error_in_time(
        errorPath,
        var_names=['time','max_error_mass','y_max_error_mass'])
    
    dataError    = [data[0],data[1]]
    dataPosition = [data[0],data[2]]
    
    create_error_graph_with_location(
        dataError,
        dataPosition,
        legendParam='None',
        graphPties=[['black','-'],[grayscale_to_RGB(0.50),'-']],
        width=width,
        figPath=figPath_error,
        show=show,
        logScale=logScale,
        plot_ylim=plot_ylim)


if __name__=="__main__":


    # main directory where the simulations are saved
    #------------------------------------------------------------
    mainDir = os.path.join(os.getenv('HOME'),
                           'projects',
                           '20150509_dim2d_bb_trans_cv_r3.5_lin')


    # dictionnaries to associate a temperature parameter with
    # an index
    #------------------------------------------------------------
    temperature_dict   = {'0.95':0,'0.99':1,'0.995':2,'0.999':3}
    flow_velocity_dict = {'0.05':0, '0.1':1, '0.25':2,  '0.5':3}
    md_threshold_dict  = {   '0':0,'0.05':1,  '0.1':2,  '0.2':3, '0.3':4}
    dctDistance_dict   = {   '2':0,   '4':1,    '8':2,   '12':3,  '16':4}
    li_dict            = {'-0.5':0,'-0.4':1, '-0.3':2,  '0.0':3}


    # options for the creation of the error graphs
    #------------------------------------------------------------
    # - temperatureStudy          : create error graph for the
    #                               temperature study
    # - velocityStudy             : create error graph for the
    #                               velocity study
    # - thresholdTemperatureStudy : create error graph for the
    #                               threshold study on temperature
    # - thresholdVelocityStudy    : create error graph for the
    #                               threshold study on velocity
    #------------------------------------------------------------
    temperatureStudy          = False
    velocityStudy             = False
    thresholdTemperatureStudy = False
    thresholdVelocityStudy    = False

    errorPosition          = False

    errorDctDistance       = False
    errorIcPerturbation    = False
    errorLiPerturbation    = False
    errorBcPerturbationT0  = False
    errorBcPerturbationvx0 = False
    errorBcPerturbationvy0 = False

    errorLiExplaination    = False
    errorIcExplaination    = False
    errorBcExplainationT0  = False
    errorBcExplainationVy0 = True

    
    # options for the line drawing
    #------------------------------------------------------------
    # - color_temperature   : grayscale colors for the temperture
    # - color_flow_velocity : grayscale colors for the velocity
    # - style_threshold     : line style for the md_threshold study
    # - width               : width of the lines
    # - show                : show the graph before saving it
    # - logScale            : use log scale to display the error
    #------------------------------------------------------------
    color_temperature = [
        grayscale_to_RGB(0.30),
        grayscale_to_RGB(0.50),
        grayscale_to_RGB(0.75),
        grayscale_to_RGB(0.90)]

    color_flow_velocity = [
        grayscale_to_RGB(0.30),
        grayscale_to_RGB(0.50),
        grayscale_to_RGB(0.75),
        grayscale_to_RGB(0.90)]

    style_threshold = ['+','.','--','-','^']
    style_detector  = ['^','-','--','-.',':']

    width = 3

    show = True

    logScale = True

    plot_ylim_T           = [0.00001 , 0.1  ]
    plot_ylim_v           = [0.000001, 0.05]
    plot_ylim_T_threshold = [0.000001, 0.1  ]
    plot_ylim_v_threshold = [0.000001, 0.005]

    fig_T           = 'fig_error_temperature.eps'
    fig_v           = 'fig_error_velocity.eps'
    fig_T_threshold = 'fig_error_temperature_threshold.eps'
    fig_v_threshold = 'fig_error_velocity_threshold.eps'

    fig_pos_T1 = 'fig_error_position_T0.999_0.1.eps'
    fig_pos_T2 = 'fig_error_position_T0.95_0.1.eps'
    fig_pos_T3 = 'fig_error_position_T0.99_0.1.eps'

    # paths for the error files
    err_dirs = create_err_paths(mainDir,
                                temperature_dict,
                                flow_velocity_dict)


    #============================================================
    #1) temperature study
    #============================================================
    if(temperatureStudy):

        temperature_array   = [0.95,0.99,0.995,0.999]
        flow_velocity_array = [0.1]
        md_threshold_array  = [0]
        legendPosition      = 'upper right'

        # output file + graph limits
        figPath   = os.path.join(mainDir,fig_T)
        plot_ylim = plot_ylim_T

        # legend + line properties
        legendParam = []
        graphPties = []
        for temperature in temperature_array:
            T_i  = temperature_dict[str(temperature)]
            legendParam.append(temperature)
            graphPties.append([color_temperature[T_i],'-'])
        
        generate_error_graph(
            err_dirs,
            temperature_array,
            flow_velocity_array,
            md_threshold_array,
            temperature_dict,
            flow_velocity_dict,
            md_threshold_dict,
            legendPosition=legendPosition,
            legendParam=legendParam,
            graphPties=graphPties,
            width=width,
            figPath=figPath,
            show=show,
            logScale=logScale,
            plot_ylim=plot_ylim)


    #============================================================
    #2) velocity study
    #============================================================
    if(velocityStudy):

        temperature_array   = [0.99]
        flow_velocity_array = [0.05,0.1,0.25,0.5]
        md_threshold_array  = [0]
        legendPosition      = 'upper left'

        # output file + graph limits
        figPath   = os.path.join(mainDir,fig_v)
        plot_ylim = plot_ylim_v

        # legend + line properties
        legendParam = []
        graphPties = []
        for flow_velocity in flow_velocity_array:
            v_i  = flow_velocity_dict[str(flow_velocity)]
            legendParam.append(flow_velocity)
            graphPties.append([color_flow_velocity[v_i],'-'])

        generate_error_graph(
            err_dirs,
            temperature_array,
            flow_velocity_array,
            md_threshold_array,
            temperature_dict,
            flow_velocity_dict,
            md_threshold_dict,
            legendPosition=legendPosition,
            legendParam=legendParam,
            graphPties=graphPties,
            width=width,
            figPath=figPath,
            show=show,
            logScale=logScale,
            plot_ylim=plot_ylim)
             

    #============================================================    
    #3) threshold study
    #============================================================
    if(thresholdTemperatureStudy):

        temperature_array   = [0.999] #[0.95,0.99,0.995,0.999]
        flow_velocity_array = [0.1]
        md_threshold_array  = [0.05, 0.1, 0.2, 0.3]
        legendPosition      = 'upper right'

        # output file + graph limits
        figPath   = os.path.join(mainDir,fig_T_threshold)
        plot_ylim = [0.000001,0.001] #plot_ylim_T_threshold

        # legend + line properties
        legendParam = []
        graphPties  = []
        for md_threshold in md_threshold_array:
            md_i = md_threshold_dict[str(md_threshold)]
            for temperature in temperature_array:
                T_i  = temperature_dict[str(temperature)]
                legendParam.append(str(temperature)+'\_'+str(md_threshold))
                graphPties.append([color_temperature[T_i],
                                   style_threshold[md_i]])

        generate_error_graph(
            err_dirs,
            temperature_array,
            flow_velocity_array,
            md_threshold_array,
            temperature_dict,
            flow_velocity_dict,
            md_threshold_dict,
            legendPosition=legendPosition,
            legendParam=legendParam,
            graphPties=graphPties,
            width=width,
            figPath=figPath,
            show=show,
            logScale=logScale,
            plot_ylim=plot_ylim)


    if(thresholdVelocityStudy):

        temperature_array   = [0.99]
        flow_velocity_array = [0.25] #[0.05,0.1,0.25,0.5]
        md_threshold_array  = [0.05, 0.1, 0.2, 0.3]
        legendPosition      = 'upper left' #upper right'

        # output file + graph limits
        figPath   = os.path.join(mainDir,fig_v_threshold)
        plot_ylim = [0.00001,0.002] #plot_ylim_v_threshold

        # legend + line properties
        legendParam = []
        graphPties  = []
        for md_threshold in md_threshold_array:
            md_i = md_threshold_dict[str(md_threshold)]
            for flow_velocity in flow_velocity_array:
                v_i  = flow_velocity_dict[str(flow_velocity)]
                #legendParam.append(str(flow_velocity)+'\_'+str(md_threshold))
                legendParam.append(str(md_threshold))
                graphPties.append([color_flow_velocity[v_i],
                                   style_threshold[md_i]])

        generate_error_graph(
            err_dirs,
            temperature_array,
            flow_velocity_array,
            md_threshold_array,
            temperature_dict,
            flow_velocity_dict,
            md_threshold_dict,
            legendPosition=legendPosition,
            legendParam=legendParam,
            graphPties=graphPties,
            width=width,
            figPath=figPath,
            show=show,
            logScale=logScale,
            plot_ylim=plot_ylim)
    
        
    #============================================================
    #4) error location in time
    #============================================================
    if(errorPosition):

        # T=0.999, v=0.1
        #=================================
        figPath_error = fig_pos_T1
        temperature   = 0.999
        flow_velocity = 0.1
        plot_ylim     = 'None'

        generate_error_position_graph(
                temperature,
                flow_velocity,
                width=width,
                figPath=figPath_error,
                plot_ylim=plot_ylim)


        # T=0.95, v=0.1
        #=================================
        figPath_error = fig_pos_T2
        temperature   = 0.95
        flow_velocity = 0.1
        plot_ylim     = 'None'

        generate_error_position_graph(
                temperature,
                flow_velocity,
                width=width,
                figPath=figPath_error,
                plot_ylim=plot_ylim)


        # T=0.99, v=0.1
        #=================================
        figPath_error = fig_pos_T3
        temperature   = 0.99
        flow_velocity = 0.1
        plot_ylim     = 'None'

        generate_error_position_graph(
                temperature,
                flow_velocity,
                width=width,
                figPath=figPath_error,
                plot_ylim=plot_ylim)


    #============================================================
    #4) error dct_distance
    #============================================================
    if(errorDctDistance):

        temperature_array      = [0.995] #,0.99,0.995,0.999]
        flow_velocity          = 0.1
        dctDistance_array      = [2,4,8,12,16]

        legendPosition = 'best'
        figPath        = 'dct_distance.png'
        plot_ylim      = [0.000001, 0.006] #[0.0000001, 0.001] #[0.00001, 0.01] #[0.0001, 0.5]

        data        = []
        legendParam = []
        graphPties  = []

        for temperature in temperature_array:

            data_error = []
            data_error.append([])
            data_error.append([])

            for dct_distance in dctDistance_array:

                # get the path for the error file
                dir_name = get_simulation_dir(temperature,
                                              flow_velocity,
                                              dct_distance=dct_distance)

                errorPath = os.path.join(mainDir,dir_name,'error','error_max.nc')

                if(os.path.isfile(errorPath)):

                    # extract the error data
                    [time_rescaled,error] = extract_max_error_in_time(errorPath)
        
                    # stored the error data for the graph
                    data.append([time_rescaled,error])

                    #set the legend properties            
                    legendParam.append(dct_distance)

                    # set the graph properties
                    T_i   = temperature_dict[str(temperature)]
                    dct_i = dctDistance_dict[str(dct_distance)]
                    graphPties.append([color_temperature[T_i],style_detector[dct_i]])

                else:
                    print errorPath+' does not exist'

        # create the graph
        create_error_graph(
            data,
            legendPosition=legendPosition,
            legendParam=legendParam,
            graphPties=graphPties,
            width=width,
            figPath=figPath,
            show=show,
            logScale=logScale,
            plot_ylim=plot_ylim)


    #============================================================
    # 5) error ic_perturbations
    #============================================================
    if(errorIcPerturbation):

        temperature_array      = [0.95,0.99,0.995,0.999]
        flow_velocity          = 0.1
        md_threshold           = 0
        ic_perturbations_array = [0.00001,0.00005,0.0001,0.0005,0.001,0.005,0.01,0.05,0.1,0.5]

        legendPosition      = 'best'
        fig_ic_perturbation = 'ic_perturbation.png'
        plot_ylim           = 'None'
        xlabel              = 'Maximum initial perturbation'

        data        = []
        legendParam = []
        graphPties  = []

        for temperature in temperature_array:

            data_error = []
            data_error.append([])
            data_error.append([])

            for ic_perturbation in ic_perturbations_array:

                # get the path for the error file
                dir_name = get_simulation_dir(temperature,
                                              flow_velocity,
                                              md_threshold=md_threshold,
                                              ic_perturbation_amp=ic_perturbation)

                errorPath = os.path.join(mainDir,dir_name,'error','error_max.nc')

                # extract the maximum of the error for this perturbation
                max_error = extract_max_error_in_time(errorPath, var_names=['max_error_in_time_mass'])

                # put the values in the database
                data_error[0].append(ic_perturbation)
                data_error[1].append(max_error[0])

            # save the data [data_error[0],data_error[1]] in the database
            data.append(data_error)

            #set the legend properties            
            legendParam.append(temperature)

            # set the graph properties
            T_i  = temperature_dict[str(temperature)]
            graphPties.append([color_temperature[T_i],'-o'])


        create_error_graph_perturbation(
            data,
            legendPosition=legendPosition,
            legendParam=legendParam,
            graphPties=graphPties,
            figPath=fig_ic_perturbation,
            plot_ylim=plot_ylim,
            xlabel=xlabel)

    if(errorLiPerturbation):

        temperature_array      = [0.95,0.99,0.995,0.999]
        flow_velocity          = 0.1
        md_threshold           = 0
        li_perturbations_array = [-0.5,-0.45,-0.4,-0.35,-0.3]

        legendPosition      = 'best'
        fig_li_perturbation = 'li_perturbation.png'
        plot_ylim           = 'None'
        xlabel              = 'Interface length perturbation'

        data        = []
        legendParam = []
        graphPties  = []

        for temperature in temperature_array:

            data_error = []
            data_error.append([])
            data_error.append([])

            for li_perturbation in li_perturbations_array:

                # get the path for the error file
                dir_name = get_simulation_dir(temperature,
                                              flow_velocity,
                                              md_threshold=md_threshold,
                                              li_perturbation_amp=li_perturbation)

                errorPath = os.path.join(mainDir,dir_name,'error','error_max.nc')

                # extract the maximum of the error for this perturbation
                max_error = extract_max_error_in_time(errorPath, var_names=['max_error_in_time_mass'])

                # put the values in the database
                data_error[0].append(li_perturbation)
                data_error[1].append(max_error[0])

            # save the data [data_error[0],data_error[1]] in the database
            data.append(data_error)

            #set the legend properties            
            legendParam.append(temperature)

            # set the graph properties
            T_i  = temperature_dict[str(temperature)]
            graphPties.append([color_temperature[T_i],'-o'])


        create_error_graph_perturbation(
            data,
            legendPosition=legendPosition,
            legendParam=legendParam,
            graphPties=graphPties,
            figPath=fig_li_perturbation,
            plot_ylim=plot_ylim,
            xlabel=xlabel,
            logScale=False)

    
    if(errorLiExplaination):

        temperature_array     = [0.99] #[0.95,0.99,0.995,0.999]
        flow_velocity         = 0.1
        li_perturbation_array = [-0.5,-0.4,-0.30,0.0]
        md_threshold          = 0
        legendPosition        = 'upper right' #upper right'

        style_perturbation = ['+','-.','--','-']

        # output file + graph limits
        figPath   = 'fig_li_explaination.png'
        plot_ylim = [0.000001,0.01] #plot_ylim_v_threshold

        # legend + line properties
        data = []
        legendParam = []
        graphPties  = []

        for temperature in temperature_array:
            for li_perturbation in li_perturbation_array:
                    
                # get the path to the error data
                T_i  = temperature_dict[str(temperature)]
                v_i  = flow_velocity_dict[str(flow_velocity)]
                Li_i = li_dict[str(li_perturbation)]

                # get the path for the error file
                dir_name = get_simulation_dir(temperature,
                                              flow_velocity,
                                              md_threshold=md_threshold,
                                              li_perturbation_amp=li_perturbation)

                errorPath = os.path.join(mainDir,dir_name,'error','error_max.nc')

                if(os.path.isfile(errorPath)):

                    # extract the error data
                    [time_rescaled,error] = extract_max_error_in_time(errorPath)
        
                    # stored the error data for the graph
                    data.append([time_rescaled,error])

                    #set the legend properties            
                    legendParam.append(li_perturbation)

                    # set the graph properties
                    T_i  = temperature_dict[str(temperature)]
                    graphPties.append([color_temperature[T_i],style_perturbation[Li_i]])


        # create the graph
        create_error_graph(
            data,
            legendPosition=legendPosition,
            legendParam=legendParam,
            graphPties=graphPties,
            width=width,
            figPath=figPath,
            show=show,
            logScale=logScale,
            plot_ylim=plot_ylim)


    if(errorBcPerturbationT0):

        temperature_array      = [0.95,0.99,0.995,0.999]
        flow_velocity          = 0.1
        md_threshold           = 0
        bc_perturbations_array = [0.000005,0.00001,0.00005,0.0001,0.0005,0.001,0.005,0.01]

        legendPosition      = 'lower right'
        fig_ic_perturbation = 'bc_perturbation_T0.png'
        plot_ylim           = [0.0001,1] #'None'
        xlabel              = 'Temperature perturbation'

        data        = []
        legendParam = []
        graphPties  = []

        for temperature in temperature_array:

            data_error = []
            data_error.append([])
            data_error.append([])

            for bc_perturbation in bc_perturbations_array:

                # get the path for the error file
                dir_name = get_simulation_dir(temperature,
                                              flow_velocity,
                                              md_threshold=md_threshold,
                                              bc_perturbation_T0_amp=temperature*bc_perturbation)

                errorPath = os.path.join(mainDir,dir_name,'error','error_max.nc')

                # extract the maximum of the error for this perturbation
                max_error = extract_max_error_in_time(errorPath, var_names=['max_error_in_time_mass'])

                # put the values in the database
                data_error[0].append(bc_perturbation)
                data_error[1].append(max_error[0])

            # save the data [data_error[0],data_error[1]] in the database
            data.append(data_error)

            #set the legend properties            
            legendParam.append(temperature)

            # set the graph properties
            T_i  = temperature_dict[str(temperature)]
            graphPties.append([color_temperature[T_i],'-o'])


        create_error_graph_perturbation(
            data,
            legendPosition=legendPosition,
            legendParam=legendParam,
            graphPties=graphPties,
            figPath=fig_ic_perturbation,
            plot_ylim=plot_ylim,
            xlabel=xlabel)


    if(errorBcPerturbationvx0):

        temperature_array      = [0.95,0.99,0.995,0.999]
        flow_velocity          = 0.1
        md_threshold           = 0
        bc_perturbations_array = [0.000005,0.00001,0.00005,0.0001,0.0005,0.001]

        legendPosition      = 'lower right'
        fig_ic_perturbation = 'bc_perturbation_vx0.png'
        plot_ylim           = [0.0001,1] #'None'
        xlabel              = '$x$-Velocity perturbation'

        data        = []
        legendParam = []
        graphPties  = []

        for temperature in temperature_array:

            data_error = []
            data_error.append([])
            data_error.append([])

            for bc_perturbation in bc_perturbations_array:

                # get the path for the error file
                dir_name = get_simulation_dir(temperature,
                                              flow_velocity,
                                              md_threshold=md_threshold,
                                              bc_perturbation_vx0_amp=bc_perturbation)

                errorPath = os.path.join(mainDir,dir_name,'error','error_max.nc')

                # extract the maximum of the error for this perturbation
                max_error = extract_max_error_in_time(errorPath, var_names=['max_error_in_time_mass'])

                # put the values in the database
                data_error[0].append(bc_perturbation)
                data_error[1].append(max_error[0])

            # save the data [data_error[0],data_error[1]] in the database
            data.append(data_error)

            #set the legend properties            
            legendParam.append(temperature)

            # set the graph properties
            T_i  = temperature_dict[str(temperature)]
            graphPties.append([color_temperature[T_i],'-o'])


        create_error_graph_perturbation(
            data,
            legendPosition=legendPosition,
            legendParam=legendParam,
            graphPties=graphPties,
            figPath=fig_ic_perturbation,
            plot_ylim=plot_ylim,
            xlabel=xlabel)


    if(errorBcPerturbationvy0):

        temperature_array      = [0.95,0.99,0.995,0.999]
        flow_velocity          = 0.1
        md_threshold           = 0
        bc_perturbations_array = [0.000005,0.00001,
                                  0.00005,0.0001,
                                  0.0005,0.001,
                                  0.005,0.01,
                                  0.05]

        legendPosition      = 'lower right'
        fig_ic_perturbation = 'bc_perturbation_vy0.png'
        plot_ylim           = [0.0001,0.5] #'None'
        xlabel              = 'Velocity perturbation'

        data        = []
        legendParam = []
        graphPties  = []

        for temperature in temperature_array:

            data_error = []
            data_error.append([])
            data_error.append([])

            for bc_perturbation in bc_perturbations_array:

                # get the path for the error file
                dir_name = get_simulation_dir(temperature,
                                              flow_velocity,
                                              md_threshold=md_threshold,
                                              bc_perturbation_vy0_amp=flow_velocity*bc_perturbation)

                errorPath = os.path.join(mainDir,dir_name,'error','error_max.nc')

                if(os.path.isfile(errorPath)):

                    # extract the maximum of the error for this perturbation
                    max_error = extract_max_error_in_time(errorPath, var_names=['max_error_in_time_mass'])

                    # put the values in the database
                    data_error[0].append(bc_perturbation)
                    data_error[1].append(max_error[0])

            # save the data [data_error[0],data_error[1]] in the database
            data.append(data_error)

            #set the legend properties            
            legendParam.append(temperature)

            # set the graph properties
            T_i  = temperature_dict[str(temperature)]
            graphPties.append([color_temperature[T_i],'-o'])


        create_error_graph_perturbation(
            data,
            legendPosition=legendPosition,
            legendParam=legendParam,
            graphPties=graphPties,
            figPath=fig_ic_perturbation,
            plot_ylim=plot_ylim,
            xlabel=xlabel)


    # explainations of the error
    if(errorIcExplaination):

        temperature_array     = [0.995]
        flow_velocity         = 0.1
        bc_perturbation_array = [0.0001,0.001,0.01]
        md_threshold          = 0
        legendPosition        = 'best' #upper left' #upper right'

        # output file + graph limits
        figPath   = 'ic_explainations.png'
        plot_ylim = [0.00001,0.01]
        marker_array = ['-.','--','-']

        data = [] 
        legendParam = []
        graphPties = []

        for temperature in temperature_array:
            for (bc_perturbation,marker) in zip(bc_perturbation_array,marker_array):
                    
                # get the path to the error data
                T_i  = temperature_dict[str(temperature)]
                v_i  = flow_velocity_dict[str(flow_velocity)]

                # get the path for the error file
                dir_name = get_simulation_dir(temperature,
                                              flow_velocity,
                                              md_threshold=md_threshold,
                                              ic_perturbation_amp=bc_perturbation)

                errorPath = os.path.join(mainDir,dir_name,'error','error_max.nc')

                
                # extract the error data
                [time_rescaled,error] = extract_max_error_in_time(errorPath)
        
                # stored the error data for the graph
                data.append([time_rescaled,error])

                #set the legend properties            
                legendParam.append(bc_perturbation)

                # set the graph properties
                T_i  = temperature_dict[str(temperature)]
                graphPties.append([color_temperature[T_i],marker])


        # create the graph
        create_error_graph(
            data,
            legendPosition=legendPosition,
            legendParam=legendParam,
            graphPties=graphPties,
            width=width,
            figPath=figPath,
            show=show,
            logScale=logScale,
            plot_ylim=plot_ylim)


    if(errorBcExplainationT0):

        temperature_array     = [0.995]
        flow_velocity         = 0.1
        bc_perturbation_array = [0.000005,0.00005,0.0005]
        md_threshold          = 0
        legendPosition        = 'upper left' #upper right'

        # output file + graph limits
        figPath   = 'bc_explainations_T0.png'
        plot_ylim = [0.000001,0.02]
        marker_array = ['-.','--','-']

        data = [] 
        legendParam = []
        graphPties = []

        for temperature in temperature_array:
            for (bc_perturbation,marker) in zip(bc_perturbation_array,marker_array):
                    
                # get the path to the error data
                T_i  = temperature_dict[str(temperature)]
                v_i  = flow_velocity_dict[str(flow_velocity)]

                # get the path for the error file
                dir_name = get_simulation_dir(temperature,
                                              flow_velocity,
                                              md_threshold=md_threshold,
                                              bc_perturbation_T0_amp=temperature*bc_perturbation)

                errorPath = os.path.join(mainDir,dir_name,'error','error_max.nc')

                
                # extract the error data
                [time_rescaled,error] = extract_max_error_in_time(errorPath)
        
                # stored the error data for the graph
                data.append([time_rescaled,error])

                #set the legend properties            
                legendParam.append(bc_perturbation)

                # set the graph properties
                T_i  = temperature_dict[str(temperature)]
                graphPties.append([color_temperature[T_i],marker])


        # create the graph
        create_error_graph(
            data,
            legendPosition=legendPosition,
            legendParam=legendParam,
            graphPties=graphPties,
            width=width,
            figPath=figPath,
            show=show,
            logScale=logScale,
            plot_ylim=plot_ylim)


    if(errorBcExplainationVy0):

        temperature_array     = [0.995]
        flow_velocity         = 0.1
        bc_perturbation_array = [0.001,0.005,0.01]
        md_threshold          = 0
        legendPosition        = 'upper left' #upper right'

        # output file + graph limits
        figPath   = 'bc_explainations_vy0.png'
        plot_ylim = [0.000001,0.02]
        marker_array = ['-.','--','-']

        data = [] 
        legendParam = []
        graphPties = []

        for temperature in temperature_array:
            for (bc_perturbation,marker) in zip(bc_perturbation_array,marker_array):
                    
                # get the path to the error data
                T_i  = temperature_dict[str(temperature)]
                v_i  = flow_velocity_dict[str(flow_velocity)]

                # get the path for the error file
                dir_name = get_simulation_dir(temperature,
                                              flow_velocity,
                                              md_threshold=md_threshold,
                                              bc_perturbation_vy0_amp=flow_velocity*bc_perturbation)

                errorPath = os.path.join(mainDir,dir_name,'error','error_max.nc')

                if(os.path.isfile(errorPath)):

                    # extract the error data
                    [time_rescaled,error] = extract_max_error_in_time(errorPath)
        
                    # stored the error data for the graph
                    data.append([time_rescaled,error])

                    #set the legend properties            
                    legendParam.append(bc_perturbation)

                    # set the graph properties
                    T_i  = temperature_dict[str(temperature)]
                    graphPties.append([color_temperature[T_i],marker])


        # create the graph
        create_error_graph(
            data,
            legendPosition=legendPosition,
            legendParam=legendParam,
            graphPties=graphPties,
            width=width,
            figPath=figPath,
            show=show,
            logScale=logScale,
            plot_ylim=plot_ylim)
