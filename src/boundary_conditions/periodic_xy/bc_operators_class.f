      !> @file
      !> class encapsulating subroutines to apply periodic boundary
      !> conditions at the edge of the computational domain
      !
      !> @author 
      !> Julien L. Desmarais
      !
      !> @brief
      !> class encapsulating subroutines to compute the 
      !> gridpoints at the edge of the computational domain
      !
      !> @date
      !> 23_09_2013 - initial version               - J.L. Desmarais
      !> 14_07_2014 - interface for erymanthianboar - J.L. Desmarais
      !-----------------------------------------------------------------
      module bc_operators_class

        use bc_operators_abstract_class, only : bc_operators_abstract
        use sd_operators_class         , only : sd_operators
        use pmodel_eq_class            , only : pmodel_eq
        use parameters_input           , only : nx,ny,ne,bc_size
        use parameters_kind            , only : rkind,ikind
        
        implicit none


        private
        public :: bc_operators


        !> @class bc_operators
        !> class encapsulating subroutines to apply
        !> periodic boundary conditions in the x and
        !> y directions at the edge of the computational
        !> domain
        !>
        !> @param period_x
        !> period along the x-direction
        !>
        !> @param period_y
        !> period along the y-direction
        !> 
        !> @param initialize
        !> initialize the period_x and period_y
        !> attributes of the boundary conditions
        !>
        !> @param apply_bc_on_nodes
        !> apply the periodic boundary conditions along the x and y
        !> directions at the edge of the computational domain
        !> for the field
        !>
        !> @param apply_bc_on_fluxes
        !> apply the periodic boundary conditions for the fluxes
        !---------------------------------------------------------------
        type, extends(bc_operators_abstract) :: bc_operators

          integer(ikind) :: period_x
          integer(ikind) :: period_y

          contains

          procedure,   pass :: ini
          procedure,   pass :: apply_bc_on_nodes
          procedure, nopass :: apply_bc_on_fluxes

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
        !> 24_09_2013 - initial version - J.L. Desmarais
        !
        !>@param this
        !> boundary conditions initialized
        !
        !>@param s
        !> spatial discretisation operators
        !
        !>@param p_model
        !> physical model to know the type of the main variables
        !--------------------------------------------------------------
        subroutine ini(this, p_model)
        
          implicit none

          class(bc_operators), intent(inout) :: this
          type(pmodel_eq)    , intent(in)    :: p_model
          
          integer :: neq

          neq     = p_model%get_eq_nb()

          this%period_x = nx-2*bc_size
          this%period_y = ny-2*bc_size

        end subroutine ini


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> subroutine applying the boundary conditions
        !> along the x and y directions at the edge of the
        !> computational domain
        !
        !> @date
        !> 24_09_2013 - initial version - J.L. Desmarais
        !
        !>@param f
        !> object encapsulating the main variables
        !
        !>@param s
        !> space discretization operators
        !--------------------------------------------------------------
        subroutine apply_bc_on_nodes(this,nodes)

          implicit none

          class(bc_operators)             , intent(in)    :: this
          real(rkind), dimension(nx,ny,ne), intent(inout) :: nodes


          integer(ikind) :: i,j
          integer        :: k

          !<compute the east and west boundary layers
          !>without the north and south corners
          do k=1, ne
             !DEC$ IVDEP
             do j=1+bc_size, ny-bc_size
                !DEC$ UNROLL(2)
                do i=1, bc_size

                   nodes(i,j,k)=
     $                  nodes(i+this%period_x,j,k)
                   nodes(i+this%period_x+bc_size,j,k)= 
     $                  nodes(i+bc_size,j,k)
                   
                end do
             end do
          end do


          !<compute the south and north layers
          !>with the east and west corners
          do k=1, ne
             !DEC$ UNROLL(2)
             do j=1, bc_size
                !DEC$ IVDEP
                do i=1, nx

                   nodes(i,j,k)=
     $                  nodes(i,j+this%period_y,k)
                   nodes(i,j+this%period_y+bc_size,k)=
     $                  nodes(i,j+bc_size,k)

                end do
             end do
          end do

        end subroutine apply_bc_on_nodes


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> subroutine applying the boundary conditions
        !> on the fluxes along the x directions at the
        !> edge of the computational domain
        !
        !> @date
        !> 24_09_2013 - initial version - J.L. Desmarais
        !
        !>@param f_used
        !> object encapsulating the main variables
        !
        !>@param s
        !> space discretization operators
        !
        !>@param flux_x
        !> flux along the x-direction
        !
        !>@param flux_y
        !> flux along the y-direction
        !--------------------------------------------------------------
        subroutine apply_bc_on_fluxes(nodes,dx,dy,s,flux_x,flux_y)

          implicit none

          real(rkind), dimension(nx,ny,ne)  , intent(in)    :: nodes
          real(rkind)                       , intent(in)    :: dx
          real(rkind)                       , intent(in)    :: dy
          type(sd_operators)                , intent(in)    :: s
          real(rkind), dimension(nx+1,ny,ne), intent(inout) :: flux_x
          real(rkind), dimension(nx,ny+1,ne), intent(inout) :: flux_y

          real(rkind) :: node,flux,dx_s,dy_s
          integer :: bc_s

          stop 'periodic_xy: apply_bc_on_fluxes not implemented'

          node=nodes(1,1,1)
          dx_s = dx
          dy_s = dy
          bc_s = s%get_bc_size()

          flux=flux_x(1,1,1)
          flux=flux_y(1,1,1)

        end subroutine apply_bc_on_fluxes

      end module bc_operators_class