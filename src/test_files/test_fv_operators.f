      !> @file
      !> test file for the object 'fv_operators'
      !
      !> @author 
      !> Julien L. Desmarais
      !
      !> @brief
      !> test the computation of the time derivatives
      !> using the finite volume method by comparing 
      !> with expected data
      !
      !> @date
      ! 13_08_2013 - initial version - J.L. Desmarais
      !-----------------------------------------------------------------
      program test_fv_operators

        use cg_operators_class , only : cg_operators
        use field_class        , only : field
        use fv_operators_class , only : fv_operators
        use parameters_input   , only : nx,ny,ne
        use parameters_kind    , only : ikind, rkind
        use simpletest_eq_class, only : simpletest_eq

        implicit none

        
        !<operators tested
        type(field)         :: field_tested
        type(cg_operators)  :: s
        type(simpletest_eq) :: p_model
        type(fv_operators)  :: t_operator

        real(rkind), dimension(nx,ny,ne) :: time_dev

        !<CPU recorded times
        real    :: time1, time2

        !<test parameters
        logical, parameter         :: detailled=.true.
        integer(ikind)             :: i,j
        real(rkind), dimension(12) :: test_data
        logical                    :: test_validated


        !<if nx<4, ny<4 then the test cannot be done
        if((nx.ne.10).or.(ny.ne.6).or.(ne.ne.1)) then
           stop 'the test needs: (nx,ny,ne)=(10,6,1)'
        end if


        !<get the initial CPU time
        call CPU_TIME(time1)


        !<initialize the tables for the field
        field_tested%dx=1.0
        field_tested%dy=1.0

        do j=1, ny
           do i=1, nx
              field_tested%nodes(i,j,1) = i + (j-1)*nx
           end do
        end do


        !<compute the time derivatives
        time_dev = t_operator%compute_time_dev(field_tested,s,p_model)


        !<print the time derivatives
        do j=1+s%get_bc_size(), ny-s%get_bc_size()
           do i=1+s%get_bc_size(), nx-s%get_bc_size()
              test_validated=(time_dev(i,j,1).eq.(-20.0d0))
              print *, i,j, test_validated
           end do
        end do

      end program test_fv_operators
