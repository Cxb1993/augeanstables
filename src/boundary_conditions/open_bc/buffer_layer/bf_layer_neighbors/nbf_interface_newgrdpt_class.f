      !> @file
      !> nbf_interface augmented with functions computing new grid points
      !
      !> @author
      !> Julien L. Desmarais
      !
      !> @brief
      !> module implementing the object inheriting from nbf_interface
      !> to encasulate the computation of new grid points
      !
      !> @date
      ! 21_11_2014 - documentation update - J.L. Desmarais
      !-----------------------------------------------------------------
      module nbf_interface_newgrdpt_class

        use bf_layer_newgrdpt_procedure_module, only :
     $       get_newgrdpt_procedure,
     $       get_interior_data_for_newgrdpt,
     $       are_intermediate_newgrdpt_data_needed,
     $       get_x_map_for_newgrdpt,
     $       get_y_map_for_newgrdpt

        use bf_newgrdpt_class, only :
     $       bf_newgrdpt

        use bf_sublayer_class, only :
     $       bf_sublayer

        use nbf_interface_class, only :
     $       nbf_interface

        use parameters_input, only :
     $       nx,ny,ne,bc_size

        use parameters_kind, only :
     $       ikind,
     $       rkind

        use pmodel_eq_class, only :
     $       pmodel_eq

        private
        public :: nbf_interface_newgrdpt


        !>@class nbf_interface-newgrdpt
        !> object augmenting the nbf_interface with functions 
        !> computing the new gridpoints
        !
        !> @param update_grdpts_after_increase
        !> turn the grdpts_id identified by general coordinates
        !> from bc_interior_pt to interior_pt and reallocate the
        !> buffer layer such that the neighboring points around it
        !> are allocated. Then compute these new grid points
        !
        !> @param compute_newgrdpt
        !> compute the new grid point in the buffer layer resulting
        !> from the computational domain extension
        !--------------------------------------------------------------
        type, extends(nbf_interface) :: nbf_interface_newgrdpt

          contains

          procedure, pass :: update_bf_grdpts_after_increase
          procedure, pass :: update_grdpts_around_new_interior_pt
          procedure, pass :: compute_newgrdpt

        end type nbf_interface_newgrdpt


        contains


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> turn the grdpts_id identified by general coordinates
        !> from bc_interior_pt to interior_pt and reallocate the buffer
        !> layer such that the neighboring points around it are allocated.
        !> Then compute these new grid points.
        !
        !> @date
        !> 21_11_2014 - initial version - J.L. Desmarais
        !
        !> @param this
        !> nbf_interface_newgrdpt encapsulating the 
        !> links to neighboring buffer layers and the
        !> functions for the computation of the new grid
        !> points in the buffer layer
        !
        !> @param bf_sublayer_updated
        !> bf_layer object encapsulating the main
        !> tables extending the interior domain
        !
        !> @param p_model
        !> physical model
        !
        !> @param t
        !> time 
        !
        !> @param dt
        !> time step
        !
        !> @param interior_x_map
        !> array with x-coordinates of the interior domain
        !
        !> @param interior_y_map
        !> array with y-coordinates of the interior domain
        !
        !> @param interior_nodes0
        !> array with the grid point data at t=t-dt
        !
        !> @param interior_nodes1
        !> array with the grid point data at t=t
        !
        !>@param selected_grdpts
        !> list containing the general coordinates of the grid points to be
        !> turned from bc_interior_pt to interior_pt
        !--------------------------------------------------------------
        subroutine update_bf_grdpts_after_increase(
     $       this,
     $       bf_sublayer_updated,
     $       p_model,
     $       t,dt,
     $       interior_x_map,
     $       interior_y_map,
     $       interior_nodes0,
     $       interior_nodes1,
     $       selected_grdpts)

          implicit none

          class(nbf_interface_newgrdpt)   , intent(in)    :: this
          type(bf_sublayer)               , intent(inout) :: bf_sublayer_updated
          type(pmodel_eq)                 , intent(in)    :: p_model
          real(rkind)                     , intent(in)    :: t
          real(rkind)                     , intent(in)    :: dt
          real(rkind), dimension(nx)      , intent(in)    :: interior_x_map
          real(rkind), dimension(ny)      , intent(in)    :: interior_y_map
          real(rkind), dimension(nx,ny,ne), intent(in)    :: interior_nodes0
          real(rkind), dimension(nx,ny,ne), intent(in)    :: interior_nodes1
          integer(ikind), dimension(:,:)  , intent(in)    :: selected_grdpts

          integer(ikind), dimension(2) :: match_table
          integer(ikind)               :: k
          integer(ikind)               :: i_prev
          integer(ikind)               :: j_prev
          integer(ikind)               :: i_center
          integer(ikind)               :: j_center


          match_table = bf_sublayer_updated%get_general_to_local_coord_tab()
          
          
          !we have a list of gridpoints that should be turned
          !from bc_interior_pt to interior_pt. For a point to be
          !considered an interior point, we need to make sure
          !that the grid points it needs to compute its time
          !derivatives are available
          !
          !previously, the nodes table of the buffer layer was
          !increased to take into account the space needed for
          !new gridpoints at the boundary
          !
          !in this function, we go through the list of gridpoint
          !whose neighbours need to be tested. As it is possible
          !to reduce the number of tests by considering the
          !previous gridpoint tested, there is a distinction
          !between k=1 and k>1 in the list of gridpoints
          !----------------------------------------------------

          !for the first grid point, there is no simplification
          !possible in checking the neighbours so the centers
          !are initialized to do as if the previous central point
          !checked was far away
          !----------------------------------------------------
          i_center = -match_table(1)+nx/2
          j_center = -match_table(2)+ny/2

          do k=1, size(selected_grdpts,2)

             !update the position of the gridpoint previously
             !tested
             i_prev   =   i_center
             j_prev   =   j_center
             i_center = - match_table(1) + selected_grdpts(1,k)
             j_center = - match_table(2) + selected_grdpts(2,k)

             !check its neighbours
             call update_grdpts_around_new_interior_pt(
     $            this,
     $            bf_sublayer_updated,
     $            p_model,
     $            t,dt,
     $            interior_x_map,
     $            interior_y_map,
     $            interior_nodes0,
     $            interior_nodes1,
     $            i_prev, j_prev,
     $            i_center, j_center)

             !update the status of the central gridpoint
             !to interior_pt
             call bf_sublayer_updated%set_new_interior_pt(
     $            i_center,
     $            j_center)

          end do

        end subroutine update_bf_grdpts_after_increase


        !> @author
        !> Julien L. Desmarais
        !>
        !> @brief
        !> update the grid points around the new interior_pt
        !
        !> @date
        !> 19_11_2014 - initial version - J.L. Desmarais
        !
        !> @param this
        !> nbf_interface_newgrdpt encapsulating the 
        !> links to neighboring buffer layers and the
        !> functions for the computation of the new grid
        !> points in the buffer layer
        !
        !> @param bf_sublayer_updated
        !> bf_layer object encapsulating the main
        !> tables extending the interior domain
        !
        !> @param p_model
        !> physical model
        !
        !> @param t
        !> time 
        !
        !> @param dt
        !> time step
        !
        !> @param interior_x_map
        !> array with x-coordinates of the interior domain
        !
        !> @param interior_y_map
        !> array with y-coordinates of the interior domain
        !
        !> @param interior_nodes0
        !> array with the grid point data at t=t-dt
        !
        !> @param interior_nodes1
        !> array with the grid point data at t=t
        !
        !> @param i_prev
        !> x-index of the previous bc_interior_pt whose 
        !> neighbors were checked
        !
        !> @param j_prev
        !> y-index of the previous bc_interior_pt whose 
        !> neighbors were checked
        !
        !> @param i_center
        !> x-index of the current bc_interior_pt whose 
        !> neighbors were checked
        !
        !> @param j_center
        !> y-index of the current bc_interior_pt whose 
        !> neighbors were checked
        !---------------------------------------------------------------
        subroutine update_grdpts_around_new_interior_pt(
     $     this,
     $     bf_sublayer_updated,
     $     p_model,
     $     t,dt,
     $     interior_x_map,
     $     interior_y_map,
     $     interior_nodes0,
     $     interior_nodes1,
     $     i_prev, j_prev,
     $     i_center, j_center)

          implicit none

          class(nbf_interface_newgrdpt)   , intent(in)    :: this
          type(bf_sublayer)               , intent(inout) :: bf_sublayer_updated
          type(pmodel_eq)                 , intent(in)    :: p_model
          real(rkind)                     , intent(in)    :: t
          real(rkind)                     , intent(in)    :: dt
          real(rkind), dimension(nx)      , intent(in)    :: interior_x_map
          real(rkind), dimension(ny)      , intent(in)    :: interior_y_map
          real(rkind), dimension(nx,ny,ne), intent(in)    :: interior_nodes0
          real(rkind), dimension(nx,ny,ne), intent(in)    :: interior_nodes1
          integer(ikind)                  , intent(in)    :: i_prev
          integer(ikind)                  , intent(in)    :: j_prev
          integer(ikind)                  , intent(in)    :: i_center
          integer(ikind)                  , intent(in)    :: j_center

          integer(ikind) :: min_j, max_j
          integer(ikind) :: i,j

          logical :: compute_grdpt


          min_j = min(j_center-j_prev,0)
          max_j = max(j_center-j_prev,0)


          !check whether the grid points around the new interior_pt
          !exist: if they do not exist, they are computed
          !in any case, the status of the neighboring points may be
          !updated: from bc_pt -> bc_interior_pt or no_pt -> bc_pt
          do j=j_center-bc_size, j_prev - bc_size + min(j_center-j_prev+2*bc_size,-1)
             do i=i_center-bc_size,i_center+bc_size
                
                compute_grdpt = bf_sublayer_updated%update_neighboring_grdpt(
     $               i,j,i_center,j_center)

                if(compute_grdpt) then
                   call compute_newgrdpt(
     $                  this,
     $                  bf_sublayer_updated,
     $                  p_model,t,dt,
     $                  i,j,
     $                  interior_x_map,
     $                  interior_y_map,
     $                  interior_nodes0,
     $                  interior_nodes1)
                end if

             end do
          end do

          do j=j_center-bc_size-min_j, j_center+bc_size-max_j
             do i=i_center-bc_size, i_prev-bc_size+min(i_center-i_prev+2*bc_size,-1)

                compute_grdpt = bf_sublayer_updated%update_neighboring_grdpt(
     $               i,j,i_center,j_center)

                if(compute_grdpt) then
                   call compute_newgrdpt(
     $                  this,
     $                  bf_sublayer_updated,
     $                  p_model,t,dt,
     $                  i,j,
     $                  interior_x_map,
     $                  interior_y_map,
     $                  interior_nodes0,
     $                  interior_nodes1)
                end if

             end do
          end do

          do j=j_center-bc_size-min_j, j_center+bc_size-max_j
             do i=i_prev+bc_size+max(i_center-i_prev-2*bc_size,1),i_center+bc_size

                compute_grdpt = bf_sublayer_updated%update_neighboring_grdpt(
     $               i,j,i_center,j_center)

                if(compute_grdpt) then
                   call compute_newgrdpt(
     $                  this,
     $                  bf_sublayer_updated,
     $                  p_model,t,dt,
     $                  i,j,
     $                  interior_x_map,
     $                  interior_y_map,
     $                  interior_nodes0,
     $                  interior_nodes1)
                end if

             end do
          end do

          do j=j_prev+bc_size+max(j_center-j_prev-2*bc_size,1), j_center+bc_size
             do i=i_center-bc_size,i_center+bc_size

                compute_grdpt = bf_sublayer_updated%update_neighboring_grdpt(
     $               i,j,i_center,j_center)

                if(compute_grdpt) then
                   call compute_newgrdpt(
     $                  this,
     $                  bf_sublayer_updated,
     $                  p_model,t,dt,
     $                  i,j,
     $                  interior_x_map,
     $                  interior_y_map,
     $                  interior_nodes0,
     $                  interior_nodes1)
                end if

             end do
          end do


          !finalize the update of the neighboring gridpoints
          !grid points that do not need to be computed but whose
          !status is modified from bc_pt to bc_interior_pt
          call bf_sublayer_updated%finalize_neighboring_grdpts_update(
     $         i_prev, j_prev,
     $         i_center, j_center)

        end subroutine update_grdpts_around_new_interior_pt

        
        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> compute the new grid point of the buffer layer
        !
        !> @date
        !> 19_11_2014 - initial version - J.L. Desmarais
        !
        !> @param this
        !> nbf_interface object encapsulting links to buffer
        !> layers at the edge between different main layers
        !
        !> @param bf_sublayer_ptr
        !> buffer layer whose new grid point is computed
        !
        !> @param p_model
        !> physical model
        !
        !> @param t
        !> time 
        !
        !> @param dt
        !> time step
        !
        !> @param i1
        !> x-index of the new grid point
        !
        !> @param j1
        !> y-index of the new grid point
        !
        !> @param interior_x_map
        !> array with x-coordinates of the interior domain
        !
        !> @param interior_y_map
        !> array with y-coordinates of the interior domain
        !
        !> @param interior_nodes0
        !> array with the grid point data at t=t-dt
        !
        !> @param interior_nodes1
        !> array with the grid point data at t=t
        !--------------------------------------------------------------
        subroutine compute_newgrdpt(
     $     this,
     $     bf_sublayer_updated,
     $     p_model,t,dt,
     $     i1,j1,
     $     interior_x_map,
     $     interior_y_map,
     $     interior_nodes0,
     $     interior_nodes1)

          implicit none

          class(nbf_interface_newgrdpt)   , intent(in)    :: this
          type(bf_sublayer)               , intent(inout) :: bf_sublayer_updated
          type(pmodel_eq)                 , intent(in)    :: p_model
          real(rkind)                     , intent(in)    :: t
          real(rkind)                     , intent(in)    :: dt
          integer(ikind)                  , intent(in)    :: i1
          integer(ikind)                  , intent(in)    :: j1
          real(rkind), dimension(nx)      , intent(in)    :: interior_x_map
          real(rkind), dimension(ny)      , intent(in)    :: interior_y_map
          real(rkind), dimension(nx,ny,ne), intent(in)    :: interior_nodes0
          real(rkind), dimension(nx,ny,ne), intent(in)    :: interior_nodes1

          integer(ikind), dimension(2)   :: match_table
          integer(ikind), dimension(2)   :: gen_coords
          logical                        :: tmp_needed
          integer(ikind), dimension(2,2) :: gen_borders

          integer    , dimension(2*bc_size+1,2*bc_size+1)    :: tmp_grdpts_id0
          real(rkind), dimension(2*bc_size+1,2*bc_size+1,ne) :: tmp_nodes0
          real(rkind), dimension(2*bc_size+1,2*bc_size+1,ne) :: tmp_nodes1

          integer                                :: localization
          type(bf_newgrdpt)                      :: bf_newgrdpt_used
          integer                                :: procedure_type
          integer                                :: gradient_type
          integer(ikind), dimension(2,2)         :: bf_align
          real(rkind)   , dimension(2*bc_size+1) :: tmp_x_map
          real(rkind)   , dimension(2*bc_size+1) :: tmp_y_map
          real(rkind)   , dimension(ne)          :: new_grdpt
          integer                                :: k


          !localization of the buffer layer
          localization = bf_sublayer_updated%get_localization()

          !compute the general coordinates of the new grid point
          match_table   = bf_sublayer_updated%get_general_to_local_coord_tab()
          gen_coords(1) = match_table(1) + i1
          gen_coords(2) = match_table(2) + j1
          
          !determine the extent of the data needed
          gen_borders(1,1) = gen_coords(1)-bc_size
          gen_borders(1,2) = gen_coords(1)+bc_size
          gen_borders(2,1) = gen_coords(2)-bc_size
          gen_borders(2,2) = gen_coords(2)+bc_size

          !determine whether the new grid point is at the interface
          !between buffer layers or at the interface with the interior
          !and so requires to create intermediate arrays gathering data
          !from the interior and the neighboring buffer layers
          tmp_needed = are_intermediate_newgrdpt_data_needed(
     $         localization,
     $         gen_borders)

          if(.not.tmp_needed) then
             tmp_needed = .not.(bf_sublayer_updated%does_previous_timestep_exist())
          end if


          !if intermediate data are required, data are gathered from
          !the interior, the buffer layer and its neighbors
          if(tmp_needed) then

             !gather the data from the interior domain
             call get_interior_data_for_newgrdpt(
     $            interior_nodes0,
     $            interior_nodes1,
     $            tmp_grdpts_id0,
     $            tmp_nodes0,
     $            tmp_nodes1,
     $            gen_borders)

             !gather the data from the current buffer
             !layer
             call bf_sublayer_updated%get_data_for_newgrdpt(
     $            tmp_grdpts_id0,
     $            tmp_nodes0,
     $            tmp_nodes1,
     $            gen_borders)

             !gather the data from the potential neighbors
             !of the buffer layer
             !- gather data from neighbor of type 1
             if(gen_borders(1,1).le.0) then
                
                call this%get_data_for_newgrdpt(
     $               localization,1,
     $               tmp_grdpts_id0,
     $               tmp_nodes0,
     $               tmp_nodes1,
     $               gen_borders)

             end if

             !- gather data from neighbor of type 2
             if(gen_borders(1,2).ge.(nx+1)) then

                call this%get_data_for_newgrdpt(
     $               localization,2,
     $               tmp_grdpts_id0,
     $               tmp_nodes0,
     $               tmp_nodes1,
     $               gen_borders)

             end if

             
             !determine the procedure and gradient type
             call get_newgrdpt_procedure(
     $            bc_size+1,bc_size+1,
     $            tmp_grdpts_id0,
     $            procedure_type,
     $            gradient_type)


             !compute the new grdpt
             ! - construct the bf_align array to localize
             !   the buffer layer
             bf_align(1,1) = gen_coords(1)
             bf_align(1,2) = gen_coords(1)
             bf_align(2,1) = gen_coords(2)
             bf_align(2,2) = gen_coords(2)

             ! - construct the bf_x_map array
             tmp_x_map = get_x_map_for_newgrdpt(interior_x_map, gen_borders)

             ! - construct the bf_y_map array
             tmp_y_map = get_y_map_for_newgrdpt(interior_y_map, gen_borders)

             ! - compute the new grdpt
             new_grdpt = bf_newgrdpt_used%compute_newgrdpt(
     $            p_model, t, dt,
     $            bf_align, tmp_x_map, tmp_y_map, tmp_nodes0,
     $            bf_align, tmp_x_map, tmp_y_map, tmp_nodes1,
     $            bc_size+1, bc_size+1,
     $            procedure_type, gradient_type)


             !set the new grdpt in the buffer layer
             do k=1,ne
                call bf_sublayer_updated%set_nodes_pt(i1,j1,k,new_grdpt(k))
             end do


          !otherwise, the grid point can be directly computed
          !from the buffer layer
          else

              call bf_sublayer_updated%compute_newgrdpt(
     $            p_model,
     $            t,dt,
     $            i1,j1)

          end if

        end subroutine compute_newgrdpt

      end module nbf_interface_newgrdpt_class