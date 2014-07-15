#-----------------------------------------------------------------------
#cluster
#-----------------------------------------------------------------------
cluster = $(AUGEANSTABLES_CLUSTER)


#-----------------------------------------------------------------------
#user main options for profiling, optimizing ...
#-----------------------------------------------------------------------
profile       = $(AUGEANSTABLES_PROFILE)        #ddt/totalview debugging
analyse       = $(AUGEANSTABLES_ANALYSE)        #gprof
trace         = $(AUGEANSTABLES_TRACE)          #vampir tracing
report        = $(AUGEANSTABLES_OPTREPORT)      #optimization report
profileGuided = $(AUGEANSTABLES_PROFILE_GUIDED) #profile guided
scalasca      = false			        #scalasca instrumentation


#-----------------------------------------------------------------------
#user main options
#-----------------------------------------------------------------------
src_dir	   = $(augeanstables)/src
config_dir = $(AUGEANSTABLES_CONFIG)
dep_dir	   = $(AUGEANSTABLES_CONFIG)/dep

sd_choice  = cg_choice            #space discretization choice
pm_choice  = dim2d_choice         #physical model choice
bc_choice  = periodic_xy_choice   #boundary condition choice
td_choice  = finitevolume_choice  #time discretization choice
ti_choice  = rk3tvd_choice        #time integration choice
io_choice  = nf90_choice          #writer choice

#-----------------------------------------------------------------------
#source files directories
#-----------------------------------------------------------------------
#define the folder paths for the source code compilation
#-----------------------------------------------------------------------
include $(config_dir)/makefile_folders.mk


#-----------------------------------------------------------------------
#folder options for compilation
#-----------------------------------------------------------------------
#space discretisation
ifeq ($(strip $(sd_choice)), cg_choice)
	sd_cdir=$(cg_dir)
endif

#physical model
ifeq ($(strip $(pm_choice)), simpletest_choice)
	pm_cdir=$(simpletest_dir)
endif
ifeq ($(strip $(pm_choice)), dim2d_choice)
	pm_cdir=$(dim2d_dir)
endif

#boundary conditions
ifeq ($(strip $(bc_choice)), periodic_xy_choice)
	bc_cdir=$(pbc_dir)
	sim_dim2d_dep=$(dep_dir)/sim_dim2d_periodic_dep.mk
	sim_dim2d_par_dep=$(dep_dir)/sim_dim2d_par_periodic_dep.mk
endif
ifeq ($(strip $(bc_choice)), reflection_xy_choice)
	bc_cdir=$(rbc_dir)
	sim_dim2d_dep=$(dep_dir)/sim_dim2d_reflection_dep.mk
	sim_dim2d_par_dep=$(dep_dir)/sim_dim2d_par_reflection_dep.mk
endif
ifeq ($(strip $(bc_choice)), wall_xy_choice)
	bc_cdir=$(wbc_dir)
	sim_dim2d_dep=$(dep_dir)/sim_dim2d_wall_dep.mk
	sim_dim2d_par_dep=$(dep_dir)/sim_dim2d_par_wall_dep.mk
endif
ifeq ($(strip $(bc_choice)), wall_x_reflection_y_choice)
	bc_cdir=$(wrbc_dir)
	sim_dim2d_dep=$(dep_dir)/sim_dim2d_wall_reflection_dep.mk
	sim_dim2d_par_dep=$(dep_dir)/sim_dim2d_par_wall_reflection_dep.mk
endif

#time discretization
ifeq ($(strip $(td_choice)), finitevolume_choice)
	td_cdir=$(fv_dir)
endif

#time integration
ifeq ($(strip $(ti_choice)), rk3tvd_choice)
	ti_cdir=$(rk3tvd_dir)
endif

#writer choice
ifeq ($(strip $(wr_choice)), nf90_choice)
	wr_cdir=$(nf90_dir)
endif

#-----------------------------------------------------------------------
#compiler and options
#-----------------------------------------------------------------------
PREP	=
FC	= $(AUGEANSTABLES_COMPILER)
FFLAGS	= 
LDFLAGS =
INCLUDE =
LIBS	=

#compiler options------------------------------------------------
include $(config_dir)/options_ifort.mk
include $(config_dir)/options_gfortran.mk

#path for the mpi, hdf5, netcdf libraries depending on the cluster used-
include $(config_dir)/libraries_bolt.mk
include $(config_dir)/libraries_cartesius.mk

#options handeling depending on the user main options: debug, trace,
#and the type of compiler used (ifort, gfortran, mpiifort...)
include $(config_dir)/options_choice.mk


#-----------------------------------------------------------------------
#source code files of the current dir
#-----------------------------------------------------------------------
SRC	= $(wildcard *.f)	#fortran source files
SRCS	= $(SRC)		#fortran program files
OBJS	= $(SRC:.f=.o)		#objects (.o and .mod)
CMD	= $(SRCS:.f=)		#executables


#----------------------------------------------------------------------
#general rules
#----------------------------------------------------------------------
include $(config_dir)/makefile_rules.mk


#----------------------------------------------------------------------
#main code dependencies (w/o the test files)
#----------------------------------------------------------------------
include $(config_dir)/makefile_dep.mk
