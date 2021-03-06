      !> @file
      !> class encapsulating subroutines to compute
      !> the wave governing equations in 2D
      !
      !> @author 
      !> Julien L. Desmarais
      !
      !> @brief
      !> class encapsulating subroutines to compute
      !> the wave governing equations in 2D
      !
      !> @date
      !> 28_07_2014 - initial version - J.L. Desmarais
      !-----------------------------------------------------------------
      module pmodel_eq_class
      
        use interface_primary, only :
     $       gradient_proc

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
     $       vector_x,
     $       vector_y,
     $       peak,
     $       negative_spot,
     $       sincos,
     $       no_wave_forcing,
     $       oscillatory_forcing,
     $       intermittent_oscillatory_forcing,
     $       moving_oscillatory_forcing,
     $       obc_eigenqties_bc,
     $       obc_eigenqties_lin

        use parameters_input, only :
     $       nx,ny,ne,
     $       bc_size,
     $       ic_choice,
     $       wave_forcing,
     $       obc_eigenqties_strategy

        use parameters_kind, only :
     $       ikind,
     $       rkind

        use pmodel_eq_default_class, only :
     $       pmodel_eq_default

        use sd_operators_class, only :
     $       sd_operators

c$$$        use wave2d_ncoords_module, only :
c$$$     $       compute_n_eigenvalues_wave2d,
c$$$     $       compute_n1_lefteigenvector_wave2d,
c$$$     $       compute_n1_righteigenvector_wave2d,
c$$$     $       compute_n2_lefteigenvector_wave2d,
c$$$     $       compute_n2_righteigenvector_wave2d,
c$$$     $       compute_n1_transM_wave2d,
c$$$     $       compute_n2_transM_wave2d

        use wave2d_parameters, only :
     $       c,
     $       c_x,
     $       c_y,
     $       epsilon,
     $       x_center,
     $       y_center,
     $       amplitude,
     $       period,
     $       amplitude_force,
     $       period_force,
     $       x_center_force,
     $       y_center_force,
     $       period_intermittent,
     $       velocity_center_force

        use wave2d_prim_module, only :
     $       position,
     $       velocity_x,
     $       velocity_y,
     $       velocity_n1,
     $       velocity_n2
        
        implicit none

        private
        public :: pmodel_eq, peak


        !> @class pmodel_eq
        !> class encapsulating operators to compute
        !> the wave governing equations in 2D
        !>
        !> @param get_model_name
        !> get the name of the physical model
        !>
        !> @param get_var_name
        !> get the name of the main variables
        !> (position, x-velocity, y-velocity)
        !>
        !> @param get_var_longname
        !> get the description of the main variables for the
        !> governing equations of the physical model
        !>
        !> @param get_var_unit
        !> get the units of the main variables
        !>
        !> @param get_var_types
        !> get the type of the main variables
        !> (scalar, vector-x, vector-y)
        !>
        !> @param get_eq_nb
        !> get the number of governing equations: 3
        !>
        !> @param apply_initial_conditions
        !> initialize the main variables
        !>
        !> @param compute_fluxes
        !> compute the fluxes along the x- and y-axis
        !
        !> @param compute_body_forces
        !> compute the forcing term
        !
        !> @param are_openbc_undermined
        !> check whether the open boundary conditions are undermined
        !> at the grid point location
        !---------------------------------------------------------------
        type, extends(pmodel_eq_default) :: pmodel_eq
          
          contains


          !description of the model
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


          !flux computation
          procedure, nopass :: compute_flux_x
          procedure, nopass :: compute_flux_y
          procedure, nopass :: compute_flux_x_nopt
          procedure, nopass :: compute_flux_y_nopt
          procedure, nopass :: compute_flux_x_oneside
          procedure, nopass :: compute_flux_y_oneside
          procedure, nopass :: compute_body_forces


          !field extension for openb b.c.
          procedure, nopass :: get_velocity
          procedure, nopass :: are_openbc_undermined
          procedure,   pass :: get_far_field
          procedure,   pass :: get_prim_obc_eigenqties


          !computations with primitive variables
          procedure, nopass :: compute_prim_var => compute_var
          procedure, nopass :: compute_cons_var => compute_var
          
          procedure, nopass :: compute_jacobian_prim_to_cons => compute_identity_matrix
          procedure, nopass :: compute_jacobian_cons_to_prim => compute_identity_matrix

          procedure, nopass :: compute_x_transM_prim
          procedure, nopass :: compute_y_transM_prim

          procedure, nopass :: compute_x_eigenvalues_prim
          procedure, nopass :: compute_y_eigenvalues_prim

          procedure, nopass :: compute_x_lefteigenvector_prim
          procedure, nopass :: compute_x_righteigenvector_prim
          procedure, nopass :: compute_y_lefteigenvector_prim
          procedure, nopass :: compute_y_righteigenvector_prim

          procedure, nopass :: compute_gradient_prim


          !variables in the rotated frame
          procedure, nopass :: compute_xy_to_n_var
          procedure, nopass :: compute_n_to_xy_var

        end type pmodel_eq


        contains

        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> interface to get the name of the physical model
        !
        !> @date
        !> 28_07_2014 - initial version - J.L. Desmarais
        !
        !>@param model_name
        !> character giving the name of the model
        !---------------------------------------------------------------
        function get_model_name() result(model_name)

          implicit none

          character(len=10) :: model_name

          model_name="Wave2D"

        end function get_model_name
        
        
        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> get the name of the main variables
        !
        !> @date
        !> 28_07_2014 - initial version - J.L. Desmarais
        !
        !>@param var_name
        !> characters giving the variable names
        !---------------------------------------------------------------
        function get_var_name() result(var_pties)

          implicit none

          character(len=10), dimension(ne) :: var_pties

          var_pties(1)="position"
          var_pties(2)="velocity_x"
          var_pties(3)="velocity_y"

        end function get_var_name
        
        
        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> get the name of the main variables
        !
        !> @date
        !> 28_07_2014 - initial version - J.L. Desmarais
        !
        !>@param var_name
        !> characters giving the variable names
        !---------------------------------------------------------------
        function get_var_longname() result(var_pties)

          implicit none

          character(len=33), dimension(ne) :: var_pties

          var_pties(1)="position"
          var_pties(2)="velocity along x-axis"
          var_pties(3)="velocity along y-axis"

        end function get_var_longname


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> get the units of the main variables
        !
        !> @date
        !> 28_07_2014 - initial version - J.L. Desmarais
        !
        !>@param var_name
        !> characters giving the variable units
        !---------------------------------------------------------------
        function get_var_unit() result(var_pties)

          implicit none

          character(len=23), dimension(ne) :: var_pties

          var_pties(1)= "m/m"
          var_pties(2)= "(m/s)/(m/s)"
          var_pties(3)= "(m/s)/(m/s)"

        end function get_var_unit


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> interface to get the type of the main variables
        !> (scalar, vector_x, vector_y, scalar)
        !
        !> @date
        !> 28_07_2014 - initial version - J.L. Desmarais
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

        end function get_var_type


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> get the simulation parameters
        !
        !> @date
        !> 10_11_2014 - initial version - J.L. Desmarais
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


          allocate(param_name(12))
          allocate(param_value(12))

          param_name(1)  = 'c'
          param_name(2)  = 'c_x'
          param_name(3)  = 'c_y'
          param_name(4)  = 'epsilon'
                         
          param_name(5)  = 'amplitude'
          param_name(6)  = 'period'
          param_name(7)  = 'x_center'
          param_name(8)  = 'y_center'

          param_name(9)  = 'amp_force'
          param_name(10) = 'per_force'
          param_name(11) = 'x_c_force'
          param_name(12) = 'y_c_force'

          param_value(1)  = c
          param_value(2)  = c_x
          param_value(3)  = c_y
          param_value(4)  = epsilon
          param_value(5)  = amplitude
          param_value(6)  = period  
          param_value(7)  = x_center
          param_value(8)  = y_center
          param_value(9)  = amplitude_force
          param_value(10) = period_force  
          param_value(11) = x_center_force
          param_value(12) = y_center_force

        end subroutine get_sim_parameters
        
        
        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> get the number of main variables
        !> in the governing equations: 4
        !
        !> @date
        !> 28_07_2014 - initial version - J.L. Desmarais
        !
        !>@param eq_nb
        !> number of governing equations
        !---------------------------------------------------------------
        function get_eq_nb() result(eq_nb)
          implicit none
          integer :: eq_nb
          eq_nb=3
        end function get_eq_nb


        function get_sd_pattern_flux_x(operator_type) result(pattern)

          implicit none

          integer, intent(in)     :: operator_type
          integer, dimension(2,2) :: pattern

          
          select case(operator_type)
            case(sd_interior_type)
               pattern = reshape((/
     $              -1,-1,1,1/),
     $              (/2,2/))

            case(sd_L0_type,
     $           sd_L1_type,
     $           sd_R1_type,
     $           sd_R0_type)
               pattern = reshape((/
     $              -1,0,1,0/),
     $              (/2,2/))

            case(sd_L0_n_type,
     $           sd_L1_n_type,
     $           sd_R1_n_type,
     $           sd_R0_n_type)

               pattern = reshape((/
     $           -1,-1,1,1/),
     $           (/2,2/))

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
     $              -1,-1,1,1/),
     $              (/2,2/))
            case(sd_L0_type,
     $           sd_L1_type,
     $           sd_R1_type,
     $           sd_R0_type)
               pattern = reshape((/
     $              0,-1,0,1/),
     $              (/2,2/))

            case(sd_L0_n_type,
     $           sd_L1_n_type,
     $           sd_R1_n_type,
     $           sd_R0_n_type)

               pattern = reshape((/
     $              -1,-1,1,1/),
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
        !> 28_07_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@param x_map
        !> array with the x-ccordinates
        !
        !>@param nodes
        !> array with the y-coordinates
        !---------------------------------------------------------------
        subroutine apply_ic(this,nodes,x_map,y_map)

          implicit none

          class(pmodel_eq)             , intent(in)    :: this
          real(rkind), dimension(:,:,:), intent(inout) :: nodes
          real(rkind), dimension(:)    , intent(in)    :: x_map
          real(rkind), dimension(:)    , intent(in)    :: y_map


          
          integer :: neq

          neq = this%get_eq_nb()


          select case(ic_choice)

            case(peak)
               call apply_peak_ic(
     $              nodes,
     $              x_map,
     $              y_map)

            case(negative_spot)
               call apply_negative_spot_ic(
     $              nodes,
     $              x_map,
     $              y_map)

            case(sincos)
               call apply_sincos_ic(
     $              nodes,
     $              x_map,
     $              y_map)

            case default
               print '(''pmodel_eq_class'')'
               print '(''apply_ic'')'
               print '(''case not recognized: '',I2)', ic_choice
               stop ''

          end select

        end subroutine apply_ic


        subroutine apply_peak_ic(nodes,x_map,y_map)

          implicit none

          real(rkind), dimension(:,:,:), intent(inout) :: nodes
          real(rkind), dimension(:)    , intent(in)    :: x_map
          real(rkind), dimension(:)    , intent(in)    :: y_map


          integer(ikind) :: i,j

          if(rkind.eq.8) then

             do j=1, size(y_map,1)
                do i=1, size(x_map,1)

                   nodes(i,j,1) = peak_ic(amplitude,
     $                                 period,
     $                                 x_map(i)-x_center,
     $                                 y_map(j)-y_center)
                   nodes(i,j,2) = 0.0d0
                   nodes(i,j,3) = 0.0d0
                   
                end do
             end do
             
          else
             
             do j=1, size(y_map,1)
                do i=1, size(x_map,1)

                   nodes(i,j,1) = peak_ic(amplitude,
     $                                 period,
     $                                 x_map(i)-x_center,
     $                                 y_map(j)-y_center)
                   nodes(i,j,2) = 0.0
                   nodes(i,j,3) = 0.0
                   
                end do
             end do
             
          end if

        end subroutine apply_peak_ic


        subroutine apply_sincos_ic(nodes,x_map,y_map)

          implicit none

          real(rkind), dimension(:,:,:), intent(inout) :: nodes
          real(rkind), dimension(:)    , intent(in)    :: x_map
          real(rkind), dimension(:)    , intent(in)    :: y_map


          integer(ikind) :: i,j
          real(rkind)    :: x,y

          
          do j=1, size(y_map,1)

             y = y_map(j)/10.0d0*(2.0d0*ACOS(-1.0d0))

             do i=1,size(x_map,1)

                x = x_map(i)/10.0d0*(2.0d0*ACOS(-1.0d0))

                nodes(i,j,1) = SIN(x)*SIN(y)
                nodes(i,j,2) = COS(x)*SIN(y)
                nodes(i,j,3) = SIN(x)*COS(y)

             end do

          end do

        end subroutine apply_sincos_ic


        subroutine apply_negative_spot_ic(nodes,x_map,y_map)

          implicit none

          real(rkind), dimension(:,:,:), intent(inout) :: nodes
          real(rkind), dimension(:)    , intent(in)    :: x_map
          real(rkind), dimension(:)    , intent(in)    :: y_map
          
          real(rkind) :: x_center, y_center
          real(rkind) :: radius_spot
          real(rkind) :: interface_spot
          real(rkind) :: interior_spot, outside_spot
        
          integer(ikind) :: i,j
          real(rkind)    :: x1,y1
          
          x_center = 0.0d0
          y_center = 0.0d0
          
          radius_spot    = 9.25d0
          interface_spot = 0.5d0

          interior_spot = -5.0
          outside_spot  =  1.0
             
             
          do j=1, size(y_map,1)
             do i=1, size(x_map,1)
                
                x1 = x_map(i)-x_center
                y1 = y_map(j)-y_center

                nodes(i,j,1) = spot_ic(
     $               radius_spot,
     $               interface_spot,
     $               interior_spot,
     $               outside_spot,
     $               x1,y1)
                nodes(i,j,2) = spot_ic(
     $               radius_spot,
     $               interface_spot,
     $               0.0d0,
     $               c**2*x1/(SQRT(x1**2+y1**2)),
     $               x1,y1)
                nodes(i,j,3) = spot_ic(
     $               radius_spot,
     $               interface_spot,
     $               0.0d0,
     $               c**2*y1/(SQRT(x1**2+y1**2)),
     $               x1,y1)
                
             end do
          end do
          
        end subroutine apply_negative_spot_ic


        function spot_ic(
     $     radius_spot,
     $     interface_spot,
     $     interior_spot,
     $     outside_spot,
     $     x,y)

          implicit none

          real(rkind), intent(in) :: radius_spot
          real(rkind), intent(in) :: interface_spot
          real(rkind), intent(in) :: interior_spot
          real(rkind), intent(in) :: outside_spot
          real(rkind), intent(in) :: x
          real(rkind), intent(in) :: y
          real(rkind)             :: spot_ic


          real(rkind) :: r

          r = SQRT(x**2+y**2)

          spot_ic =
     $         0.5d0*(outside_spot+interior_spot) +
     $         0.5d0*(outside_spot-interior_spot)*TANH(
     $         (r-radius_spot)/(2.0d0*interface_spot))

        end function spot_ic



        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute the peak needed for the initial conditions
        !> of the wave 2d
        !
        !> @date
        !> 28_07_2014 - initial version - J.L. Desmarais
        !
        !>@param amplitude
        !> amplitude of the peak
        !
        !>@param period
        !> characteristic size for the compact support of the peak
        !
        !>@param x
        !> x-coordinate identifying where the initial condition is
        !> evaluated
        !
        !>@param y
        !> y-coordinate identifying where the initial condition is
        !> evaluated
        !---------------------------------------------------------------
        function peak_ic(amplitude, period, x, y)

          implicit none

          real(rkind), intent(in) :: amplitude
          real(rkind), intent(in) :: period
          real(rkind), intent(in) :: x
          real(rkind), intent(in) :: y
          real(rkind)             :: peak_ic


          real(rkind) :: radius
          real(rkind) :: radius_max
          real(rkind) :: omega
          

          radius = Sqrt(x**2+y**2)

          if(rkind.eq.8) then

             radius_max = period/2.0d0
             omega      = 2.0d0*ACOS(-1.0d0)/period

             if(radius.le.radius_max) then
                peak_ic = amplitude*(1.0d0 + cos(omega*radius))
             else
                peak_ic = 0.0d0                
             end if

          else

             radius_max = period/2.0
             omega      = 2.0*ACOS(-1.0)/period

             if(radius.le.radius_max) then
                peak_ic = amplitude*(1.0 + cos(omega*radius))
             else
                peak_ic = 0.0
             end if
             
          end if

        end function peak_ic
        
        
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

          integer     :: i,j
          real(rkind) :: dy_s

          dy_s = dy

          !<fluxes along the x-axis
          do j=bc_size+1, ny-bc_size
             do i=bc_size+1, nx+1-bc_size

                flux_x(i,j,1) = - c**2*s%f(nodes,i,j,velocity_x)
     $                          - epsilon*s%dfdx(nodes,i,j,position,dx)

                flux_x(i,j,2) = - c**2*s%f(nodes,i,j,position)
     $                          - epsilon*s%dfdx(nodes,i,j,velocity_x,dx)

                flux_x(i,j,3) = - c_x*s%f(nodes,i,j,velocity_y)
     $                          - epsilon*s%dfdx(nodes,i,j,velocity_y,dx)

             end do
          end do

        end function compute_flux_x


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

          integer     :: i,j
          real(rkind) :: dx_s

          dx_s = dx


          !<fluxes along the x-axis
          do j=bc_size+1, ny+1-bc_size
             do i=bc_size+1, nx-bc_size

                flux_y(i,j,1) = - c**2*s%g(nodes,i,j,velocity_y)
     $                          - epsilon*s%dgdy(nodes,i,j,position,dy)

                flux_y(i,j,2) = - c_y*s%g(nodes,i,j,velocity_x)
     $                          - epsilon*s%dgdy(nodes,i,j,velocity_x,dy)

                flux_y(i,j,3) = - c**2*s%g(nodes,i,j,position)
     $                          - epsilon*s%dgdy(nodes,i,j,velocity_y,dy)

             end do
          end do

        end function compute_flux_y


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
          real(rkind)    :: dy_s

          dy_s = dy

          !<fluxes along the x-axis
          do j=y_borders(1), y_borders(2)
             !DEC$ IVDEP
             do i=x_borders(1), x_borders(2)+1

                if((grdpts_id(i,j).eq.interior_pt).or.
     $               (grdpts_id(i,j).eq.bc_interior_pt)) then

                   flux_x(i,j,1) = - c**2*s%f(nodes,i,j,velocity_x)
     $                             - epsilon*s%dfdx(nodes,i,j,position,dx)

                   flux_x(i,j,2) = - c**2*s%f(nodes,i,j,position)
     $                             - epsilon*s%dfdx(nodes,i,j,velocity_x,dx)

                   flux_x(i,j,3) = - c_x*s%f(nodes,i,j,velocity_y)
     $                             - epsilon*s%dfdx(nodes,i,j,velocity_y,dx)

                end if

             end do
          end do

        end subroutine compute_flux_x_nopt


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
          real(rkind)    :: dx_s

          dx_s = dx

          !<fluxes along the y-axis
          do j=y_borders(1), y_borders(2)+1
             !DEC$ IVDEP
             do i=x_borders(1), x_borders(2)

                 if((grdpts_id(i,j).eq.interior_pt).or.
     $               (grdpts_id(i,j).eq.bc_interior_pt)) then

                   flux_y(i,j,1) = - c**2*s%g(nodes,i,j,velocity_y)
     $                             - epsilon*s%dgdy(nodes,i,j,position,dy)

                   flux_y(i,j,2) = - c_y*s%g(nodes,i,j,velocity_x)
     $                             - epsilon*s%dgdy(nodes,i,j,velocity_x,dy)

                   flux_y(i,j,3) = - c**2*s%g(nodes,i,j,position)
     $                             - epsilon*s%dgdy(nodes,i,j,velocity_y,dy)

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

          real(rkind) :: dy_s

          dy_s = dy

          !<fluxes along the x-axis
          flux_x(1) = - c**2*s_oneside%f(nodes,i,j,velocity_x)
     $                - epsilon*s_oneside%dfdx(nodes,i,j,position,dx)

          flux_x(2) = - c**2*s_oneside%f(nodes,i,j,position)
     $                - epsilon*s_oneside%dfdx(nodes,i,j,velocity_x,dx)
          
          flux_x(3) = - c_x*s_oneside%f(nodes,i,j,velocity_y)
     $                - epsilon*s_oneside%dfdx(nodes,i,j,velocity_y,dx)

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

          real(rkind) :: dx_s

          dx_s = dx


          !<fluxes along the x-axis
          flux_y(1) = - c**2*s_oneside%g(nodes,i,j,velocity_y)
     $                - epsilon*s_oneside%dgdy(nodes,i,j,position,dy)
          
          flux_y(2) = - c_y*s_oneside%g(nodes,i,j,velocity_x)
     $                - epsilon*s_oneside%dgdy(nodes,i,j,velocity_x,dy)
          
          flux_y(3) = - c**2*s_oneside%g(nodes,i,j,position)
     $                - epsilon*s_oneside%dgdy(nodes,i,j,velocity_y,dy)

        end function compute_flux_y_oneside


        function compute_body_forces(t,x,y,nodes,k,prim) result(body_forces)

          implicit none

          real(rkind)               , intent(in) :: t
          real(rkind)               , intent(in) :: x
          real(rkind)               , intent(in) :: y
          real(rkind), dimension(ne), intent(in) :: nodes
          integer                   , intent(in) :: k
          real(rkind)                            :: body_forces
          logical, optional         , intent(in) :: prim

          logical :: prim_op

          real(rkind) :: omega
          real(rkind) :: node_s
          real(rkind) :: t2

          real(rkind) :: x_center
          real(rkind) :: y_center          

          if(present(prim)) then
             prim_op = prim
          end if


          select case(wave_forcing)

            case(no_wave_forcing)

               body_forces = 0


            case(oscillatory_forcing)

               if(k.eq.1) then
                  omega       = 2.0d0*ACOS(-1.0d0)/period_force
                  body_forces = peak_ic(
     $                 amplitude_force*SIN(omega*t),
     $                 period,
     $                 x-x_center_force,
     $                 y-y_center_force)
               else
                  body_forces = 0
               end if


            case(intermittent_oscillatory_forcing)

               if(k.eq.1) then

                  t2 = t - nint(t/(period_force+period_intermittent))*
     $                 (period_force+period_intermittent)

                  if(t2.lt.period_force) then
                  
                     omega = 2.0d0*ACOS(-1.0d0)/period_force
                     body_forces = peak_ic(
     $                    amplitude_force*SIN(omega*t),
     $                    period,
     $                    x-x_center_force,
     $                    y-y_center_force)

                  else
                     body_forces = 0
                  end if

               else
                  body_forces = 0
               end if


            case(moving_oscillatory_forcing)
               
               x_center = velocity_center_force*t
               y_center = y_center_force

               if(k.eq.1) then

                  omega = 2.0d0*ACOS(-1.0d0)/period_force
                  body_forces = peak_ic(
     $                 amplitude_force*SIN(omega*t),
     $                 period,
     $                 x-x_center,
     $                 y-y_center)

               else
                  body_forces = 0
               end if


            case default
               print '(''pmodel_eq_class'')'
               print '(''apply_ic'')'
               print '(''wave_forcing not recognized: '', I2)', wave_forcing
               stop ''

          end select

          node_s = nodes(1)

        end function compute_body_forces


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

          velocity(1) = nodes(2)
          velocity(2) = nodes(3)

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

          real(rkind) :: node_s, dx_s, dy_s

          !real(rkind) :: d_liq, d_vap
          !
          !d_liq = 1.1-0.05*(1.1-0.1)
          !d_vap = 0.1+0.05*(1.1-0.1)
          !
          !if((nodes(1).ge.d_vap).and.(nodes(1).le.d_liq)) then
          !   undermined = .true.
          !else
          !   undermined = .false.
          !end if

          !node_s = nodes(1)

          undermined = (nodes(2,2,1).lt.0)
          !undermined = .false.

          node_s = nodes(2,2,1)
          dx_s   = x_map(2)-x_map(1)
          dy_s   = y_map(2)-y_map(1)

        end function are_openbc_undermined


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> nodes_in = nodes_out
        !
        !> @date
        !> 05_02_2015 - initial version - J.L. Desmarais
        !
        !>@param nodes_in
        !> array with the grid point data
        !
        !>@return nodes_out
        !> array with the grid point data
        !--------------------------------------------------------------
        function compute_var(nodes_in) result(nodes_out)

          implicit none

          real(rkind), dimension(ne), intent(in) :: nodes_in
          real(rkind), dimension(ne)             :: nodes_out

          nodes_out = nodes_in

        end function compute_var


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> nodes_in = nodes_out
        !
        !> @date
        !> 05_02_2015 - initial version - J.L. Desmarais
        !
        !>@param nodes_in
        !> array with the grid point data
        !
        !>@return nodes_out
        !> array with the grid point data
        !--------------------------------------------------------------
        function compute_identity_matrix(nodes_prim_extended)
     $     result(matrix)

          implicit none

          real(rkind), dimension(ne+1) , intent(in) :: nodes_prim_extended
          real(rkind), dimension(ne,ne)             :: matrix

          real(rkind) :: node_s

          node_s = nodes_prim_extended(1)

          matrix = reshape((/
     $         1,0,0,
     $         0,1,0,
     $         0,0,1/),
     $         (/ne,ne/))

        end function compute_identity_matrix


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> computation of the transverse matrix in the x-direction
        !
        !> @date
        !> 13_11_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@return eigenvect
        !> transverse matrix in the x-direction
        !--------------------------------------------------------------
        function compute_x_transM_prim(nodes_prim_extended) result(matrix)

          implicit none

          real(rkind), dimension(ne+1) , intent(in) :: nodes_prim_extended
          real(rkind), dimension(ne,ne)             :: matrix

          real(rkind) :: node_s

          node_s = nodes_prim_extended(1)

          if(rkind.eq.8) then

             matrix(1,1) = 0.0d0
             matrix(2,1) = 0.0d0
             matrix(3,1) = -c**2

             matrix(1,2) = 0.0d0
             matrix(2,2) = 0.0d0
             matrix(3,2) = 0.0d0

             matrix(1,3) = -c**2
             matrix(2,3) = 0.0d0
             matrix(3,3) = 0.0d0

          else

             matrix(1,1) = 0.0
             matrix(2,1) = 0.0
             matrix(3,1) = -c**2

             matrix(1,2) = 0.0
             matrix(2,2) = 0.0
             matrix(3,2) = 0.0

             matrix(1,3) = -c**2
             matrix(2,3) = 0.0
             matrix(3,3) = 0.0

          end if

        end function compute_x_transM_prim


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> computation of the transverse matrix in the y-direction
        !
        !> @date
        !> 13_11_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@return eigenvect
        !> transverse matrix in the y-direction
        !--------------------------------------------------------------
        function compute_y_transM_prim(nodes_prim_extended) result(matrix)

          implicit none

          real(rkind), dimension(ne+1) , intent(in) :: nodes_prim_extended
          real(rkind), dimension(ne,ne)             :: matrix

          real(rkind) :: node_s

          node_s = nodes_prim_extended(1)

          if(rkind.eq.8) then

             matrix(1,1) = 0.0d0
             matrix(2,1) = -c**2
             matrix(3,1) = 0.0d0

             matrix(1,2) = -c**2
             matrix(2,2) = 0.0d0
             matrix(3,2) = 0.0d0

             matrix(1,3) = 0.0d0
             matrix(2,3) = 0.0d0
             matrix(3,3) = 0.0d0

          else

             matrix(1,1) = 0.0
             matrix(2,1) = -c**2
             matrix(3,1) = 0.0

             matrix(1,2) = -c**2
             matrix(2,2) = 0.0
             matrix(3,2) = 0.0

             matrix(1,3) = 0.0
             matrix(2,3) = 0.0
             matrix(3,3) = 0.0

          end if

        end function compute_y_transM_prim


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> computation of the eigenvalues for the hyperbolic terms
        !> in the x-direction
        !
        !> @date
        !> 01_08_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@return eigenvalues
        !> eigenvalues at the location of the grid point
        !--------------------------------------------------------------
        function compute_x_eigenvalues_prim(nodes_prim_extended) result(vector)

          implicit none

          real(rkind), dimension(ne+1), intent(in) :: nodes_prim_extended
          real(rkind), dimension(ne)               :: vector


          real(rkind) :: node_s

          node_s = nodes_prim_extended(1)

          if(rkind.eq.8) then
             vector(1) = 0.0d0
          else
             vector(1) = 0.0
          end if
          vector(2) = -c**2
          vector(3) =  c**2

        end function compute_x_eigenvalues_prim


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> computation of the eigenvalues for the hyperbolic terms
        !> in the y-direction
        !
        !> @date
        !> 01_08_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@return vector
        !> vector at the location of the grid point
        !--------------------------------------------------------------
        function compute_y_eigenvalues_prim(nodes_prim_extended) result(vector)

          implicit none

          real(rkind), dimension(ne+1), intent(in) :: nodes_prim_extended
          real(rkind), dimension(ne)               :: vector

          real(rkind) :: node_s

          node_s = nodes_prim_extended(1)

          if(rkind.eq.8) then
             vector(1) = 0.0d0
          else
             vector(1) = 0.0
          end if
          vector(2) = -c**2
          vector(3) =  c**2

        end function compute_y_eigenvalues_prim


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> computation of the left eigenvectors for the hyperbolic terms
        !> in the x-direction
        !
        !> @date
        !> 01_08_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@return eigenvalues
        !> eigenvectors at the location of the grid point
        !--------------------------------------------------------------
        function compute_x_lefteigenvector_prim(nodes_prim_extended) result(matrix)

          implicit none

          real(rkind), dimension(ne+1) , intent(in) :: nodes_prim_extended
          real(rkind), dimension(ne,ne)             :: matrix


          real(rkind) :: node_s

          node_s = nodes_prim_extended(1)


          if(rkind.eq.8) then
             matrix(1,1) =  0.0d0
             matrix(2,1) =  0.0d0
             matrix(3,1) =  1.0d0
                               
             matrix(1,2) =  0.5d0
             matrix(2,2) =  0.5d0
             matrix(3,2) =  0.0d0
             
             matrix(1,3) = -0.5d0
             matrix(2,3) =  0.5d0
             matrix(3,3) =  0.0d0
             
          else
             matrix(1,1) =  0.0
             matrix(2,1) =  0.0
             matrix(3,1) =  1.0
                               
             matrix(1,2) =  0.5
             matrix(2,2) =  0.5
             matrix(3,2) =  0.0

             matrix(1,3) = -0.5
             matrix(2,3) =  0.5
             matrix(3,3) =  0.0

          end if

        end function compute_x_lefteigenvector_prim


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> computation of the right eigenvectors for the hyperbolic terms
        !> in the x-direction
        !
        !> @date
        !> 01_08_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@return eigenvect
        !> eigenvectors at the location of the grid point
        !--------------------------------------------------------------
        function compute_x_righteigenvector_prim(nodes_prim_extended) result(matrix)

          implicit none

          real(rkind), dimension(ne+1) , intent(in) :: nodes_prim_extended
          real(rkind), dimension(ne,ne)             :: matrix


          real(rkind) :: node_s

          node_s = nodes_prim_extended(1)

          if(rkind.eq.8) then
             matrix(1,1) =  0.0d0
             matrix(2,1) =  1.0d0
             matrix(3,1) = -1.0d0
             
             matrix(1,2) =  0.0d0
             matrix(2,2) =  1.0d0
             matrix(3,2) =  1.0d0
                               
             matrix(1,3) =  1.0d0
             matrix(2,3) =  0.0d0
             matrix(3,3) =  0.0d0
             
          else
             matrix(1,1) =  0.0
             matrix(2,1) =  1.0
             matrix(3,1) = -1.0
             
             matrix(1,2) =  0.0
             matrix(2,2) =  1.0
             matrix(3,2) =  1.0
                               
             matrix(1,3) =  1.0
             matrix(2,3) =  0.0
             matrix(3,3) =  0.0

          end if

        end function compute_x_righteigenvector_prim


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> computation of the left eigenvectors for the hyperbolic terms
        !> in the x-direction
        !
        !> @date
        !> 01_08_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@return eigenvect
        !> eigenvectors at the location of the grid point
        !--------------------------------------------------------------
        function compute_y_lefteigenvector_prim(nodes_prim_extended)
     $     result(matrix)

          implicit none

          real(rkind), dimension(ne+1) , intent(in) :: nodes_prim_extended
          real(rkind), dimension(ne,ne)             :: matrix


          real(rkind) :: node_s

          node_s = nodes_prim_extended(1)


          if(rkind.eq.8) then

             matrix(1,1) =  0.0d0
             matrix(2,1) =  1.0d0
             matrix(3,1) =  0.0d0
                               
             matrix(1,2) =  0.5d0
             matrix(2,2) =  0.0d0
             matrix(3,2) =  0.5d0

             matrix(1,3) = -0.5d0
             matrix(2,3) =  0.0d0
             matrix(3,3) =  0.5d0

          else

             matrix(1,1) =  0.0
             matrix(2,1) =  1.0
             matrix(3,1) =  0.0
                               
             matrix(1,2) =  0.5
             matrix(2,2) =  0.0
             matrix(3,2) =  0.5

             matrix(1,3) = -0.5
             matrix(2,3) =  0.0
             matrix(3,3) =  0.5

          end if

        end function compute_y_lefteigenvector_prim


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> computation of the right eigenvector for the hyperbolic terms
        !> in the x-direction
        !
        !> @date
        !> 01_08_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@return eigenvect
        !> eigenvectors at the location of the grid point
        !--------------------------------------------------------------
        function compute_y_righteigenvector_prim(nodes_prim_extended)
     $     result(matrix)

          implicit none

          real(rkind), dimension(ne+1) , intent(in) :: nodes_prim_extended
          real(rkind), dimension(ne,ne)             :: matrix


          real(rkind) :: node_s

          node_s = nodes_prim_extended(1)

          if(rkind.eq.8) then

             matrix(1,1) =  0.0d0
             matrix(2,1) =  1.0d0
             matrix(3,1) = -1.0d0

             matrix(1,2) =  1.0d0
             matrix(2,2) =  0.0d0
             matrix(3,2) =  0.0d0
                               
             matrix(1,3) =  0.0d0
             matrix(2,3) =  1.0d0
             matrix(3,3) =  1.0d0

          else

             matrix(1,1) =  0.0
             matrix(2,1) =  1.0
             matrix(3,1) = -1.0

             matrix(1,2) =  1.0
             matrix(2,2) =  0.0
             matrix(3,2) =  0.0
                               
             matrix(1,3) =  0.0
             matrix(2,3) =  1.0
             matrix(3,3) =  1.0

          end if

        end function compute_y_righteigenvector_prim


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
        function compute_gradient_prim(nodes,i,j,gradient,dn,use_n_dir)
     $     result(grad_var)

          implicit none

          real(rkind), dimension(:,:,:), intent(in) :: nodes
          integer(ikind)               , intent(in) :: i
          integer(ikind)               , intent(in) :: j
          procedure(gradient_proc)                  :: gradient
          real(rkind)                  , intent(in) :: dn
          logical    , optional        , intent(in) :: use_n_dir
          real(rkind), dimension(ne)                :: grad_var


          logical :: use_n_dir_op


          if(present(use_n_dir)) then
             use_n_dir_op = use_n_dir
          else
             use_n_dir_op = .false.
          end if


          if(use_n_dir_op) then
             
             grad_var(1) = gradient(nodes,i,j,position   ,dn)
             grad_var(2) = gradient(nodes,i,j,velocity_n1,dn)
             grad_var(3) = gradient(nodes,i,j,velocity_n2,dn)

          else

             grad_var(1) = gradient(nodes,i,j,position  ,dn)
             grad_var(2) = gradient(nodes,i,j,velocity_x,dn)
             grad_var(3) = gradient(nodes,i,j,velocity_y,dn)

          end if

        end function compute_gradient_prim


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> computation of the transverse matrix in the y-direction
        !
        !> @date
        !> 13_11_2014 - initial version - J.L. Desmarais
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

          integer     :: neq
          real(rkind) :: t_s
          
          neq = this%get_eq_nb()
          t_s = t

          select case(ic_choice)
            case(peak,sincos)
               if(rkind.eq.8) then
                  var(1) = 0.0d0
                  var(2) = 0.0d0
                  var(3) = 0.0d0
               else
                  var(1) = 0.0
                  var(2) = 0.0
                  var(3) = 0.0
               end if

            case(negative_spot)
               
               if(rkind.eq.8) then
                  var(1) = 1.0d0
                  var(2) = c**2*x/(SQRT(x**2+y**2))
                  var(3) = c**2*y/(SQRT(x**2+y**2))
               else
                  var(1) = 1.0
                  var(2) = c**2*x/(SQRT(x**2+y**2))
                  var(3) = c**2*y/(SQRT(x**2+y**2))
               end if

            case default
               print '(''pmodel_eq_class'')'
               print '(''get_far_field'')'
               print '(''ic_choice not recognized: '',I2)', ic_choice
               stop ''
          end select

        end function get_far_field


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> determine the grid points used to evaluate
        !> the eigenquantities at the edge of the
        !> computational domain
        !
        !> @date
        !> 02_02_2015 - initial version - J.L. Desmarais
        !
        !>@param this
        !> physical model
        !
        !>@param t
        !> time
        !
        !>@param x
        !> x-coordinate of the grid points at the boundary
        !
        !>@param y
        !> y-coordinate of the grid points at the boundary
        !
        !>@param nodes_bc
        !> array with the grid point data at the boundary
        !
        !>@param nodes_bc
        !> array with the grid point data at the boundary
        !
        !>@param nodes_bc
        !> array with the grid point data at the boundary
        !
        !>@param nodes_eigenqties
        !> grid points used to evaluate the eigenquantities at the
        !> boundary
        !--------------------------------------------------------------
        function get_prim_obc_eigenqties(
     $     this,t,x,y,nodes_bc)
     $     result(nodes_prim_extended)

          implicit none

          class(pmodel_eq)            , intent(in) :: this
          real(rkind)                 , intent(in) :: t
          real(rkind)                 , intent(in) :: x
          real(rkind)                 , intent(in) :: y
          real(rkind), dimension(ne)  , intent(in) :: nodes_bc
          real(rkind), dimension(ne+1)             :: nodes_prim_extended


          select case(obc_eigenqties_strategy)

            case(obc_eigenqties_bc)
               nodes_prim_extended(1:ne) = nodes_bc

            case(obc_eigenqties_lin)
               nodes_prim_extended(1:ne) = this%get_far_field(t,x,y)

           case default
               print '(''wave2d/pmodel_eq_class'')'
               print '(''get_nodes_obc_eigenqties'')'
               print '(''obc_eigenqties_strategy not recognized'')'
               print '(''obc_eigenqties_strategy: '',I2)', obc_eigenqties_strategy
               stop ''

          end select


        end function get_prim_obc_eigenqties


        function compute_xy_to_n_var(nodes) result(nodes_n)

          implicit none

          real(rkind), dimension(ne), intent(in) :: nodes
          real(rkind), dimension(ne)             :: nodes_n

          if(rkind.eq.8) then
             nodes_n(1) = nodes(1)
             nodes_n(2) = 0.5d0*Sqrt(2.0d0)*(nodes(2)-nodes(3))
             nodes_n(3) = 0.5d0*Sqrt(2.0d0)*(nodes(2)+nodes(3))
          else
             nodes_n(1) = nodes(1)
             nodes_n(2) = 0.5*Sqrt(2.0)*(nodes(2)-nodes(3))
             nodes_n(3) = 0.5*Sqrt(2.0)*(nodes(2)+nodes(3))
          end if

        end function compute_xy_to_n_var


        function compute_n_to_xy_var(nodes_n) result(nodes)

          implicit none

          real(rkind), dimension(ne), intent(in) :: nodes_n
          real(rkind), dimension(ne)             :: nodes

          if(rkind.eq.8) then
             nodes(1) = nodes_n(1)
             nodes(2) = 0.5d0*Sqrt(2.0d0)*(nodes_n(2)+nodes_n(3))
             nodes(3) = 0.5d0*Sqrt(2.0d0)*(nodes_n(3)-nodes_n(2))
          else
             nodes(1) = nodes_n(1)
             nodes(2) = 0.5d0*Sqrt(2.0d0)*(nodes_n(2)+nodes_n(3))
             nodes(3) = 0.5d0*Sqrt(2.0d0)*(nodes_n(3)-nodes_n(2))
          end if

        end function compute_n_to_xy_var

      end module pmodel_eq_class
