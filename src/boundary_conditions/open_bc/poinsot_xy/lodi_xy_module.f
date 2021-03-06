      !> @file
      !> module implemeting subroutines to apply open boundary
      !> conditions at the edge of the computational domain using
      !> lodi boundary conditions
      !
      !> @author 
      !> Julien L. Desmarais
      !
      !> @brief
      !> module implemeting subroutines to apply open boundary
      !> conditions at the edge of the computational domain using
      !> lodi boundary conditions
      !
      !> @date
      !> 13_08_2014 - initial version - J.L. Desmarais
      !-----------------------------------------------------------------
      module lodi_xy_module

        use interface_primary, only :
     $       gradient_x_proc,
     $       gradient_y_proc

        use lodi_inflow_class, only :
     $       lodi_inflow

        use lodi_outflow_class, only :
     $       lodi_outflow

        use openbc_operators_module, only :
     $       incoming_proc,
     $       inflow_left,
     $       inflow_right,
     $       add_body_forces

        use pmodel_eq_class, only :
     $       pmodel_eq        

        use parameters_input, only :
     $       nx,ny,ne,bc_size

        use parameters_constant, only :
     $       always_inflow,
     $       always_outflow,
     $       ask_flow,
     $       left,
     $       right

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
        
        implicit none

        private
        public ::
     $       compute_timedev_xlayer,
     $       compute_timedev_ylayer,
     $       compute_timedev_corner_W,
     $       compute_timedev_corner_E,
     $       compute_timedev_xlayer_local,
     $       compute_timedev_ylayer_local,
     $       compute_timedev_corner_local,
     $       compute_x_timedev_with_openbc,
     $       compute_y_timedev_with_openbc

        contains


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> subroutine computing the time derivatives for the
        !> south or north layer using open boundary conditions
        !
        !> @date
        !> 13_08_2014 - initial version - J.L. Desmarais
        !
        !>@param p_model
        !> governing equations of the physical model
        !
        !>@param t
        !> time
        !
        !>@param nodes
        !> array of grid points
        !
        !>@param x_map
        !> coordinate map in the x-direction
        !
        !>@param y_map
        !> coordinate map in the y-direction
        !
        !>@param i
        !> index identifying the grid point position along the x-axis
        !
        !>@param j
        !> index identifying the grid point position along the y-axis
        !
        !>@param flux_x
        !> fluxes along the x-direction
        !
        !>@param gradient
        !> procedure computing the gradient along the x-direction
        !
        !>@param inflow_bc
        !> procedure computing the contribution to the time derivatives
        !> from an inflow boundary condition
        !
        !>@param outflow_bc
        !> procedure computing the contribution to the time derivatives
        !> from an outflow boundary condition
        !
        !>@param incoming_y
        !> procedure identifying whether the boundary normal to the
        !> y-direction is of inflow or outflow type
        !
        !>@param timedev
        !> time derivatives of the governing variables
        !-------------------------------------------------------------
        subroutine compute_timedev_xlayer(
     $       p_model,
     $       t, nodes, x_map, y_map, i,j,
     $       flux_y,
     $       side_x,
     $       gradient_x,
     $       inflow_bc,
     $       outflow_bc,
     $       is_inflow_x,
     $       oneside_xflow,
     $       timedev)

          implicit none

          type(pmodel_eq)                   , intent(in)    :: p_model
          real(rkind)                       , intent(in)    :: t
          real(rkind), dimension(nx,ny,ne)  , intent(in)    :: nodes
          real(rkind), dimension(nx)        , intent(in)    :: x_map
          real(rkind), dimension(ny)        , intent(in)    :: y_map
          integer(ikind)                    , intent(in)    :: i
          integer(ikind)                    , intent(in)    :: j
          real(rkind), dimension(nx,ny+1,ne), intent(in)    :: flux_y
          logical                           , intent(in)    :: side_x
          procedure(gradient_x_proc)                        :: gradient_x
          type(lodi_inflow)                 , intent(in)    :: inflow_bc
          type(lodi_outflow)                , intent(in)    :: outflow_bc
          procedure(incoming_proc)                          :: is_inflow_x
          integer                           , intent(in)    :: oneside_xflow
          real(rkind), dimension(nx,ny,ne)  , intent(inout) :: timedev

          timedev(i,j,:) =
     $         compute_timedev_xlayer_local(
     $         p_model,
     $         t, nodes, x_map, y_map, i,j,
     $         flux_y,
     $         side_x,
     $         gradient_x,
     $         inflow_bc,
     $         outflow_bc,
     $         is_inflow_x,
     $         oneside_xflow)     

        end subroutine compute_timedev_xlayer        


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> subroutine computing the time derivatives for the
        !> west or east layers using open boundary conditions
        !
        !> @date
        !> 13_08_2014 - initial version - J.L. Desmarais
        !
        !>@param p_model
        !> governing equations of the physical model
        !
        !>@param t
        !> time
        !
        !>@param nodes
        !> array of grid points
        !
        !>@param x_map
        !> coordinate map in the x-direction
        !
        !>@param y_map
        !> coordinate map in the y-direction
        !
        !>@param j
        !> index identifying the grid point position along the y-axis
        !
        !>@param flux_x
        !> fluxes along the x-direction
        !
        !>@param gradient
        !> procedure computing the gradient along the x-direction
        !
        !>@param inflow_bc
        !> procedure computing the contribution to the time derivatives
        !> from an inflow boundary condition
        !
        !>@param outflow_bc
        !> procedure computing the contribution to the time derivatives
        !> from an outflow boundary condition
        !
        !>@param incoming_y
        !> procedure identifying whether the boundary normal to the
        !> y-direction is of inflow or outflow type
        !
        !>@param timedev
        !> time derivatives of the governing variables
        !-------------------------------------------------------------
        subroutine compute_timedev_ylayer(
     $     p_model,
     $     t, nodes, x_map, y_map, j,
     $     flux_x,
     $     side_y,
     $     gradient_y,
     $     inflow_bc,
     $     outflow_bc,
     $     is_inflow_y,
     $     oneside_yflow,
     $     timedev)

          implicit none

          type(pmodel_eq)                   , intent(in)    :: p_model
          real(rkind)                       , intent(in)    :: t
          real(rkind), dimension(nx,ny,ne)  , intent(in)    :: nodes
          real(rkind), dimension(nx)        , intent(in)    :: x_map
          real(rkind), dimension(ny)        , intent(in)    :: y_map
          integer(ikind)                    , intent(in)    :: j
          real(rkind), dimension(nx+1,ny,ne), intent(in)    :: flux_x
          logical                           , intent(in)    :: side_y
          procedure(gradient_y_proc)                        :: gradient_y
          type(lodi_inflow)                 , intent(in)    :: inflow_bc
          type(lodi_outflow)                , intent(in)    :: outflow_bc
          procedure(incoming_proc)                          :: is_inflow_y
          integer    , optional             , intent(in)    :: oneside_yflow
          real(rkind), dimension(nx,ny,ne)  , intent(inout) :: timedev

          integer(ikind) :: i
          real(rkind)    :: dx

          dx = x_map(2) - x_map(1)


          do i=3, nx-bc_size

             timedev(i,j,:) = 
     $            compute_timedev_ylayer_local(
     $            p_model,
     $            t, nodes, x_map, y_map, i,j,
     $            flux_x,
     $            side_y,
     $            gradient_y,
     $            inflow_bc,
     $            outflow_bc,
     $            is_inflow_y,
     $            oneside_yflow)

          end do

        end subroutine compute_timedev_ylayer


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> subroutine computing the time derivatives for the
        !> west corner using open boundary conditions
        !
        !> @date
        !> 13_08_2014 - initial version - J.L. Desmarais
        !
        !>@param p_model
        !> governing equations of the physical model
        !
        !>@param t
        !> time
        !
        !>@param nodes
        !> array of grid points
        !
        !>@param x_map
        !> coordinate map in the x-direction
        !
        !>@param y_map
        !> coordinate map in the y-direction
        !
        !>@param j
        !> index identifying the grid point position along the y-axis
        !
        !>@param gradient
        !> procedure computing the gradient along the x-direction
        !
        !>@param inflow_bc
        !> procedure computing the contribution to the time derivatives
        !> from an inflow boundary condition
        !
        !>@param outflow_bc
        !> procedure computing the contribution to the time derivatives
        !> from an outflow boundary condition
        !
        !>@param incoming_y
        !> procedure identifying whether the boundary normal to the
        !> y-direction is of inflow or outflow type
        !
        !>@param timedev
        !> time derivatives of the governing variables
        !-------------------------------------------------------------
        subroutine compute_timedev_corner_W(
     $     p_model,
     $     t, nodes, x_map, y_map, j,
     $     side_y,
     $     gradient_y,
     $     inflow_bc,
     $     outflow_bc,
     $     is_inflow_y,
     $     oneside_xflow,
     $     oneside_yflow,
     $     timedev)

          implicit none

          type(pmodel_eq)                 , intent(in)    :: p_model
          real(rkind)                     , intent(in)    :: t
          real(rkind), dimension(nx,ny,ne), intent(in)    :: nodes
          real(rkind), dimension(nx)      , intent(in)    :: x_map
          real(rkind), dimension(ny)      , intent(in)    :: y_map
          integer(ikind)                  , intent(in)    :: j
          logical                         , intent(in)    :: side_y
          procedure(gradient_y_proc)                      :: gradient_y
          type(lodi_inflow)               , intent(in)    :: inflow_bc
          type(lodi_outflow)              , intent(in)    :: outflow_bc
          procedure(incoming_proc)                        :: is_inflow_y
          integer                         , intent(in)    :: oneside_xflow
          integer                         , intent(in)    :: oneside_yflow
          real(rkind), dimension(nx,ny,ne), intent(inout) :: timedev

          integer(ikind) :: i
          logical        :: side_x

          side_x = left

          i = 1
          timedev(i,j,:) = compute_timedev_corner_local(
     $         p_model,
     $         t,
     $         nodes,
     $         x_map,
     $         y_map,
     $         i,
     $         j,
     $         side_x,
     $         side_y,
     $         gradient_x_x_oneside_L0,
     $         gradient_y,
     $         inflow_bc,
     $         outflow_bc,
     $         inflow_left,
     $         is_inflow_y,
     $         oneside_xflow,
     $         oneside_yflow)

          i = 2
          timedev(i,j,:) = compute_timedev_corner_local(
     $         p_model,
     $         t,
     $         nodes,
     $         x_map,
     $         y_map,
     $         i,
     $         j,
     $         side_x,
     $         side_y,
     $         gradient_x_x_oneside_L1,
     $         gradient_y,
     $         inflow_bc,
     $         outflow_bc,
     $         inflow_left,
     $         is_inflow_y,
     $         oneside_xflow,
     $         oneside_yflow)

        end subroutine compute_timedev_corner_W        


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> subroutine computing the time derivatives for the
        !> east corner using open boundary conditions
        !
        !> @date
        !> 13_08_2014 - initial version - J.L. Desmarais
        !
        !>@param p_model
        !> governing equations of the physical model
        !
        !>@param t
        !> time
        !
        !>@param nodes
        !> array of grid points
        !
        !>@param x_map
        !> coordinate map in the x-direction
        !
        !>@param y_map
        !> coordinate map in the y-direction
        !
        !>@param j
        !> index identifying the grid point position along the y-axis
        !
        !>@param gradient
        !> procedure computing the gradient along the x-direction
        !
        !>@param inflow_bc
        !> procedure computing the contribution to the time derivatives
        !> from an inflow boundary condition
        !
        !>@param outflow_bc
        !> procedure computing the contribution to the time derivatives
        !> from an outflow boundary condition
        !
        !>@param incoming_y
        !> procedure identifying whether the boundary normal to the
        !> y-direction is of inflow or outflow type
        !
        !>@param timedev
        !> time derivatives of the governing variables
        !-------------------------------------------------------------
        subroutine compute_timedev_corner_E(
     $     p_model,
     $     t, nodes, x_map, y_map, j,
     $     side_y,
     $     gradient_y,
     $     inflow_bc,
     $     outflow_bc,
     $     is_inflow_y,
     $     oneside_xflow,
     $     oneside_yflow,
     $     timedev)

          implicit none

          type(pmodel_eq)                 , intent(in)    :: p_model
          real(rkind)                     , intent(in)    :: t
          real(rkind), dimension(nx,ny,ne), intent(in)    :: nodes
          real(rkind), dimension(nx)      , intent(in)    :: x_map
          real(rkind), dimension(ny)      , intent(in)    :: y_map
          integer(ikind)                  , intent(in)    :: j
          logical                         , intent(in)    :: side_y
          procedure(gradient_y_proc)                      :: gradient_y
          type(lodi_inflow)               , intent(in)    :: inflow_bc
          type(lodi_outflow)              , intent(in)    :: outflow_bc
          procedure(incoming_proc)                        :: is_inflow_y
          integer                         , intent(in)    :: oneside_xflow
          integer                         , intent(in)    :: oneside_yflow
          real(rkind), dimension(nx,ny,ne), intent(inout) :: timedev

          logical        :: side_x
          integer(ikind) :: i

          side_x = right

          i=nx-1
          timedev(i,j,:) = compute_timedev_corner_local(
     $         p_model,
     $         t,
     $         nodes,
     $         x_map,
     $         y_map,
     $         i,
     $         j,
     $         side_x,
     $         side_y,
     $         gradient_x_x_oneside_R1,
     $         gradient_y,
     $         inflow_bc,
     $         outflow_bc,
     $         inflow_right,
     $         is_inflow_y,
     $         oneside_xflow,
     $         oneside_yflow)

          i=nx
          timedev(i,j,:) = compute_timedev_corner_local(
     $         p_model,
     $         t,
     $         nodes,
     $         x_map,
     $         y_map,
     $         i,
     $         j,
     $         side_x,
     $         side_y,
     $         gradient_x_x_oneside_R0,
     $         gradient_y,
     $         inflow_bc,
     $         outflow_bc,
     $         inflow_right,
     $         is_inflow_y,
     $         oneside_xflow,
     $         oneside_yflow)

        end subroutine compute_timedev_corner_E


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> subroutine computing the time derivatives for the
        !> east or west layer using open boundary conditions
        !
        !> @date
        !> 21_10_2014 - initial version - J.L. Desmarais
        !
        !>@param p_model
        !> governing equations of the physical model
        !
        !>@param t
        !> time
        !
        !>@param nodes
        !> array of grid points
        !
        !>@param x_map
        !> coordinate map in the x-direction
        !
        !>@param y_map
        !> coordinate map in the y-direction
        !
        !>@param i
        !> index identifying the grid point position along the x-axis
        !
        !>@param j
        !> index identifying the grid point position along the y-axis
        !
        !>@param flux_x
        !> fluxes along the x-direction
        !
        !>@param gradient
        !> procedure computing the gradient along the x-direction
        !
        !>@param inflow_bc
        !> procedure computing the contribution to the time derivatives
        !> from an inflow boundary condition
        !
        !>@param outflow_bc
        !> procedure computing the contribution to the time derivatives
        !> from an outflow boundary condition
        !
        !>@param is_inflow_x
        !> procedure identifying whether the boundary normal to the
        !> x-direction is of inflow or outflow type
        !
        !>@param timedev
        !> time derivatives of the governing variables
        !-------------------------------------------------------------
        function compute_timedev_xlayer_local(
     $     p_model,
     $     t, nodes, x_map, y_map, i,j,
     $     flux_y,
     $     side_x,
     $     gradient_x,
     $     inflow_bc,
     $     outflow_bc,
     $     is_inflow_x,
     $     oneside_xflow)
     $     result(timedev)

          implicit none

          type(pmodel_eq)                   , intent(in)    :: p_model
          real(rkind)                       , intent(in)    :: t
          real(rkind), dimension(:,:,:)     , intent(in)    :: nodes
          real(rkind), dimension(:)         , intent(in)    :: x_map
          real(rkind), dimension(:)         , intent(in)    :: y_map
          integer(ikind)                    , intent(in)    :: i
          integer(ikind)                    , intent(in)    :: j
          real(rkind), dimension(:,:,:)     , intent(in)    :: flux_y
          logical                           , intent(in)    :: side_x
          procedure(gradient_x_proc)                        :: gradient_x
          type(lodi_inflow)                 , intent(in)    :: inflow_bc
          type(lodi_outflow)                , intent(in)    :: outflow_bc
          procedure(incoming_proc)                          :: is_inflow_x
          integer                           , intent(in)    :: oneside_xflow
          real(rkind), dimension(ne)                        :: timedev

          real(rkind) :: dy

          dy = y_map(2) - y_map(1)

          timedev = 
     $         compute_x_timedev_with_openbc(
     $         p_model,
     $         t, nodes, x_map, y_map, i,j,
     $         side_x,
     $         gradient_x,
     $         inflow_bc,
     $         outflow_bc,
     $         is_inflow_x,
     $         oneside_xflow) +
     $         
     $         1.0d0/dy*(flux_y(i,j,:) - flux_y(i,j+1,:)) +
     $         
     $         add_body_forces(
     $         p_model,
     $         t, x_map(i), y_map(j), nodes(i,j,:))

        end function compute_timedev_xlayer_local


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> subroutine computing the time derivatives for the
        !> east or west layer using open boundary conditions
        !
        !> @date
        !> 21_10_2014 - initial version - J.L. Desmarais
        !
        !>@param p_model
        !> governing equations of the physical model
        !
        !>@param t
        !> time
        !
        !>@param nodes
        !> array of grid points
        !
        !>@param x_map
        !> coordinate map in the x-direction
        !
        !>@param y_map
        !> coordinate map in the y-direction
        !
        !>@param i
        !> index identifying the grid point position along the x-axis
        !
        !>@param j
        !> index identifying the grid point position along the y-axis
        !
        !>@param flux_x
        !> fluxes along the x-direction
        !
        !>@param gradient
        !> procedure computing the gradient along the x-direction
        !
        !>@param inflow_bc
        !> procedure computing the contribution to the time derivatives
        !> from an inflow boundary condition
        !
        !>@param outflow_bc
        !> procedure computing the contribution to the time derivatives
        !> from an outflow boundary condition
        !
        !>@param is_inflow_x
        !> procedure identifying whether the boundary normal to the
        !> x-direction is of inflow or outflow type
        !
        !>@param timedev
        !> time derivatives of the governing variables
        !-------------------------------------------------------------
        function compute_timedev_ylayer_local(
     $     p_model,
     $     t, nodes, x_map, y_map, i,j,
     $     flux_x,
     $     side_y,
     $     gradient_y,
     $     inflow_bc,
     $     outflow_bc,
     $     is_inflow_y,
     $     oneside_yflow)
     $     result(timedev)

          implicit none

          type(pmodel_eq)                   , intent(in)    :: p_model
          real(rkind)                       , intent(in)    :: t
          real(rkind), dimension(:,:,:)     , intent(in)    :: nodes
          real(rkind), dimension(:)         , intent(in)    :: x_map
          real(rkind), dimension(:)         , intent(in)    :: y_map
          integer(ikind)                    , intent(in)    :: i
          integer(ikind)                    , intent(in)    :: j
          real(rkind), dimension(:,:,:)     , intent(in)    :: flux_x
          logical                           , intent(in)    :: side_y
          procedure(gradient_y_proc)                        :: gradient_y
          type(lodi_inflow)                 , intent(in)    :: inflow_bc
          type(lodi_outflow)                , intent(in)    :: outflow_bc
          procedure(incoming_proc)                          :: is_inflow_y
          integer                           , intent(in)    :: oneside_yflow
          real(rkind), dimension(ne)                        :: timedev

          real(rkind) :: dx

          dx = x_map(2) - x_map(1)

          timedev = 
     $            1.0d0/dx*(flux_x(i,j,:) - flux_x(i+1,j,:)) +
     $            
     $            compute_y_timedev_with_openbc(
     $            p_model,
     $            t, nodes, x_map, y_map, i,j,
     $            side_y,
     $            gradient_y,
     $            inflow_bc,
     $            outflow_bc,
     $            is_inflow_y,
     $            oneside_yflow) +
     $         
     $            add_body_forces(
     $            p_model,
     $            t, x_map(i), y_map(j), nodes(i,j,:))

        end function compute_timedev_ylayer_local


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> subroutine computing the time derivatives for the
        !> east or west layer using open boundary conditions
        !
        !> @date
        !> 21_10_2014 - initial version - J.L. Desmarais
        !
        !>@param p_model
        !> governing equations of the physical model
        !
        !>@param t
        !> time
        !
        !>@param nodes
        !> array of grid points
        !
        !>@param x_map
        !> coordinate map in the x-direction
        !
        !>@param y_map
        !> coordinate map in the y-direction
        !
        !>@param i
        !> index identifying the grid point position along the x-axis
        !
        !>@param j
        !> index identifying the grid point position along the y-axis
        !
        !>@param flux_x
        !> fluxes along the x-direction
        !
        !>@param gradient
        !> procedure computing the gradient along the x-direction
        !
        !>@param inflow_bc
        !> procedure computing the contribution to the time derivatives
        !> from an inflow boundary condition
        !
        !>@param outflow_bc
        !> procedure computing the contribution to the time derivatives
        !> from an outflow boundary condition
        !
        !>@param is_inflow_x
        !> procedure identifying whether the boundary normal to the
        !> x-direction is of inflow or outflow type
        !
        !>@param timedev
        !> time derivatives of the governing variables
        !-------------------------------------------------------------
        function compute_timedev_corner_local(
     $     p_model,
     $     t,
     $     nodes,
     $     x_map,
     $     y_map,
     $     i,
     $     j,
     $     side_x,
     $     side_y,
     $     gradient_x,
     $     gradient_y,
     $     inflow_bc,
     $     outflow_bc,
     $     is_inflow_x,
     $     is_inflow_y,
     $     oneside_xflow,
     $     oneside_yflow)
     $     result(timedev)

          implicit none

          type(pmodel_eq)                   , intent(in)    :: p_model
          real(rkind)                       , intent(in)    :: t
          real(rkind), dimension(:,:,:)     , intent(in)    :: nodes
          real(rkind), dimension(:)         , intent(in)    :: x_map
          real(rkind), dimension(:)         , intent(in)    :: y_map
          integer(ikind)                    , intent(in)    :: i
          integer(ikind)                    , intent(in)    :: j
          logical                           , intent(in)    :: side_x
          logical                           , intent(in)    :: side_y
          procedure(gradient_x_proc)                        :: gradient_x
          procedure(gradient_y_proc)                        :: gradient_y
          type(lodi_inflow)                 , intent(in)    :: inflow_bc
          type(lodi_outflow)                , intent(in)    :: outflow_bc
          procedure(incoming_proc)                          :: is_inflow_x
          procedure(incoming_proc)                          :: is_inflow_y
          integer                           , intent(in)    :: oneside_xflow
          integer                           , intent(in)    :: oneside_yflow
          real(rkind), dimension(ne)                        :: timedev

          timedev = 
     $         compute_x_timedev_with_openbc(
     $         p_model,
     $         t, nodes, x_map, y_map, i,j,
     $         side_x,
     $         gradient_x,
     $         inflow_bc,
     $         outflow_bc,
     $         is_inflow_x,
     $         oneside_xflow) + 
     $         
     $         compute_y_timedev_with_openbc(
     $         p_model,
     $         t, nodes, x_map, y_map, i,j,
     $         side_y,
     $         gradient_y,
     $         inflow_bc,
     $         outflow_bc,
     $         is_inflow_y,
     $         oneside_yflow) +
     $         
     $         add_body_forces(
     $         p_model,
     $         t, x_map(i), y_map(j), nodes(i,j,:))

        end function compute_timedev_corner_local


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute the contribution of the hyperbolic terms of the
        !> governing equations in the y-direction to the time
        !> derivatives of the governing variables
        !
        !> @date
        !> 13_08_2014 - initial version - J.L. Desmarais
        !
        !>@param p_model
        !> governing equations of the physical model
        !
        !>@param t
        !> time
        !
        !>@param nodes
        !> array of grid points
        !
        !>@param x_map
        !> coordinate map in the x-direction
        !
        !>@param y_map
        !> coordinate map in the y-direction
        !
        !>@param i
        !> index identifying the grid point position along the x-axis
        !
        !>@param j
        !> index identifying the grid point position along the y-axis
        !
        !>@param gradient
        !> procedure computing the gradient along the x-direction
        !
        !>@param inflow_bc
        !> procedure computing the contribution to the time derivatives
        !> from an inflow boundary condition
        !
        !>@param outflow_bc
        !> procedure computing the contribution to the time derivatives
        !> from an outflow boundary condition
        !
        !>@param is_inflow
        !> procedure identifying whether the boundary condition is
        !> of inflow or outflow type
        !-------------------------------------------------------------
        function compute_x_timedev_with_openbc(
     $     p_model,
     $     t, nodes, x_map, y_map, i,j,
     $     side,
     $     gradient,
     $     inflow_bc,
     $     outflow_bc,
     $     is_inflow,
     $     oneside_flow)
     $     result(timedev)

          implicit none

          
          type(pmodel_eq)              , intent(in) :: p_model
          real(rkind)                  , intent(in) :: t
          real(rkind), dimension(:,:,:), intent(in) :: nodes
          real(rkind), dimension(:)    , intent(in) :: x_map
          real(rkind), dimension(:)    , intent(in) :: y_map
          integer(ikind)               , intent(in) :: i
          integer(ikind)               , intent(in) :: j
          logical                      , intent(in) :: side
          procedure(gradient_x_proc)                :: gradient
          type(lodi_inflow)            , intent(in) :: inflow_bc
          type(lodi_outflow)           , intent(in) :: outflow_bc
          procedure(incoming_proc)                  :: is_inflow
          integer            , optional, intent(in) :: oneside_flow
          real(rkind), dimension(ne)                :: timedev


          logical :: inflow_option


          if(present(oneside_flow)) then
             select case(oneside_flow)
               case(always_inflow)
                  inflow_option = .true.
               case(always_outflow)
                  inflow_option = .false.
               case(ask_flow)
                  inflow_option = is_inflow(nodes(i,j,2))
               case default
                  print '(''lodi_xy_module'')'
                  print '(''compute_x_timedev_with_openbc'')'
                  print '(''option asked: '')', oneside_flow
                  stop 'oneside_flow option not recognized'
             end select
          else
             inflow_option = is_inflow(nodes(i,j,2))
          end if

             
          !determine whether the b.c. is an inflow or outflow
          !b.c. by looking at the sign of the x-component of
          !the momentum vector
          if(inflow_option) then
             timedev = inflow_bc%compute_x_timedev(
     $            p_model,
     $            t, nodes, x_map, y_map, i,j,
     $            side,
     $            gradient)

          else
             timedev = outflow_bc%compute_x_timedev(
     $            p_model,
     $            t, nodes, x_map, y_map, i,j,
     $            side,
     $            gradient)

          end if

        end function compute_x_timedev_with_openbc


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute the contribution of the hyperbolic terms of the
        !> governing equations in the y-direction to the time
        !> derivatives of the governing variables
        !
        !> @date
        !> 13_08_2014 - initial version - J.L. Desmarais
        !
        !>@param p_model
        !> governing equations of the physical model
        !
        !>@param t
        !> time
        !
        !>@param nodes
        !> array of grid points
        !
        !>@param x_map
        !> coordinate map in the x-direction
        !
        !>@param y_map
        !> coordinate map in the y-direction
        !
        !>@param i
        !> index identifying the grid point position along the x-axis
        !
        !>@param j
        !> index identifying the grid point position along the y-axis
        !
        !>@param gradient
        !> procedure computing the gradient along the y-direction
        !
        !>@param inflow_bc
        !> procedure computing the contribution to the time derivatives
        !> from an inflow boundary condition
        !
        !>@param outflow_bc
        !> procedure computing the contribution to the time derivatives
        !> from an outflow boundary condition
        !
        !>@param is_inflow
        !> procedure identifying whether the boundary condition is
        !> of inflow or outflow type        
        !-------------------------------------------------------------
        function compute_y_timedev_with_openbc(
     $     p_model,
     $     t, nodes, x_map, y_map, i,j,
     $     side,
     $     gradient,
     $     inflow_bc,
     $     outflow_bc,
     $     is_inflow,
     $     oneside_flow)
     $     result(timedev)

          implicit none

          
          type(pmodel_eq)              , intent(in) :: p_model
          real(rkind)                  , intent(in) :: t
          real(rkind), dimension(:,:,:), intent(in) :: nodes
          real(rkind), dimension(:)    , intent(in) :: x_map
          real(rkind), dimension(:)    , intent(in) :: y_map
          integer(ikind)               , intent(in) :: i
          integer(ikind)               , intent(in) :: j
          logical                      , intent(in) :: side
          procedure(gradient_y_proc)                :: gradient
          type(lodi_inflow)            , intent(in) :: inflow_bc
          type(lodi_outflow)           , intent(in) :: outflow_bc
          procedure(incoming_proc)                  :: is_inflow
          integer            , optional, intent(in) :: oneside_flow
          real(rkind), dimension(ne)                :: timedev

          logical :: inflow_option


          if(present(oneside_flow)) then
             select case(oneside_flow)
               case(always_inflow)
                  inflow_option = .true.
               case(always_outflow)
                  inflow_option = .false.
               case(ask_flow)
                  inflow_option = is_inflow(nodes(i,j,3))
               case default
                  print '(''lodi_xy_module'')'
                  print '(''compute_y_timedev_with_openbc'')'
                  stop 'oneside_flow option not recognized'
             end select
          else
             inflow_option = is_inflow(nodes(i,j,3))
          end if

             
          !determine whether the b.c. is an inflow or outflow
          !b.c. by looking at the sign of the y-component of
          !the momentum vector
          if(inflow_option) then
             timedev = inflow_bc%compute_y_timedev(
     $            p_model,
     $            t, nodes, x_map, y_map, i,j,
     $            side,
     $            gradient)

          else
             timedev = outflow_bc%compute_y_timedev(
     $            p_model,
     $            t, nodes, x_map, y_map, i,j,
     $            side,
     $            gradient)

          end if

        end function compute_y_timedev_with_openbc

      end module lodi_xy_module
