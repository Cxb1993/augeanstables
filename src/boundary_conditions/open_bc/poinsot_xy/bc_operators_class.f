      !> @file
      !> class encapsulating subroutines to apply open boundary
      !> conditions at the edge of the computational domain using
      !> lodi boundary conditions
      !
      !> @author 
      !> Julien L. Desmarais
      !
      !> @brief
      !> class encapsulating subroutines to apply open boundary
      !> conditions at the edge of the computational domain using
      !> lodi boundary conditions
      !
      !> @date
      !> 13_08_2014 - initial version - J.L. Desmarais
      !-----------------------------------------------------------------
      module bc_operators_class

        use bc_operators_default_class, only :
     $     bc_operators_default

        use lodi_inflow_class, only :
     $       lodi_inflow

        use lodi_outflow_class, only :
     $       lodi_outflow

        use lodi_xy_module, only :
     $       compute_timedev_xlayer,
     $       compute_timedev_ylayer,
     $       compute_timedev_corner_W,
     $       compute_timedev_corner_E

        use interface_primary, only :
     $       gradient_x_proc,
     $       gradient_y_proc

        use openbc_operators_module, only :
     $       compute_fluxes_at_the_edges_2ndorder,
     $       inflow_left,
     $       inflow_right

        use pmodel_eq_class, only :
     $       pmodel_eq

        use parameters_constant, only :
     $       bc_timedev_choice,
     $       left,
     $       right

        use parameters_input, only :
     $       nx,ny,ne,bc_size,
     $       obc_type_N,
     $       obc_type_S,
     $       obc_type_E,
     $       obc_type_W

        use parameters_kind, only :
     $       rkind,ikind

        use sd_operators_fd_module, only :
     $       gradient_x_x_oneside_L0,
     $       gradient_x_x_oneside_L1,
     $       gradient_x_x_oneside_R1,
     $       gradient_x_x_oneside_R0,
     $       gradient_y_y_oneside_L0,
     $       gradient_y_y_oneside_L1,
     $       gradient_y_y_oneside_R1,
     $       gradient_y_y_oneside_R0

        use sd_operators_x_oneside_L0_class, only :
     $       sd_operators_x_oneside_L0

        use sd_operators_x_oneside_L1_class, only :
     $       sd_operators_x_oneside_L1

        use sd_operators_x_oneside_R1_class, only :
     $       sd_operators_x_oneside_R1

        use sd_operators_x_oneside_R0_class, only :
     $       sd_operators_x_oneside_R0

        use sd_operators_y_oneside_L0_class, only :
     $       sd_operators_y_oneside_L0

        use sd_operators_y_oneside_L1_class, only :
     $       sd_operators_y_oneside_L1

        use sd_operators_y_oneside_R1_class, only :
     $       sd_operators_y_oneside_R1

        use sd_operators_y_oneside_R0_class, only :
     $       sd_operators_y_oneside_R0

        
        implicit none


        private
        public :: bc_operators


        !> @class bc_operators
        !> class encapsulating subroutines to apply
        !> open boundary conditions in the x and
        !> y directions at the edge of the computational
        !> domain
        !
        !> @param ini
        !> initialize the bcx_type and bcy_type
        !> attributes of the boundary conditions
        !
        !> @param apply_bc_on_timedev
        !> apply the open boundary conditions for the time derivatives
        !---------------------------------------------------------------
        type, extends(bc_operators_default) :: bc_operators

          type(lodi_inflow)  :: inflow_bc
          type(lodi_outflow) :: outflow_bc

          integer :: oneside_flow_N
          integer :: oneside_flow_S
          integer :: oneside_flow_E
          integer :: oneside_flow_W

          contains

          procedure, pass :: ini
          procedure, pass :: apply_bc_on_timedev => apply_bc_on_timedev_2ndorder

        end type bc_operators        
      

        contains

        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> subroutine initializing the main attributes
        !> of the boundary conditions
        !
        !> @date
        !> 13_08_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> boundary conditions initialized
        !
        !>@param p_model
        !> physical model to know the type of the main variables
        !--------------------------------------------------------------
        subroutine ini(this,p_model)
        
          implicit none

          class(bc_operators), intent(inout) :: this
          type(pmodel_eq)    , intent(in)    :: p_model
          
          integer :: neq

          neq = p_model%get_eq_nb()

          this%bcx_type = bc_timedev_choice
          this%bcy_type = bc_timedev_choice

          call this%inflow_bc%ini()
          call this%outflow_bc%ini()

          this%oneside_flow_N = obc_type_N
          this%oneside_flow_S = obc_type_S
          this%oneside_flow_E = obc_type_E
          this%oneside_flow_W = obc_type_W

        end subroutine ini


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> subroutine applying the boundary conditions
        !> on the time derivatives with space operators
        !> that are 2nd order accurate in the interior
        !> and 1st order accurate at the boundary
        !
        !> @date
        !> 13_08_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array of grid point data
        !
        !>@param dx
        !> space step along the x-axis
        !
        !>@param dy
        !> space step along the y-axis
        !
        !>@param p_model
        !> governing equations of the physical model
        !
        !>@param flux_x
        !> fluxes along the x-direction
        !
        !>@param flux_y
        !> fluxes along the y-direction
        !
        !>@param timedev
        !> time derivatives
        !-------------------------------------------------------------
        subroutine apply_bc_on_timedev_2ndorder(
     $     this,
     $     p_model,
     $     t,nodes,x_map,y_map,
     $     flux_x,flux_y,
     $     timedev)
        
          implicit none
        
          class(bc_operators)               , intent(in)    :: this
          type(pmodel_eq)                   , intent(in)    :: p_model
          real(rkind)                       , intent(in)    :: t
          real(rkind), dimension(nx,ny,ne)  , intent(in)    :: nodes
          real(rkind), dimension(nx)        , intent(in)    :: x_map
          real(rkind), dimension(ny)        , intent(in)    :: y_map
          real(rkind), dimension(nx+1,ny,ne), intent(inout) :: flux_x
          real(rkind), dimension(nx,ny+1,ne), intent(inout) :: flux_y
          real(rkind), dimension(nx,ny,ne)  , intent(inout) :: timedev


          type(sd_operators_x_oneside_L0) :: s_x_L0
          type(sd_operators_x_oneside_L1) :: s_x_L1
          type(sd_operators_x_oneside_R1) :: s_x_R1
          type(sd_operators_x_oneside_R0) :: s_x_R0
          type(sd_operators_y_oneside_L0) :: s_y_L0
          type(sd_operators_y_oneside_L1) :: s_y_L1
          type(sd_operators_y_oneside_R1) :: s_y_R1
          type(sd_operators_y_oneside_R0) :: s_y_R0


          real(rkind)    :: dx,dy
          integer(ikind) :: i,j


          dx = x_map(2) - x_map(1)
          dy = y_map(2) - y_map(1)


          !compute the fluxes at the edge of the computational
          !domain
          call compute_fluxes_at_the_edges_2ndorder(
     $         nodes, dx, dy,
     $         s_x_L0, s_x_L1, s_x_R1, s_x_R0,
     $         s_y_L0, s_y_L1, s_y_R1, s_y_R0,
     $         p_model,
     $         flux_x, flux_y)


          !apply the boundary conditions on the south layer
          j=1
          call compute_timedev_corner_W(
     $         p_model,
     $         t, nodes, x_map, y_map, j,
     $         left,
     $         gradient_y_y_oneside_L0,
     $         this%inflow_bc,
     $         this%outflow_bc,
     $         inflow_left,
     $         this%oneside_flow_W,
     $         this%oneside_flow_S,
     $         timedev)

          call compute_timedev_ylayer(
     $         p_model,
     $         t, nodes, x_map, y_map, j,
     $         flux_x,
     $         left,
     $         gradient_y_y_oneside_L0,
     $         this%inflow_bc,
     $         this%outflow_bc,
     $         inflow_left,
     $         this%oneside_flow_S,
     $         timedev)

          call compute_timedev_corner_E(
     $         p_model,
     $         t, nodes, x_map, y_map, j,
     $         left,
     $         gradient_y_y_oneside_L0,
     $         this%inflow_bc,
     $         this%outflow_bc,
     $         inflow_left,
     $         this%oneside_flow_E,
     $         this%oneside_flow_S,
     $         timedev)


          j=2
          call compute_timedev_corner_W(
     $         p_model,
     $         t, nodes, x_map, y_map, j,
     $         left,
     $         gradient_y_y_oneside_L1,
     $         this%inflow_bc,
     $         this%outflow_bc,
     $         inflow_left,
     $         this%oneside_flow_W,
     $         this%oneside_flow_S,
     $         timedev)

          call compute_timedev_ylayer(
     $         p_model,
     $         t, nodes, x_map, y_map, j,
     $         flux_x,
     $         left,
     $         gradient_y_y_oneside_L1,
     $         this%inflow_bc,
     $         this%outflow_bc,
     $         inflow_left,
     $         this%oneside_flow_S,
     $         timedev)

          call compute_timedev_corner_E(
     $         p_model,
     $         t, nodes, x_map, y_map, j,
     $         left,
     $         gradient_y_y_oneside_L1,
     $         this%inflow_bc,
     $         this%outflow_bc,
     $         inflow_left,
     $         this%oneside_flow_E,
     $         this%oneside_flow_S,
     $         timedev)


          !apply the boundary conditions on the west and east
          !layers
          do j=bc_size+1, ny-bc_size

             i=1
             call compute_timedev_xlayer(
     $            p_model,
     $            t, nodes, x_map, y_map, i,j,
     $            flux_y,
     $            left,
     $            gradient_x_x_oneside_L0,
     $            this%inflow_bc,
     $            this%outflow_bc,
     $            inflow_left,
     $            this%oneside_flow_W,
     $            timedev)

             i=bc_size
             call compute_timedev_xlayer(
     $            p_model,
     $            t, nodes, x_map, y_map, i,j,
     $            flux_y,
     $            left,
     $            gradient_x_x_oneside_L1,
     $            this%inflow_bc,
     $            this%outflow_bc,
     $            inflow_left,
     $            this%oneside_flow_W,
     $            timedev)

             i=nx-1
             call compute_timedev_xlayer(
     $            p_model,
     $            t, nodes, x_map, y_map, i,j,
     $            flux_y,
     $            right,
     $            gradient_x_x_oneside_R1,
     $            this%inflow_bc,
     $            this%outflow_bc,
     $            inflow_right,
     $            this%oneside_flow_E,
     $            timedev)

             i=nx
             call compute_timedev_xlayer(
     $            p_model,
     $            t, nodes, x_map, y_map, i,j,
     $            flux_y,
     $            right,
     $            gradient_x_x_oneside_R0,
     $            this%inflow_bc,
     $            this%outflow_bc,
     $            inflow_right,
     $            this%oneside_flow_E,
     $            timedev)

          end do


          !apply the boundary conditions on the north layer
          j=ny-1
          call compute_timedev_corner_W(
     $         p_model,
     $         t, nodes, x_map, y_map, j,
     $         right,
     $         gradient_y_y_oneside_R1,
     $         this%inflow_bc,
     $         this%outflow_bc,
     $         inflow_right,
     $         this%oneside_flow_W,
     $         this%oneside_flow_N,
     $         timedev)

          call compute_timedev_ylayer(
     $         p_model,
     $         t, nodes, x_map, y_map, j,
     $         flux_x,
     $         right,
     $         gradient_y_y_oneside_R1,
     $         this%inflow_bc,
     $         this%outflow_bc,
     $         inflow_right,
     $         this%oneside_flow_N,
     $         timedev)

          call compute_timedev_corner_E(
     $         p_model,
     $         t, nodes, x_map, y_map, j,
     $         right,
     $         gradient_y_y_oneside_R1,
     $         this%inflow_bc,
     $         this%outflow_bc,
     $         inflow_right,
     $         this%oneside_flow_E,
     $         this%oneside_flow_N,
     $         timedev)

          j=ny
          call compute_timedev_corner_W(
     $         p_model,
     $         t, nodes, x_map, y_map, j,
     $         right,
     $         gradient_y_y_oneside_R0,
     $         this%inflow_bc,
     $         this%outflow_bc,
     $         inflow_right,
     $         this%oneside_flow_W,
     $         this%oneside_flow_N,
     $         timedev)

          call compute_timedev_ylayer(
     $         p_model,
     $         t, nodes, x_map, y_map, j,
     $         flux_x,
     $         right,
     $         gradient_y_y_oneside_R0,
     $         this%inflow_bc,
     $         this%outflow_bc,
     $         inflow_right,
     $         this%oneside_flow_N,
     $         timedev)

          call compute_timedev_corner_E(
     $         p_model,
     $         t, nodes, x_map, y_map, j,
     $         right,
     $         gradient_y_y_oneside_R0,
     $         this%inflow_bc,
     $         this%outflow_bc,
     $         inflow_right,
     $         this%oneside_flow_E,
     $         this%oneside_flow_N,
     $         timedev)
        
        end subroutine apply_bc_on_timedev_2ndorder        

      end module bc_operators_class