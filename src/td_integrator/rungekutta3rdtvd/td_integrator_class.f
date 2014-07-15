      !> @file
      !> class encapsulating subroutines to integrate
      !> the governing equations using Runge-Kutta 3rd
      !> order time integration scheme developed in
      !> “Efficient implementation of essentially non-
      !> oscillatory shock-capturing methods”, J. Comput.
      !> Phys., 77 (1988), pp. 439-471, C.-W. Shu and
      !> S. Osher
      !
      !> @author 
      !> Julien L. Desmarais
      !
      !> @brief
      !> class encapsulating subroutines to integrate
      !> the governing equations using Runge-Kutta 3rd
      !> order time integration scheme developed in
      !> “Efficient implementation of essentially non-
      !> oscillatory shock-capturing methods”, J. Comput.
      !> Phys., 77 (1988), pp. 439-471, C.-W. Shu and
      !> S. Osher
      !
      !> @date
      !> 13_08_2013 - initial version                   - J.L. Desmarais
      !
      !> \f{eqnarray*}{
      !> u_1     &=& u_n + \Delta t*\frac{d u_n}{dt} \\\
      !> u_2     &=& \frac{1}{4}u_n + \frac{3}{4} \left(
      !>             u_1 + \Delta t * \frac{d u_1}{dt} \right) \\\
      !> u_{n+1} &=& \frac{1}{3}u_n + \frac{2}{3} \left(
      !>             u_2 + \Delta t * \frac{d u_2}{dt} \right) \\\
      !> \f}
      !-----------------------------------------------------------------
      module td_integrator_class

        use field_abstract_class        , only : field_abstract
        use parameters_input            , only : nx,ny,ne,bc_size
        use parameters_kind             , only : rkind, ikind
        use td_integrator_abstract_class, only : td_integrator_abstract

        implicit none


        !> @class rk3tvd
        !> class encapsulating subroutines to integrate
        !> the governing equations using Runge-Kutta 3rd
        !> order time integration scheme
        !>
        !> @param integrate
        !> integrate the computational field for dt
        !> \f{eqnarray*}{
        !> u_1     &=& u_n + \Delta t*\frac{d u_n}{dt} \\\
        !> u_2     &=& \frac{1}{4}u_n + \frac{3}{4} \left(
        !>             u_1 + \Delta t * \frac{d u_1}{dt} \right) \\\
        !> u_{n+1} &=& \frac{1}{3}u_n + \frac{2}{3} \left(
        !>             u_2 + \Delta t * \frac{d u_2}{dt}\right)\\\
        !> \f}
        !---------------------------------------------------------------
        type, extends(td_integrator_abstract) :: td_integrator

          contains
          procedure, nopass :: integrate

        end type td_integrator


        contains


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> subroutine to integrate the governing equations using
        !> the numerical scheme developed by C.W.Shu and S.Osher
        !
        !> @date
        !> 13_08_2013 - initial version - J.L. Desmarais
        !
        !>@param field_used
        !> object encapsulating the main variables
        !
        !>@param sd
        !> space discretization operators
        !
        !>@param p_model
        !> physical model
        !
        !>@param bc_used
        !> boundary conditions
        !
        !>@param td
        !> time discretisation operators
        !
        !>@param dt
        !> time step integrated
        !--------------------------------------------------------------
        subroutine integrate(field_used, dt)

          implicit none

          class(field_abstract), intent(inout) :: field_used
          real(rkind)          , intent(in)    :: dt

          real(rkind), dimension(nx,ny,ne) :: nodes_tmp
          real(rkind), dimension(nx,ny,ne) :: time_dev
          

          !<runge-kutta first step
          !> u_1 = u_n + dt*d/dt(u_n)
          !> u_n is saved in nodes_tmp
          !> u_1 is saved in field_used%nodes
          !DEC$ FORCEINLINE RECURSIVE
          time_dev = field_used%compute_time_dev()

          !DEC$ FORCEINLINE RECURSIVE
          call field_used%compute_integration_step(
     $         dt, nodes_tmp, time_dev, compute_1st_step)

          !<apply the boundary conditions
          !DEC$ FORCEINLINE RECURSIVE
          call field_used%apply_bc_on_nodes()


          !<runge-kutta second step
          !> u_2 = 1/4*u_n + 3/4*(u_1 + dt * du_1/dt)
          !> u_n is saved in nodes_tmp
          !> u_2 is saved in field_used%nodes
          !DEC$ FORCEINLINE RECURSIVE
          time_dev = field_used%compute_time_dev()

          !DEC$ FORCEINLINE RECURSIVE
          call field_used%compute_integration_step(
     $         dt, nodes_tmp, time_dev, compute_2nd_step)

          !<apply the boundary conditions
          !DEC$ FORCEINLINE RECURSIVE
          call field_used%apply_bc_on_nodes()


          !<runge-kutta third step
          !> u_{n+1} = 1/3*u_n + 2/3*(u_2 + dt du_2/dt
          !> u_n is saved in nodes_tmp
          !> u_{n+1} is saved in field_used%nodes
          !DEC$ FORCEINLINE RECURSIVE
          time_dev = field_used%compute_time_dev()

          !DEC$ FORCEINLINE RECURSIVE
          call field_used%compute_integration_step(
     $         dt, nodes_tmp, time_dev, compute_3rd_step)

          !<apply the boundary conditions
          !DEC$ FORCEINLINE RECURSIVE
          call field_used%apply_bc_on_nodes()

        end subroutine integrate


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> subroutine to compute the 1st runge-kutta step using
        !> the numerical scheme developed by C.W.Shu and S.Osher
        !> \f$ u_1 = u_n + \Delta t*\frac{d u_n}{dt}\f$
        !
        !> @date
        !> 23_09_2013 - initial version - J.L. Desmarais
        !
        !>@param dt
        !> time step
        !
        !>@param time_dev
        !> table containing the time derivative at \f$ t=n \f$
        !
        !>@param field_used
        !> object encapsulating the main variables at \f$ t=\Delta t \f$
        !
        !>@param nodes_tmp
        !> nodes at \f$ t=n \f$
        !--------------------------------------------------------------
        subroutine compute_1st_step(
     $     nodes,
     $     dt,
     $     nodes_tmp,
     $     time_dev)

          implicit none

          real(rkind), dimension(nx,ny,ne), intent(inout) :: nodes
          real(rkind)                     , intent(in)    :: dt 
          real(rkind), dimension(nx,ny,ne), intent(inout) :: nodes_tmp
          real(rkind), dimension(nx,ny,ne), intent(in)    :: time_dev
          
          integer        :: k
          integer(ikind) :: i,j

          
          do k=1, ne
             do j=bc_size+1, ny-bc_size
                do i=bc_size+1, nx-bc_size
                   nodes_tmp(i,j,k) = nodes(i,j,k)
                   nodes(i,j,k)     = nodes(i,j,k) + dt*time_dev(i,j,k)
                end do
             end do
          end do

        end subroutine compute_1st_step


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> subroutine to compute the 2nd runge-kutta step using
        !> the numerical scheme developed by C.W.Shu and S.Osher
        !> \f$u_2 = \frac{1}{4}u_n + \frac{3}{4} \left(
        !> u_1 + \Delta t * \frac{d u_1}{dt} \right) \f$
        !
        !> @date
        !> 23_09_2013 - initial version - J.L. Desmarais
        !
        !>@param dt
        !> time step
        !
        !>@param time_dev
        !> table containing the time derivative at \f$ t=n \f$
        !
        !>@param field_used
        !> object encapsulating the main variables at \f$ t=\Delta t \f$
        !
        !>@param nodes_tmp
        !> nodes at \f$ t=n \f$
        !--------------------------------------------------------------
        subroutine compute_2nd_step(
     $     nodes,
     $     dt,
     $     nodes_tmp,
     $     time_dev)

          implicit none

          real(rkind), dimension(nx,ny,ne), intent(inout) :: nodes
          real(rkind)                     , intent(in)    :: dt
          real(rkind), dimension(nx,ny,ne), intent(inout) :: nodes_tmp
          real(rkind), dimension(nx,ny,ne), intent(in)    :: time_dev
          
          integer        :: k
          integer(ikind) :: i,j

          real(rkind), parameter :: b2 = 0.75d0
          
          if(rkind.eq.8) then
             do k=1, ne
                do j=bc_size+1, ny-bc_size
                   do i=bc_size+1, nx-bc_size
                      nodes(i,j,k) =
     $                     b2*nodes_tmp(i,j,k)+
     $                     (1.0d0-b2)*(nodes(i,j,k)+dt*time_dev(i,j,k))
                   end do
                end do
             end do
          else
             do k=1, ne
                do j=bc_size+1, ny-bc_size
                   do i=bc_size+1, nx-bc_size
                      nodes(i,j,k) = 
     $                     b2*nodes_tmp(i,j,k)+
     $                     (1.0-b2)*(nodes(i,j,k)+dt*time_dev(i,j,k))
                   end do
                end do
             end do
          end if

        end subroutine compute_2nd_step


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> subroutine to compute the 3rd runge-kutta step using
        !> the numerical scheme developed by C.W.Shu and S.Osher
        !> \f$ u_{n+1} = \frac{1}{3}u_n + \frac{2}{3} \left(
        !>             u_2 + \Delta t * \frac{d u_2}{dt}\right) \f$
        !> @date
        !> 23_09_2013 - initial version - J.L. Desmarais
        !
        !>@param dt
        !> time step
        !
        !>@param time_dev
        !> table containing the time derivative at \f$ t=n \f$
        !
        !>@param field_used
        !> object encapsulating the main variables at \f$ t=\Delta t \f$
        !
        !>@param nodes_tmp
        !> nodes at \f$ t=n \f$
        !--------------------------------------------------------------
        subroutine compute_3rd_step(
     $     nodes,
     $     dt,
     $     nodes_tmp,
     $     time_dev)

          implicit none

          real(rkind), dimension(nx,ny,ne), intent(inout) :: nodes
          real(rkind)                     , intent(in)    :: dt
          real(rkind), dimension(nx,ny,ne), intent(inout) :: nodes_tmp
          real(rkind), dimension(nx,ny,ne), intent(in)    :: time_dev


          integer        :: k
          integer(ikind) :: i,j

          real(rkind), parameter :: b3 = 1.0d0/3.0d0

          if(rkind.eq.8) then

             do k=1 ,ne
                do j=bc_size+1, ny-bc_size
                   do i=bc_size+1, nx-bc_size
                      nodes(i,j,k) =
     $                     b3*nodes_tmp(i,j,k)+
     $                     (1.0d0-b3)*(nodes(i,j,k)+dt*time_dev(i,j,k))
                   end do
                end do
             end do

          else

             do k=1 ,ne
                do j=bc_size+1, ny-bc_size
                   do i=bc_size+1, nx-bc_size
                      nodes(i,j,k) =
     $                     b3*nodes_tmp(i,j,k)+
     $                     (1.0-b3)*(nodes(i,j,k)+dt*time_dev(i,j,k))
                   end do
                end do
             end do

          end if

        end subroutine compute_3rd_step

      end module td_integrator_class


c$$$      print *,'first step'
c$$$
c$$$          do j=1, nodes_profile(2)
c$$$             do i=1, nodes_profile(1)
c$$$                print '(''('',I2,'','',I2,'')'', 3X,
c$$$     $                  ''u1='',F10.2)',
c$$$     $               i,j,
c$$$     $               field_used%nodes(i,j,1)
c$$$             end do
c$$$          end do

c$$$         print *,'second step'
c$$$
c$$$          do j=1, nodes_profile(2)
c$$$             do i=1, nodes_profile(1)
c$$$                print '(''('',I2,'','',I2,'')'', 3X,
c$$$     $                  ''u2='',F10.2)',
c$$$     $               i,j,
c$$$     $               field_used%nodes(i,j,1)
c$$$             end do
c$$$          end do

c$$$         do j=1, nodes_profile(2)-2*bc_size
c$$$             do i=1, nodes_profile(1)-2*bc_size
c$$$                print '(''('',I2,'','',I2,'')'', 3X,
c$$$     $                  ''time_dev='',F10.2)',
c$$$     $               i,j,
c$$$     $               time_dev(i,j,1)
c$$$             end do
c$$$          end do
