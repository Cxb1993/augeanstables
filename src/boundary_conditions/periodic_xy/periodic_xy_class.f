      !> @file
      !> class encapsulating subroutines to apply periodic
      !> boundary conditions in the x and y directions
      !
      !> @author 
      !> Julien L. Desmarais
      !
      !> @brief
      !> class encapsulating subroutines to apply periodic
      !> boundary conditions in the x and y directions
      !
      !> @date
      !> 13_08_2013 - initial version                   - J.L. Desmarais
      !-----------------------------------------------------------------
      module periodic_xy_class

        use cg_operators_class, only : cg_operators
        use field_class       , only : field
        use parameters_kind   , only : ikind, rkind

        implicit none
        
        
        private
        public :: periodic_xy


        !> @class periodic_xy
        !> class encapsulating subroutines to apply periodic
        !> boundary conditions in the x and y directions
        !>
        !> @param apply_bc_on_nodes
        !> apply the periodic boundary conditions along the x and y
        !> directions at the edge of the computational domain
        !---------------------------------------------------------------
        type :: periodic_xy

          contains

          procedure, nopass, non_overridable :: apply_bc_on_nodes

        end type periodic_xy


        contains


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> subroutine applying the periodic boundary conditions
        !> along the x and y directions
        !
        !> @date
        !> 13_08_2013 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> main variables on the 2d computational field
        !
        !>@param s
        !> space discretization operators
        !--------------------------------------------------------------
        subroutine apply_bc_on_nodes(nodes,s)
        
          implicit none

          real(rkind), dimension(:,:,:), intent(inout) :: nodes
          type(cg_operators)           , intent(in)    :: s


          integer(ikind) :: i
          integer(ikind) :: j
          integer        :: k
          integer        :: bc_size
          integer        :: period_x
          integer        :: period_y


          bc_size  = s%get_bc_size()
          period_x = size(nodes,1)-2*bc_size
          period_y = size(nodes,2)-2*bc_size


          !<compute the east and west boundary layers
          !>without the north and south corners
          do k=1, size(nodes,3)
             do j=1+bc_size, size(nodes,2)-bc_size
                do i=1, bc_size

                   nodes(i,j,k)=nodes(i+period_x,j,k)
                   nodes(i+period_x+bc_size,j,k)=nodes(i+bc_size,j,k)
                   
                end do
             end do
          end do


          !<compute the south and north layers
          !>with the east and west corners
          do k=1, size(nodes,3)
             do j=1, bc_size
                do i=1, size(nodes,1)

                   nodes(i,j,k)=nodes(i,j+period_y,k)
                   nodes(i,j+period_y+bc_size,k)=nodes(i,j+bc_size,k)

                end do
             end do
          end do

        end subroutine apply_bc_on_nodes

      end module periodic_xy_class
