#!/usr/bin/python

'''
@description
script used to generate the main results of the
study of the impact of the DIM open b.c in 2D

the results are obtained by comparing simulations
on small domains with an equivalent simulation on
a large domain where the perturbations do not have
time to reach the edges and to come back

1) temperature study
T \in [0.95,0.99,0.995,0.999] at v=0.1

2) flow mean velocity study
v \in [0.05, 0.1, 0.25, 0.5] at T=0.99

3) threshold study
threshold \in [0.0001, 0.001, 0.01, 0.1, 0.2, 0.3]
for T \in [0.95,0.99,0.995,0.999]
and v \in [0.05, 0.1, 0.25, 0.5]

'''


if __name__="__main__":


    # main directory where the simulations
    # are saved
    mainDir='/home/jdesmarais/projects'


    # input used as template
    model_input=os.path.join(
        os.getenv('augeanstables'),'src','test_files','config','default_inputs','dim2d',
        'dim2d_bubble_transported_hedstrom_xy.txt')


    ##1) temperature study
    #temperature_array = [0.95,0.99,0.995,0.999]
    #flow_velocity     = 0.1
    #md_threshold      = 0
    #large_domain_run  = True
    #
    #
    #for temperature in temperature_array:
    #    
    #    [destDir,
    #     nameRun_sm_domain,
    #     nameRun_lg_domain] =\
    #     \
    #     generate_sm_lg_results(mainDir,
    #                            temperature,
    #                            flow_velocity,
    #                            model_input,
    #                            bf_layer_option=True,
    #                            large_domain_run=large_domain_run)
         

    ##2) flow mean velocity study
    #temperature         = 0.99
    #flow_velocity_array = [0.05,0.1,0.25,0.5]
    #md_threshold        = 0
    #large_domain_run    = True
    #
    #for flow_velocity in flow_velocity_array:
    #    
    #    [destDir,
    #     nameRun_sm_domain,
    #     nameRun_lg_domain] =\
    #     \
    #     generate_sm_lg_results(mainDir,
    #                            temperature,
    #                            flow_velocity,
    #                            model_input,
    #                            bf_layer_option=True,
    #                            large_domain_run=large_domain_run)


    #3) threshold study
    temperature_array = [0.95,0.99,0.995,0.999]

    
        