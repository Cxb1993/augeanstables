      program test_bf_layer_abstract_prog

        use bf_layer_abstract_class, only : bf_layer_abstract
        use parameters_constant    , only : N,S,E,W,N_E,N_W,S_E,S_W
        use parameters_kind        , only : rkind, ikind
        use parameters_input       , only : nx,ny,ne,bc_size

        implicit none

        type(bf_layer_abstract) :: bf_layer_tested_N
        type(bf_layer_abstract) :: bf_layer_tested_S
        type(bf_layer_abstract) :: bf_layer_tested_E
        type(bf_layer_abstract) :: bf_layer_tested_W
        type(bf_layer_abstract) :: bf_layer_tested_NE
        type(bf_layer_abstract) :: bf_layer_tested_NW
        type(bf_layer_abstract) :: bf_layer_tested_SE
        type(bf_layer_abstract) :: bf_layer_tested_SW

        real(rkind)   , dimension(nx,ny,ne) :: nodes
        integer(ikind), dimension(2,2)      :: alignment
        integer(ikind)                      :: i,j,k
        integer       , dimension(8)        :: bf_layer_loc
        character(len=20)                   :: sizes_filename, nodes_filename, grdid_filename
        
        call srand(10)

        do k=1, ne
           do j=1, ny
              do i=1, nx
                 nodes(i,j,k) = RAND() !(k-1)*1000 + (j-1)*100 + (i-1)
              end do
           end do
        end do

        !print the nodes
        call print_sizes(nodes,'interior_sizes.dat')
        call print_nodes(nodes,'interior_nodes.dat')

        !buffer layers tested
        bf_layer_loc = [N,S,E,W,N_E,N_W,S_E,S_W]

        !alignment
        alignment(1,1) = bc_size+3
        alignment(1,2) = bc_size+4
        alignment(2,1) = bc_size+3
        alignment(2,2) = bc_size+4

        
        do i=1, size(bf_layer_loc,1)

           select case(bf_layer_loc(i))
             case(N)
                sizes_filename = "N_sizes.dat"
                nodes_filename = "N_nodes.dat"
                grdid_filename = "N_grdpt_id.dat"

                call bf_layer_tested_N%ini(bf_layer_loc(i))           
                call bf_layer_tested_N%allocate_bf_layer(alignment, nodes)
                call bf_layer_tested_N%print_sizes(sizes_filename)
                call bf_layer_tested_N%print_nodes(nodes_filename)
                call bf_layer_tested_N%print_grdpts_id(grdid_filename)

             case(S)
                sizes_filename = "S_sizes.dat"
                nodes_filename = "S_nodes.dat"
                grdid_filename = "S_grdpt_id.dat"

                call bf_layer_tested_S%ini(bf_layer_loc(i))           
                call bf_layer_tested_S%allocate_bf_layer(alignment, nodes)
                call bf_layer_tested_S%print_sizes(sizes_filename)
                call bf_layer_tested_S%print_nodes(nodes_filename)
                call bf_layer_tested_S%print_grdpts_id(grdid_filename)

             case(E)
                sizes_filename = "E_sizes.dat"
                nodes_filename = "E_nodes.dat"
                grdid_filename = "E_grdpt_id.dat"

                call bf_layer_tested_E%ini(bf_layer_loc(i))           
                call bf_layer_tested_E%allocate_bf_layer(alignment, nodes)
                call bf_layer_tested_E%print_sizes(sizes_filename)
                call bf_layer_tested_E%print_nodes(nodes_filename)
                call bf_layer_tested_E%print_grdpts_id(grdid_filename)

             case(W)
                sizes_filename = "W_sizes.dat"
                nodes_filename = "W_nodes.dat"
                grdid_filename = "W_grdpt_id.dat"

                call bf_layer_tested_W%ini(bf_layer_loc(i))           
                call bf_layer_tested_W%allocate_bf_layer(alignment, nodes)
                call bf_layer_tested_W%print_sizes(sizes_filename)
                call bf_layer_tested_W%print_nodes(nodes_filename)
                call bf_layer_tested_W%print_grdpts_id(grdid_filename)

             case(N_E)
                sizes_filename = "NE_sizes.dat"
                nodes_filename = "NE_nodes.dat"
                grdid_filename = "NE_grdpt_id.dat"

                call bf_layer_tested_NE%ini(bf_layer_loc(i))           
                call bf_layer_tested_NE%allocate_bf_layer(alignment, nodes)
                call bf_layer_tested_NE%print_sizes(sizes_filename)
                call bf_layer_tested_NE%print_nodes(nodes_filename)
                call bf_layer_tested_NE%print_grdpts_id(grdid_filename)

             case(N_W)
                sizes_filename = "NW_sizes.dat"
                nodes_filename = "NW_nodes.dat"
                grdid_filename = "NW_grdpt_id.dat"

                call bf_layer_tested_NW%ini(bf_layer_loc(i))           
                call bf_layer_tested_NW%allocate_bf_layer(alignment, nodes)
                call bf_layer_tested_NW%print_sizes(sizes_filename)
                call bf_layer_tested_NW%print_nodes(nodes_filename)
                call bf_layer_tested_NW%print_grdpts_id(grdid_filename)

             case(S_E)
                sizes_filename = "SE_sizes.dat"
                nodes_filename = "SE_nodes.dat"
                grdid_filename = "SE_grdpt_id.dat"

                call bf_layer_tested_SE%ini(bf_layer_loc(i))           
                call bf_layer_tested_SE%allocate_bf_layer(alignment, nodes)
                call bf_layer_tested_SE%print_sizes(sizes_filename)
                call bf_layer_tested_SE%print_nodes(nodes_filename)
                call bf_layer_tested_SE%print_grdpts_id(grdid_filename)

             case(S_W)
                sizes_filename = "SW_sizes.dat"
                nodes_filename = "SW_nodes.dat"
                grdid_filename = "SW_grdpt_id.dat"

                call bf_layer_tested_SW%ini(bf_layer_loc(i))           
                call bf_layer_tested_SW%allocate_bf_layer(alignment, nodes)
                call bf_layer_tested_SW%print_sizes(sizes_filename)
                call bf_layer_tested_SW%print_nodes(nodes_filename)
                call bf_layer_tested_SW%print_grdpts_id(grdid_filename)

           end select

           !test the buffer layer
           

        end do


        contains

        subroutine print_nodes(nodes, filename)

          implicit none

          real(rkind), dimension(:,:,:), intent(in) :: nodes
          character(*)                 , intent(in) :: filename

          integer :: ios
          
          open(unit=1,
     $          file=filename,
     $          action="write", 
     $          status="unknown",
     $          form='unformatted',
     $          access='sequential',
     $          position='rewind',
     $          iostat=ios)

           if(ios.eq.0) then
              write(unit=1, iostat=ios) nodes
              close(unit=1)
           else
              stop 'file opening pb'
           end if

        end subroutine print_nodes


        subroutine print_sizes(nodes, filename)

          implicit none

          real(rkind), dimension(:,:,:), intent(in) :: nodes
          character(*)                 , intent(in) :: filename

          integer :: ios
          
          open(unit=1,
     $          file=filename,
     $          action="write", 
     $          status="unknown",
     $          form='unformatted',
     $          access='sequential',
     $          position='rewind',
     $          iostat=ios)

           if(ios.eq.0) then
              write(unit=1, iostat=ios) size(nodes,1),
     $             size(nodes,2),
     $             size(nodes,3)
              close(unit=1)
           else
              stop 'file opening pb'
           end if

        end subroutine print_sizes

      end program test_bf_layer_abstract_prog
