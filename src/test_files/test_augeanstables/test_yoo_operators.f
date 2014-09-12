      program test_yoo_operators

        use bc_operators_class, only :
     $     bc_operators

        use ns2d_parameters, only :
     $       gamma,
     $       mach_infty

        use openbc_operators_module, only :
     $       compute_fluxes_at_the_edges_2ndorder

        use parameters_constant, only :
     $       vector_x,
     $       x_direction

        use parameters_input, only :
     $       sigma_P,
     $       flow_direction,
     $       nx,ny,ne,bc_size

        use parameters_kind, only :
     $       ikind,
     $       rkind

        use pmodel_eq_class, only :
     $       pmodel_eq

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


        real(rkind), dimension(nx,ny,ne)   :: nodes
        real(rkind), dimension(nx)         :: x_map
        real(rkind), dimension(ny)         :: y_map
        real(rkind)                        :: t
        real(rkind)                        :: dx
        real(rkind)                        :: dy
        type(pmodel_eq)                    :: p_model
        real(rkind), dimension(nx+1,ny,ne) :: flux_x
        real(rkind), dimension(nx,ny+1,ne) :: flux_y
        real(rkind), dimension(nx,ny,ne)   :: timedev
        type(bc_operators)                 :: bc_used

        logical :: test_validated
        logical :: detailled
        

        !check the parameters
        if((nx.ne.5).or.(ny.ne.5).or.(ne.ne.4)) then
           print '(''test designed for:'')'
           print '(''nx=5'')'
           print '(''ny=5'')'
           print '(''pm_model=ns2d'')'
           stop 'change inputs'
        end if

        
        detailled = .false.
        if(
     $       (.not.is_test_validated(gamma,5.0d0/3.0d0,detailled)).or.
     $       (.not.is_test_validated(mach_infty,0.2d0,detailled)).or.
     $       (.not.is_test_validated(sigma_P,0.25d0,detailled)).or.
     $       (.not.(flow_direction.eq.x_direction))) then

           print '(''the test requires: '')'
           print '(''gamma=5/3'')'
           print '(''mach_infty=0.2'')'
           print '(''sigma_P=0.25'')'
           print '(''flow_direction=x-direction'')'
           stop ''

        end if


        !test compute_fluxes_and_lodi_at_the_edges_2ndorder
        print '(''test compute_fluxes_and_lodi_at_the_edges_2ndorder'')'
        print '(''--------------------------------------------------'')'

        detailled = .false.

        call initialize_nodes(p_model,nodes,x_map,y_map,dx,dy)

        test_validated = test_compute_edge_fluxes(
     $       p_model,nodes,x_map,y_map,
     $       bc_used,
     $       detailled)
        print '()'
        


        !test apply_bc_on_timedev
        print '(''test apply_bc_on_timedev'')'
        print '(''---------------------------------------'')'

        detailled = .false.

        call initialize_nodes(p_model,nodes,x_map,y_map,dx,dy)

        call bc_used%ini(p_model)

        call bc_used%apply_bc_on_timedev(
     $       p_model,
     $       t,nodes,x_map,y_map,
     $       flux_x,flux_y,
     $       timedev)


        contains

        !initialize the nodes
        subroutine initialize_nodes(p_model,nodes,x_map,y_map,dx,dy)

          implicit none

          type(pmodel_eq)                 , intent(in)  :: p_model
          real(rkind), dimension(nx,ny,ne), intent(out) :: nodes
          real(rkind), dimension(nx)      , intent(out) :: x_map
          real(rkind), dimension(ny)      , intent(out) :: y_map
          real(rkind)                     , intent(out) :: dx
          real(rkind)                     , intent(out) :: dy

          integer, dimension(ne) :: var_type
          integer(ikind) :: i,j
          integer        :: k


          !fill the nodes (i in [1,3])x(j in [1,5])
          !mass----------------
          nodes(1,1,1) =  2.3d0
          nodes(2,1,1) =  1.02d0
          nodes(3,1,1) =  3.2d0
                          
          nodes(1,2,1) =  1.2d0
          nodes(2,2,1) =  8.6d0
          nodes(3,2,1) =  6.13d0
                          
          nodes(1,3,1) =  0.23d0
          nodes(2,3,1) =  4.5d0
          nodes(3,3,1) =  7.13d0
                          
          nodes(1,4,1) =  8.5d0
          nodes(2,4,1) =  7.8d0
          nodes(3,4,1) =  1.5d0
                          
          nodes(1,5,1) =  0.2d0
          nodes(2,5,1) =  3.6d0
          nodes(3,5,1) =  9.23d0

          !momentum-x----------
          nodes(1,1,2) = -6.045d0
          nodes(2,1,2) =  8.125d0
          nodes(3,1,2) =  0.0d0
                    
          nodes(1,2,2) = -6.3d0
          nodes(2,2,2) =  7.98d0
          nodes(3,2,2) =  0.0d0
                    
          nodes(1,3,2) = -0.15d0
          nodes(2,3,2) = -6.213d0
          nodes(3,3,2) =  0.0d0
                    
          nodes(1,4,2) =  8.23d0
          nodes(2,4,2) =  3.012d0
          nodes(3,4,2) =  0.0d0
                    
          nodes(1,5,2) = -1.23d0
          nodes(2,5,2) =  7.8d0
          nodes(3,5,2) =  0.0d0

          !momentum-y----------
          nodes(1,1,3) =  2.01d0
          nodes(2,1,3) =  3.25d0
          nodes(3,1,3) =  6.2d0
                    
          nodes(1,2,3) =  7.135d0
          nodes(2,2,3) = -2.01d0
          nodes(3,2,3) =  3.06d0
                    
          nodes(1,3,3) =  9.46d0
          nodes(2,3,3) =  9.16d0
          nodes(3,3,3) =  4.12d0
                    
          nodes(1,4,3) =  2.13d0
          nodes(2,4,3) = -2.15d0
          nodes(3,4,3) = -3.25d0
                    
          nodes(1,5,3) =  6.1023d0
          nodes(2,5,3) =  5.23d0
          nodes(3,5,3) =  1.12d0

          !total_energy--------
          nodes(1,1,4) =  20.1d0
          nodes(2,1,4) =  895.26d0
          nodes(3,1,4) =  961.23d0

          nodes(1,2,4) =  78.256d0
          nodes(2,2,4) =  8.45d0
          nodes(3,2,4) =  7.4d0

          nodes(1,3,4) =  256.12d0
          nodes(2,3,4) =  163.48d0
          nodes(3,3,4) =  9.56d0
                    
          nodes(1,4,4) =  56.12d0
          nodes(2,4,4) =  7.89d0
          nodes(3,4,4) =  629.12d0
                    
          nodes(1,5,4) =  102.3d0
          nodes(2,5,4) =  231.02d0
          nodes(3,5,4) =  7.123d0

          
          !fill the nodes (i in [4,5])x(j in [1,5]) by using
          !the symmetry along the x-axis
          var_type = p_model%get_var_type()

          do k=1, ne
             do j=1,5
                do i=1,2
                   if(var_type(k).eq.vector_x) then
                      nodes(6-i,j,k) = - nodes(i,j,k)
                   else
                      nodes(6-i,j,k) =   nodes(i,j,k)
                   end if
                end do
             end do
          end do


          !set to zero the nodes (i in [3])x(j in [1,5]) for
          !variables of type vector_x
          i=3
          do k=1,ne
             if(var_type(k).eq.vector_x) then
                do j=1,5
                   nodes(i,j,k)=0.0
                end do
             end if
          end do


          !initialize dx
          dx = 0.4d0

          !intiialize dy
          dy = 0.6d0

          !initialize the x_map
          do i=1,5
             x_map(i) = (i-1)*dx
          end do

          !initialize the y_map
          do i=1,5
             y_map(i) = (i-1)*dy
          end do
          
        end subroutine initialize_nodes


        !check the data
        function is_test_validated(var,cst,detailled) result(test_validated)

          implicit none

          real(rkind), intent(in) :: var
          real(rkind), intent(in) :: cst
          logical    , intent(in) :: detailled
          logical                 :: test_validated

          if(detailled) then
             print *, int(var*1e5)
             print *, int(cst*1e5)
          end if
          
          test_validated=abs(
     $         int(var*10000.)-
     $         sign(int(abs(cst*10000.)),int(cst*10000.))).le.1
          
        end function is_test_validated


        !test compute_edge_fluxes
        function test_compute_edge_fluxes(
     $     p_model,nodes,x_map,y_map,
     $     bc_used,
     $     detailled)
     $     result(test_validated)

          implicit none

          type(pmodel_eq)                 , intent(in)    :: p_model
          real(rkind), dimension(nx,ny,ne), intent(in)    :: nodes
          real(rkind), dimension(nx)      , intent(in)    :: x_map
          real(rkind), dimension(ny)      , intent(in)    :: y_map
          type(bc_operators)              , intent(inout) :: bc_used
          logical                         , intent(in)    :: detailled
          logical                                         :: test_validated

          type(sd_operators_x_oneside_L0) :: s_x_L0
          type(sd_operators_x_oneside_L1) :: s_x_L1
          type(sd_operators_x_oneside_R1) :: s_x_R1
          type(sd_operators_x_oneside_R0) :: s_x_R0
          type(sd_operators_y_oneside_L0) :: s_y_L0
          type(sd_operators_y_oneside_L1) :: s_y_L1
          type(sd_operators_y_oneside_R1) :: s_y_R1
          type(sd_operators_y_oneside_R0) :: s_y_R0
 
          real(rkind), dimension(nx+1,ny,ne) :: test_data_flux_x
          real(rkind), dimension(nx,ny+1,ne) :: test_data_flux_y
          real(rkind), dimension(nx+1,ny,ne) :: flux_x
          real(rkind), dimension(nx,ny+1,ne) :: flux_y

          logical        :: test_loc
          integer(ikind) :: i,j
          integer        :: k


          !computation of the test data
          call compute_fluxes_at_the_edges_2ndorder(
     $         nodes, dx, dy,
     $         s_x_L0, s_x_L1, s_x_R1, s_x_R0,
     $         s_y_L0, s_y_L1, s_y_R1, s_y_R0,
     $         p_model,
     $         test_data_flux_x, test_data_flux_y)

          !computation of the data to be tested
          call bc_used%ini(p_model)

          call bc_used%apply_bc_on_timedev(
     $         p_model,
     $         t,nodes,x_map,y_map,
     $         flux_x,flux_y,
     $         timedev)

          !comparison of the data
          test_validated = .true.

          do k=1, ne
             do j=1, bc_size
                do i=bc_size+1, nx-bc_size+1
                   
                   test_loc = is_test_validated(
     $                  flux_x(i,j,k),
     $                  test_data_flux_x(i,j,k),
     $                  detailled)
                   test_validated = test_validated.and.test_loc

                end do
             end do

             do j=ny-bc_size+1, ny
                do i=bc_size+1, nx-bc_size+1
                   
                   test_loc = is_test_validated(
     $                  flux_x(i,j,k),
     $                  test_data_flux_x(i,j,k),
     $                  detailled)
                   test_validated = test_validated.and.test_loc

                end do
             end do

          end do
          if(.not.detailled) then
             print '(''test_flux_x(edge): '',L1)', test_validated
          end if


          test_validated=.true.
          
          do k=1, ne
             do j=bc_size+1, ny-bc_size+1
                do i=1, bc_size
                   
                   test_loc = is_test_validated(
     $                  flux_y(i,j,k),
     $                  test_data_flux_y(i,j,k),
     $                  detailled)
                   test_validated = test_validated.and.test_loc

                end do

                do i=nx-bc_size+1,nx
                   
                   test_loc = is_test_validated(
     $                  flux_y(i,j,k),
     $                  test_data_flux_y(i,j,k),
     $                  detailled)
                   test_validated = test_validated.and.test_loc

                end do
             end do
          end do

          if(.not.detailled) then
             print '(''test_flux_y(edge): '',L1)', test_validated
          end if

        end function test_compute_edge_fluxes

      end program test_yoo_operators