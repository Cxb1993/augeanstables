#-----------------------------------------------------------------------
#makefile commands
#-----------------------------------------------------------------------
include $(AUGEANSTABLES_CONFIG)/makefile_header.mk


test_bf_compute_prog.o:	$(bf_layer_dir)/parameters_bf_layer.o\
			$(cbf_layer_dir)/bf_compute_class.o\
			$(param_dir)/parameters_constant.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o

test_bf_compute_prog:	$(param_dep)\
			$(cg_dep)\
			$(simpletest_dep)\
			$(periodic_dep)\
			$(fv_dep)\
			interface_integration_step.o\
			bf_compute_class.o


test_bf_layer_prog.o:	$(bf_layer_dir)/parameters_bf_layer.o\
			$(bf_layer_dir)/bf_layer_class.o\
			$(param_dir)/parameters_constant.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o

test_bf_layer_prog:	$(param_dep)\
			$(cg_dep)\
			$(simpletest_dep)\
			$(periodic_dep)\
			$(fv_dep)\
			interface_integration_step.o\
			$(bf_layer_dep)


test_bf_mainlayer_prog.o:$(bf_layer_dir)/bf_mainlayer_class.o\
			$(bf_layer_dir)/bf_sublayer_class.o\
			$(bf_layer_dir)/parameters_bf_layer.o\
			$(param_dir)/parameters_constant.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o

test_bf_mainlayer_prog:	$(param_dep)\
			$(cg_dep)\
			$(simpletest_dep)\
			$(periodic_dep)\
			$(fv_dep)\
			interface_integration_step.o\
			$(bf_layer_dep)\
			bf_sublayer_class.o\
			bf_mainlayer_class.o

test_bf_interface_prog.o:$(bf_layer_dir)/bf_interface_class.o\
			$(bf_layer_dir)/bf_mainlayer_class.o\
			$(bf_layer_dir)/bf_sublayer_class.o\
			$(bf_layer_dir)/parameters_bf_layer.o\
			$(param_dir)/parameters_constant.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o

test_bf_interface_prog:	$(param_dep)\
			$(cg_dep)\
			$(simpletest_dep)\
			$(periodic_dep)\
			$(fv_dep)\
			interface_integration_step.o\
			$(bf_interface_dep)

test_mattsson_operators.o:\
			$(test_dir)/test_lernaeanhydra/check_data_module.o\
			$(sd_dir)/interface_primary.o\
			$(sd_dir)/sd_operators_abstract_class.o\
			$(mt_dir)/sd_operators_class.o\
			$(mt_dir)/sd_operators_x_oneside_L0_class.o\
			$(mt_dir)/sd_operators_x_oneside_L1_class.o\
			$(mt_dir)/sd_operators_x_oneside_R1_class.o\
			$(mt_dir)/sd_operators_x_oneside_R0_class.o\
			$(mt_dir)/sd_operators_y_oneside_L0_class.o\
			$(mt_dir)/sd_operators_y_oneside_L1_class.o\
			$(mt_dir)/sd_operators_y_oneside_R1_class.o\
			$(mt_dir)/sd_operators_y_oneside_R0_class.o\
			$(mt_dir)/sd_operators_fd_module.o\
			$(mt_dir)/sd_operators_fd_ncoords_module.o\
			$(mt_dir)/sd_operators_n_class.o\
			$(mt_dir)/sd_operators_n1_oneside_L0_class.o\
			$(mt_dir)/sd_operators_n1_oneside_L1_class.o\
			$(mt_dir)/sd_operators_n1_oneside_R1_class.o\
			$(mt_dir)/sd_operators_n1_oneside_R0_class.o\
			$(mt_dir)/sd_operators_n2_oneside_L0_class.o\
			$(mt_dir)/sd_operators_n2_oneside_L1_class.o\
			$(mt_dir)/sd_operators_n2_oneside_R1_class.o\
			$(mt_dir)/sd_operators_n2_oneside_R0_class.o\
			$(dim2d_dir)/dim2d_prim_module.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o

test_mattsson_operators:\
			check_data_module.o\
			$(param_dep)\
			$(mt_dep)\
			sd_operators_x_oneside_L0_class.o\
			sd_operators_x_oneside_L1_class.o\
			sd_operators_x_oneside_R1_class.o\
			sd_operators_x_oneside_R0_class.o\
			sd_operators_y_oneside_L0_class.o\
			sd_operators_y_oneside_L1_class.o\
			sd_operators_y_oneside_R1_class.o\
			sd_operators_y_oneside_R0_class.o\
			interface_primary.o\
			sd_operators_fd_module.o\
			sd_operators_fd_ncoords_module.o\
			sd_operators_n_class.o\
			sd_operators_n1_oneside_L0_class.o\
			sd_operators_n1_oneside_L1_class.o\
			sd_operators_n1_oneside_R1_class.o\
			sd_operators_n1_oneside_R0_class.o\
			sd_operators_n2_oneside_L0_class.o\
			sd_operators_n2_oneside_L1_class.o\
			sd_operators_n2_oneside_R1_class.o\
			sd_operators_n2_oneside_R0_class.o\
			dim2d_parameters.o\
			dim2d_prim_module.o

test_cg_operators.o:\
			$(sd_dir)/interface_primary.o\
			$(sd_dir)/sd_operators_abstract_class.o\
			$(cg_dir)/sd_operators_class.o\
			$(cg_dir)/sd_operators_x_oneside_L0_class.o\
			$(cg_dir)/sd_operators_x_oneside_L1_class.o\
			$(cg_dir)/sd_operators_x_oneside_R0_class.o\
			$(cg_dir)/sd_operators_x_oneside_R1_class.o\
			$(cg_dir)/sd_operators_y_oneside_L0_class.o\
			$(cg_dir)/sd_operators_y_oneside_L1_class.o\
			$(cg_dir)/sd_operators_y_oneside_R1_class.o\
			$(cg_dir)/sd_operators_y_oneside_R0_class.o\
			$(cg_dir)/sd_operators_fd_module.o\
			$(dim2d_dir)/dim2d_prim_module.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o

test_cg_operators:\
			$(param_dep)\
			$(cg_dep)\
			sd_operators_x_oneside_L0_class.o\
			sd_operators_x_oneside_L1_class.o\
			sd_operators_x_oneside_R0_class.o\
			sd_operators_x_oneside_R1_class.o\
			sd_operators_y_oneside_L0_class.o\
			sd_operators_y_oneside_L1_class.o\
			sd_operators_y_oneside_R1_class.o\
			sd_operators_y_oneside_R0_class.o\
			interface_primary.o\
			sd_operators_fd_module.o\
			dim2d_parameters.o\
			dim2d_prim_module.o

test_openbc_operators.o:\
			$(obc_dir)/openbc_operators_module.o\
			$(simpletest_dir)/pmodel_eq_class.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o\
			$(mt_dir)/sd_operators_class.o\
			$(mt_dir)/sd_operators_x_oneside_L0_class.o\
			$(mt_dir)/sd_operators_x_oneside_L1_class.o\
			$(mt_dir)/sd_operators_x_oneside_R1_class.o\
			$(mt_dir)/sd_operators_x_oneside_R0_class.o\
			$(mt_dir)/sd_operators_y_oneside_L0_class.o\
			$(mt_dir)/sd_operators_y_oneside_L1_class.o\
			$(mt_dir)/sd_operators_y_oneside_R1_class.o\
			$(mt_dir)/sd_operators_y_oneside_R0_class.o

test_openbc_operators:	$(param_dep)\
			$(mt_dep)\
			$(simpletest_dep)\
			sd_operators_x_oneside_L0_class.o\
			sd_operators_x_oneside_L1_class.o\
			sd_operators_x_oneside_R0_class.o\
			sd_operators_x_oneside_R1_class.o\
			sd_operators_y_oneside_L0_class.o\
			sd_operators_y_oneside_L1_class.o\
			sd_operators_y_oneside_R1_class.o\
			sd_operators_y_oneside_R0_class.o\
			openbc_operators_module.o

test_bc_operators_openbc.o:\
			$(hobc_dir)/bc_operators_class.o\
			$(simpletest_dir)/pmodel_eq_class.o\
			$(param_dir)/parameters_constant.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o\
			$(mt_dir)/sd_operators_class.o\
			$(mt_dir)/sd_operators_x_oneside_L0_class.o\
			$(mt_dir)/sd_operators_x_oneside_L1_class.o\
			$(mt_dir)/sd_operators_x_oneside_R1_class.o\
			$(mt_dir)/sd_operators_x_oneside_R0_class.o\
			$(mt_dir)/sd_operators_y_oneside_L0_class.o\
			$(mt_dir)/sd_operators_y_oneside_L1_class.o\
			$(mt_dir)/sd_operators_y_oneside_R1_class.o\
			$(mt_dir)/sd_operators_y_oneside_R0_class.o

test_bc_operators_openbc:\
			$(param_dep)\
			$(mt_dep)\
			$(simpletest_dep)\
			sd_operators_x_oneside_L0_class.o\
			sd_operators_x_oneside_L1_class.o\
			sd_operators_x_oneside_R0_class.o\
			sd_operators_x_oneside_R1_class.o\
			sd_operators_y_oneside_L0_class.o\
			sd_operators_y_oneside_L1_class.o\
			sd_operators_y_oneside_R1_class.o\
			sd_operators_y_oneside_R0_class.o\
			$(hedstrom_xy_dep)


test_hedstrom_xy.o:	$(hrobc_dir)/bc_operators_class.o\
			$(hobc_dir)/hedstrom_xy_module.o\
			$(obc_dir)/openbc_operators_module.o\
			$(param_dir)/parameters_kind.o\
			$(param_dir)/parameters_input.o\
			$(wave1d_dir)/pmodel_eq_class.o\
			$(mt_dir)/sd_operators_fd_module.o

test_hedstrom_xy:	$(param_dep)\
			$(mt_dep)\
			$(wave1d_dep)\
			$(hedstrom_x_reflection_y_dep)

test_hedstrom_xy_corners.o:\
			$(hcobc_dir)/hedstrom_xy_corners_module.o\
			$(obc_dir)/openbc_operators_module.o\
			$(param_dir)/parameters_constant.o\
			$(param_dir)/parameters_kind.o\
			$(param_dir)/parameters_input.o\
			$(wave2d_dir)/pmodel_eq_class.o\
			$(sd_cdir)/sd_operators_fd_module.o\
			$(wave2d_dir)/wave2d_parameters.o

test_hedstrom_xy_corners:\
			$(param_dep)\
			$(mt_dep)\
			$(wave2d_dep)\
			hedstrom_xy_corners_module.o\
			sd_operators_fd_n_module.o\
			openbc_operators_module.o\
			sd_operators_x_oneside_L0_class.o\
			sd_operators_x_oneside_L1_class.o\
			sd_operators_x_oneside_R0_class.o\
			sd_operators_x_oneside_R1_class.o\
			sd_operators_y_oneside_L0_class.o\
			sd_operators_y_oneside_L1_class.o\
			sd_operators_y_oneside_R1_class.o\
			sd_operators_y_oneside_R0_class.o

test_bc_operators_hedstrom_xy_corners.o:\
			$(hcobc_dir)/bc_operators_class.o\
			$(obc_dir)/openbc_operators_module.o\
			$(param_dir)/parameters_constant.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o\
			$(wave2d_dir)/pmodel_eq_class.o\
			$(mt_dir)/sd_operators_fd_module.o\
			$(wave2d_dir)/wave2d_parameters.o

test_bc_operators_hedstrom_xy_corners:\
			$(hedstrom_xy_corners_dep)\
			$(param_dep)\
			$(wave2d_dep)\
			$(mt_dep)

test_ns2d_eq_program.o:	$(param_dir)/parameters_kind.o\
			$(param_dir)/parameters_input.o\
			$(ns2d_dir)/ns2d_parameters.o\
			$(ns2d_dir)/ns2d_prim_module.o\
			$(ns2d_dir)/ns2d_fluxes_module.o\
			$(mt_dir)/sd_operators_class.o\
			$(ns2d_dir)/pmodel_eq_class.o

test_ns2d_eq_program:	parameters_kind.o\
			interface_primary.o\
			$(mt_dep)\
			$(ns2d_dep)

test_poinsot_ns2d_operators.o:\
			$(pobc_dir)/bc_operators_class.o\
			$(pobc_ns2d_dir)/lodi_ns2d_class.o\
			$(pobc_ns2d_dir)/lodi_inflow_class.o\
			$(pobc_ns2d_dir)/lodi_outflow_class.o\
			$(ns2d_dir)/ns2d_parameters.o\
			$(param_dir)/parameters_constant.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o\
			$(ns2d_dir)/pmodel_eq_class.o\
			$(mt_dir)/sd_operators_fd_module.o

test_poinsot_ns2d_operators:\
			$(param_dep)\
			$(poinsot_ns2d_dep)\
			$(ns2d_dep)\
			$(mt_dep)

test_lodi_transverse.o:	$(ns2d_dir)/ns2d_parameters.o\
			$(ns2d_dir)/ns2d_fluxes_module.o\
			$(param_dir)/parameters_kind.o\
			$(sd_cdir)/sd_operators_class.o\
			$(yobc_dir)/lodi_transverse_module.o

test_lodi_transverse:	parameters_kind.o\
			ns2d_parameters.o\
			interface_primary.o\
			parameters_constant.o\
			parameters_input.o\
			ns2d_prim_module.o\
			sd_operators_fd_module.o\
			sd_operators_abstract_class.o\
			sd_operators_class.o\
			ns2d_fluxes_module.o\
			lodi_transverse_module.o

test_lodi_relaxation_coeff.o:\
			$(yobc_ns2d_dir)/lodi_relaxation_coeff_module.o\
			$(ns2d_dir)/ns2d_parameters.o\
			$(param_dir)/parameters_constant.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o

test_lodi_relaxation_coeff:\
			parameters_kind.o\
			ns2d_parameters.o\
			parameters_constant.o\
			parameters_input.o\
			lodi_relaxation_coeff_module.o

test_yoo_ns2d_edge_module.o:\
			$(param_dir)/parameters_constant.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o\
			$(ns2d_dir)/pmodel_eq_class.o

test_yoo_ns2d_edge_x.o:\
			$(yobc_dir)/lodi_edge_abstract_class.o\
			$(yobc_ns2d_dir)/lodi_edge_inflow_class.o\
			$(yobc_ns2d_dir)/lodi_edge_outflow_class.o\
			$(param_dir)/parameters_constant.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o\
			$(ns2d_dir)/pmodel_eq_class.o\
			$(mt_dir)/sd_operators_fd_module.o\
			test_yoo_ns2d_edge_module.o

test_yoo_ns2d_edge_x:	$(param_dep)\
			$(ns2d_dep)\
			$(mt_dep)\
			lodi_component_module.o\
			lodi_transverse_module.o\
			lodi_relaxation_coeff_module.o\
			lodi_edge_abstract_class.o\
			lodi_edge_ns2d_class.o\
			lodi_edge_inflow_class.o\
			lodi_edge_outflow_class.o\
			test_yoo_ns2d_edge_module.o

test_yoo_ns2d_edge_y.o:\
			$(yobc_dir)/lodi_edge_abstract_class.o\
			$(yobc_ns2d_dir)/lodi_edge_inflow_class.o\
			$(yobc_ns2d_dir)/lodi_edge_outflow_class.o\
			$(param_dir)/parameters_constant.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o\
			$(ns2d_dir)/pmodel_eq_class.o\
			$(mt_dir)/sd_operators_fd_module.o\
			test_yoo_ns2d_edge_module.o

test_yoo_ns2d_edge_y:	$(param_dep)\
			$(ns2d_dep)\
			$(mt_dep)\
			lodi_component_module.o\
			lodi_transverse_module.o\
			lodi_relaxation_coeff_module.o\
			lodi_edge_abstract_class.o\
			lodi_edge_ns2d_class.o\
			lodi_edge_inflow_class.o\
			lodi_edge_outflow_class.o\
			test_yoo_ns2d_edge_module.o

test_yoo_ns2d_corners.o:$(yobc_ns2d_dir)/lodi_corner_inflow_inflow_class.o\
			$(yobc_ns2d_dir)/lodi_corner_inflow_outflow_class.o\
			$(yobc_ns2d_dir)/lodi_corner_outflow_outflow_class.o\
			$(param_dir)/parameters_constant.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o\
			$(ns2d_dir)/pmodel_eq_class.o\
			$(mt_dir)/sd_operators_fd_module.o

test_yoo_ns2d_corners:	$(param_dep)\
			$(ns2d_dep)\
			$(mt_dep)\
			lodi_component_module.o\
			lodi_relaxation_coeff_module.o\
			lodi_corner_abstract_class.o\
			lodi_corner_ns2d_class.o\
			lodi_corner_inflow_inflow_class.o\
			lodi_corner_inflow_outflow_class.o\
			lodi_corner_outflow_outflow_class.o

test_yoo_lodi_timedev_xy.o:\
			$(yobc_ns2d_dir)/lodi_edge_inflow_class.o\
			$(yobc_ns2d_dir)/lodi_edge_outflow_class.o\
			$(yobc_dir)/lodi_timedev_xy_module.o\
			$(ns2d_dir)/ns2d_parameters.o\
			$(param_dir)/parameters_constant.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o\
			$(ns2d_dir)/pmodel_eq_class.o\
			$(mt_dir)/sd_operators_fd_module.o

test_yoo_lodi_timedev_xy:\
			$(param_dep)\
			$(mt_dep)\
			$(ns2d_dep)\
			sd_operators_x_oneside_L0_class.o\
			sd_operators_x_oneside_L1_class.o\
			sd_operators_x_oneside_R1_class.o\
			sd_operators_x_oneside_R0_class.o\
			sd_operators_y_oneside_L0_class.o\
			sd_operators_y_oneside_L1_class.o\
			sd_operators_y_oneside_R1_class.o\
			sd_operators_y_oneside_R0_class.o\
			openbc_operators_module.o\
			lodi_component_module.o\
			lodi_transverse_module.o\
			lodi_relaxation_coeff_module.o\
			lodi_edge_abstract_class.o\
			lodi_edge_ns2d_class.o\
			lodi_edge_inflow_class.o\
			lodi_edge_outflow_class.o\
			lodi_corner_abstract_class.o\
			lodi_corner_ns2d_class.o\
			lodi_corner_inflow_inflow_class.o\
			lodi_corner_inflow_outflow_class.o\
			lodi_corner_outflow_outflow_class.o\
			lodi_timedev_xy_module.o

test_yoo_sym_x.o:	$(yobc_dir)/bc_operators_class.o\
			$(ns2d_dir)/ns2d_parameters.o\
			$(param_dir)/parameters_constant.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o\
			$(ns2d_dir)/pmodel_eq_class.o

test_yoo_sym_x:		$(param_dep)\
			$(mt_dep)\
			$(ns2d_dep)\
			$(yoo_ns2d_dep)

test_yoo_sym_y.o:	$(yobc_dir)/bc_operators_class.o\
			$(ns2d_dir)/ns2d_parameters.o\
			$(param_dir)/parameters_constant.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o\
			$(ns2d_dir)/pmodel_eq_class.o

test_yoo_sym_y:		$(param_dep)\
			$(mt_dep)\
			$(ns2d_dep)\
			$(yoo_ns2d_dep)

test_yoo_ns2d_operators.o:\
			$(yobc_dir)/bc_operators_class.o\
			$(ns2d_dir)/ns2d_parameters.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o\
			$(ns2d_dir)/pmodel_eq_class.o\
			$(sd_cdir)/sd_operators_x_oneside_L0_class.o\
			$(sd_cdir)/sd_operators_x_oneside_L1_class.o\
			$(sd_cdir)/sd_operators_x_oneside_R1_class.o\
			$(sd_cdir)/sd_operators_x_oneside_R0_class.o\
			$(sd_cdir)/sd_operators_y_oneside_L0_class.o\
			$(sd_cdir)/sd_operators_y_oneside_L1_class.o\
			$(sd_cdir)/sd_operators_y_oneside_R1_class.o\
			$(sd_cdir)/sd_operators_y_oneside_R0_class.o

test_yoo_ns2d_operators:\
			$(param_dep)\
			$(mt_dep)\
			$(ns2d_dep)\
			$(yoo_ns2d_dep)

test_yoo_new_operators.o:\
			$(yobc_dir)/bc_operators_class.o\
			$(yobc_ns2d_dir)/bc_operators_ns2d_class.o\
			$(ns2d_dir)/ns2d_parameters.o\
			$(param_dir)/parameters_input.o\
			$(param_dir)/parameters_kind.o\
			$(ns2d_dir)/pmodel_eq_class.o\
			$(sd_cdir)/sd_operators_x_oneside_L0_class.o\
			$(sd_cdir)/sd_operators_x_oneside_L1_class.o\
			$(sd_cdir)/sd_operators_x_oneside_R1_class.o\
			$(sd_cdir)/sd_operators_x_oneside_R0_class.o\
			$(sd_cdir)/sd_operators_y_oneside_L0_class.o\
			$(sd_cdir)/sd_operators_y_oneside_L1_class.o\
			$(sd_cdir)/sd_operators_y_oneside_R1_class.o\
			$(sd_cdir)/sd_operators_y_oneside_R0_class.o

test_yoo_new_operators:	$(param_dep)\
			$(mt_dep)\
			$(ns2d_dep)\
			$(yoo_ns2d_dep)\
			bc_operators_ns2d_class.o
