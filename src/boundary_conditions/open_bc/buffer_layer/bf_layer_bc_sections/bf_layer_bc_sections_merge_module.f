      !> @file
      !> subroutines for the merge of bc_sections : anti-corners
      !> can be included in the computation of edges
      !
      !> @author
      !> Julien L. Desmarais
      !
      !> @brief
      !> subroutines for the merge of bc_sections : anti-corners
      !> can be included in the computation of edges
      !
      !> @date
      ! 28_04_2015 - initial version - J.L. Desmarais
      !-----------------------------------------------------------------
      module bf_layer_bc_sections_merge_module

        use parameters_bf_layer, only :
     $       no_overlap,
     $       N_overlap,
     $       S_overlap,
     $       E_overlap,
     $       W_overlap,
     $       interior_pt,
     $       bc_interior_pt,
     $       bc_pt

        use parameters_constant, only :
     $       left, right,
     $       
     $       no_bc_procedure_type,
     $       N_edge_type,
     $       S_edge_type,
     $       E_edge_type,
     $       W_edge_type,
     $       NE_corner_type,
     $       NW_corner_type,
     $       SE_corner_type,
     $       SW_corner_type,
     $       NE_edge_type,
     $       NW_edge_type,
     $       SE_edge_type,
     $       SW_edge_type

        use parameters_kind, only :
     $       ikind


        implicit none


        private
        public ::
     $       reallocate_bc_sections_for_merge,
     $       update_corner_for_merge,
     $       update_anticorner_for_merge,
     $       test_grdpts_id_config,
     $       get_edge_test_param,
     $       get_anticorner_test_param,
     $       get_extent_bc_section_edge


        contains

        
        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> remove from the array of bc_sections the anti-corners
        !> that are added to edge-type bc_section
        !
        !> @date
        !> 28_04_2015 - initial version - J.L. Desmarais
        !
        !@param[inout] bc_sections
        ! array of bc_sections where the anti-corners that should be 
        ! removed have their type modified to no_bc_procedure_type
        !
        !@param[in] nb_ele_removed
        ! number of elements removed in the array of bc_sections
        !------------------------------------------------------------
        subroutine reallocate_bc_sections_for_merge(
     $       bc_sections,
     $       nb_ele_removed)

          implicit none

          integer(ikind), dimension(:,:), allocatable, intent(inout) :: bc_sections
          integer                                    , intent(in)    :: nb_ele_removed

          integer(ikind), dimension(:,:), allocatable :: bc_sections_tmp
          integer :: i,k


          allocate(bc_sections_tmp(size(bc_sections,1),size(bc_sections,2)-nb_ele_removed))

          
          k=1

          do i=1, size(bc_sections,2)
             
             if(bc_sections(1,i).ne.no_bc_procedure_type) then 

                bc_sections_tmp(:,k) = bc_sections(:,i)
                k=k+1

             end if

          end do

          call MOVE_ALLOC(bc_sections_tmp,bc_sections)

        end subroutine reallocate_bc_sections_for_merge


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> update a bc_section of type corner which is overlap by
        !> an edge when the latter is merged with an anti-corner:
        !> unlike update_anticorner_for_merge(), this function also
        !> overlap the corner as the anti-corner was previously
        !> overlap by the edge
        !
        !> @date
        !> 28_04_2015 - initial version - J.L. Desmarais
        !
        !@param[in] anticorner_type
        ! type of anti-corner which is overlap by an edge
        !
        !@param[in] anticorner_position
        ! position of the anti-corner which is overlap by an edge
        !
        !@param[in] corner_type
        ! type of corner which is overlap by an edge
        !
        !@param[in] corner_position
        ! position of the corner which is overlap by an edge
        !
        !@param[in] corner_overlap
        ! overlap-type set to the corner overlap by an edge
        !
        !@param[inout] bc_sections
        ! array of bc_sections
        !
        !@param[inout] nb_ele_removed
        ! number of elements to be removed in the bc_sections b/c of
        ! the overlap of an anti-corner by an edge
        !------------------------------------------------------------
        subroutine update_corner_for_merge(
     $       anticorner_type,
     $       anticorner_position,
     $       corner_type,
     $       corner_position,
     $       corner_overlap,
     $       bc_sections,
     $       nb_ele_removed)

          implicit none

          integer                       , intent(in)    :: anticorner_type
          integer(ikind), dimension(2)  , intent(in)    :: anticorner_position
          integer                       , intent(in)    :: corner_type
          integer(ikind), dimension(2)  , intent(in)    :: corner_position
          integer                       , intent(in)    :: corner_overlap
          integer(ikind), dimension(:,:), intent(inout) :: bc_sections
          integer                       , intent(inout) :: nb_ele_removed

          integer(ikind) :: j_max
          integer        :: k
          integer(ikind) :: j_min


          j_max = max(anticorner_position(2),corner_position(2))


          do k=1, size(bc_sections,2)

             j_min = bc_sections(3,k)
             
             if(  (anticorner_type.eq.bc_sections(1,k)).and.
     $            (anticorner_position(1).eq.bc_sections(2,k)).and.
     $            (anticorner_position(2).eq.j_min)) then

                bc_sections(1,k) = no_bc_procedure_type

                nb_ele_removed = nb_ele_removed+1

             else

                if(  (corner_type.eq.bc_sections(1,k)).and.
     $               (corner_position(1).eq.bc_sections(2,k)).and.
     $               (corner_position(2).eq.j_min)) then

                   bc_sections(5,k) = corner_overlap

                else

                   if(j_min.gt.j_max) then
                      exit
                   end if

                end if

             end if

          end do

        end subroutine update_corner_for_merge


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> update a bc_section of type anti-corner which is overlap by
        !> an edge when the latter is merged with an anti-corner
        !
        !> @date
        !> 28_04_2015 - initial version - J.L. Desmarais
        !
        !@param[in] anticorner_type
        ! type of anti-corner which is overlap by an edge
        !
        !@param[in] anticorner_position
        ! position of the anti-corner which is overlap by an edge
        !
        !@param[inout] bc_sections
        ! array of bc_sections
        !
        !@param[inout] nb_ele_removed
        ! number of elements to be removed in the bc_sections b/c of
        ! the overlap of an anti-corner by an edge
        !------------------------------------------------------------
        subroutine update_anticorner_for_merge(
     $       anticorner_type,
     $       anticorner_position,
     $       bc_sections,
     $       nb_ele_removed)

          implicit none

          integer                       , intent(in)    :: anticorner_type
          integer(ikind), dimension(2)  , intent(in)    :: anticorner_position
          integer(ikind), dimension(:,:), intent(inout) :: bc_sections
          integer                       , intent(inout) :: nb_ele_removed

          integer        :: k
          integer(ikind) :: j_min


          do k=1, size(bc_sections,2)

             j_min = bc_sections(3,k)
             
             if(  (anticorner_type.eq.bc_sections(1,k)).and.
     $            (anticorner_position(1).eq.bc_sections(2,k)).and.
     $            (anticorner_position(2).eq.j_min)) then

                bc_sections(1,k) = no_bc_procedure_type

                nb_ele_removed = nb_ele_removed+1
                exit

             end if

          end do

        end subroutine update_anticorner_for_merge


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> verify that the two grdpts_id configurations match
        !
        !> @date
        !> 28_04_2015 - initial version - J.L. Desmarais
        !
        !@param[in] config
        ! grdpts_id tested
        !
        !@param[in] config_test
        ! grdpts_id configuration that config should match
        !
        !@return test_validated
        ! determine whether the configurations are the same
        !------------------------------------------------------------
        function test_grdpts_id_config(config,config_test)
     $       result(test_validated)

          integer, dimension(:,:), intent(in) :: config
          integer, dimension(:,:), intent(in) :: config_test
          logical                             :: test_validated

          integer :: i,j


          if(.not.(
     $         (size(config,1).eq.size(config_test,1)).and.
     $         (size(config,2).eq.size(config_test,2)))) then
             print '(''bf_layer_bc_sections_merge_module'')'
             print '(''test_grdpts_id_config'')'
             print '(''sizes do not match'')'
             print '(''size_x: '',I2,''->'',I2)', size(config,1), size(config_test,1)
             print '(''size_y: '',I2,''->'',I2)', size(config,2), size(config_test,2)
             print '()'
             stop ''
          end if


         test_validated = .true.

          do j=1,size(config,2)

             do i=1, size(config,1)

                if(config(i,j).ne.config_test(i,j)) then
                   test_validated = .false.
                   exit
                end if

             end do

             if(.not.test_validated) then
                exit
             end if

          end do

        end function test_grdpts_id_config


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> verify that the two grdpts_id configurations match
        !
        !> @date
        !> 28_04_2015 - initial version - J.L. Desmarais
        !
        !@param[in] edge_bc_section
        ! edge bc_section whose overlap with neighboring anti-corner
        ! is investigated
        !
        !@param[in] side
        ! either left or right, indicating which side of the
        ! bc_section is studied
        !
        !@param[out] grdpts_ex_borders
        ! [i_min,i_max]x[j_min,j_max] of the grdpts_id to be extracted
        !
        !@param[out] test_merge_loc_borders
        ! which grdpts from the test_merge array are tested
        !
        !@param[out] test_merge_array
        ! what is the pattern the grdpts_id should match
        !
        !@param[out] test_over_loc_borders
        ! which grdpts from the test_over array are tested
        !
        !@param[out] test_over_array
        ! what is the pattern the grdpts_id should match
        !
        !@param[out] merge_anticorner_type
        ! determine the type of anticorner that should be merged
        ! if the test is validated
        !
        !@param[out] merge_anticorner_position
        ! determine the position of the anticorner that should be
        ! merged if the test is validated
        !
        !@param[out] over_corner_type
        ! determine the type of corner that should be overlap if
        ! the test is validated
        !
        !@param[out] over_corner_position
        ! determine the position of the anticorner that should be
        ! overlap if the test is validated
        !
        !@param[out] over_corner_overlap
        ! determine the overlap of the corner if the test is validated
        !------------------------------------------------------------
        subroutine get_edge_test_param(
     $       edge_bc_section,
     $       side,
     $       
     $       grdpts_ex_borders,
     $       
     $       test_merge_loc_borders,
     $       test_merge_array,
     $       
     $       test_over_loc_borders,
     $       test_over_array,
     $       
     $       merge_anticorner_type,
     $       merge_anticorner_position,
     $       
     $       over_corner_type,
     $       over_corner_position,
     $       over_corner_overlap,
     $       
     $       edge_new_position)

          implicit none

          integer(ikind), dimension(5)  , intent(in)  :: edge_bc_section
          logical                       , intent(in)  :: side
          integer(ikind), dimension(2,2), intent(out) :: grdpts_ex_borders
          integer(ikind), dimension(2,2), intent(out) :: test_merge_loc_borders
          integer(ikind), dimension(4,4), intent(out) :: test_merge_array
          integer(ikind), dimension(2,2), intent(out) :: test_over_loc_borders
          integer(ikind), dimension(4,4), intent(out) :: test_over_array
          integer(ikind)                , intent(out) :: merge_anticorner_type
          integer(ikind), dimension(2)  , intent(out) :: merge_anticorner_position
          integer(ikind)                , intent(out) :: over_corner_type
          integer(ikind), dimension(2)  , intent(out) :: over_corner_position
          integer                       , intent(out) :: over_corner_overlap
          integer(ikind), dimension(3)  , intent(out) :: edge_new_position
          
          
          integer(ikind) :: i_min
          integer(ikind) :: i_max
          integer(ikind) :: j_min
          integer(ikind) :: j_max


          select case(edge_bc_section(1))

            case(N_edge_type)

               i_min = edge_bc_section(2)
               j_min = edge_bc_section(3)
               i_max = edge_bc_section(4)

               test_merge_loc_borders = reshape((/1,1,2,4/),(/2,2/))
               test_over_loc_borders  = reshape((/1,1,2,3/),(/2,2/))

               over_corner_overlap  = S_overlap

               if(side.eqv.left) then
                  grdpts_ex_borders = reshape((/
     $                 i_min-2, j_min,
     $                 i_min-1, j_min+3/),
     $                 (/2,2/))                  

                  test_merge_array(1:2,1:4) = reshape((/
     $                 bc_interior_pt, bc_interior_pt,
     $                 bc_interior_pt, bc_pt         ,
     $                 bc_interior_pt, bc_pt         ,
     $                 bc_pt         , bc_pt         /),
     $                 (/2,4/))

                  test_over_array(1:2,1:3) = reshape((/
     $                 bc_interior_pt, bc_interior_pt,
     $                 bc_interior_pt, bc_pt         ,
     $                 bc_pt         , bc_pt         /),
     $                 (/2,3/))

                  merge_anticorner_type     = NE_edge_type
                  merge_anticorner_position = [i_min-2,j_min]
                  
                  over_corner_type     = NE_corner_type
                  over_corner_position = [i_min-2,j_min+1]

                  edge_new_position = [i_min-2,j_min,i_max]

               else
                  grdpts_ex_borders = reshape((/
     $                 i_max+1, j_min,
     $                 i_max+2, j_min+3/),
     $                 (/2,2/))

                  test_merge_array(1:2,1:4) = reshape((/
     $                 bc_interior_pt, bc_interior_pt,
     $                 bc_pt         , bc_interior_pt,
     $                 bc_pt         , bc_interior_pt,
     $                 bc_pt         , bc_pt         /),
     $                 (/2,4/))

                  test_over_array(1:2,1:3) = reshape((/
     $                 bc_interior_pt, bc_interior_pt,
     $                 bc_pt         , bc_interior_pt,
     $                 bc_pt         , bc_pt         /),
     $                 (/2,3/))

                  merge_anticorner_type     = NW_edge_type
                  merge_anticorner_position = [i_max+1,j_min]
                  
                  over_corner_type     = NW_corner_type
                  over_corner_position = [i_max+1,j_min+1]

                  edge_new_position = [i_min,j_min,i_max+2]

               end if


            case(S_edge_type)

               i_min = edge_bc_section(2)
               j_min = edge_bc_section(3)
               i_max = edge_bc_section(4)

               test_merge_loc_borders = reshape((/1,1,2,4/),(/2,2/))
               test_over_loc_borders  = reshape((/1,2,2,4/),(/2,2/))

               over_corner_overlap  = N_overlap

               if(side.eqv.left) then
                  grdpts_ex_borders = reshape((/
     $                 i_min-2,j_min-2,
     $                 i_min-1,j_min+1/),
     $                 (/2,2/))

                  test_merge_array(1:2,1:4) = reshape((/
     $                 bc_pt         , bc_pt,
     $                 bc_interior_pt, bc_pt,
     $                 bc_interior_pt, bc_pt,
     $                 bc_interior_pt, bc_interior_pt/),
     $                 (/2,4/))

                  test_over_array(1:2,2:4) = reshape((/
     $                 bc_pt         , bc_pt,
     $                 bc_interior_pt, bc_pt,
     $                 bc_interior_pt, bc_interior_pt/),
     $                 (/2,3/))

                  merge_anticorner_type     = SE_edge_type
                  merge_anticorner_position = [i_min-2,j_min]
                  
                  over_corner_type     = SE_corner_type
                  over_corner_position = [i_min-2,j_min-1]

                  edge_new_position = [i_min-2,j_min,i_max]

               else
                  grdpts_ex_borders = reshape((/
     $                 i_max+1,j_min-2,
     $                 i_max+2,j_min+1/),
     $                 (/2,2/))

                  test_merge_array(1:2,1:4) = reshape((/
     $                 bc_pt         , bc_pt,
     $                 bc_pt         , bc_interior_pt,
     $                 bc_pt         , bc_interior_pt,
     $                 bc_interior_pt, bc_interior_pt/),
     $                 (/2,4/))

                  test_over_array(1:2,2:4) = reshape((/
     $                 bc_pt         , bc_pt,
     $                 bc_pt         , bc_interior_pt,
     $                 bc_interior_pt, bc_interior_pt/),
     $                 (/2,3/))

                  merge_anticorner_type     = SW_edge_type
                  merge_anticorner_position = [i_max+1,j_min]
                  
                  over_corner_type     = SW_corner_type
                  over_corner_position = [i_max+1,j_min-1]

                  edge_new_position = [i_min,j_min,i_max+2]

               end if
               

            case(E_edge_type)

               i_min = edge_bc_section(2)
               j_min = edge_bc_section(3)
               j_max = edge_bc_section(4)

               test_merge_loc_borders = reshape((/1,1,4,2/),(/2,2/))
               test_over_loc_borders  = reshape((/1,1,3,2/),(/2,2/))

               over_corner_overlap  = W_overlap

               if(side.eqv.left) then
                  grdpts_ex_borders = reshape((/
     $                 i_min  ,j_min-2,
     $                 i_min+3,j_min-1/),
     $                 (/2,2/))

                  test_merge_array(1:4,1:2) = reshape((/
     $                 bc_interior_pt, bc_interior_pt, bc_interior_pt, bc_pt,
     $                 bc_interior_pt, bc_pt         , bc_pt         , bc_pt/),
     $                 (/4,2/))

                  test_over_array(1:3,1:2) = reshape((/
     $                 bc_interior_pt, bc_interior_pt, bc_pt,
     $                 bc_interior_pt, bc_pt         , bc_pt/),
     $                 (/3,2/))

                  merge_anticorner_type     = NE_edge_type
                  merge_anticorner_position = [i_min,j_min-2]
                  
                  over_corner_type     = NE_corner_type
                  over_corner_position = [i_min+1,j_min-2]

                  edge_new_position = [i_min,j_min-2,j_max]

               else
                  grdpts_ex_borders = reshape((/
     $                 i_min  ,j_max+1,
     $                 i_min+3,j_max+2/),
     $                 (/2,2/))

                  test_merge_array(1:4,1:2) = reshape((/
     $                 bc_interior_pt, bc_pt         , bc_pt         , bc_pt,
     $                 bc_interior_pt, bc_interior_pt, bc_interior_pt, bc_pt/),
     $                 (/4,2/))

                  test_over_array(1:3,1:2) = reshape((/
     $                 bc_interior_pt, bc_pt         , bc_pt,
     $                 bc_interior_pt, bc_interior_pt, bc_pt/),
     $                 (/3,2/))

                  merge_anticorner_type     = SE_edge_type
                  merge_anticorner_position = [i_min,j_max+1]
                  
                  over_corner_type     = SE_corner_type
                  over_corner_position = [i_min+1,j_max+1]

                  edge_new_position = [i_min,j_min,j_max+2]

               end if
               

            case(W_edge_type)

               i_min = edge_bc_section(2)
               j_min = edge_bc_section(3)
               j_max = edge_bc_section(4)

               test_merge_loc_borders = reshape((/1,1,4,2/),(/2,2/))
               test_over_loc_borders  = reshape((/2,1,4,2/),(/2,2/))

               over_corner_overlap  = E_overlap

               if(side.eqv.left) then
                  grdpts_ex_borders = reshape((/
     $                 i_min-2,j_min-2,
     $                 i_min+1,j_min-1/),
     $                 (/2,2/))

                  test_merge_array(1:4,1:2) = reshape((/
     $                 bc_pt, bc_interior_pt, bc_interior_pt, bc_interior_pt, 
     $                 bc_pt, bc_pt         , bc_pt         , bc_interior_pt/),
     $                 (/4,2/))

                  test_over_array(2:4,1:2) = reshape((/
     $                 bc_pt, bc_interior_pt, bc_interior_pt, 
     $                 bc_pt, bc_pt         , bc_interior_pt/),
     $                 (/3,2/))

                  merge_anticorner_type     = NW_edge_type
                  merge_anticorner_position = [i_min,j_min-2]
                  
                  over_corner_type     = NW_corner_type
                  over_corner_position = [i_min-1,j_min-2]

                  edge_new_position = [i_min,j_min-2,j_max]

               else
                  grdpts_ex_borders = reshape((/
     $                 i_min-2,j_max+1,
     $                 i_min+1,j_max+2/),
     $                 (/2,2/))

                  test_merge_array(1:4,1:2) = reshape((/
     $                 bc_pt, bc_pt         , bc_pt         , bc_interior_pt,
     $                 bc_pt, bc_interior_pt, bc_interior_pt, bc_interior_pt/),
     $                 (/4,2/))

                  test_over_array(2:4,1:2) = reshape((/
     $                 bc_pt, bc_pt         , bc_interior_pt,
     $                 bc_pt, bc_interior_pt, bc_interior_pt/), 
     $                 (/3,2/))

                  merge_anticorner_type     = SW_edge_type
                  merge_anticorner_position = [i_min,j_max+1]
                  
                  over_corner_type     = SW_corner_type
                  over_corner_position = [i_min-1,j_max+1]

                  edge_new_position = [i_min,j_min,j_max+2]

               end if

            case default
               print '(''bf_layer_bc_sections_merge_module'')'
               print '(''get_edge_test_param'')'
               print '(''edge type not recognized'')'
               print '(''edge_type: '',I3)', edge_bc_section(1)

          end select

        end subroutine get_edge_test_param


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> verify that the two grdpts_id configurations match
        !
        !> @date
        !> 28_04_2015 - initial version - J.L. Desmarais
        !
        !@param[in] anticorner_bc_section
        ! anticorner bc_section whose neighboring corners is
        ! investigated
        !
        !@param[in] side
        ! either left or right, indicating which side of the
        ! bc_section is studied
        !
        !@param[out] grdpts_ex_borders
        ! [i_min,i_max]x[j_min,j_max] of the grdpts_id to be extracted
        !
        !@param[out] test1_loc_borders
        ! which grdpts from the test_merge array are tested
        !
        !@param[out] test1_array
        ! what is the pattern the grdpts_id should match
        !
        !@param[out] test2_loc_borders
        ! which grdpts from the test_over array are tested
        !
        !@param[out] test2_array
        ! what is the pattern the grdpts_id should match
        !
        !@param[out] new_anticorner_type
        ! determine the type of anticorner that should be merged
        ! if the test is validated
        !------------------------------------------------------------
        subroutine get_anticorner_test_param(
     $       anticorner_bc_section,
     $       side,
     $       
     $       grdpts_ex_borders,
     $       
     $       test1_loc_borders,
     $       test1_array,
     $       
     $       test2_loc_borders,
     $       test2_array,
     $       
     $       new_anticorner_type)

          implicit none

          integer(ikind), dimension(5)  , intent(in)  :: anticorner_bc_section
          logical                       , intent(in)  :: side
          integer(ikind), dimension(2,2), intent(out) :: grdpts_ex_borders
          integer(ikind), dimension(2,2), intent(out) :: test1_loc_borders
          integer(ikind), dimension(2,2), intent(out) :: test1_array
          integer(ikind), dimension(2,2), intent(out) :: test2_loc_borders
          integer(ikind), dimension(2,2), intent(out) :: test2_array
          integer(ikind)                , intent(out) :: new_anticorner_type
          
          
          integer(ikind) :: i_min
          integer(ikind) :: j_min


          i_min = anticorner_bc_section(2)
          j_min = anticorner_bc_section(3)

          select case(anticorner_bc_section(1))

            case(NW_edge_type)

               new_anticorner_type = NW_corner_type

               if(side.eqv.left) then

                  grdpts_ex_borders = reshape((/
     $                 i_min-2,j_min,i_min-1,j_min+1/),
     $                 (/2,2/))
                  
                  test1_loc_borders = reshape((/
     $                 1,1,2,2/),
     $                 (/2,2/))
                  
                  test1_array(1:2,1:2) = reshape((/
     $                 bc_pt, bc_interior_pt,
     $                 bc_pt, bc_pt/),
     $                 (/2,2/))
                  
                  test2_loc_borders = reshape((/
     $                 2,1,2,2/),
     $                 (/2,2/))
                  
                  test2_array(2:2,1:2) = reshape((/
     $                 bc_pt,
     $                 bc_pt/),
     $                 (/1,2/))

               else

                  grdpts_ex_borders = reshape((/
     $                 i_min,j_min+2,i_min+1,j_min+3/),
     $                 (/2,2/))
                  
                  test1_loc_borders = reshape((/
     $                 1,1,2,2/),
     $                 (/2,2/))
                  
                  test1_array(1:2,1:2) = reshape((/
     $                 bc_pt, bc_interior_pt,
     $                 bc_pt, bc_pt/),
     $                 (/2,2/))
                  
                  test2_loc_borders = reshape((/
     $                 1,1,2,1/),
     $                 (/2,2/))
                  
                  test2_array(1:2,1:1) = reshape((/
     $                 bc_pt,
     $                 bc_pt/),
     $                 (/2,1/))

               end if


            case(NE_edge_type)

               new_anticorner_type = NE_corner_type

               if(side.eqv.left) then

                  grdpts_ex_borders = reshape((/
     $                 i_min+2,j_min,i_min+3,j_min+1/),
     $                 (/2,2/))
                  
                  test1_loc_borders = reshape((/
     $                 1,1,2,2/),
     $                 (/2,2/))
                  
                  test1_array(1:2,1:2) = reshape((/
     $                 bc_interior_pt, bc_pt,
     $                 bc_pt, bc_pt/),
     $                 (/2,2/))
                  
                  test2_loc_borders = reshape((/
     $                 1,1,1,2/),
     $                 (/2,2/))
                  
                  test2_array(1:1,1:2) = reshape((/
     $                 bc_pt,
     $                 bc_pt/),
     $                 (/1,2/))

               else

                  grdpts_ex_borders = reshape((/
     $                 i_min,j_min+2,i_min+1,j_min+3/),
     $                 (/2,2/))
                  
                  test1_loc_borders = reshape((/
     $                 1,1,2,2/),
     $                 (/2,2/))
                  
                  test1_array(1:2,1:2) = reshape((/
     $                 bc_interior_pt, bc_pt,
     $                 bc_pt         , bc_pt/),
     $                 (/2,2/))
                  
                  test2_loc_borders = reshape((/
     $                 1,1,2,1/),
     $                 (/2,2/))
                  
                  test2_array(1:2,1:1) = reshape((/
     $                 bc_pt,
     $                 bc_pt/),
     $                 (/2,1/))

               end if


            case(SW_edge_type)

               new_anticorner_type = SW_corner_type

               if(side.eqv.left) then

                  grdpts_ex_borders = reshape((/
     $                 i_min-2,j_min,i_min-1,j_min+1/),
     $                 (/2,2/))
                  
                  test1_loc_borders = reshape((/
     $                 1,1,2,2/),
     $                 (/2,2/))
                  
                  test1_array(1:2,1:2) = reshape((/
     $                 bc_pt, bc_pt,
     $                 bc_pt, bc_interior_pt/),
     $                 (/2,2/))
                  
                  test2_loc_borders = reshape((/
     $                 2,1,2,2/),
     $                 (/2,2/))
                  
                  test2_array(2:2,1:2) = reshape((/
     $                 bc_pt,
     $                 bc_pt/),
     $                 (/1,2/))

               else

                  grdpts_ex_borders = reshape((/
     $                 i_min,j_min-2,i_min+1,j_min-1/),
     $                 (/2,2/))
                  
                  test1_loc_borders = reshape((/
     $                 1,1,2,2/),
     $                 (/2,2/))
                  
                  test1_array(1:2,1:2) = reshape((/
     $                 bc_pt, bc_pt,
     $                 bc_pt, bc_interior_pt/),
     $                 (/2,2/))
                  
                  test2_loc_borders = reshape((/
     $                 1,2,2,2/),
     $                 (/2,2/))
                  
                  test2_array(1:2,2:2) = reshape((/
     $                 bc_pt,
     $                 bc_pt/),
     $                 (/2,1/))

               end if


            case(SE_edge_type)

               new_anticorner_type = SE_corner_type

               if(side.eqv.left) then

                  grdpts_ex_borders = reshape((/
     $                 i_min+2,j_min,i_min+3,j_min+1/),
     $                 (/2,2/))
                  
                  test1_loc_borders = reshape((/
     $                 1,1,2,2/),
     $                 (/2,2/))
                  
                  test1_array(1:2,1:2) = reshape((/
     $                 bc_pt         , bc_pt,
     $                 bc_interior_pt, bc_pt/),
     $                 (/2,2/))
                  
                  test2_loc_borders = reshape((/
     $                 1,1,1,2/),
     $                 (/2,2/))
                  
                  test2_array(1:1,1:2) = reshape((/
     $                 bc_pt,
     $                 bc_pt/),
     $                 (/1,2/))

               else

                  grdpts_ex_borders = reshape((/
     $                 i_min,j_min-2,i_min+1,j_min-1/),
     $                 (/2,2/))
                  
                  test1_loc_borders = reshape((/
     $                 1,1,2,2/),
     $                 (/2,2/))
                  
                  test1_array(1:2,1:2) = reshape((/
     $                 bc_pt         , bc_pt,
     $                 bc_interior_pt, bc_pt/),
     $                 (/2,2/))
                  
                  test2_loc_borders = reshape((/
     $                 1,2,2,2/),
     $                 (/2,2/))
                  
                  test2_array(1:2,2:2) = reshape((/
     $                 bc_pt,
     $                 bc_pt/),
     $                 (/2,1/))

               end if

            case default
               print '(''bf_layer_bc_sections_merge_module'')'
               print '(''get_anticorner_test_param'')'
               print '(''anticorner type not recognized: '',I2)', anticorner_bc_section(1)
               stop ''

          end select

        end subroutine get_anticorner_test_param


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> get the extent of the bc_section of type edge
        !
        !> @date
        !> 23_04_2015 - initial version - J.L. Desmarais
        !
        !>@param bc_section
        !> parameters characterizing the bc_section
        !> [type of bc_section,i_min,j_min,max,overlap]
        !
        !>@return extent 
        !> extent of the edge (in the x-direction for N and S edges,
        !> in the y-direction for E and W edges)
        !--------------------------------------------------------------
        function get_extent_bc_section_edge(bc_section)
     $     result(extent)

          integer(ikind), dimension(5), intent(in) :: bc_section
          integer(ikind)                           :: extent


          select case(bc_section(1))
            case(N_edge_type,S_edge_type)
               extent = bc_section(4) - bc_section(2) + 1

            case(E_edge_type,W_edge_type)
               extent = bc_section(4) - bc_section(3) + 1

            case default
               print '(''bf_layer_bc_sections_merge_module'')'
               print '(''get_extent_bc_section_edge'')'
               print '(''edge_bc_section not recognized: '',I2)', bc_section(1)
               stop ''

          end select

        end function get_extent_bc_section_edge

      end module bf_layer_bc_sections_merge_module
