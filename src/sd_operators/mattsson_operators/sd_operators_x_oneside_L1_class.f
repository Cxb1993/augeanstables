      !> @file
      !> class encapsulating subroutines for the space discretization
      !> using one-side operators in the x-direction with one grid point
      !> on the left side
      !
      !> @author 
      !> Julien L. Desmarais
      !
      !> @brief
      !> class encapsulating subroutines for the space discretisation
      !> using operators that are 1st order accurate in the x-direction
      !> with one grid point on the left side and operators that are 2nd
      !> order accurate in the y-direction
      !
      !> @date
      !> 29_07_2014 - Initial version - J.L. Desmarais
      !-----------------------------------------------------------------
      module sd_operators_x_oneside_L1_class

        use sd_operators_fd_module, only :
     $       gradient_x_x_oneside_L0,
     $       gradient_x_interior,
     $       gradient_y_interior

        use interface_primary, only :
     $       get_primary_var,
     $       get_secondary_var

        use parameters_constant, only :
     $       sd_L1_type

        use parameters_kind, only :
     $       ikind,
     $       rkind

        use sd_operators_class, only :
     $       sd_operators

        implicit none

        private
        public :: sd_operators_x_oneside_L1


        !> @class sd_operators_x_oneside_L1
        !> class encapsulating 
        !
        !> @param get_bc_size
        !> get the boundary layer size
        !
        !> @param get_operator_type
        !> get the type of operator
        !
        !> @param f
        !> evaluate data at [i-1/2,j]
        !
        !> @param dfdx
        !> evaluate \f$\frac{\partial}{\partial x}\f$ at [i-1/2,j]
        !
        !> @param dfdy
        !> evaluate \f$\frac{\partial}{\partial y}\f$ at [i-1/2,j]
        !
        !> @param d2fdx2
        !> evaluate \f$\frac{\partial}{\partial x^2}\f$ at [i-1/2,j]
        !
        !> @param d2fdy2
        !> evaluate \f$\frac{\partial}{\partial y^2}\f$ at [i-1/2,j]
        !
        !> @param d2fdxdy
        !> evaluate \f$\frac{\partial}{\partial x \partial y}\f$
        !> at [i-1/2,j]
        !        
        !> @param g
        !> evaluate data at [i,j-1/2]
        !
        !> @param dgdx
        !> evaluate \f$\frac{\partial}{\partial x}\f$ at [i,j-1/2]
        !
        !> @param dgdy
        !> evaluate \f$\frac{\partial}{\partial y}\f$ at [i,j-1/2]
        !
        !> @param d2gdx2
        !> evaluate \f$\frac{\partial}{\partial x^2}\f$ at [i,j-1/2]
        !
        !> @param d2gdy2
        !> evaluate \f$\frac{\partial}{\partial y^2}\f$ at [i,j-1/2]
        !
        !> @param d2gdxdy
        !> evaluate \f$\frac{\partial}{\partial x \partial y}\f$
        !> at [i,j-1/2]
        !---------------------------------------------------------------
        type, extends(sd_operators) :: sd_operators_x_oneside_L1

          contains

          procedure, nopass :: get_operator_type

          procedure, nopass :: dfdx_nl     => dfdx_x_oneside_L1_nl
          procedure, nopass :: d2fdx2      => d2fdx2_x_oneside_L1

        end type sd_operators_x_oneside_L1

        contains


        !> @author 
        !> Julien L. Desmarais
        !
        !> @brief
        !> get the type of operator
        !
        !> @date
        !> 28_01_2015 - initial version - J.L. Desmarais
        !
        !>@param operator_type
        !> integer identifying the type of operator
        !---------------------------------------------------------------
        function get_operator_type() result(operator_type)

          integer :: operator_type

          operator_type = sd_L1_type

        end function get_operator_type


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute \f$ \frac{\partial u}{\partial x} \bigg|_{i-\frac{1}{2}
        !> ,j} = \frac{1}{\Delta x}(- 2 u_{i,j} + 3 u_{i+1,j} - u_{i+2,j})
        !> \f$
        !
        !> @date
        !> 29_07_2014 - initial version  - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@param i
        !> index along x-axis where the data is evaluated
        !
        !>@param j
        !> index along y-axis where the data is evaluated
        !
        !>@param proc
        !> procedure computing the special quantity evaluated at [i,j]
        !> (ex: pressure, temperature,...)
        !
        !>@param dx
        !> grid step along the x-axis
        !
        !>@param dy
        !> grid step along the y-axis
        !
        !>@param var
        !> data evaluated at [i,j]
        !---------------------------------------------------------------
        function dfdx_x_oneside_L1_nl(nodes,i,j,proc,dx,dy) result(var)

          implicit none

          real(rkind), dimension(:,:,:), intent(in) :: nodes
          integer(ikind)               , intent(in) :: i
          integer(ikind)               , intent(in) :: j
          procedure(get_secondary_var)              :: proc
          real(rkind)                  , intent(in) :: dx
          real(rkind)                  , intent(in) :: dy
          real(rkind)                               :: var

          if(rkind.eq.8) then

             !TAG INLINE
             var = 1.0d0/dx*(
     $            -proc(nodes,i-1,j,dx,dy,gradient_x_x_oneside_L0,gradient_y_interior)
     $            +proc(nodes,i  ,j,dx,dy,gradient_x_interior    ,gradient_y_interior))
          else
             var = 1.0/dx*(
     $            -proc(nodes,i-1,j,dx,dy,gradient_x_x_oneside_L0,gradient_y_interior)
     $            +proc(nodes,i  ,j,dx,dy,gradient_x_interior    ,gradient_y_interior))
          end if

        end function dfdx_x_oneside_L1_nl

        
        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute \f$ \frac{\partial^2 u}{\partial x^2}\bigg|
        !> _{i-\frac{1}{2},j} = \frac{1}{2 {\Delta x}^2}(u_{i-1,j} +
        !> u_{i,j} - 7 u_{i+1,j} + 7 u_{i+2,j} - 2 u_{i+3,j}) \f$
        !
        !> @date
        !> 29_07_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@param i
        !> index along x-axis where the data is evaluated
        !
        !>@param j
        !> index along y-axis where the data is evaluated
        !
        !>@param proc
        !> procedure computing the special quantity evaluated at [i,j]
        !> (ex: pressure, temperature,...)
        !
        !>@param dx
        !> grid step along the x-axis
        !
        !>@param var
        !> data evaluated at [i,j]
        !---------------------------------------------------------------
        function d2fdx2_x_oneside_L1(
     $     nodes,i,j,proc,dx)
     $     result(var)

          implicit none

          real(rkind), dimension(:,:,:), intent(in) :: nodes
          integer(ikind)               , intent(in) :: i
          integer(ikind)               , intent(in) :: j
          procedure(get_primary_var)                :: proc
          real(rkind)                  , intent(in) :: dx
          real(rkind)                               :: var

          if(rkind.eq.8) then
             !TAG INLINE
             var = 0.5d0/(dx**2)*(
     $            +      proc(nodes,i-1,j)
     $            +      proc(nodes,i  ,j)
     $            -7.0d0*proc(nodes,i+1,j)
     $            +7.0d0*proc(nodes,i+2,j)
     $            -2.0d0*proc(nodes,i+3,j)
     $            )
          else
             var = 0.5/(dx**2)*(
     $            +    proc(nodes,i-1,j)
     $            +    proc(nodes,i  ,j)
     $            -7.0*proc(nodes,i+1,j)
     $            +7.0*proc(nodes,i+2,j)
     $            -2.0*proc(nodes,i+3,j)
     $            )
          end if

        end function d2fdx2_x_oneside_L1
        
      end module sd_operators_x_oneside_L1_class
