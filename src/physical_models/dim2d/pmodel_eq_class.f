      !> @file
      !> class encapsulating subroutines to compute
      !> the reduced governing equations of the Diffuse
      !> Interface Model in 2D as derivated by J.Desmarais
      !> and J.G.M Kuerten
      !
      !> @author 
      !> Julien L. Desmarais
      !
      !> @brief
      !> class encapsulating subroutines to compute
      !> the governing equations of the Diffuse
      !> Interface Model in 2D:
      !> “Extension of the 1-D characteristic open boundary
      !> conditions to the diffuse interface model”,
      !> Computational Methods in Multiphase Flow VII,
      !> WIT Press, J. Desmarais and J.G.M. Kuerten
      !
      !> @date
      !> 08_08_2013 - initial version               - J.L. Desmarais
      !> 11_07_2014 - interface for erymanthianboar - J.L. Desmarais
      !> 10_12_2014 - eigensystems                  - J.L. Desmarais
      !> 11_12_2014 - initial conditions            - J.L. Desmarais
      !-----------------------------------------------------------------
      module pmodel_eq_class


        !space discretization module
        use interface_primary, only :
     $       gradient_x_proc,
     $       gradient_y_proc,
     $       gradient_n_proc

        use sd_operators_class, only :
     $       sd_operators

        use sd_operators_fd_module, only :
     $       gradient_x_interior,
     $       gradient_y_interior


        !diffuse interface model equations
        use dim2d_parameters, only :
     $       viscous_r, Re, We, Pr,
     $       cv_r, gravity,
     $       epsilon, zeta

        use dim2d_prim_module, only :
     $       mass_density,
     $       momentum_x,
     $       momentum_y,
     $       total_energy,
     $       classical_pressure_local,
     $       speed_of_sound,
     $       temperature_eff,
     $       compute_jacobian_cons_to_prim,
     $       compute_jacobian_prim_to_cons,
     $       compute_x_timedev_from_LODI_vector_dim2d,
     $       compute_y_timedev_from_LODI_vector_dim2d,
     $       compute_timedev_from_LODI_vectors_dim2d

        use dim2d_ncoords_module, only :
     $       compute_n1_eigenvalues_dim2d,
     $       compute_n2_eigenvalues_dim2d,
     $       compute_n1_lefteigenvector_dim2d,
     $       compute_n1_righteigenvector_dim2d,
     $       compute_n2_lefteigenvector_dim2d,
     $       compute_n2_righteigenvector_dim2d,
     $       compute_n1_transM_dim2d,
     $       compute_n2_transM_dim2d

        use dim2d_fluxes_module, only :
     $       flux_x_mass_density,
     $       flux_y_mass_density,
     $       flux_x_momentum_x,
     $       flux_y_momentum_x,
     $       flux_x_momentum_y,
     $       flux_y_momentum_y,
     $       flux_x_total_energy,
     $       flux_y_total_energy,
     $       flux_x_inviscid_momentum_x,
     $       flux_y_inviscid_momentum_x,
     $       flux_x_inviscid_momentum_y,
     $       flux_y_inviscid_momentum_y,
     $       flux_x_inviscid_total_energy,
     $       flux_y_inviscid_total_energy,
     $       flux_x_viscid_momentum_x,
     $       flux_y_viscid_momentum_x,
     $       flux_x_viscid_momentum_y,
     $       flux_y_viscid_momentum_y,
     $       flux_x_viscid_total_energy,
     $       flux_y_viscid_total_energy,
     $       flux_x_capillarity_momentum_x,
     $       flux_y_capillarity_momentum_x,
     $       flux_x_capillarity_momentum_y,
     $       flux_y_capillarity_momentum_y,
     $       flux_x_capillarity_total_energy,
     $       flux_y_capillarity_total_energy

        use dim2d_state_eq_module, only :
     $       get_mass_density_liquid,
     $       get_mass_density_vapor


        !diffuse interface model initial conditions
        use ic_class, only :
     $       ic


        !global parameters
        use parameters_bf_layer, only :
     $       bc_interior_pt,
     $       interior_pt

        use parameters_constant, only :
     $       sd_interior_type,
     $       sd_L0_type,
     $       sd_L1_type,
     $       sd_R1_type,
     $       sd_R0_type,
     $       sd_L0_n_type,
     $       sd_L1_n_type,
     $       sd_R1_n_type,
     $       sd_R0_n_type,
     $       scalar,
     $       vector_x, vector_y,
     $       steady_state,
     $       drop_retraction,
     $       bubble_ascending,
     $       homogeneous_liquid,
     $       drop_collision,
     $       phase_separation,
     $       earth_gravity_choice

        use parameters_input, only :
     $       nx,ny,ne,bc_size,
     $       ic_choice,
     $       gravity_choice,
     $       flow_velocity,
     $       T0,
     $       bf_openbc_md_threshold_ac,
     $       bf_openbc_md_threshold

        use parameters_kind, only :
     $       ikind,
     $       rkind


        !parent class
        use pmodel_eq_default_class, only :
     $       pmodel_eq_default


        implicit none

        private
        public :: pmodel_eq


        !> @class pmodel_eq
        !> class encapsulating operators to compute
        !> the governing equations of the Diffuse Interface
        !> Model in 2D
        !
        !> @param get_model_name
        !> get the name of the physcial model
        !
        !> @param get_var_name
        !> get the name of the main variables
        !> (mass, momentum_x, momentum_y, total_energy)
        !
        !> @param get_var_longname
        !> get the description of the main variables for the
        !> governing equations of the physical model
        !
        !> @param get_var_unit
        !> get the units of the main variables
        !> (\f$ kg.m^{-3}, kg.m^{-2}.s^{-1},
        !> kg.m^{-2}.s^{-1}, J.kg.m^{-3}) \f$
        !
        !> @param get_var_type
        !> get the type of the main variables
        !> (scalar, vector_x, vector_y, scalar)
        !
        !> @param get_sim_parameters
        !> get the simulation parameters specific to the DIM
        !> such as Re,Pr,We...
        !
        !> @param get_eq_nb
        !> get the number of governing equations: 4
        !
        !> @param get_sd_pattern_flux_x
        !> gridpoints needed around the central grid point
        !> to compute the fluxes in the x-direction in/out
        !
        !> @param get_sd_pattern_flux_y
        !> gridpoints needed around the central grid point
        !> to compute the fluxes in the y-direction in/out
        !
        !> @param apply_ic
        !> initialize the main variables of the governing equations
        !> considering the user choices (drop retraction, two drops
        !> collision...)
        !
        !> @param get_mach_ux_infty
        !> get the mach number based on the velocity in the x-direction
        !> in the far field
        !
        !> @param get_mach_uy_infty
        !> get the mach number based on the velocity in the y-direction
        !> in the far field
        !
        !> @param get_u_in
        !> get the velocity in the x-direction imposed in the far field
        !
        !> @param get_v_in
        !> get the velocity in the y-direction imposed in the far field
        !
        !> @param get_T_in
        !> get the temperature imposed in the far field
        !
        !> @param get_P_out
        !> get the pressure imposed in the far field
        !
        !> @param compute_flux_x
        !> compute the fluxes along the x-axis with fixed sized arrays
        !
        !> @param compute_flux_y
        !> compute the fluxes along the y-axis with fixed sized arrays
        !
        !> @param compute_flux_x_nopt
        !> compute the fluxes along the x-axis with non-fixed sized
        !> arrays
        !
        !> @param compute_flux_y_nopt
        !> compute the fluxes along the y-axis with non-fixed sized
        !> arrays
        !
        !> @param compute_flux_x_oneside
        !> compute the fluxes along the x-axis with non-fixed sized
        !> arrays using oneside space discretization operators
        !
        !> @param compute_flux_y_oneside
        !> compute the fluxes along the y-axis with non-fixed sized
        !> arrays using oneside space discretization operators
        !
        !> @param compute_flux_x_by_parts
        !> compute the fluxes along the x-axis with non-fixed sized
        !> arrays by making distinction b\w the inviscid and the viscid
        !> parts
        !
        !> @param compute_flux_y_by_parts
        !> compute the fluxes along the y-axis with non-fixed sized
        !> arrays by making distinction b\w the inviscid and the viscid
        !> parts
        !
        !> @param compute_body_forces
        !> compute the body forces at a grid point location
        !
        !> @param get_viscous_coeff
        !> get the inverse of the Reynolds number
        !
        !> @param get_velocity
        !> compute the velocity
        !
        !> @param are_openbc_undermined
        !> determine whether the open b.c. are undermined at the grid
        !> point location
        !
        !> @param compute_x_eigenvalues
        !> compute the eigenvalues for the convective part in the
        !> x-direction
        !
        !> @param compute_y_eigenvalues
        !> compute the eigenvalues for the convective part in the
        !> y-direction
        !
        !> @param compute_x_lefteigenvector
        !> compute the left eigenmatrix for the convective part in the
        !> x-direction
        !
        !> @param compute_x_righteigenvector
        !> compute the right eigenmatrix for the convective part in the
        !> x-direction
        !
        !> @param compute_y_lefteigenvector
        !> compute the left eigenmatrix for the convective part in the
        !> y-direction
        !
        !> @param compute_y_righteigenvector
        !> compute the right eigenmatrix for the convective part in the
        !> y-direction
        !
        !> @param compute_n1_eigenvalues
        !> compute the eigenvalues for the convective part in the
        !> (x-y)-direction
        !
        !> @param compute_n2_eigenvalues
        !> compute the eigenvalues for the convective part in the
        !> (x+y)-direction
        !
        !> @param compute_n1_lefteigenvector
        !> compute the left eigenmatrix for the convective part in the
        !> (x-y)-direction
        !
        !> @param compute_n1_righteigenvector
        !> compute the right eigenmatrix for the convective part in the
        !> (x-y)-direction
        !
        !> @param compute_n2_lefteigenvector
        !> compute the left eigenmatrix for the convective part in the
        !> (x+y)-direction
        !
        !> @param compute_n2_righteigenvector
        !> compute the right eigenmatrix for the convective part in the
        !> (x+y)-direction
        !
        !> @param compute_x_transM
        !> compute the transverse matrix of the convective part in the
        !> x-direction
        !
        !> @param compute_y_transM
        !> compute the transverse matrix of the convective part in the
        !> y-direction
        !
        !> @param compute_n1_transM
        !> compute the transverse matrix of the convective part in the
        !> (x-y)-direction
        !
        !> @param compute_n2_transM
        !> compute the transverse matrix of the convective part in the
        !> (x+y)-direction
        !
        !> @param compute_x_leftConsLodiM
        !> compute the conservative LODI matrix for the convective part
        !> in the x-direction
        !
        !> @param compute_y_leftConsLodiM
        !> compute the conservative LODI matrix for the convective part
        !> in the y-direction
        !
        !> @param compute_x_timedev_from_LODI_vector
        !> compute the contribution of the LODI vector in the x-direction
        !> to the time derivatives
        !
        !> @param compute_y_timedev_from_LODI_vector
        !> compute the contribution of the LODI vector in the y-direction
        !> to the time derivatives
        !
        !> @param compute_timedev_from_LODI_vector
        !> compute the contribution of the LODI vector in the x- and y-
        !> directions to the time derivatives
        !
        !> @param compute_x_gradient
        !> compute the gradient of the governing variables in the
        !> x-direction
        !
        !> @param compute_y_gradient
        !> compute the gradient of the governing variables in the
        !> y-direction
        !
        !> @param compute_n_gradient
        !> compute the gradient of the governing variables either in the
        !> (x-y)- or the (x+y)-direction
        !---------------------------------------------------------------
        type, extends(pmodel_eq_default) :: pmodel_eq
          
          type(ic) :: initial_conditions

          contains

          !description of the model and its main
          !governing variables
          procedure, nopass :: get_model_name
          procedure, nopass :: get_var_name
          procedure, nopass :: get_var_longname
          procedure, nopass :: get_var_unit
          procedure, nopass :: get_var_type
          procedure, nopass :: get_sim_parameters
          procedure, nopass :: get_eq_nb

          !sd operators pattern for the fluxes
          procedure, nopass :: get_sd_pattern_flux_x
          procedure, nopass :: get_sd_pattern_flux_y

          !initial conditions procedures
          procedure,   pass :: apply_ic
          procedure,   pass :: get_mach_ux_infty
          procedure,   pass :: get_mach_uy_infty
          procedure,   pass :: get_u_in
          procedure,   pass :: get_v_in
          procedure,   pass :: get_T_in
          procedure,   pass :: get_P_out

          !flux computation
          procedure, nopass :: compute_flux_x
          procedure, nopass :: compute_flux_y
          procedure, nopass :: compute_flux_x_nopt
          procedure, nopass :: compute_flux_y_nopt
          procedure, nopass :: compute_flux_x_oneside
          procedure, nopass :: compute_flux_y_oneside
          procedure, nopass :: compute_flux_x_by_parts
          procedure, nopass :: compute_flux_y_by_parts
          procedure, nopass :: compute_body_forces
          procedure, nopass :: get_viscous_coeff

          !field extension for open b.c.
          procedure, nopass :: get_velocity
          procedure, nopass :: are_openbc_undermined
          procedure,   pass :: get_far_field

          !eigenquantities computation
          procedure, nopass :: compute_x_eigenvalues
          procedure, nopass :: compute_y_eigenvalues
          procedure, nopass :: compute_x_lefteigenvector
          procedure, nopass :: compute_x_righteigenvector
          procedure, nopass :: compute_y_lefteigenvector
          procedure, nopass :: compute_y_righteigenvector

          procedure, nopass :: compute_n1_eigenvalues => compute_n1_eigenvalues_dim2d
          procedure, nopass :: compute_n2_eigenvalues => compute_n2_eigenvalues_dim2d
          procedure, nopass :: compute_n1_lefteigenvector  => compute_n1_lefteigenvector_dim2d
          procedure, nopass :: compute_n1_righteigenvector => compute_n1_righteigenvector_dim2d
          procedure, nopass :: compute_n2_lefteigenvector  => compute_n2_lefteigenvector_dim2d
          procedure, nopass :: compute_n2_righteigenvector => compute_n2_righteigenvector_dim2d

          !transverse matrices
          procedure, nopass :: compute_x_transM
          procedure, nopass :: compute_y_transM
          procedure, nopass :: compute_n1_transM => compute_n1_transM_dim2d
          procedure, nopass :: compute_n2_transM => compute_n2_transM_dim2d

          !lodi computations
          procedure, nopass :: compute_x_leftConsLodiM
          procedure, nopass :: compute_y_leftConsLodiM
          procedure, nopass :: compute_x_timedev_from_LODI_vector => compute_x_timedev_from_LODI_vector_dim2d
          procedure, nopass :: compute_y_timedev_from_LODI_vector => compute_y_timedev_from_LODI_vector_dim2d
          procedure, nopass :: compute_timedev_from_LODI_vectors => compute_timedev_from_LODI_vectors_dim2d
          
          !gradient computation
          procedure, nopass :: compute_x_gradient
          procedure, nopass :: compute_y_gradient
          procedure, nopass :: compute_n_gradient
          
        end type pmodel_eq


        contains

        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> interface to get the name of the physical model
        !
        !> @date
        !> 08_08_2013 - initial version - J.L. Desmarais
        !
        !>@param model_name
        !> character giving the name of the model
        !---------------------------------------------------------------
        function get_model_name() result(model_name)

          implicit none

          character(len=10) :: model_name

          model_name="DIM2D"

        end function get_model_name
        
        
        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> get the name of the main variables
        !
        !> @date
        !> 08_08_2013 - initial version - J.L. Desmarais
        !
        !>@param var_name
        !> characters giving the variable names
        !---------------------------------------------------------------
        function get_var_name() result(var_pties)

          implicit none

          character(len=10), dimension(ne) :: var_pties

          var_pties(1)="mass"
          var_pties(2)="momentum_x"
          var_pties(3)="momentum_y"
          var_pties(4)="energy"          

        end function get_var_name
        
        
        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> get the name of the main variables
        !
        !> @date
        !> 08_08_2013 - initial version - J.L. Desmarais
        !
        !>@param var_name
        !> characters giving the variable names
        !---------------------------------------------------------------
        function get_var_longname() result(var_pties)

          implicit none

          character(len=33), dimension(ne) :: var_pties

          var_pties(1)="mass density"
          var_pties(2)="momentum density along the x-axis"
          var_pties(3)="momentum density along the y-axis"
          var_pties(4)="total energy density"

        end function get_var_longname


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> get the units of the main variables
        !
        !> @date
        !> 08_08_2013 - initial version - J.L. Desmarais
        !
        !>@param var_name
        !> characters giving the variable units
        !---------------------------------------------------------------
        function get_var_unit() result(var_pties)

          implicit none

          character(len=23), dimension(ne) :: var_pties

          var_pties(1)= "(kg/m3)/(kg/m3)"
          var_pties(2)= "(kg/(m2.s))/(kg/(m2.s))"
          var_pties(3)= "(kg/(m2.s))/(kg/(m2.s))"
          var_pties(4)= "(J/m3)/(J.m3)"

        end function get_var_unit


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> interface to get the type of the main variables
        !> (scalar, vector_x, vector_y, scalar)
        !
        !> @date
        !> 08_08_2013 - initial version - J.L. Desmarais
        !
        !>@param var_name
        !> characters giving the variable type
        !---------------------------------------------------------------
        function get_var_type() result(var_type)

          implicit none

          integer, dimension(ne) :: var_type

          var_type(1)=scalar
          var_type(2)=vector_x
          var_type(3)=vector_y
          var_type(4)=scalar

        end function get_var_type


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> get the simulation parameters
        !
        !> @date
        !> 12_08_2014 - initial version - J.L. Desmarais
        !
        !>@param param_name
        !> array with the name of the characteristic parameters
        !> for the simulation
        !
        !>@param param_value
        !> array with the value of the characteristic parameters
        !> for the simulation
        !--------------------------------------------------------------
        subroutine get_sim_parameters(param_name, param_value)

          implicit none

          character(20), dimension(:), allocatable, intent(out) :: param_name
          real(rkind)  , dimension(:), allocatable, intent(out) :: param_value


          allocate(param_name(8))
          allocate(param_value(8))

          param_name(1)  = 'viscous_r'
          param_name(2)  = 'Re'
          param_name(3)  = 'We'
          param_name(4)  = 'Pr'
          param_name(5)  = 'cv_r'
          param_name(6)  = 'gravity'
          param_name(7)  = 'flow_velocity'
          param_name(8)  = 'temperature'

          param_value(1) = viscous_r
          param_value(2) = Re
          param_value(3) = We
          param_value(4) = Pr
          param_value(5) = cv_r
          param_value(6) = gravity
          param_value(7) = flow_velocity
          param_value(8) = T0

        end subroutine get_sim_parameters
        
        
        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> get the number of main variables
        !> in the governing equations: 4
        !
        !> @date
        !> 08_08_2013 - initial version - J.L. Desmarais
        !
        !>@param eq_nb
        !> number of governing equations
        !---------------------------------------------------------------
        function get_eq_nb() result(eq_nb)
          implicit none
          integer :: eq_nb
          eq_nb=4
        end function get_eq_nb


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> gridpoints needed around the central grid point
        !> to compute the fluxes in the x-direction in/out
        !
        !> @date
        !> 27_01_2015 - initial version - J.L. Desmarais
        !
        !>@param operator_type
        !> type of operator used to compute the flux
        !
        !> @return pattern
        !> space discretization pattern around the central point
        !---------------------------------------------------------------
        function get_sd_pattern_flux_x(operator_type) result(pattern)

          implicit none

          integer, intent(in)     :: operator_type
          integer, dimension(2,2) :: pattern

          
          select case(operator_type)
            case(sd_interior_type)
               pattern = reshape((/
     $              -2,-2,2,2/),
     $              (/2,2/))
            case(sd_L0_type)
               pattern = reshape((/
     $              -2,0,2,2/),
     $              (/2,2/))
            case(sd_L1_type)
               pattern = reshape((/
     $              -2,-1,2,1/),
     $              (/2,2/))
            case(sd_R1_type)
               pattern = reshape((/
     $              -2,-1,2,1/),
     $              (/2,2/))
            case(sd_R0_type)
               pattern = reshape((/
     $              -2,-2,2,0/),
     $              (/2,2/))

            case(sd_L0_n_type,
     $           sd_L1_n_type,
     $           sd_R1_n_type,
     $           sd_R0_n_type)

               pattern = reshape((/
     $              -2,-2,2,2/),
     $              (/2,2/))

            case default
               print '(''dim2d/pmodel_eq_class'')'
               print '(''get_sd_pattern_flux_x'')'
               print '(''operator_type not recognized'')'
               print '(''operator_type: '',I2)', operator_type
               stop ''
          end select

        end function get_sd_pattern_flux_x


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> gridpoints needed around the central grid point
        !> to compute the fluxes in the y-direction in/out
        !
        !> @date
        !> 27_01_2015 - initial version - J.L. Desmarais
        !
        !> @param operator_type
        !> type of operator used to compute the flux
        !
        !> @param pattern
        !> space discretization pattern around the central point
        !---------------------------------------------------------------
        function get_sd_pattern_flux_y(operator_type) result(pattern)

          implicit none

          integer, intent(in)     :: operator_type
          integer, dimension(2,2) :: pattern

          
          select case(operator_type)
            case(sd_interior_type)
               pattern = reshape((/
     $              -2,-2,2,2/),
     $              (/2,2/))
            case(sd_L0_type)
               pattern = reshape((/
     $              0,-2,2,2/),
     $              (/2,2/))
            case(sd_L1_type)
               pattern = reshape((/
     $              -1,-2,1,2/),
     $              (/2,2/))
            case(sd_R1_type)
               pattern = reshape((/
     $              -1,-2,1,2/),
     $              (/2,2/))
            case(sd_R0_type)
               pattern = reshape((/
     $              -2,-2,0,2/),
     $              (/2,2/))

            case(sd_L0_n_type,
     $           sd_L1_n_type,
     $           sd_R1_n_type,
     $           sd_R0_n_type)

               pattern = reshape((/
     $              -2,-2,2,2/),
     $              (/2,2/))

            case default
               print '(''dim2d/pmodel_eq_class'')'
               print '(''get_sd_pattern_flux_y'')'
               print '(''operator_type not recognized'')'
               print '(''operator_type: '',I2)', operator_type
               stop ''
          end select

        end function get_sd_pattern_flux_y
        
        
        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> apply the initial conditions to the main
        !> variables of the governing equations
        !
        !> @date
        !> 11_12_2014 - initial version - J.L. Desmarais
        !
        !>@param field_used
        !> object encapsulating the main variables
        !---------------------------------------------------------------
        subroutine apply_ic(this,nodes,x_map,y_map)

          implicit none

          class(pmodel_eq)             , intent(in)    :: this
          real(rkind), dimension(:,:,:), intent(inout) :: nodes
          real(rkind), dimension(:)    , intent(in)    :: x_map
          real(rkind), dimension(:)    , intent(in)    :: y_map

          call this%initial_conditions%apply_ic(nodes,x_map,y_map)

        end subroutine apply_ic


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> get the far field Mach number in the x-direction
        !
        !> @date
        !> 11_12_2014 - initial version - J.L. Desmarais
        !
        !>@result var
        !> far field Mach number in the x-direction
        !---------------------------------------------------------------
        function get_mach_ux_infty(this,side) result(var)

          implicit none

          class(pmodel_eq), intent(in) :: this
          logical         , intent(in) :: side
          real(rkind)                  :: var

          var = this%initial_conditions%get_mach_ux_infty(side)

        end function get_mach_ux_infty


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> get the far field Mach number in the y-direction
        !
        !> @date
        !> 11_12_2014 - initial version - J.L. Desmarais
        !
        !>@result var
        !> far field Mach number in the y-direction
        !---------------------------------------------------------------
        function get_mach_uy_infty(this,side) result(var)

          implicit none

          class(pmodel_eq), intent(in) :: this
          logical         , intent(in) :: side
          real(rkind)                  :: var

          var = this%initial_conditions%get_mach_uy_infty(side)

        end function get_mach_uy_infty


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> get the x-component of the velocity enforced
        !> at the edge of the computational domain
        !
        !> @date
        !> 11_12_2014 - initial version - J.L. Desmarais
        !
        !>@result var
        !> x-component of the velocity enforced at the edge of the
        !> computational domain
        !---------------------------------------------------------------
        function get_u_in(this,t,x,y) result(var)

          implicit none

          class(pmodel_eq), intent(in) :: this
          real(rkind)     , intent(in) :: t
          real(rkind)     , intent(in) :: x
          real(rkind)     , intent(in) :: y
          real(rkind)                  :: var

          var = this%initial_conditions%get_u_in(t,x,y)

        end function get_u_in


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> get the y-component of the velocity enforced
        !> at the edge of the computational domain
        !
        !> @date
        !> 11_12_2014 - initial version - J.L. Desmarais
        !
        !>@result var
        !> y-component of the velocity enforced at the edge of the
        !> computational domain
        !---------------------------------------------------------------
        function get_v_in(this,t,x,y) result(var)

          implicit none

          class(pmodel_eq), intent(in) :: this
          real(rkind)     , intent(in) :: t
          real(rkind)     , intent(in) :: x
          real(rkind)     , intent(in) :: y
          real(rkind)                  :: var

          var = this%initial_conditions%get_v_in(t,x,y)

        end function get_v_in


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> get the temperature enforced at the edge of the
        !> computational domain
        !
        !> @date
        !> 11_12_2014 - initial version - J.L. Desmarais
        !
        !>@result var
        !> temperature enforced at the edge of the computational domain
        !---------------------------------------------------------------
        function get_T_in(this,t,x,y) result(var)

          implicit none

          class(pmodel_eq), intent(in) :: this
          real(rkind)     , intent(in) :: t
          real(rkind)     , intent(in) :: x
          real(rkind)     , intent(in) :: y
          real(rkind)                  :: var

          var = this%initial_conditions%get_T_in(t,x,y)

        end function get_T_in


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> get the pressure enforced at the edge of the
        !> computational domain
        !
        !> @date
        !> 11_12_2014 - initial version - J.L. Desmarais
        !
        !>@result var
        !> pressure enforced at the edge of the computational domain
        !---------------------------------------------------------------
        function get_P_out(this,t,x,y) result(var)

          implicit none

          class(pmodel_eq), intent(in) :: this
          real(rkind)     , intent(in) :: t
          real(rkind)     , intent(in) :: x
          real(rkind)     , intent(in) :: y
          real(rkind)                  :: var

          var = this%initial_conditions%get_P_out(t,x,y)

        end function get_P_out
        
        
        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> interface to apply the initial conditions
        !> to the main variables of the governing
        !> equations
        !
        !> @date
        !> 08_08_2013 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@param dx
        !> grid size along the x-axis
        !
        !>@param dy
        !> grid size along the y-axis
        !
        !>@param s
        !> space discretization operators
        !
        !>@param flux_x
        !> fluxes along the x-axis
        !---------------------------------------------------------------
        function compute_flux_x(nodes,dx,dy,s) result(flux_x)
        
          implicit none

          real(rkind), dimension(nx,ny,ne)  , intent(in)   :: nodes
          real(rkind)                       , intent(in)   :: dx
          real(rkind)                       , intent(in)   :: dy
          type(sd_operators)                , intent(in)   :: s
          real(rkind), dimension(nx+1,ny,ne)               :: flux_x

          integer(ikind) :: i,j


          !<fluxes along the x-axis
          do j=1+bc_size, ny-bc_size
             !DEC$ IVDEP
             do i=1+bc_size, nx+1-bc_size

                !DEC$ FORCEINLINE RECURSIVE
                flux_x(i,j,1) =
     $               flux_x_mass_density(
     $               nodes,s,i,j)

                !DEC$ FORCEINLINE RECURSIVE
                flux_x(i,j,2) = flux_x_momentum_x(
     $               nodes,s,i,j,
     $               dx, dy)

                !DEC$ FORCEINLINE RECURSIVE
                flux_x(i,j,3) = flux_x_momentum_y(
     $               nodes,s,i,j,
     $               dx, dy)

                !DEC$ FORCEINLINE RECURSIVE
                flux_x(i,j,4) = flux_x_total_energy(
     $               nodes,s,i,j,
     $               dx, dy)

             end do
          end do

        end function compute_flux_x


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> interface to apply the initial conditions
        !> to the main variables of the governing
        !> equations
        !
        !> @date
        !> 08_08_2013 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@param dy
        !> grid size along the y-axis
        !
        !>@param s
        !> space discretization operators
        !
        !>@param flux_y
        !> fluxes along the y-axis
        !---------------------------------------------------------------
        function compute_flux_y(nodes,dx,dy,s) result(flux_y)
        
          implicit none

          real(rkind), dimension(nx,ny,ne)  , intent(in)   :: nodes
          real(rkind)                       , intent(in)   :: dx
          real(rkind)                       , intent(in)   :: dy
          type(sd_operators)                , intent(in)   :: s
          real(rkind), dimension(nx,ny+1,ne)               :: flux_y

          integer(ikind) :: i,j


          !<fluxes along the y-axis
          do j=1+bc_size, ny+1-bc_size
             !DEC$ IVDEP
             do i=1+bc_size, nx-bc_size

                !DEC$ FORCEINLINE RECURSIVE
                flux_y(i,j,1) = flux_y_mass_density(
     $               nodes,s,i,j)

                !DEC$ FORCEINLINE RECURSIVE
                flux_y(i,j,2) = flux_y_momentum_x(
     $               nodes,s,i,j,
     $               dx, dy)

                !DEC$ FORCEINLINE RECURSIVE
                flux_y(i,j,3) = flux_y_momentum_y(
     $               nodes,s,i,j,
     $               dx, dy)

                !DEC$ FORCEINLINE RECURSIVE
                flux_y(i,j,4) = flux_y_total_energy(
     $               nodes,s,i,j,
     $               dx, dy)

             end do
          end do

        end function compute_flux_y


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> interface to apply the initial conditions
        !> to the main variables of the governing
        !> equations
        !
        !> @date
        !> 08_08_2013 - initial version - J.L. Desmarais
        !
        !>@param this
        !> physical model
        !>
        !>@param nodes
        !> array with the grid point data
        !
        !>@param dx
        !> grid step along the x-axis
        !
        !>@param dy
        !> grid step along the y-axis
        !
        !>@param s
        !> space discretization operators      
        !
        !>@param grdpts_id
        !> role of the grid points
        !
        !>@param flux_x
        !> fluxes along the x-axis
        !---------------------------------------------------------------
        subroutine compute_flux_x_nopt(
     $     nodes,dx,dy,s,
     $     grdpts_id,
     $     flux_x,
     $     x_borders,
     $     y_borders)
        
          implicit none

          real(rkind)   , dimension(:,:,:), intent(in)    :: nodes
          real(rkind)                     , intent(in)    :: dx
          real(rkind)                     , intent(in)    :: dy
          type(sd_operators)              , intent(in)    :: s
          integer       , dimension(:,:)  , intent(in)    :: grdpts_id
          real(rkind)   , dimension(:,:,:), intent(inout) :: flux_x
          integer(ikind), dimension(2)    , intent(in)    :: x_borders
          integer(ikind), dimension(2)    , intent(in)    :: y_borders

          integer(ikind) :: i,j


          !<fluxes along the x-axis
          do j=y_borders(1), y_borders(2)
             !DEC$ IVDEP
             do i=x_borders(1), x_borders(2)+1

                if((grdpts_id(i,j).eq.interior_pt).or.
     $               (grdpts_id(i,j).eq.bc_interior_pt))then

                   !DEC$ FORCEINLINE RECURSIVE
                   flux_x(i,j,1) =
     $                  flux_x_mass_density(
     $                  nodes,s,i,j)
                   
                   !DEC$ FORCEINLINE RECURSIVE
                   flux_x(i,j,2) = flux_x_momentum_x(
     $                  nodes,s,i,j,
     $                  dx, dy)
                   
                   !DEC$ FORCEINLINE RECURSIVE
                   flux_x(i,j,3) = flux_x_momentum_y(
     $                  nodes,s,i,j,
     $                  dx, dy)
                   
                   !DEC$ FORCEINLINE RECURSIVE
                   flux_x(i,j,4) = flux_x_total_energy(
     $                  nodes,s,i,j,
     $                  dx, dy)

                end if

             end do
          end do

        end subroutine compute_flux_x_nopt


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> interface to apply the initial conditions
        !> to the main variables of the governing
        !> equations
        !
        !> @date
        !> 08_08_2013 - initial version - J.L. Desmarais
        !
        !>@param this
        !> physical model
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@param s
        !> space discretization operators
        !
        !>@param dx
        !> grid step along the x-axis
        !
        !>@param dy
        !> grid step along the y-axis
        !
        !>@param grdpts_id
        !> role of the grid points
        !
        !>@param flux_y
        !> fluxes along the y-axis
        !---------------------------------------------------------------
        subroutine compute_flux_y_nopt(
     $     nodes,dx,dy,s,
     $     grdpts_id,
     $     flux_y,
     $     x_borders,
     $     y_borders)
        
          implicit none

          real(rkind)   , dimension(:,:,:), intent(in)    :: nodes
          real(rkind)                     , intent(in)    :: dx
          real(rkind)                     , intent(in)    :: dy
          type(sd_operators)              , intent(in)    :: s
          integer       , dimension(:,:)  , intent(in)    :: grdpts_id
          real(rkind)   , dimension(:,:,:), intent(inout) :: flux_y
          integer(ikind), dimension(2)    , intent(in)    :: x_borders
          integer(ikind), dimension(2)    , intent(in)    :: y_borders

          integer(ikind) :: i,j


          !<fluxes along the y-axis
          do j=y_borders(1), y_borders(2)+1
             !DEC$ IVDEP
             do i=x_borders(1), x_borders(2)

                if((grdpts_id(i,j).eq.interior_pt).or.
     $               (grdpts_id(i,j).eq.bc_interior_pt))then

                   !DEC$ FORCEINLINE RECURSIVE
                   flux_y(i,j,1) = flux_y_mass_density(nodes,s,i,j)
                   
                   !DEC$ FORCEINLINE RECURSIVE
                   flux_y(i,j,2) = flux_y_momentum_x(
     $                  nodes,s,i,j,
     $                  dx,dy)
                   
                   !DEC$ FORCEINLINE RECURSIVE
                   flux_y(i,j,3) = flux_y_momentum_y(
     $                  nodes,s,i,j,
     $                  dx,dy)
                   
                   !DEC$ FORCEINLINE RECURSIVE
                   flux_y(i,j,4) = flux_y_total_energy(
     $                  nodes,s,i,j,
     $                  dx,dy)

                end if

             end do
          end do

        end subroutine compute_flux_y_nopt


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> computation of the fluxes along the x-axis
        !
        !> @date
        !> 28_07_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> object encapsulating the main variables
        !
        !>@param dx
        !> grid size along the x-axis
        !
        !>@param dy
        !> grid size along the y-axis
        !
        !>@param i
        !> x-index where the flux_x is computed
        !
        !>@param j
        !> y-index where the flux_x is computed
        !
        !>@param s_oneside
        !> space discretization operators
        !
        !>@param flux_x
        !> fluxes along the x-axis
        !---------------------------------------------------------------
        function compute_flux_x_oneside(nodes,dx,dy,i,j,s_oneside)
     $     result(flux_x)
        
          implicit none

          real(rkind), dimension(:,:,:), intent(in)   :: nodes
          real(rkind)                  , intent(in)   :: dx
          real(rkind)                  , intent(in)   :: dy
          integer(ikind)               , intent(in)   :: i
          integer(ikind)               , intent(in)   :: j
          class(sd_operators)          , intent(in)   :: s_oneside
          real(rkind), dimension(ne)                  :: flux_x

          !<fluxes along the x-axis
          !DEC$ FORCEINLINE RECURSIVE
          flux_x(1) = flux_x_mass_density(
     $         nodes,s_oneside,i,j)
          
          !DEC$ FORCEINLINE RECURSIVE
          flux_x(2) = flux_x_momentum_x(
     $         nodes,s_oneside,i,j,
     $         dx,dy)
          
          !DEC$ FORCEINLINE RECURSIVE
          flux_x(3) = flux_x_momentum_y(
     $         nodes,s_oneside,i,j,
     $         dx,dy)
          
          !DEC$ FORCEINLINE RECURSIVE
          flux_x(4) = flux_x_total_energy(
     $         nodes,s_oneside,i,j,
     $         dx,dy)

        end function compute_flux_x_oneside


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> computation of the fluxes along the y-axis
        !
        !> @date
        !> 28_07_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> object encapsulating the main variables
        !
        !>@param dx
        !> grid size along the x-axis
        !
        !>@param dy
        !> grid size along the y-axis
        !
        !>@param i
        !> x-index where the flux_x is computed
        !
        !>@param j
        !> y-index where the flux_x is computed
        !
        !>@param s_oneside
        !> space discretization operators
        !
        !>@param flux_y
        !> fluxes along the y-axis
        !---------------------------------------------------------------
        function compute_flux_y_oneside(nodes,dx,dy,i,j,s_oneside)
     $     result(flux_y)
        
          implicit none

          real(rkind), dimension(:,:,:), intent(in)   :: nodes
          real(rkind)                  , intent(in)   :: dx
          real(rkind)                  , intent(in)   :: dy
          integer(ikind)               , intent(in)   :: i
          integer(ikind)               , intent(in)   :: j
          class(sd_operators)          , intent(in)   :: s_oneside
          real(rkind), dimension(ne)                  :: flux_y


          !DEC$ FORCEINLINE RECURSIVE
          flux_y(1) = flux_y_mass_density(
     $         nodes,s_oneside,i,j)
          
          !DEC$ FORCEINLINE RECURSIVE
          flux_y(2) = flux_y_momentum_x(
     $         nodes,s_oneside,i,j,
     $         dx,dy)
          
          !DEC$ FORCEINLINE RECURSIVE
          flux_y(3) = flux_y_momentum_y(
     $         nodes,s_oneside,i,j,
     $         dx,dy)
          
          !DEC$ FORCEINLINE RECURSIVE
          flux_y(4) = flux_y_total_energy(
     $         nodes,s_oneside,i,j,
     $         dx,dy)

        end function compute_flux_y_oneside


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute the fluxes by parts (get the inviscid and the
        !> viscid parts)
        !
        !> @date
        !> 12_12_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@param dx
        !> space step along the x-direction
        !
        !>@param dy
        !> space step along the y-direction
        !
        !>@param i
        !> index identifying the nodes along the x-direction
        !
        !>@param j
        !> index identifying the nodes along the y-direction
        !
        !>@param s_oneside
        !> space discretization operator
        !
        !>@param inviscid_flux
        !> inviscid flux at (i-1/2,j)
        !
        !>@param viscid_flux
        !> viscous flux computed at (i-1/2,j)
        !
        !>@return flux_x
        !> flux computed at (i-1/2,j)
        !--------------------------------------------------------------
        function compute_flux_x_by_parts(
     $     nodes,dx,dy,i,j,s_oneside,
     $     inviscid_flux, viscid_flux)
     $     result(flux_x)
        
          implicit none
        
          real(rkind), dimension(:,:,:), intent(in)   :: nodes
          real(rkind)                  , intent(in)   :: dx
          real(rkind)                  , intent(in)   :: dy
          integer(ikind)               , intent(in)   :: i
          integer(ikind)               , intent(in)   :: j
          class(sd_operators)          , intent(in)   :: s_oneside
          real(rkind), dimension(ne)   , intent(out)  :: inviscid_flux
          real(rkind), dimension(ne)   , intent(out)  :: viscid_flux
          real(rkind), dimension(ne)                  :: flux_x


          real(rkind), dimension(ne) :: capillarity_flux


          !inviscid part
          !--------------------------------
          !DEC$ FORCEINLINE RECURSIVE
          inviscid_flux(1) = flux_x_mass_density(nodes,s_oneside,i,j)
          
          !DEC$ FORCEINLINE RECURSIVE
          inviscid_flux(2) = flux_x_inviscid_momentum_x(nodes,s_oneside,i,j)
          
          !DEC$ FORCEINLINE RECURSIVE
          inviscid_flux(3) = flux_x_inviscid_momentum_y(nodes,s_oneside,i,j)
          
          !DEC$ FORCEINLINE RECURSIVE
          inviscid_flux(4) = flux_x_inviscid_total_energy(nodes,s_oneside,i,j)


          !viscid part
          !--------------------------------
          !DEC$ FORCEINLINE RECURSIVE
          viscid_flux(1) = 0.0d0
          
          !DEC$ FORCEINLINE RECURSIVE
          viscid_flux(2) = flux_x_viscid_momentum_x(nodes,s_oneside,i,j,dx,dy)
          
          !DEC$ FORCEINLINE RECURSIVE
          viscid_flux(3) = flux_x_viscid_momentum_y(nodes,s_oneside,i,j,dx,dy)
          
          !DEC$ FORCEINLINE RECURSIVE
          viscid_flux(4) = flux_x_viscid_total_energy(nodes,s_oneside,i,j,dx,dy)


          !capillarity part
          !--------------------------------
          !DEC$ FORCEINLINE RECURSIVE
          capillarity_flux(1) = 0.0d0
          
          !DEC$ FORCEINLINE RECURSIVE
          capillarity_flux(2) = flux_x_capillarity_momentum_x(nodes,s_oneside,i,j,dx,dy)
          
          !DEC$ FORCEINLINE RECURSIVE
          capillarity_flux(3) = flux_x_capillarity_momentum_y(nodes,s_oneside,i,j,dx,dy)
          
          !DEC$ FORCEINLINE RECURSIVE
          capillarity_flux(4) = flux_x_capillarity_total_energy(nodes,s_oneside,i,j,dx,dy)


          !total flux
          !--------------------------------
          flux_x(1) = inviscid_flux(1)
          flux_x(2) = inviscid_flux(2) - epsilon*viscid_flux(2) - zeta*capillarity_flux(2)
          flux_x(3) = inviscid_flux(3) - epsilon*viscid_flux(3) - zeta*capillarity_flux(3)
          flux_x(4) = inviscid_flux(4) - epsilon*viscid_flux(4) - zeta*capillarity_flux(4)
          
        end function compute_flux_x_by_parts


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute the fluxes by parts (get the inviscid and the
        !> viscid parts)
        !
        !> @date
        !> 10_11_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@param dx
        !> space step along the x-direction
        !
        !>@param dy
        !> space step along the y-direction
        !
        !>@param i
        !> index identifying the nodes along the x-direction
        !
        !>@param j
        !> index identifying the nodes along the y-direction
        !
        !>@param s_oneside
        !> space discretization operator
        !
        !>@param inviscid_flux
        !> inviscid flux at (i+1/2,j)
        !
        !>@param viscid_flux
        !> viscous flux computed at (i+1/2,j)
        !
        !>@return flux_x
        !> flux computed at (i+1/2,j)
        !--------------------------------------------------------------
        function compute_flux_y_by_parts(
     $     nodes,dx,dy,i,j,s_oneside,
     $     inviscid_flux, viscid_flux)
     $     result(flux_y)
        
          implicit none
        
          real(rkind), dimension(:,:,:), intent(in)   :: nodes
          real(rkind)                  , intent(in)   :: dx
          real(rkind)                  , intent(in)   :: dy
          integer(ikind)               , intent(in)   :: i
          integer(ikind)               , intent(in)   :: j
          class(sd_operators)          , intent(in)   :: s_oneside
          real(rkind), dimension(ne)   , intent(out)  :: inviscid_flux
          real(rkind), dimension(ne)   , intent(out)  :: viscid_flux
          real(rkind), dimension(ne)                  :: flux_y
          

          real(rkind), dimension(ne) :: capillarity_flux


          !inviscid part
          !--------------------------------
          !DEC$ FORCEINLINE RECURSIVE
          inviscid_flux(1) = flux_y_mass_density(nodes,s_oneside,i,j)
          
          !DEC$ FORCEINLINE RECURSIVE
          inviscid_flux(2) = flux_y_inviscid_momentum_x(nodes,s_oneside,i,j)
          
          !DEC$ FORCEINLINE RECURSIVE
          inviscid_flux(3) = flux_y_inviscid_momentum_y(nodes,s_oneside,i,j)
          
          !DEC$ FORCEINLINE RECURSIVE
          inviscid_flux(4) = flux_y_inviscid_total_energy(nodes,s_oneside,i,j)


          !viscid part
          !--------------------------------
          !DEC$ FORCEINLINE RECURSIVE
          viscid_flux(1) = 0.0d0
          
          !DEC$ FORCEINLINE RECURSIVE
          viscid_flux(2) = flux_y_viscid_momentum_x(nodes,s_oneside,i,j,dx,dy)
          
          !DEC$ FORCEINLINE RECURSIVE
          viscid_flux(3) = flux_y_viscid_momentum_y(nodes,s_oneside,i,j,dx,dy)
          
          !DEC$ FORCEINLINE RECURSIVE
          viscid_flux(4) = flux_y_viscid_total_energy(nodes,s_oneside,i,j,dx,dy)

          
          !capillarity part
          !--------------------------------
          !DEC$ FORCEINLINE RECURSIVE
          capillarity_flux(1) = 0.0d0
          
          !DEC$ FORCEINLINE RECURSIVE
          capillarity_flux(2) = flux_y_capillarity_momentum_x(nodes,s_oneside,i,j,dx,dy)
          
          !DEC$ FORCEINLINE RECURSIVE
          capillarity_flux(3) = flux_y_capillarity_momentum_y(nodes,s_oneside,i,j,dx,dy)
          
          !DEC$ FORCEINLINE RECURSIVE
          capillarity_flux(4) = flux_y_capillarity_total_energy(nodes,s_oneside,i,j,dx,dy)


          !total flux
          !--------------------------------
          flux_y(1) = inviscid_flux(1)
          flux_y(2) = inviscid_flux(2) - epsilon*viscid_flux(2) - zeta*capillarity_flux(2)
          flux_y(3) = inviscid_flux(3) - epsilon*viscid_flux(3) - zeta*capillarity_flux(3)
          flux_y(4) = inviscid_flux(4) - epsilon*viscid_flux(4) - zeta*capillarity_flux(4)
          
        end function compute_flux_y_by_parts


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> interface to compute the body forces
        !> acting on the cell
        !
        !> @date
        !> 23_09_2013 - initial version - J.L. Desmarais
        !
        !>@param field_used
        !> object encapsulating the main variables
        !
        !>@param body_forces
        !> body forces evaluated at (i,j)
        !--------------------------------------------------------------
        function compute_body_forces(t,x,y,nodes,k) result(body_forces)

          implicit none

          real(rkind)               , intent(in) :: t
          real(rkind)               , intent(in) :: x
          real(rkind)               , intent(in) :: y
          real(rkind), dimension(ne), intent(in) :: nodes
          integer                   , intent(in) :: k
          real(rkind)                            :: body_forces

          real(rkind) :: t_s,x_s,y_s

          if(gravity_choice.eq.earth_gravity_choice) then
             select case(k)
               case(1)
                  body_forces = 0
               case(2)
                  body_forces = 0
               case(3)
                  body_forces = -nodes(1)*gravity
               case(4)
                  body_forces = -nodes(3)*gravity
               case default
                  body_forces = 0
                  print '(''dim2d/pmodel_eq_class'')'
                  print '(''compute_body_forces'')'
                  stop '1=< k =<4 violated'
             end select

          else

             body_forces = 0

          end if

          t_s = t
          x_s = x
          y_s = y

        end function compute_body_forces


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> get the viscous constant
        !
        !> @date
        !> 12_12_2014 - initial version - J.L. Desmarais
        !
        !>@return viscous_coeff
        !> viscous coefficient: 1/Re
        !-------------------------------------------------------------
        function get_viscous_coeff() result(viscous_coeff)

          implicit none

          real(rkind) :: viscous_coeff

          viscous_coeff = epsilon

        end function get_viscous_coeff


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> interface to compute the body forces
        !> acting on the cell
        !
        !> @date
        !> 17_07_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> governing variables at the grid point location
        !
        !>@param velocity
        !> velocity vector at the grid point location
        !--------------------------------------------------------------
        function get_velocity(nodes) result(velocity)

          implicit none

          real(rkind), dimension(ne), intent(in) :: nodes
          real(rkind), dimension(2)              :: velocity

          velocity(1) = nodes(2)/nodes(1)
          velocity(2) = nodes(3)/nodes(1)

        end function get_velocity



        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> check whether the open boundary conditions
        !> are undermined at the grid point location
        !
        !> @date
        !> 17_07_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@param undermined
        !> check if the open boundary conditions are undermined
        !> at the grid point location
        !--------------------------------------------------------------
        function are_openbc_undermined(x_map,y_map,nodes) result(undermined)

          implicit none

          real(rkind), dimension(3)     , intent(in) :: x_map
          real(rkind), dimension(3)     , intent(in) :: y_map
          real(rkind), dimension(3,3,ne), intent(in) :: nodes
          logical                                    :: undermined

          real(rkind) :: P
          real(rkind) :: coeff

          real(rkind) :: dx,dy
          real(rkind) :: T
          real(rkind) :: md_liq, md_vap
          real(rkind) :: md_mid, md_liq_thr, md_vap_thr


          !test based on the speed of sound:
          !if it becomes imaginary, the openbc are undermined
          !--------------------------------------------------
          P = classical_pressure_local(nodes(2,2,:))

          if(rkind.eq.8) then
             coeff = P + nodes(2,2,1)**2*(-3.0d0+2.0d0*nodes(2,2,1))
          else
             coeff = P + nodes(2,2,1)**2*(-3.0+2.0*nodes(2,2,1))
          end if

          undermined = coeff.lt.0


          !test based on the mass density:
          !if the mass density is located inside the multi-
          !phase region, the openbc are set as undermined
          !1) compute temperature
          !2) deduce the mass densities of the saturated liquid
          !   and vapor phases
          !3) determine the threshold values for the mass-density
          !   to be inside the multi-phase region
          !--------------------------------------------------
          if((.not.undermined).and.bf_openbc_md_threshold_ac) then
             
             if(rkind.eq.8) then

                dx = 0.5d0*(x_map(3)-x_map(1))
                dy = 0.5d0*(y_map(3)-y_map(1))
                
                T = 3.0d0/(8.0d0*cv_r)*temperature_eff(
     $               nodes,2,2,
     $               dx,dy,
     $               gradient_x_interior,
     $               gradient_y_interior)

             else

                dx = 0.5*(x_map(3)-x_map(1))
                dy = 0.5*(y_map(3)-y_map(1))

                T = 3.0/(8.0*cv_r)*temperature_eff(
     $               nodes,2,2,
     $               dx,dy,
     $               gradient_x_interior,
     $               gradient_y_interior)

             end if

             md_liq = get_mass_density_liquid(T)
             md_vap = get_mass_density_vapor(T)

             md_mid     = 0.5d0*(md_vap+md_liq)
             md_vap_thr = md_vap+bf_openbc_md_threshold*(md_mid-md_vap)
             md_liq_thr = md_liq-bf_openbc_md_threshold*(md_liq-md_mid)

             undermined = (nodes(2,2,1).ge.md_vap_thr).and.
     $                    (nodes(2,2,1).le.md_liq_thr)

          end if

        end function are_openbc_undermined


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> get the governing variables imposed in the far field
        !
        !> @date
        !> 12_12_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> physical model
        !
        !>@param t
        !> time
        !
        !>@param x
        !> x-coordinate
        !
        !>@param y
        !> y-coordinate
        !
        !>@return var
        !> governing variables in the far-field
        !--------------------------------------------------------------
        function get_far_field(this,t,x,y) result(var)

          implicit none

          class(pmodel_eq)          , intent(in) :: this
          real(rkind)               , intent(in) :: t
          real(rkind)               , intent(in) :: x
          real(rkind)               , intent(in) :: y
          real(rkind), dimension(ne)             :: var

          var = this%initial_conditions%get_far_field(t,x,y)

        end function get_far_field


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> computation of the eigenvalues for the hyperbolic terms
        !> in the x-direction
        !
        !> @date
        !> 10_12_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@return eigenvalues
        !> eigenvalues at the location of the grid point
        !--------------------------------------------------------------
        function compute_x_eigenvalues(nodes) result(eigenvalues)

          implicit none

          real(rkind), dimension(ne), intent(in) :: nodes
          real(rkind), dimension(ne)             :: eigenvalues

          real(rkind) :: ux
          real(rkind) :: c

          ux = nodes(2)/nodes(1)
          c  = speed_of_sound(nodes)

          eigenvalues(1) = ux
          eigenvalues(2) = ux
          eigenvalues(3) = ux-c
          eigenvalues(4) = ux+c

        end function compute_x_eigenvalues


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> computation of the eigenvalues for the hyperbolic terms
        !> in the y-direction
        !
        !> @date
        !> 10_12_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@return eigenvalues
        !> eigenvalues at the location of the grid point
        !--------------------------------------------------------------
        function compute_y_eigenvalues(nodes) result(eigenvalues)

          implicit none

          real(rkind), dimension(ne), intent(in) :: nodes
          real(rkind), dimension(ne)             :: eigenvalues

          real(rkind) :: uy
          real(rkind) :: c

          uy = nodes(3)/nodes(1)
          c  = speed_of_sound(nodes)

          eigenvalues(1) = uy
          eigenvalues(2) = uy
          eigenvalues(3) = uy-c
          eigenvalues(4) = uy+c

        end function compute_y_eigenvalues


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> computation of the left eigenmatrix for the hyperbolic
        !> terms in the x-direction
        !
        !> @date
        !> 10_12_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@param k
        !> integer identifying the eigenvector
        !
        !>@return eigenvect
        !> left eigenmatrix
        !--------------------------------------------------------------
        function compute_x_lefteigenvector(nodes) result(eigenvect)

          implicit none

          real(rkind), dimension(ne), intent(in) :: nodes
          real(rkind), dimension(ne,ne)          :: eigenvect

          real(rkind), dimension(ne,ne) :: jacPrimCons
          real(rkind), dimension(ne,ne) :: leftEigenMPrim
          real(rkind)                   :: c
          real(rkind)                   :: q_c


          !computation of J, the jacobian matrix from primitive
          !to conservative variables
          jacPrimCons = compute_jacobian_prim_to_cons(nodes)


          !left eigenmatrix for the primitive
          !variables, L_p
          c   = speed_of_sound(nodes)
          q_c = 0.5d0*nodes(1)*c

          if(rkind.eq.8) then

             leftEigenMPrim(1,1) = 0.0d0
             leftEigenMPrim(2,1) = 0.0d0
             leftEigenMPrim(3,1) = 1.0d0
             leftEigenMPrim(4,1) = 0.0d0

             leftEigenMPrim(1,2) = 1.0d0
             leftEigenMPrim(2,2) = 0.0d0
             leftEigenMPrim(3,2) = 0.0d0
             leftEigenMPrim(4,2) =-1.0d0/c**2

             leftEigenMPrim(1,3) = 0.0d0
             leftEigenMPrim(2,3) =-q_c
             leftEigenMPrim(3,3) = 0.0d0
             leftEigenMPrim(4,3) = 0.5d0

             leftEigenMPrim(1,4) = 0.0d0
             leftEigenMPrim(2,4) = q_c
             leftEigenMPrim(3,4) = 0.0d0
             leftEigenMPrim(4,4) = 0.5d0

          else

             leftEigenMPrim(1,1) = 0.0
             leftEigenMPrim(2,1) = 0.0
             leftEigenMPrim(3,1) = 1.0
             leftEigenMPrim(4,1) = 0.0

             leftEigenMPrim(1,2) = 1.0
             leftEigenMPrim(2,2) = 0.0
             leftEigenMPrim(3,2) = 0.0
             leftEigenMPrim(4,2) =-1.0/c**2

             leftEigenMPrim(1,3) = 0.0
             leftEigenMPrim(2,3) =-q_c
             leftEigenMPrim(3,3) = 0.0
             leftEigenMPrim(4,3) = 0.5

             leftEigenMPrim(1,4) = 0.0
             leftEigenMPrim(2,4) = q_c
             leftEigenMPrim(3,4) = 0.0
             leftEigenMPrim(4,4) = 0.5

          end if

          !compute the left eigenmatrix by L = L_p.J
          eigenvect = MATMUL(jacPrimCons,leftEigenMPrim)

        end function compute_x_lefteigenvector


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> computation of the left eigenmatrixr for the hyperbolic
        !> terms in the x-direction
        !
        !> @date
        !> 10_12_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@return eigenvect
        !> right eigenmatrix
        !--------------------------------------------------------------
        function compute_x_righteigenvector(nodes) result(eigenvect)

          implicit none

          real(rkind), dimension(ne), intent(in) :: nodes
          real(rkind), dimension(ne,ne)          :: eigenvect


          real(rkind), dimension(ne,ne) :: jacConsPrim
          real(rkind), dimension(ne,ne) :: rightEigenMPrim
          real(rkind)                   :: c
          real(rkind)                   :: inv_c
          real(rkind)                   :: inv_q_c


          !computation of J, the jacobian matrix from conservative
          !to primitive variables
          jacConsPrim = compute_jacobian_cons_to_prim(nodes)


          !right eigenmatrix for the primitive
          !variables, R_p
          c       = speed_of_sound(nodes)
          inv_c   = 1.0d0/c**2
          inv_q_c = 1.0d0/(nodes(1)*c)

          if(rkind.eq.8) then

             rightEigenMPrim(1,1) = 0.0d0
             rightEigenMPrim(2,1) = 1.0d0
             rightEigenMPrim(3,1) = inv_c
             rightEigenMPrim(4,1) = inv_c
             
             rightEigenMPrim(1,2) = 0.0d0
             rightEigenMPrim(2,2) = 0.0d0
             rightEigenMPrim(3,2) =-inv_q_c
             rightEigenMPrim(4,2) = inv_q_c

             rightEigenMPrim(1,3) = 1.0d0
             rightEigenMPrim(2,3) = 0.0d0
             rightEigenMPrim(3,3) = 0.0d0
             rightEigenMPrim(4,3) = 0.0d0

             rightEigenMPrim(1,4) = 0.0d0
             rightEigenMPrim(2,4) = 0.0d0
             rightEigenMPrim(3,4) = 1.0d0
             rightEigenMPrim(4,4) = 1.0d0

          else

             rightEigenMPrim(1,1) = 0.0
             rightEigenMPrim(2,1) = 1.0
             rightEigenMPrim(3,1) = inv_c
             rightEigenMPrim(4,1) = inv_c
             
             rightEigenMPrim(1,2) = 0.0
             rightEigenMPrim(2,2) = 0.0
             rightEigenMPrim(3,2) =-inv_q_c
             rightEigenMPrim(4,2) = inv_q_c

             rightEigenMPrim(1,3) = 1.0
             rightEigenMPrim(2,3) = 0.0
             rightEigenMPrim(3,3) = 0.0
             rightEigenMPrim(4,3) = 0.0

             rightEigenMPrim(1,4) = 0.0
             rightEigenMPrim(2,4) = 0.0
             rightEigenMPrim(3,4) = 1.0
             rightEigenMPrim(4,4) = 1.0

          end if

          !right eigenmatrix computed as R = J.R_p
          eigenvect = MATMUL(rightEigenMPrim,jacConsPrim)

        end function compute_x_righteigenvector


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> computation of the left eigenmatrix for the hyperbolic
        !> terms in the y-direction
        !
        !> @date
        !> 10_12_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@return eigenvect
        !> left eigenmatrix
        !--------------------------------------------------------------
        function compute_y_lefteigenvector(nodes) result(eigenvect)

          implicit none

          real(rkind), dimension(ne), intent(in) :: nodes
          real(rkind), dimension(ne,ne)          :: eigenvect


          real(rkind), dimension(ne,ne) :: jacPrimCons
          real(rkind), dimension(ne,ne) :: leftEigenMPrim
          real(rkind)                   :: c


          !computation of J, the jacobian matrix from primitive
          !to conservative variables
          jacPrimCons = compute_jacobian_prim_to_cons(nodes)


          !left eigenmatrix for the primitive
          !variables, L_p
          c  = speed_of_sound(nodes)

          if(rkind.eq.8) then

             leftEigenMPrim(1,1) = 0.0d0
             leftEigenMPrim(2,1) = 1.0d0
             leftEigenMPrim(3,1) = 0.0d0
             leftEigenMPrim(4,1) = 0.0d0

             leftEigenMPrim(1,2) = 1.0d0
             leftEigenMPrim(2,2) = 0.0d0
             leftEigenMPrim(3,2) = 0.0d0
             leftEigenMPrim(4,2) =-1.0d0/c**2

             leftEigenMPrim(1,3) = 0.0d0
             leftEigenMPrim(2,3) = 0.0d0
             leftEigenMPrim(3,3) =-0.5d0*nodes(1)*c
             leftEigenMPrim(4,3) = 0.5d0

             leftEigenMPrim(1,4) = 0.0d0
             leftEigenMPrim(2,4) = 0.0d0
             leftEigenMPrim(3,4) = 0.5d0*nodes(1)*c
             leftEigenMPrim(4,4) = 0.5d0

          else

             leftEigenMPrim(1,1) = 0.0
             leftEigenMPrim(2,1) = 1.0
             leftEigenMPrim(3,1) = 0.0
             leftEigenMPrim(4,1) = 0.0

             leftEigenMPrim(1,2) = 1.0
             leftEigenMPrim(2,2) = 0.0
             leftEigenMPrim(3,2) = 0.0
             leftEigenMPrim(4,2) =-1.0/c**2

             leftEigenMPrim(1,3) = 0.0
             leftEigenMPrim(2,3) = 0.0
             leftEigenMPrim(3,3) =-0.5*nodes(1)*c
             leftEigenMPrim(4,3) = 0.5

             leftEigenMPrim(1,4) = 0.0
             leftEigenMPrim(2,4) = 0.0
             leftEigenMPrim(3,4) = 0.5*nodes(1)*c
             leftEigenMPrim(4,4) = 0.5

          end if


          !compute the left eigenmatrix by L = L_p.J
          eigenvect = MATMUL(jacPrimCons,leftEigenMPrim)

        end function compute_y_lefteigenvector


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> computation of the right eigenmatrix for the hyperbolic
        !> terms in the y-direction
        !
        !> @date
        !> 10_12_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@return eigenvalues
        !> right eigenmatrix
        !--------------------------------------------------------------
        function compute_y_righteigenvector(nodes) result(eigenvect)

          implicit none

          real(rkind), dimension(ne), intent(in) :: nodes
          real(rkind), dimension(ne,ne)          :: eigenvect


          real(rkind), dimension(ne,ne) :: jacConsPrim
          real(rkind), dimension(ne,ne) :: rightEigenMPrim
          real(rkind)                   :: c
          real(rkind)                   :: inv_q_c


          !computation of J, the jacobian matrix from conservative
          !to primitive variables
          jacConsPrim = compute_jacobian_cons_to_prim(nodes)


          !right eigenmatrix for the primitive
          !variables, R_p
          c   = speed_of_sound(nodes)
          inv_q_c = 1.0d0/(nodes(1)*c)

          if(rkind.eq.8) then

             rightEigenMPrim(1,1) = 0.0d0
             rightEigenMPrim(2,1) = 1.0d0
             rightEigenMPrim(3,1) = 1.0d0/c**2
             rightEigenMPrim(4,1) = 1.0d0/c**2

             rightEigenMPrim(1,2) = 1.0d0
             rightEigenMPrim(2,2) = 0.0d0
             rightEigenMPrim(3,2) = 0.0d0
             rightEigenMPrim(4,2) = 0.0d0

             rightEigenMPrim(1,3) = 0.0d0
             rightEigenMPrim(2,3) = 0.0d0
             rightEigenMPrim(3,3) =-inv_q_c
             rightEigenMPrim(4,3) = inv_q_c

             rightEigenMPrim(1,4) = 0.0d0
             rightEigenMPrim(2,4) = 0.0d0
             rightEigenMPrim(3,4) = 1.0d0
             rightEigenMPrim(4,4) = 1.0d0

          else

             rightEigenMPrim(1,1) = 0.0
             rightEigenMPrim(2,1) = 1.0
             rightEigenMPrim(3,1) = 1.0/c**2
             rightEigenMPrim(4,1) = 1.0/c**2

             rightEigenMPrim(1,2) = 1.0
             rightEigenMPrim(2,2) = 0.0
             rightEigenMPrim(3,2) = 0.0
             rightEigenMPrim(4,2) = 0.0

             rightEigenMPrim(1,3) = 0.0
             rightEigenMPrim(2,3) = 0.0
             rightEigenMPrim(3,3) =-inv_q_c
             rightEigenMPrim(4,3) = inv_q_c

             rightEigenMPrim(1,4) = 0.0
             rightEigenMPrim(2,4) = 0.0
             rightEigenMPrim(3,4) = 1.0
             rightEigenMPrim(4,4) = 1.0

          end if

          !right eigenmatrix computed as R = J.R_p
          eigenvect = MATMUL(rightEigenMPrim,jacConsPrim)

        end function compute_y_righteigenvector


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> computation of the transverse matrix in the x-direction
        !> if the convective part of the governing equations is
        !> written as
        !> \f$ \frac{\partial v}{\partial t} +
        !>    A^x_v \frac{\partial v}{\partial x} + 
        !>    A^y_v \frac{\partial v}{\partial y}
        !> \f$
        !> then the transverse matrix in the x-direction is
        !> \f$ A^y_p = J^v_p \cdot A^y_p \cdot J^p_v\f$
        !> where $J^v_p$ and $J^p_v$ are the Jacobian matrices
        !> and $A^y_p$ is the transverse matrix for the primitive
        !> variables
        !
        !> @date
        !> 10_12_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@return eigenvect
        !> transverse matrix in the x-direction
        !--------------------------------------------------------------
        function compute_x_transM(nodes) result(eigenvect)

          implicit none

          real(rkind), dimension(ne), intent(in) :: nodes
          real(rkind), dimension(ne,ne)          :: eigenvect


          real(rkind), dimension(ne,ne) :: jacConsPrim
          real(rkind), dimension(ne,ne) :: jacPrimCons
          real(rkind), dimension(ne,ne) :: xTransMPrim

          real(rkind)                   :: uy
          real(rkind)                   :: c


          !computation of J, the jacobian matrix from conservative
          !to primitive variables
          jacConsPrim = compute_jacobian_cons_to_prim(nodes)
          jacPrimCons = compute_jacobian_prim_to_cons(nodes)


          !transverse matrix for the primitive variables
          uy = nodes(3)/nodes(1)         !velocity_y
          c  = speed_of_sound(nodes)     !speed of sound
          

          if(rkind.eq.8) then

             xTransMPrim(1,1) = uy
             xTransMPrim(2,1) = 0.0d0
             xTransMPrim(3,1) = nodes(1)
             xTransMPrim(4,1) = 0.0d0

             xTransMPrim(1,2) = 0.0d0
             xTransMPrim(2,2) = uy
             xTransMPrim(3,2) = 0.0d0
             xTransMPrim(4,2) = 0.0d0

             xTransMPrim(1,3) = 0.0d0
             xTransMPrim(2,3) = 0.0d0
             xTransMPrim(3,3) = uy
             xTransMPrim(4,3) = 1.0d0/nodes(1)

             xTransMPrim(1,4) = 0.0d0
             xTransMPrim(2,4) = 0.0d0
             xTransMPrim(3,4) = c**2*nodes(1)
             xTransMPrim(4,4) = uy

          else
             
             xTransMPrim(1,1) = uy
             xTransMPrim(2,1) = 0.0
             xTransMPrim(3,1) = nodes(1)
             xTransMPrim(4,1) = 0.0

             xTransMPrim(1,2) = 0.0
             xTransMPrim(2,2) = uy
             xTransMPrim(3,2) = 0.0
             xTransMPrim(4,2) = 0.0

             xTransMPrim(1,3) = 0.0
             xTransMPrim(2,3) = 0.0
             xTransMPrim(3,3) = uy
             xTransMPrim(4,3) = 1.0/nodes(1)

             xTransMPrim(1,4) = 0.0
             xTransMPrim(2,4) = 0.0
             xTransMPrim(3,4) = c**2*nodes(1)
             xTransMPrim(4,4) = uy

          end if

          !transverse matrix computed as A^y_v = J^v_p.A^y_p.J^p_v
          eigenvect = MATMUL(MATMUL(jacPrimCons,xTransMPrim),jacConsPrim)

        end function compute_x_transM


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> computation of the transverse matrix in the x-direction
        !> if the convective part of the governing equations is
        !> written as
        !> \f$ \frac{\partial v}{\partial t} +
        !>    A_x \frac{\partial v}{\partial x} + 
        !>    A_y \frac{\partial v}{\partial y}
        !> \f$
        !> then the transverse matrix in the y-direction is
        !> \f$ A^x_p = J^v_p \cdot A^x_p \cdot J^p_v\f$
        !> where $J^v_p$ and $J^p_v$ are the Jacobian matrices
        !> and $A^x_p$ is the transverse matrix for the primitive
        !> variables
        !
        !> @date
        !> 10_12_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@return eigenvect
        !> transverse matrix in the y-direction
        !--------------------------------------------------------------
        function compute_y_transM(nodes) result(eigenvect)

          implicit none

          real(rkind), dimension(ne), intent(in) :: nodes
          real(rkind), dimension(ne,ne)          :: eigenvect


          real(rkind), dimension(ne,ne) :: jacConsPrim
          real(rkind), dimension(ne,ne) :: jacPrimCons
          real(rkind), dimension(ne,ne) :: yTransMPrim

          real(rkind)                   :: ux
          real(rkind)                   :: c


          !computation of J, the jacobian matrix from conservative
          !to primitive variables
          jacConsPrim = compute_jacobian_cons_to_prim(nodes)
          jacPrimCons = compute_jacobian_prim_to_cons(nodes)


          !transverse matrix for the primitive variables
          ux = nodes(2)/nodes(1)         !velocity_x
          c  = speed_of_sound(nodes)     !speed of sound
          

          if(rkind.eq.8) then
             
             yTransMPrim(1,1) = ux
             yTransMPrim(2,1) = nodes(1)
             yTransMPrim(3,1) = 0.0d0
             yTransMPrim(4,1) = 0.0d0

             yTransMPrim(1,2) = 0.0d0
             yTransMPrim(2,2) = ux
             yTransMPrim(3,2) = 0.0d0
             yTransMPrim(4,2) = 1.0d0/nodes(1)

             yTransMPrim(1,3) = 0.0d0
             yTransMPrim(2,3) = 0.0d0
             yTransMPrim(3,3) = ux
             yTransMPrim(4,3) = 0.0d0

             yTransMPrim(1,4) = 0.0d0
             yTransMPrim(2,4) = c**2*nodes(1)
             yTransMPrim(3,4) = 0.0d0
             yTransMPrim(4,4) = ux

          else
             
             yTransMPrim(1,1) = ux
             yTransMPrim(2,1) = nodes(1)
             yTransMPrim(3,1) = 0.0
             yTransMPrim(4,1) = 0.0

             yTransMPrim(1,2) = 0.0
             yTransMPrim(2,2) = ux
             yTransMPrim(3,2) = 0.0
             yTransMPrim(4,2) = 1.0/nodes(1)

             yTransMPrim(1,3) = 0.0
             yTransMPrim(2,3) = 0.0
             yTransMPrim(3,3) = ux
             yTransMPrim(4,3) = 0.0

             yTransMPrim(1,4) = 0.0
             yTransMPrim(2,4) = c**2*nodes(1)
             yTransMPrim(3,4) = 0.0
             yTransMPrim(4,4) = ux

          end if

          !transverse matrix computed as A^x_v = J^v_p.A^x_p.J^p_v
          eigenvect = MATMUL(MATMUL(jacPrimCons,yTransMPrim),jacConsPrim)

        end function compute_y_transM


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> computation of the left LODI conservative matrix in the
        !> x-direction
        !
        !> @date
        !> 11_12_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@return eigenvect
        !> conservative LODI matrix in the x-direction
        !--------------------------------------------------------------
        function compute_x_leftConsLodiM(nodes) result(eigenvect)

          implicit none

          real(rkind), dimension(ne), intent(in) :: nodes
          real(rkind), dimension(ne,ne)          :: eigenvect


          real(rkind), dimension(ne,ne) :: jacPrimCons
          real(rkind), dimension(ne,ne) :: leftLodiM

          real(rkind)                   :: c
          real(rkind)                   :: q_c


          !computation of J, the jacobian matrix from primitive
          !to conservative variables
          jacPrimCons = compute_jacobian_prim_to_cons(nodes)


          !left LODI matrix for the primitive variables
          c   = speed_of_sound(nodes)     !speed of sound
          q_c = nodes(1)*c
          

          if(rkind.eq.8) then

             leftLodiM(1,1) = 0.0d0
             leftLodiM(2,1) = 0.0d0
             leftLodiM(3,1) = 1.0d0
             leftLodiM(4,1) = 0.0d0

             leftLodiM(1,2) = c**2
             leftLodiM(2,2) = 0.0d0
             leftLodiM(3,2) = 0.0d0
             leftLodiM(4,2) =-1.0d0

             leftLodiM(1,3) = 0.0d0
             leftLodiM(2,3) =-q_c
             leftLodiM(3,3) = 0.0d0
             leftLodiM(4,3) = 1.0d0

             leftLodiM(1,4) = 0.0d0
             leftLodiM(2,4) = q_c
             leftLodiM(3,4) = 0.0d0
             leftLodiM(4,4) = 1.0d0

          else
             
             leftLodiM(1,1) = 0.0
             leftLodiM(2,1) = 0.0
             leftLodiM(3,1) = 1.0
             leftLodiM(4,1) = 0.0

             leftLodiM(1,2) = c**2
             leftLodiM(2,2) = 0.0
             leftLodiM(3,2) = 0.0
             leftLodiM(4,2) =-1.0

             leftLodiM(1,3) = 0.0
             leftLodiM(2,3) =-q_c
             leftLodiM(3,3) = 0.0
             leftLodiM(4,3) = 1.0

             leftLodiM(1,4) = 0.0
             leftLodiM(2,4) = q_c
             leftLodiM(3,4) = 0.0
             leftLodiM(4,4) = 1.0

          end if

          !conservative LODI matrix computed as N^x_L = M^x_L.J^p_v
          eigenvect = MATMUL(jacPrimCons,leftLodiM)

        end function compute_x_leftConsLodiM


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> computation of the left LODI conservative matrix in the
        !> y-direction
        !
        !> @date
        !> 11_12_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@return eigenvect
        !> conservative LODI matrix in the y-direction
        !--------------------------------------------------------------
        function compute_y_leftConsLodiM(nodes) result(eigenvect)

          implicit none

          real(rkind), dimension(ne), intent(in) :: nodes
          real(rkind), dimension(ne,ne)          :: eigenvect


          real(rkind), dimension(ne,ne) :: jacPrimCons
          real(rkind), dimension(ne,ne) :: leftLodiM

          real(rkind)                   :: c
          real(rkind)                   :: q_c


          !computation of J, the jacobian matrix from primitive
          !to conservative variables
          jacPrimCons = compute_jacobian_prim_to_cons(nodes)


          !left LODI matrix for the primitive variables
          c   = speed_of_sound(nodes)     !speed of sound
          q_c = nodes(1)*c
          

          if(rkind.eq.8) then

             leftLodiM(1,1) = 0.0d0
             leftLodiM(2,1) = 1.0d0
             leftLodiM(3,1) = 0.0d0
             leftLodiM(4,1) = 0.0d0

             leftLodiM(1,2) = c**2
             leftLodiM(2,2) = 0.0d0
             leftLodiM(3,2) = 0.0d0
             leftLodiM(4,2) =-1.0d0

             leftLodiM(1,3) = 0.0d0
             leftLodiM(2,3) = 0.0d0
             leftLodiM(3,3) =-q_c
             leftLodiM(4,3) = 1.0d0

             leftLodiM(1,4) = 0.0d0
             leftLodiM(2,4) = 0.0d0
             leftLodiM(3,4) = q_c
             leftLodiM(4,4) = 1.0d0

          else
             
             leftLodiM(1,1) = 0.0
             leftLodiM(2,1) = 1.0
             leftLodiM(3,1) = 0.0
             leftLodiM(4,1) = 0.0

             leftLodiM(1,2) = c**2
             leftLodiM(2,2) = 0.0
             leftLodiM(3,2) = 0.0
             leftLodiM(4,2) =-1.0

             leftLodiM(1,3) = 0.0
             leftLodiM(2,3) = 0.0
             leftLodiM(3,3) =-q_c
             leftLodiM(4,3) = 1.0

             leftLodiM(1,4) = 0.0
             leftLodiM(2,4) = 0.0
             leftLodiM(3,4) = q_c
             leftLodiM(4,4) = 1.0

          end if

          !conservative LODI matrix computed as N^y_L = M^y_L.J^p_v
          eigenvect = MATMUL(jacPrimCons,leftLodiM)

        end function compute_y_leftConsLodiM


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> interface for the computation of the gradient of the
        !> governing variables in the x-direction
        !
        !> @date
        !> 01_08_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@param i
        !> integer identifying the index in the x-direction
        !
        !>@param j
        !> integer identifying the index in the y-direction
        !
        !>@param gradient
        !> procedure used to compute the gradient along the x-axis
        !
        !>@param dx
        !> grid space step along the x-axis
        !
        !>@return grad_var
        !> gradient of the governing variables along the x-axis
        !--------------------------------------------------------------
        function compute_x_gradient(nodes,i,j,gradient,dx) result(grad_var)

          implicit none

          real(rkind), dimension(:,:,:), intent(in) :: nodes
          integer(ikind)               , intent(in) :: i
          integer(ikind)               , intent(in) :: j
          procedure(gradient_x_proc)                :: gradient
          real(rkind)                  , intent(in) :: dx
          real(rkind), dimension(ne)                :: grad_var

          grad_var(1) = gradient(nodes,i,j,mass_density,dx)
          grad_var(2) = gradient(nodes,i,j,momentum_x  ,dx)
          grad_var(3) = gradient(nodes,i,j,momentum_y  ,dx)
          grad_var(4) = gradient(nodes,i,j,total_energy,dx)

        end function compute_x_gradient


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> interface for the computation of the gradient of the
        !> governing variables in the y-direction 
        !
        !> @date
        !> 01_08_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@param i
        !> integer identifying the index in the x-direction
        !
        !>@param j
        !> integer identifying the index in the y-direction
        !
        !>@param gradient
        !> procedure used to compute the gradient along the y-axis
        !
        !>@param dy
        !> grid space step along the y-axis
        !
        !>@return grad_var
        !> gradient of the governing variables along the x-axis
        !--------------------------------------------------------------
        function compute_y_gradient(nodes,i,j,gradient,dy) result(grad_var)

          implicit none

          real(rkind), dimension(:,:,:), intent(in) :: nodes
          integer(ikind)               , intent(in) :: i
          integer(ikind)               , intent(in) :: j
          procedure(gradient_y_proc)                :: gradient
          real(rkind)                  , intent(in) :: dy
          real(rkind), dimension(ne)                :: grad_var

          grad_var(1) = gradient(nodes,i,j,mass_density,dy)
          grad_var(2) = gradient(nodes,i,j,momentum_x  ,dy)
          grad_var(3) = gradient(nodes,i,j,momentum_y  ,dy)
          grad_var(4) = gradient(nodes,i,j,total_energy,dy)

        end function compute_y_gradient


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> interface for the computation of the gradient of the
        !> governing variables in the n-direction (either (x-y)
        !> or (x+y) direction depending on the procedure passed)
        !
        !> @date
        !> 10_12_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@param i
        !> integer identifying the index in the x-direction
        !
        !>@param j
        !> integer identifying the index in the y-direction
        !
        !>@param gradient
        !> procedure used to compute the gradient along the y-axis
        !
        !>@param dx
        !> grid space step along the x-axis
        !
        !>@param dy
        !> grid space step along the y-axis
        !
        !>@return grad_var
        !> gradient of the governing variables along the x-axis
        !--------------------------------------------------------------
        function compute_n_gradient(nodes,i,j,gradient,dx,dy) result(grad_var)

          implicit none

          real(rkind), dimension(:,:,:), intent(in) :: nodes
          integer(ikind)               , intent(in) :: i
          integer(ikind)               , intent(in) :: j
          procedure(gradient_n_proc)                :: gradient
          real(rkind)                  , intent(in) :: dx
          real(rkind)                  , intent(in) :: dy
          real(rkind), dimension(ne)                :: grad_var

          grad_var(1) = gradient(nodes,i,j,mass_density,dx,dy)
          grad_var(2) = gradient(nodes,i,j,momentum_x  ,dx,dy)
          grad_var(3) = gradient(nodes,i,j,momentum_y  ,dx,dy)
          grad_var(4) = gradient(nodes,i,j,total_energy,dx,dy)

        end function compute_n_gradient

      end module pmodel_eq_class
