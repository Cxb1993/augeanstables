      !> @file
      !> class encapsulating subroutines to compute
      !> the time derivatives of the main variables
      !> using the finite volume method
      !
      !> @author 
      !> Julien L. Desmarais
      !
      !> @brief
      !> class encapsulating subroutines to compute
      !> the time derivatives of the main variables
      !> using the finite volume method
      !
      !> @date
      !> 13_08_2013 - initial version               - J.L. Desmarais
      !> 14_07_2014 - interface for erymanthianboar - J.L. Desmarais
      !-----------------------------------------------------------------
      module td_operators_class

        use bc_operators_class, only :
     $       bc_operators

        use bf_layer_bc_sections_class , only :
     $       bf_layer_bc_sections

        use sd_operators_class, only :
     $       sd_operators

        use parameters_constant, only :
     $       earth_gravity_choice,
     $       bc_fluxes_choice,
     $       bc_timedev_choice

        use parameters_bf_layer, only :
     $       no_pt

        use parameters_input, only : 
     $       nx,ny,ne,bc_size,
     $       gravity_choice,
     $       bcx_type_choice,
     $       bcy_type_choice

        use parameters_kind, only :
     $       rkind, ikind

        use pmodel_eq_class, only :
     $       pmodel_eq

        use td_operators_abstract_class, only :
     $       td_operators_abstract

        implicit none

        private
        public :: td_operators


        !> @class td_operators
        !> class encapsulating operators to compute
        !> the time derivatives of the main variables
        !> using the finite volume method
        !>
        !> @param compute_time_dev
        !> compute the time derivatives
        !
        !> @param compute_time_dev_nopt
        !> compute the time derivatives without optimizing the
        !> size of the arrays passed as arguments
        !---------------------------------------------------------------
        type, extends(td_operators_abstract) :: td_operators

          contains

          procedure, nopass :: compute_time_dev
          procedure, nopass :: compute_time_dev_nopt

        end type td_operators


        contains


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> subroutine computing the time derivatives using the
        !> space discretisation operators and the physical model
        !
        !> @date
        !> 13_08_2013 - initial version - J.L. Desmarais
        !
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
        !>@param p_model
        !> physical model
        !
        !>@param bc_used
        !> boundary conditions
        !
        !>@param time_dev
        !> time derivatives
        !--------------------------------------------------------------
        function compute_time_dev(t,nodes,x_map,y_map,s,p_model,bc_used)
     $     result(time_dev)

          implicit none

          real(rkind)                     , intent(in) :: t
          real(rkind), dimension(nx,ny,ne), intent(in) :: nodes
          real(rkind), dimension(nx)      , intent(in) :: x_map
          real(rkind), dimension(ny)      , intent(in) :: y_map
          type(sd_operators)              , intent(in) :: s
          type(pmodel_eq)                 , intent(in) :: p_model
          type(bc_operators)              , intent(in) :: bc_used
          real(rkind), dimension(nx,ny,ne)             :: time_dev

          real(rkind)                        :: dx
          real(rkind)                        :: dy
          integer                            :: k
          integer(ikind)                     :: i,j
          real(rkind), dimension(nx+1,ny,ne) :: flux_x
          real(rkind), dimension(nx,ny+1,ne) :: flux_y


          dx = x_map(2) - x_map(1)
          dy = y_map(2) - y_map(1)
          

          !<compute the fluxes
          !FORCEINLINE RECURSIVE
          flux_x = p_model%compute_flux_x(nodes,dx,dy,s)

          !FORCEINLINE RECURSIVE
          flux_y = p_model%compute_flux_y(nodes,dx,dy,s)


          !< if the boundary conditions influence the computation
          !> of the fluxes, then we need to modify the fluxes
          if((bcx_type_choice.eq.bc_fluxes_choice).or.
     $       (bcy_type_choice.eq.bc_fluxes_choice)) then
             call bc_used%apply_bc_on_fluxes(
     $            nodes,dx,dy,s,flux_x,flux_y)
          end if


          !<compute the time derivatives
          !>select if the body forces computation is required
          if(gravity_choice.eq.earth_gravity_choice) then

             !<compute the time derivatives
             do k=1, ne
                do j=1+bc_size, ny-bc_size
                   do i=1+bc_size, nx-bc_size
                      time_dev(i,j,k)=
     $                     (flux_x(i,j,k)/dx-flux_x(i+1,j,k)/dx)+
     $                     (flux_y(i,j,k)/dy-flux_y(i,j+1,k)/dy)+
     $                     p_model%compute_body_forces(nodes(i,j,:),k)
                   end do
                end do
             end do

          else

             !<compute the time derivatives
             do k=1, ne
                do j=1+bc_size, ny-bc_size
                   do i=1+bc_size, nx-bc_size
                      time_dev(i,j,k)=
     $                     (flux_x(i,j,k)/dx-flux_x(i+1,j,k)/dx)+
     $                     (flux_y(i,j,k)/dy-flux_y(i,j+1,k)/dy)
                   end do
                end do
             end do

          end if

          !< if the boundary conditions influence the computation
          !> of the time derivatives, then we need to compute the
          !> time derivatives at the boundary
          if((bcx_type_choice.eq.bc_timedev_choice).or.
     $       (bcy_type_choice.eq.bc_timedev_choice)) then
             call bc_used%apply_bc_on_timedev(
     $            p_model,
     $            t,nodes,x_map,y_map,
     $            flux_x,flux_y,
     $            time_dev)
          end if
          

        end function compute_time_dev



        !compute the time derivatives without knowing the size of the
        !tables
        subroutine compute_time_dev_nopt(
     $     nodes,dx,dy,s,p_model,bc_used,
     $     time_dev, grdpts_id, bc_sections,
     $     x_borders, y_borders)

            implicit none


            real(rkind)   , dimension(:,:,:)           , intent(in)    :: nodes
            real(rkind)                                , intent(in)    :: dx
            real(rkind)                                , intent(in)    :: dy
            type(sd_operators)                         , intent(in)    :: s
            type(pmodel_eq)                            , intent(in)    :: p_model
            type(bc_operators)                         , intent(in)    :: bc_used
            real(rkind)   , dimension(:,:,:)           , intent(out)   :: time_dev
            integer       , dimension(:,:)             , intent(in)    :: grdpts_id
            integer       , dimension(:,:), allocatable, intent(inout) :: bc_sections
            integer(ikind), dimension(2)  , optional   , intent(in)    :: x_borders
            integer(ikind), dimension(2)  , optional   , intent(in)    :: y_borders

            integer(ikind)                             :: i_min,i_max
            integer(ikind)                             :: j_min,j_max
            integer(ikind)                             :: i,j
            integer                                    :: k
            real(rkind), dimension(:,:,:), allocatable :: flux_x
            real(rkind), dimension(:,:,:), allocatable :: flux_y


            if(present(x_borders)) then
               i_min = x_borders(1)
               i_max = x_borders(2)
            else
               i_min = bc_size+1
               i_max = size(nodes,1)-bc_size
            end if

            if(present(y_borders)) then
               j_min = y_borders(1)
               j_max = y_borders(2)
            else
               j_min = bc_size+1
               j_max = size(nodes,2)-bc_size
            end if

            allocate(flux_x(size(nodes,1)+1,size(nodes,2),ne))
            allocate(flux_y(size(nodes,1),size(nodes,2)+1,ne))

            stop 'td-operators: compute_time_dev_nopt not implemented'


            !<compute the fluxes
            !FORCEINLINE RECURSIVE
            call p_model%compute_flux_x_nopt(
     $           nodes,dx,dy,s,
     $           grdpts_id,flux_x,
     $           x_borders, y_borders)


            !FORCEINLINE RECURSIVE
            call p_model%compute_flux_y_nopt(
     $           nodes,dx,dy,s,
     $           grdpts_id,flux_y,
     $           x_borders, y_borders)


            !<if the boundary conditions influence the computation
            !> of the fluxes, then we need to modify the fluxes
            if((bcx_type_choice.eq.bc_fluxes_choice).or.
     $         (bcy_type_choice.eq.bc_fluxes_choice)) then
               call bc_used%apply_bc_on_fluxes(
     $              nodes,dx,dy,s,flux_x,flux_y)
            end if


            !<compute the time derivatives
            !>select if the body forces computation is required
            if(gravity_choice.eq.earth_gravity_choice) then

               !<compute the time derivatives
               do k=1, ne
                  do j=1+bc_size, size(time_dev,2)-bc_size
                     do i=1+bc_size, size(time_dev,1)-bc_size

                        if(grdpts_id(i,j).ne.no_pt) then

                           time_dev(i,j,k)=
     $                          (flux_x(i,j,k)/dx-flux_x(i+1,j,k)/dx)+
     $                          (flux_y(i,j,k)/dy-flux_y(i,j+1,k)/dy)+
     $                          p_model%compute_body_forces(
     $                             nodes(i,j,:),k)

                        end if

                     end do
                  end do
               end do

            else

               !<compute the time derivatives
               do k=1, ne
                  do j=1+bc_size, size(time_dev,2)-bc_size
                     do i=1+bc_size, size(time_dev,1)-bc_size

                        if(grdpts_id(i,j).ne.no_pt) then

                           time_dev(i,j,k)=
     $                          (flux_x(i,j,k)/dx-flux_x(i+1,j,k)/dx)+
     $                          (flux_y(i,j,k)/dy-flux_y(i,j+1,k)/dy)

                        end if
                     end do
                  end do
               end do

            end if

            !< if the boundary conditions influence the computation
            !> of the time derivatives, then we need to compute the
            !> time derivatives at the boundary
            if((bcx_type_choice.eq.bc_timedev_choice).or.
     $         (bcy_type_choice.eq.bc_timedev_choice)) then
               stop 'not implemented'
            end if

            deallocate(flux_x)
            deallocate(flux_y)

        end subroutine compute_time_dev_nopt

      end module td_operators_class
