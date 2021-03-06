      module wave2d_ncoords_module

        use interface_primary       , only : gradient_n_proc
        use wave2d_prim_module      , only : position,
     $                                       velocity_x,
     $                                       velocity_y
        use parameters_input        , only : nx,ny,ne
        use parameters_kind         , only : ikind, rkind


        private
        public :: compute_n_gradient,
     $            compute_n_eigenvalues,
     $            compute_n1_lefteigenvector,
     $            compute_n1_righteigenvector,
     $            compute_n2_lefteigenvector,
     $            compute_n2_righteigenvector


        contains


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> interface for the computation of the gradient of the
        !> governing variables in the (x-y)-direction
        !
        !> @date
        !> 05_08_2014 - initial version - J.L. Desmarais
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
        !> procedure used to compute the gradient along the
        !> diagonal direction
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

          real(rkind), dimension(nx,ny,ne), intent(in) :: nodes
          integer(ikind)                  , intent(in) :: i
          integer(ikind)                  , intent(in) :: j
          procedure(gradient_n_proc)                   :: gradient
          real(rkind)                     , intent(in) :: dx
          real(rkind)                     , intent(in) :: dy
          real(rkind), dimension(ne)                   :: grad_var


          grad_var(1) = gradient(nodes,i,j,position  ,dx,dy)
          grad_var(2) = gradient(nodes,i,j,velocity_x,dx,dy)
          grad_var(3) = gradient(nodes,i,j,velocity_y,dx,dy)

        end function compute_n_gradient


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> computation of the eigenvalues for the hyperbolic terms
        !> in the (x-y)-direction
        !
        !> @date
        !> 05_08_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@return eigenvalues
        !> eigenvalues at the location of the grid point
        !--------------------------------------------------------------
        function compute_n_eigenvalues(nodes) result(eigenvalues)

          implicit none

          real(rkind), dimension(ne), intent(in) :: nodes
          real(rkind), dimension(ne)             :: eigenvalues


          real(rkind) :: node_s

          node_s = nodes(1)

          if(rkind.eq.8) then
             eigenvalues(1) =  0.0d0
             eigenvalues(2) = -Sqrt(2.0d0)*c**2
             eigenvalues(3) =  Sqrt(2.0d0)*c**2
          else
             eigenvalues(1) = 0.0
             eigenvalues(2) = -Sqrt(2.0)*c**2
             eigenvalues(3) =  Sqrt(2.0)*c**2
          end if

        end function compute_n_eigenvalues


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> computation of the left eigenvector for the hyperbolic terms
        !> in the (x-y)-direction. By denoting L the left eigenmatrix, the
        !> result of the function is L[k,:]
        !
        !> @date
        !> 05_08_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@param k
        !> integer identifying the eigenvector
        !
        !>@return eigenvalues
        !> eigenvalues at the location of the grid point
        !--------------------------------------------------------------
        function compute_n1_lefteigenvector(nodes,k) result(eigenvect)

          implicit none

          real(rkind), dimension(ne), intent(in) :: nodes
          integer                   , intent(in) :: k
          real(rkind), dimension(ne)             :: eigenvect


          real(rkind) :: node_s

          node_s = nodes(1)


          select case(k)
            case(1)
               if(rkind.eq.8) then
                  eigenvect(1) = 0.0d0
                  eigenvect(2) = 0.5d0
                  eigenvect(3) = 0.5d0
               else
                  eigenvect(1) = 0.0
                  eigenvect(2) = 0.5
                  eigenvect(3) = 0.5
               end if
            case(2)
               if(rkind.eq.8) then
                  eigenvect(1) =-0.5d0/Sqrt(2.0d0)
                  eigenvect(2) =-0.25d0
                  eigenvect(3) = 0.25d0
               else
                  eigenvect(1) =-0.5/Sqrt(2.0)
                  eigenvect(2) =-0.25
                  eigenvect(3) = 0.25
               end if
            case(3)
               if(rkind.eq.8) then
                  eigenvect(1) = 0.5d0/Sqrt(2.0d0)
                  eigenvect(2) =-0.25d0
                  eigenvect(3) = 0.25d0
               else
                  eigenvect(1) = 0.5/Sqrt(2.0)
                  eigenvect(2) =-0.25
                  eigenvect(3) = 0.25
               end if
            case default
               print '(''wave2d: compute_x_righteigenvector'')'
               print '(''k: '',I2)', k
               stop 'k not recognized'
          end select

        end function compute_n1_lefteigenvector


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> computation of the right eigenvector for the hyperbolic terms
        !> in the (x-y)-direction. By denoting R the right eigenmatrix, the
        !> result of the function is R[k,:]
        !
        !> @date
        !> 05_08_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@param k
        !> integer identifying the eigenvector
        !
        !>@return eigenvect
        !> eigenvector at the location of the grid point
        !--------------------------------------------------------------
        function compute_n1_righteigenvector(nodes,k) result(eigenvect)

          implicit none

          real(rkind), dimension(ne), intent(in) :: nodes
          integer                   , intent(in) :: k
          real(rkind), dimension(ne)             :: eigenvect


          real(rkind) :: node_s

          node_s = nodes(1)

          select case(k)
            case(1)
               if(rkind.eq.8) then
                  eigenvect(1) =  0.0d0
                  eigenvect(2) = -Sqrt(2.0d0)
                  eigenvect(3) =  Sqrt(2.0d0)
               else
                  eigenvect(1) =  0.0
                  eigenvect(2) = -Sqrt(2.0)
                  eigenvect(3) =  Sqrt(2.0)
               end if
            case(2)
               if(rkind.eq.8) then
                  eigenvect(1) = 1.0d0
                  eigenvect(2) =-1.0d0
                  eigenvect(3) =-1.0d0
               else
                  eigenvect(1) = 1.0
                  eigenvect(2) =-1.0
                  eigenvect(3) =-1.0
               end if
            case(3)
               if(rkind.eq.8) then
                  eigenvect(1) = 1.0d0
                  eigenvect(2) = 1.0d0
                  eigenvect(3) = 1.0d0
               else
                  eigenvect(1) = 1.0
                  eigenvect(2) = 1.0
                  eigenvect(3) = 1.0
               end if
            case default
               print '(''wave2d: compute_x_lefteigenvector'')'
               print '(''k: '',I2)', k
               stop 'k not recognized'
          end select          

        end function compute_n1_righteigenvector


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> computation of the left eigenvector for the hyperbolic terms
        !> in the (x+y)-direction. By denoting L the left eigenmatrix, the
        !> result of the function is L[k,:]
        !
        !> @date
        !> 06_08_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@param k
        !> integer identifying the eigenvector
        !
        !>@return eigenvalues
        !> eigenvalues at the location of the grid point
        !--------------------------------------------------------------
        function compute_n2_lefteigenvector(nodes,k) result(eigenvect)

          implicit none

          real(rkind), dimension(ne), intent(in) :: nodes
          integer                   , intent(in) :: k
          real(rkind), dimension(ne)             :: eigenvect


          real(rkind) :: node_s

          node_s = nodes(1)


          select case(k)
            case(1)
               if(rkind.eq.8) then
                  eigenvect(1) = 0.0d0
                  eigenvect(2) =-0.5d0
                  eigenvect(3) = 0.5d0
               else
                  eigenvect(1) = 0.0
                  eigenvect(2) =-0.5
                  eigenvect(3) = 0.5
               end if
            case(2)
               if(rkind.eq.8) then
                  eigenvect(1) = 0.5d0/Sqrt(2.0d0)
                  eigenvect(2) = 0.25d0
                  eigenvect(3) = 0.25d0
               else
                  eigenvect(1) = 0.5/Sqrt(2.0)
                  eigenvect(2) = 0.25
                  eigenvect(3) = 0.25
               end if
            case(3)
               if(rkind.eq.8) then
                  eigenvect(1) =-0.5d0/Sqrt(2.0d0)
                  eigenvect(2) = 0.25d0
                  eigenvect(3) = 0.25d0
               else
                  eigenvect(1) =-0.5/Sqrt(2.0)
                  eigenvect(2) = 0.25
                  eigenvect(3) = 0.25
               end if
            case default
               print '(''wave2d: compute_x_righteigenvector'')'
               print '(''k: '',I2)', k
               stop 'k not recognized'
          end select

        end function compute_n2_lefteigenvector


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> computation of the right eigenvector for the hyperbolic terms
        !> in the (x+y)-direction. By denoting R the right eigenmatrix, the
        !> result of the function is R[k,:]
        !
        !> @date
        !> 06_08_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes
        !> array with the grid point data
        !
        !>@param k
        !> integer identifying the eigenvector
        !
        !>@return eigenvect
        !> eigenvector at the location of the grid point
        !--------------------------------------------------------------
        function compute_n2_righteigenvector(nodes,k) result(eigenvect)

          implicit none

          real(rkind), dimension(ne), intent(in) :: nodes
          integer                   , intent(in) :: k
          real(rkind), dimension(ne)             :: eigenvect


          real(rkind) :: node_s

          node_s = nodes(1)

          select case(k)
            case(1)
               if(rkind.eq.8) then
                  eigenvect(1) =  0.0d0
                  eigenvect(2) =  Sqrt(2.0d0)
                  eigenvect(3) = -Sqrt(2.0d0)
               else
                  eigenvect(1) =  0.0
                  eigenvect(2) =  Sqrt(2.0)
                  eigenvect(3) = -Sqrt(2.0)
               end if
            case(2)
               if(rkind.eq.8) then
                  eigenvect(1) =-1.0d0
                  eigenvect(2) = 1.0d0
                  eigenvect(3) = 1.0d0
               else
                  eigenvect(1) =-1.0
                  eigenvect(2) = 1.0
                  eigenvect(3) = 1.0
               end if
            case(3)
               if(rkind.eq.8) then
                  eigenvect(1) = 1.0d0
                  eigenvect(2) = 1.0d0
                  eigenvect(3) = 1.0d0
               else
                  eigenvect(1) = 1.0
                  eigenvect(2) = 1.0
                  eigenvect(3) = 1.0
               end if
            case default
               print '(''wave2d: compute_x_lefteigenvector'')'
               print '(''k: '',I2)', k
               stop 'k not recognized'
          end select          

        end function compute_n2_righteigenvector

      end module wave2d_n_module
      
