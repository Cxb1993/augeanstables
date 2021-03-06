      !> @file
      !> test file for the 'bc_operators_par'
      !> for the reflection boundary conditions
      !
      !> @author 
      !> Julien L. Desmarais
      !
      !> @brief
      !> test the application of the reflection boundary conditions
      !> in a parallel memory distributed system
      !
      !> @date
      ! 26_08_2013 - initial version - J.L. Desmarais
      !-----------------------------------------------------------------
      program test_reflection_xy_par

        use bc_operators_par_class, only : bc_operators_par
        use sd_operators_class    , only : sd_operators
        use pmodel_eq_class       , only : pmodel_eq
        use mpi
        use mpi_process_class     , only : mpi_process
        use parameters_constant   , only : reflection_xy_choice
        use parameters_input      , only : nx,ny,ne,npx,npy,bc_choice
        use parameters_kind       , only : ikind,rkind

        implicit none


        !< operators tested
        integer :: comm_2d
        integer :: usr_rank
        real(rkind), dimension(nx,ny,ne) :: nodes
        type(mpi_process)     :: mpi_op
        type(bc_operators_par):: bc_par_tested
        type(pmodel_eq)       :: p_model

        
        !< intermediate variables
        logical :: test=.true.
        logical :: test_validated


        !< the test is designed for (npx,npy)=(2,2)
        !> and reflection boundary conditions
        if((npx.ne.2).or.(npy.ne.2).or.
     $       (bc_choice.ne.reflection_xy_choice)) then
           print '(''the test needs (npx,npy,bc_choice)='')'
           stop '(2,2,reflection_xy_choice)'
        end if


        !< initialization of the mpi process
        call mpi_op%ini_mpi()


        !< initialization of the cartesian communicator
        call mpi_op%ini_cartesian_communicator(comm_2d, usr_rank)


        !< initialization of the bc_operator_par object
        call bc_par_tested%ini(comm_2d, p_model)


        !< initialization of the data in nodes
        nodes = ini_data(usr_rank)


        !< test the application of the reflection boundary conditions
        !> on the nodes
        call bc_par_tested%apply_bc_on_nodes(comm_2d, usr_rank, nodes)
        if(.not.test) then
           call write_data('test_xy',usr_rank,nodes)
        else
           test_validated = compare_data('test_xy',usr_rank,nodes)
           print '(''Proc '', I1, '' : apply_bc_on_nodes: '', L1)',
     $          usr_rank, test_validated
        end if


        !< finalization of the mpi process
        call mpi_op%finalize_mpi()


        contains


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute the initial data for the nodes
        !
        !> @date
        !> 26_08_2013 - initial version - J.L. Desmarais
        !
        !>@param proc_rank
        !> rank of the processor computing the tile
        !
        !>@param nodes
        !> nodes computed on the tile
        !--------------------------------------------------------------
        function ini_data(proc_rank) result(nodes)

          implicit none

          integer             , intent(in) :: proc_rank
          real(rkind), dimension(nx,ny,ne) :: nodes

          integer(ikind) :: i,j
          integer        :: k

          do k=1,ne
             do j=1,ny
                do i=1,nx
                   nodes(i,j,k)=compute_ini_data(proc_rank,i,j,k)
                end do
             end do
          end do

        end function ini_data


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute the initial data for the nodes
        !
        !> @date
        !> 26_08_2013 - initial version - J.L. Desmarais
        !
        !>@param proc_rank
        !> rank of the processor computing the tile
        !
        !>@param i
        !> integer identifying the first coordinate
        !
        !>@param j
        !> integer identifying the second coordinate
        !
        !>@param k
        !> integer identifying the third coordinate
        !
        !>@param var
        !> nodes computed on the tile
        !--------------------------------------------------------------
        function compute_ini_data(proc_rank,i,j,k) result(var)
          implicit none

          integer(ikind), intent(in) :: i,j
          integer       , intent(in) :: proc_rank,k
          real(rkind)         :: var

          var = 1000*proc_rank+100*k+10*j+i

        end function compute_ini_data


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> write the data computed on the tile
        !
        !> @date
        !> 26_08_2013 - initial version - J.L. Desmarais
        !
        !>@param filename_base
        !> character giving the name of the file
        !
        !>@param proc_rank
        !> rank of the processor computing the tile
        !
        !>@param nodes
        !> nodes computed on the tile
        !--------------------------------------------------------------
        subroutine write_data(filename_base,proc_rank,nodes)
          implicit none

          character(len=7)                , intent(in) :: filename_base
          integer                         , intent(in) :: proc_rank
          real(rkind), dimension(nx,ny,ne), intent(in) :: nodes


          character(len=14) ::filename
          integer(ikind) :: i,j


          write(filename,'(A7,''_'',I1,''.txt'')')
     $         filename_base, proc_rank

          open(unit=11,
     $         file=filename,
     $         status='unknown',
     $         position='rewind')

          do j=1, ny
             do i=1,nx
                write(11,'(4F20.6)')
     $               nodes(i,j,1), nodes(i,j,2),
     $               nodes(i,j,3), nodes(i,j,4)
             end do
          end do

          close(11)

        end subroutine write_data


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> read the data saved in a text file
        !
        !> @date
        !> 26_08_2013 - initial version - J.L. Desmarais
        !
        !>@param filename_base
        !> character giving the name of the file
        !
        !>@param proc_rank
        !> rank of the processor computing the tile
        !
        !>@param nodes
        !> nodes computed on the tile
        !--------------------------------------------------------------
        subroutine read_data(filename_base,proc_rank,nodes)
          implicit none

          character(len=7)                , intent(in)   :: filename_base
          integer                         , intent(in)   :: proc_rank
          real(rkind), dimension(nx,ny,ne), intent(inout):: nodes


          character(len=27) :: filename

          integer(ikind) :: i,j

          write(filename, '(''../data_test/'', A7,''_'',I1,''.txt'')')
     $         filename_base, proc_rank

          open(unit=11,
     $         file=filename,
     $         status='unknown',
     $         position='rewind')

          do j=1, ny
             do i=1,nx
                read(11,'(4F20.6)')
     $               nodes(i,j,1), nodes(i,j,2),
     $               nodes(i,j,3), nodes(i,j,4)
             end do
          end do

          close(11)

        end subroutine read_data


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> subroutine to compare the data with previously computed data
        !> that have been validated by the user
        !
        !> @date
        !> 26_08_2013 - initial version - J.L. Desmarais
        !
        !>@param filename_base
        !> character giving the name of the file
        !
        !>@param proc_rank
        !> rank of the processor computing the tile
        !
        !>@param nodes
        !> nodes computed on the tile
        !
        !>@param test_validated
        !> logical indicating if the two sets of data correspond
        !--------------------------------------------------------------
        function compare_data(filename_base,proc_rank,nodes)
     $     result(test_validated)
          implicit none

          character(len=7)                , intent(in) :: filename_base
          integer                         , intent(in) :: proc_rank
          real(rkind), dimension(nx,ny,ne), intent(in) :: nodes
          logical                                      :: test_validated

          real(rkind), dimension(nx,ny,ne) :: test_nodes

          integer(ikind) :: i,j
          integer        :: k

          call read_data(filename_base,proc_rank,test_nodes)

          k=1
          test_validated=.true.
          do while (test_validated.and.(k.le.ne))
             j=1
             do while (test_validated.and.(j.le.ny))
                i=1
                do while (test_validated.and.(i.le.nx))
                   test_validated=test_nodes(i,j,k).eq.nodes(i,j,k)
                   i=i+1
                end do
                j=j+1
             end do
             k=k+1
          end do

        end function compare_data

      end program test_reflection_xy_par
