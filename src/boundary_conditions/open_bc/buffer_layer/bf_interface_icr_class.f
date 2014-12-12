      !> @file
      !> module implementing the object encapsulating the position of
      !> the increasing detectors and the subroutines extending the
      !> computational domain if they are triggered
      !
      !> @author
      !> Julien L. Desmarais
      !
      !> @brief
      !> module implementing the object encapsulating the position of
      !> the increasing detectors and the subroutines extending the
      !> computational domain if they are triggered
      !
      !> @date
      ! 27_06_2014 - documentation update - J.L. Desmarais
      !-----------------------------------------------------------------
      module bf_interface_icr_class

        !temporary objects to create one closed path
        !of detectors out of several detector lists
        use bf_detector_dcr_param_class, only :
     $     bf_detector_dcr_param

        !subroutines needed to compute the position
        !of intermediate detectors when combining
        !several detector lists into one closed path
        use bf_detector_module, only :
     $       get_inter_detector_param,
     $       get_inter_detector_coords

        !temporary object to store the new detectors
        !before being reduced to only the number of
        !elements stored
        use bf_detector_icr_list_class, only :
     $       bf_detector_icr_list

        !temporary object to store the bc_interior_pt
        !grid points activated by the detectors
        use bf_path_icr_class, only :
     $       bf_path_icr

        use bf_nbc_template_module
 
        use bf_sublayer_class, only :
     $       bf_sublayer

        use bf_interface_class, only :
     $       bf_interface

        use parameters_bf_layer, only :
     $       bc_interior_pt,
     $       dct_icr_distance,
     $       dct_icr_N_default,
     $       dct_icr_S_default,
     $       dct_icr_E_default,
     $       dct_icr_W_default

        use parameters_constant, only :
     $       N,S,E,W,interior

        use parameters_input, only :
     $       nx,ny,ne,bc_size,
     $       dt,search_nb_dt,
     $       write_detectors

        use parameters_kind, only :
     $       ikind,
     $       rkind

        use pmodel_eq_class, only :
     $       pmodel_eq

        implicit none

        private
        public :: bf_interface_icr


        !>@class bf_interface_icr
        !> class encapsulating the position of the increasing detectors
        !> and the subroutines extending the interior domain
        !
        !>@param N_detectors_list
        !> list containing the position of the north detectors
        !
        !>@param S_detectors_list
        !> list containing the position of the south detectors
        !
        !>@param E_detectors_list
        !> list containing the position of the east detectors
        !
        !>@param W_detectors_list
        !> list containing the position of the west detectors
        !
        !>@param ini
        !> initialize the position of the increasing detectors
        !> and the parent object
        !
        !>@param get_modified_grdpts_list
        !> from a detector position, get a list of bc_interior_pt
        !> activated
        !
        !>@param process_idetector_list
        !> process the list of current detectors, modify the buffer
        !> layers. If they are activated by the detectors and
        !> determine the new list of detectors
        !
        !>@param combine_bf_idetector_lists
        !> connect the bf_detector_icr_list objects and determine the
        !> new detector lists
        !
        !>@param update_bf_layers_with_idetectors
        !> update the size of the computational domain based on the
        !> increasing detector activations
        !
        !>@param update_icr_detectors_after_removal
        !> update the position of the increasing detectors
        !> if a sublayer is removed
        !
        !>@param remove_sublayer
        !> remove a sublayer
        !
        !>@param is_detector_icr_activated
        !> check whether the detector is activated
        !
        !>@param get_central_grdpt
        !> check whether the detector is activated
        !
        !>@param check_neighboring_bc_interior_pts
        !> check the identity of the grid points surrounding a central
        !> point: this function encapsulates the function used if the
        !> central point is at the interface between the interior and
        !> the buffer layers and the function checking the grid points
        !> in case all the grid points are inside a buffer layer
        !
        !>@param check_neighboring_bc_interior_pts_for_interior
        !> check the neighboring bc_interior_pt around the central
        !> point identified by its general coordinates
        !
        !>@param is_inside_border_layer
        !> check the identity of the grid points surrounding a central
        !> point: this function encapsulates the function used if the
        !> central point is at the interface between the interior and
        !> the buffer layers and the function checking the grid points
        !> in case all the grid points are inside a buffer layer
        !
        !>@param create_nbc_interior_pt_template
        !> create the template for the neighboring points around
        !> the central point asked: as the central is located in
        !> a layer at the interface between the interior points
        !> and the boundary layers, it is required to initialize
        !> the template using the coordinates as if there were no
        !> boundary layers, then data are exchanged with the
        !> neighboring buffer layers
        !
        !>@param check_nbc_interior_pt_template
        !> check if the grid points around the center point are
        !> bc_interior_pt
        !
        !>@param check_bc_interior_pt
        !> check whether the grid point tested is a bc_interior_pt
        !> and if so save the general coordinates of the grid point
        !> in mgrdpts
        !
        !>@param update_grdpts_id_for_template
        !> update the position of the increasing detectors
        !> if a sublayer is removed
        !
        !>@param print_idetectors_on
        !> print the increasing detector positions on a matrix
        !
        !>@param print_idetectors_on_formatted_file
        !> print the increasing detector positions on formatted
        !> output files
        !---------------------------------------------------------------
        type, extends(bf_interface) :: bf_interface_icr

          integer(ikind), dimension(:,:), allocatable, private :: N_dct_icoords
          integer(ikind), dimension(:,:), allocatable, private :: S_dct_icoords
          integer(ikind), dimension(:,:), allocatable, private :: E_dct_icoords
          integer(ikind), dimension(:,:), allocatable, private :: W_dct_icoords

          real(rkind)   , dimension(:,:), allocatable, private :: N_dct_rcoords
          real(rkind)   , dimension(:,:), allocatable, private :: S_dct_rcoords
          real(rkind)   , dimension(:,:), allocatable, private :: E_dct_rcoords
          real(rkind)   , dimension(:,:), allocatable, private :: W_dct_rcoords

          contains

          procedure,   pass :: ini
          procedure,   pass :: get_modified_grdpts_list
          procedure,   pass :: process_idetector_list
          procedure,   pass :: combine_bf_idetector_lists
          procedure,   pass :: update_bf_layers_with_idetectors

          procedure,   pass :: update_icr_detectors_after_removal
          procedure,   pass :: remove_sublayer

          procedure, nopass, private :: is_detector_icr_activated
          procedure, nopass          :: get_central_grdpt
          procedure,   pass, private :: check_neighboring_bc_interior_pts
          procedure,   pass, private :: check_neighboring_bc_interior_pts_for_interior
          procedure, nopass, private :: is_inside_border_layer
          procedure,   pass          :: create_nbc_interior_pt_template
          procedure, nopass          :: check_nbc_interior_pt_template
          procedure, nopass, private :: check_bc_interior_pt
          procedure,   pass, private :: update_grdpts_id_for_template

          procedure,   pass          :: print_netcdf
          procedure,   pass          :: print_idetectors_on
          procedure,   pass          :: print_idetectors_on_formatted_file

          procedure,   pass          :: get_dct_coords

        end type bf_interface_icr


        contains


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> initialize the position of the increasing detectors
        !> and the parent object
        !
        !> @date
        !> 27_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_interface_icr object encapsulating the position of
        !> the increasing detectors and the subroutine controlling
        !> the extension of the computational domain
        !--------------------------------------------------------------
        subroutine ini(this,interior_x_map,interior_y_map)

          implicit none

          class(bf_interface_icr)   , intent(inout) :: this
          real(rkind), dimension(nx), intent(in)    :: interior_x_map
          real(rkind), dimension(ny), intent(in)    :: interior_y_map

          integer(ikind) :: i


          !initialize the parent attributes
          call this%bf_interface%ini(interior_x_map,interior_y_map)


          !intialize the attributes specific to bf_interface_icr
          !list with the coordinates of the detectors as (i,j)
          allocate(this%N_dct_icoords(2,nx-2*(bc_size+dct_icr_distance)+2))
          allocate(this%N_dct_rcoords(2,nx-2*(bc_size+dct_icr_distance)+2))
          allocate(this%S_dct_icoords(2,nx-2*(bc_size+dct_icr_distance)+2))
          allocate(this%S_dct_rcoords(2,nx-2*(bc_size+dct_icr_distance)+2))          
          allocate(this%E_dct_icoords(2,ny-2*(bc_size+dct_icr_distance)))
          allocate(this%E_dct_rcoords(2,ny-2*(bc_size+dct_icr_distance)))
          allocate(this%W_dct_icoords(2,ny-2*(bc_size+dct_icr_distance)))
          allocate(this%W_dct_rcoords(2,ny-2*(bc_size+dct_icr_distance)))


          !arrays with the coordinates of the South detectors
          do i=bc_size+dct_icr_distance, nx-(bc_size+dct_icr_distance)+1

             !(x,y)-indices
             this%S_dct_icoords(1,i-(bc_size+dct_icr_distance)+1) = i
             this%S_dct_icoords(2,i-(bc_size+dct_icr_distance)+1) = dct_icr_S_default

             !(x,y)-coordinates
             this%S_dct_rcoords(1,i-(bc_size+dct_icr_distance)+1) = interior_x_map(i)
             this%S_dct_rcoords(2,i-(bc_size+dct_icr_distance)+1) = interior_y_map(dct_icr_S_default)

          end do


          !arrays with the coordinates of the North detectors
          do i=bc_size+dct_icr_distance, nx-(bc_size+dct_icr_distance)+1

             !(x,y)-indices
             this%N_dct_icoords(1,i-(bc_size+dct_icr_distance)+1) = i
             this%N_dct_icoords(2,i-(bc_size+dct_icr_distance)+1) = dct_icr_N_default

             !(x,y)-coordinates
             this%N_dct_rcoords(1,i-(bc_size+dct_icr_distance)+1) = interior_x_map(i)
             this%N_dct_rcoords(2,i-(bc_size+dct_icr_distance)+1) = interior_y_map(dct_icr_N_default)

          end do


          !arrays with the coordinates of the West detectors
          do i=bc_size+dct_icr_distance+1, ny-(bc_size+dct_icr_distance)

             !(x,y)-indices
             this%W_dct_icoords(1,i-(bc_size+dct_icr_distance)) = dct_icr_W_default
             this%W_dct_icoords(2,i-(bc_size+dct_icr_distance)) = i

             !(x,y)-coordinates
             this%W_dct_rcoords(1,i-(bc_size+dct_icr_distance)) = interior_x_map(dct_icr_W_default)
             this%W_dct_rcoords(2,i-(bc_size+dct_icr_distance)) = interior_y_map(i)

          end do


          !arrays with the coordinates of the East detectors
          do i=bc_size+dct_icr_distance+1, ny-(bc_size+dct_icr_distance)

             !(x,y)-indices
             this%E_dct_icoords(1,i-(bc_size+dct_icr_distance)) = dct_icr_E_default
             this%E_dct_icoords(2,i-(bc_size+dct_icr_distance)) = i

             !(x,y)-coordinates
             this%E_dct_rcoords(1,i-(bc_size+dct_icr_distance)) = interior_x_map(dct_icr_E_default)
             this%E_dct_rcoords(2,i-(bc_size+dct_icr_distance)) = interior_y_map(i)
             
          end do          

        end subroutine ini


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> update the size of the computational domain based on the
        !> increasing detector activations
        !
        !> @date
        !> 27_06_2014 - initial version - J.L. Desmarais
        !
        !> @param this
        !> bf_interface_icr object encapsulating the position of
        !> the increasing detectors and the subroutine controlling
        !> the extension of the computational domain
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
        !> table encapsulating the coordinates along the x-axis
        !
        !> @param interior_y_map
        !> table encapsulating the coordinates along the y-axis
        !
        !> @param interior_nodes_0
        !> table encapsulating the data of the grid points of the
        !> interior domain at the previous time step (t-dt)
        !
        !> @param interior_nodes_1
        !> table encapsulating the data of the grid points of the
        !> interior domain at the current time step (t)
        !--------------------------------------------------------------
        subroutine update_bf_layers_with_idetectors(
     $     this,
     $     p_model,
     $     t,dt,
     $     interior_x_map,
     $     interior_y_map,
     $     interior_nodes0,
     $     interior_nodes1)

          implicit none

          class(bf_interface_icr)         , intent(inout) :: this
          type(pmodel_eq)                 , intent(in)    :: p_model
          real(rkind)                     , intent(in)    :: t
          real(rkind)                     , intent(in)    :: dt
          real(rkind), dimension(nx)      , intent(in)    :: interior_x_map
          real(rkind), dimension(ny)      , intent(in)    :: interior_y_map
          real(rkind), dimension(nx,ny,ne), intent(in)    :: interior_nodes0
          real(rkind), dimension(nx,ny,ne), intent(in)    :: interior_nodes1


          type(bf_path_icr)              :: path_update_idetectors
          integer(ikind), dimension(2)   :: cpt_coords_p

          !temporary objects to store the new positions of the detectors
          type(bf_detector_icr_list)     :: N_dct_list_n
          type(bf_detector_icr_list)     :: S_dct_list_n
          type(bf_detector_icr_list)     :: E_dct_list_n
          type(bf_detector_icr_list)     :: W_dct_list_n


          !initialization of the path that will gather information
          !on the buffer layers to be updated: the path collects
          !the updating information belonging to a specific buffer
          !layer and when another buffer layer is activated by
          !the detectors the path applies all the changes to the
          !previous buffer layer and starts collecting information
          !on the next buffer layer
          call path_update_idetectors%ini()

          !there are 4 layers of detectors corresponding to the 4
          !cardinal points. They create a closed path of detectors
          !we update in this order:
          !1: S, 2: E, 3: W, 4: N
          !in this way the path created by one buffer layer can
          !be continued by the next list of detectors and prevent
          !double operations on buffer layers
          
          !0) initialization of the first point indicating 
          !   where the previous neighboring bc_interior_pt
          !   were analyzed
          cpt_coords_p = [nx/2, ny/2]

          !1) South detectors
          if(allocated(this%S_dct_icoords)) then
             call S_dct_list_n%ini(S, size(this%S_dct_icoords,2))

             call process_idetector_list(
     $            this,
     $            this%S_dct_icoords,
     $            this%S_dct_rcoords,
     $            S_dct_list_n,
     $            p_model,
     $            t,dt,
     $            interior_x_map,
     $            interior_y_map,
     $            interior_nodes0,
     $            interior_nodes1,
     $            cpt_coords_p,
     $            path_update_idetectors)

          end if

          !2) East detectors
          if(allocated(this%E_dct_icoords)) then
             call E_dct_list_n%ini(E, size(this%E_dct_icoords,2))

             call process_idetector_list(
     $            this,
     $            this%E_dct_icoords,
     $            this%E_dct_rcoords,
     $            E_dct_list_n,
     $            p_model,
     $            t,dt,
     $            interior_x_map,
     $            interior_y_map,
     $            interior_nodes0,
     $            interior_nodes1,
     $            cpt_coords_p,
     $            path_update_idetectors)

          end if

          !3) West detectors
          if(allocated(this%W_dct_icoords)) then
             call W_dct_list_n%ini(W, size(this%W_dct_icoords,2))

             call process_idetector_list(
     $            this,
     $            this%W_dct_icoords,
     $            this%W_dct_rcoords,
     $            W_dct_list_n,
     $            p_model,
     $            t,dt,
     $            interior_x_map,
     $            interior_y_map,
     $            interior_nodes0,
     $            interior_nodes1,
     $            cpt_coords_p,
     $            path_update_idetectors)

          end if

          !4) North detectors
          if(allocated(this%N_dct_icoords)) then
             call N_dct_list_n%ini(N, size(this%N_dct_icoords,2))

             call process_idetector_list(
     $            this,
     $            this%N_dct_icoords,
     $            this%N_dct_rcoords,
     $            N_dct_list_n,
     $            p_model,
     $            t,dt,
     $            interior_x_map,
     $            interior_y_map,
     $            interior_nodes0,
     $            interior_nodes1,
     $            cpt_coords_p,
     $            path_update_idetectors)

          end if

          !5) process the last path as after the detectors of
          !   the last main layer are analysed, it is possible
          !   that the final part of the path has not been
          !   processed
          if(path_update_idetectors%get_nb_pts().gt.0) then
             call path_update_idetectors%process_path(
     $            this,
     $            p_model,
     $            t,dt,
     $            interior_x_map,
     $            interior_y_map,
     $            interior_nodes0,
     $            interior_nodes1)
          end if


          !6) reconnect the detector paths
          !   the buffer layer have been updated
          !   we now have several detector lists but they do
          !   not make a closed path. They are now reconnected
          call combine_bf_idetector_lists(
     $         this,
     $         N_dct_list_n,
     $         S_dct_list_n,
     $         E_dct_list_n,
     $         W_dct_list_n)

        end subroutine update_bf_layers_with_idetectors


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> connect the bf_detector_icr_list objects and determine the
        !> new detector lists
        !
        !> @date
        !> 27_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_interface_icr object encapsulating the position of
        !> the increasing detectors and the subroutine controlling
        !> the extension of the computational domain
        !
        !>@param N_idetectors_list
        !> temporary object where the position of the new north
        !> increasing detectors is stored
        !
        !>@param S_idetectors_list
        !> temporary object where the position of the new south
        !> increasing detectors is stored
        !
        !>@param E_idetectors_list
        !> temporary object where the position of the new east
        !> increasing detectors is stored
        !
        !>@param W_idetectors_list
        !> temporary object where the position of the new west
        !> increasing detectors is stored
        !--------------------------------------------------------------
        subroutine combine_bf_idetector_lists(
     $     this,
     $     N_dct_list_n,
     $     S_dct_list_n,
     $     E_dct_list_n,
     $     W_dct_list_n)

          implicit none

          class(bf_interface_icr)   , intent(inout) :: this
          type(bf_detector_icr_list), intent(in)    :: N_dct_list_n
          type(bf_detector_icr_list), intent(in)    :: S_dct_list_n
          type(bf_detector_icr_list), intent(in)    :: E_dct_list_n
          type(bf_detector_icr_list), intent(in)    :: W_dct_list_n


          !intermediate coordinates when computing the parameters
          !for the detectors between the cardinal detector lists
          integer(ikind), dimension(2) :: icoord_1
          real(rkind)   , dimension(2) :: rcoord_1
          integer(ikind), dimension(2) :: icoord_2
          real(rkind)   , dimension(2) :: rcoord_2

          integer(ikind), dimension(2) :: icoord_SW
          real(rkind)   , dimension(2) :: rcoord_SW
          real(rkind)   , dimension(2) :: icoord_icr_SW
          real(rkind)   , dimension(2) :: rcoord_icr_SW
          integer(ikind)               :: inter_nb_SW

          integer(ikind), dimension(2) :: icoord_SE
          real(rkind)   , dimension(2) :: rcoord_SE
          real(rkind)   , dimension(2) :: icoord_icr_SE
          real(rkind)   , dimension(2) :: rcoord_icr_SE
          integer(ikind)               :: inter_nb_SE

          integer(ikind), dimension(2) :: icoord_NE
          real(rkind)   , dimension(2) :: rcoord_NE
          real(rkind)   , dimension(2) :: icoord_icr_NE
          real(rkind)   , dimension(2) :: rcoord_icr_NE
          integer(ikind)               :: inter_nb_NE

          integer(ikind), dimension(2) :: icoord_NW
          real(rkind)   , dimension(2) :: rcoord_NW
          real(rkind)   , dimension(2) :: icoord_icr_NW
          real(rkind)   , dimension(2) :: rcoord_icr_NW
          integer(ikind)               :: inter_nb_NW

          logical :: W_in_S
          logical :: S_in_E
          logical :: N_in_W
          logical :: N_in_E

          logical :: N_remove_first_dct
          logical :: N_remove_last_dct
          logical :: S_remove_first_dct
          logical :: S_remove_last_dct
          logical :: E_remove_first_dct
          logical :: E_remove_last_dct
          logical :: W_remove_first_dct
          logical :: W_remove_last_dct

          N_remove_first_dct = .false.
          N_remove_last_dct  = .false.
          S_remove_first_dct = .false.
          S_remove_last_dct  = .false.
          E_remove_first_dct = .false.
          E_remove_last_dct  = .false.
          W_remove_first_dct = .false.
          W_remove_last_dct  = .false.


          !WARNING: we need to organize the intermediate detectors
          !         between the detector lists in increasing i and j
          !         otherwise, there will lead to important cache misses
          !         we also need to make sure that the detectors are
          !         correcty assigned to each cardinal point to prevent
          !         wrong connections between the detectors lists .i.e.
          !         we need to make sure that: ((<-> : is connected)
          !           - head(W) <-> head(S)
          !           - tail(S) <-> head(E)
          !           - tail(E) <-> tail(N)
          !           - head(N) <-> tail(W)

          ! determine the parameters for the intermediate
          ! detectors between the W and S detectors
          call W_dct_list_n%get_head(icoord_1,rcoord_1)
          call S_dct_list_n%get_head(icoord_2,rcoord_2)
          call get_inter_detector_param(
     $         icoord_1,
     $         rcoord_1,
     $         icoord_2,
     $         rcoord_2,
     $         icoord_icr_SW,
     $         rcoord_icr_SW,
     $         inter_nb_SW)

          !remove overlap b/w S and W
          if((icoord_1(1).eq.icoord_2(1)).and.(
     $         icoord_1(2).eq.icoord_2(1))) then
             W_remove_first_dct = .true.
          end if

          !
          !  |  ___S___
          ! W| /
          !  !/
          !----------------------------------------
          if(icoord_icr_SW(2).ge.0) then

             W_in_S = .true.

             icoord_SW = icoord_1
             rcoord_SW = rcoord_1

          else

          !
          !  |                        |
          ! W|                       W|
          !  !              or        !
          !   \                      /
          !    \___S____            /____S____
          !----------------------------------------
             W_in_S = .false.

             icoord_SW = icoord_2
             rcoord_SW = rcoord_2

             icoord_icr_SW(1) = -icoord_icr_SW(1)
             icoord_icr_SW(2) = -icoord_icr_SW(2)
             rcoord_icr_SW(1) = -rcoord_icr_SW(1)
             rcoord_icr_SW(2) = -rcoord_icr_SW(2)

          end if


          ! determine the parameters for the intermediate
          ! detectors between the E and S detectors
          call S_dct_list_n%get_tail(icoord_1,rcoord_1)
          call E_dct_list_n%get_head(icoord_2,rcoord_2)
          call get_inter_detector_param(
     $         icoord_1,
     $         rcoord_1,
     $         icoord_2,
     $         rcoord_2,
     $         icoord_icr_SE,
     $         rcoord_icr_SE,
     $         inter_nb_SE)

          !remove overlap b/w S and E
          if((icoord_1(1).eq.icoord_2(1)).and.(
     $         icoord_1(2).eq.icoord_2(1))) then
             E_remove_first_dct = .true.
          end if


          icoord_SE = icoord_1
          rcoord_SE = rcoord_1

          !
          !          |E 
          !          !
          !         /
          ! ___S___/
          !----------------------------------------
          if(icoord_icr_SE(2).gt.0) then

             S_in_E = .true.
          !
          !          |
          !          |
          ! ___S___  |E
          !        \ |
          !         \!
          !----------------------------------------
          else

             S_in_E = .false.

          end if


          ! determine the parameters for the intermediate
          ! detectors between the W and N detectors
          call W_dct_list_n%get_tail(icoord_1,rcoord_1)
          call N_dct_list_n%get_head(icoord_2,rcoord_2)
          call get_inter_detector_param(
     $         icoord_1,
     $         rcoord_1,
     $         icoord_2,
     $         rcoord_2,
     $         icoord_icr_NW,
     $         rcoord_icr_NW,
     $         inter_nb_NW)

          !remove overlap b/w W and N
          if((icoord_1(1).eq.icoord_2(1)).and.(
     $         icoord_1(2).eq.icoord_2(1))) then
             W_remove_last_dct = .true.
          end if

          icoord_NW = icoord_1
          rcoord_NW = rcoord_1
          
          !     ____N____
          !    /
          !   /       
          !  |
          ! W|
          !  |
          !----------------------------------------
          if(icoord_icr_NW(2).gt.0) then

             N_in_W = .true.

          else

             N_in_W = .false.

          end if


          ! determine the parameters for the intermediate
          ! detectors between the E and N detectors
          call E_dct_list_n%get_tail(icoord_1,rcoord_1)
          call N_dct_list_n%get_tail(icoord_2,rcoord_2)
          call get_inter_detector_param(
     $         icoord_1,
     $         rcoord_1,
     $         icoord_2,
     $         rcoord_2,
     $         icoord_icr_NE,
     $         rcoord_icr_NE,
     $         inter_nb_NE)

          !remove overlap b/w E and N
          if((icoord_1(1).eq.icoord_2(1)).and.(
     $         icoord_1(2).eq.icoord_2(1))) then
             E_remove_last_dct = .true.
          end if

          ! ____N____
          !          \
          !           \
          !            |
          !            |E
          !            |
          !----------------------------------------
          if(icoord_icr_NE(2).gt.0) then

             N_in_E = .true.

             icoord_NE = icoord_1
             rcoord_NE = rcoord_1

          !
          !           /|
          ! ____N____/ |E
          !            |
          !----------------------------------------
          else

             N_in_E = .false.

             icoord_NE = icoord_2
             rcoord_NE = rcoord_2

             icoord_icr_NE(1) = -icoord_icr_NE(1)
             icoord_icr_NE(2) = -icoord_icr_NE(2)
             rcoord_icr_NE(1) = -rcoord_icr_NE(1)
             rcoord_icr_NE(2) = -rcoord_icr_NE(2)
          end if

          
          ! recombine South detector list
          call finalize_dct_list(
     $         this%S_dct_icoords,
     $         this%S_dct_rcoords,
     $         W_in_S,
     $         icoord_SW,
     $         rcoord_SW,
     $         icoord_icr_SW,
     $         rcoord_icr_SW,
     $         inter_nb_SW,
     $         S_dct_list_n,
     $         .not.(S_in_E),
     $         icoord_SE,
     $         rcoord_SE,
     $         icoord_icr_SE,
     $         rcoord_icr_SE,
     $         inter_nb_SE)

          ! recombine West detector list
          call finalize_dct_list(
     $         this%W_dct_icoords,
     $         this%W_dct_rcoords,
     $         .not.(W_in_S),
     $         icoord_SW,
     $         rcoord_SW,
     $         icoord_icr_SW,
     $         rcoord_icr_SW,
     $         inter_nb_SW,
     $         W_dct_list_n,
     $         N_in_W,
     $         icoord_NW,
     $         rcoord_NW,
     $         icoord_icr_NW,
     $         rcoord_icr_NW,
     $         inter_nb_NW)

          if(W_remove_first_dct.or.W_remove_last_dct) then

             call remove_overlap(
     $            this%W_dct_icoords,
     $            this%W_dct_rcoords,
     $            W_remove_first_dct,
     $            W_remove_last_dct)

          end if

          ! recombine East detector list
          call finalize_dct_list(
     $         this%E_dct_icoords,
     $         this%E_dct_rcoords,
     $         S_in_E,
     $         icoord_SE,
     $         rcoord_SE,
     $         icoord_icr_SE,
     $         rcoord_icr_SE,
     $         inter_nb_SE,
     $         E_dct_list_n,
     $         N_in_E,
     $         icoord_NE,
     $         rcoord_NE,
     $         icoord_icr_NE,
     $         rcoord_icr_NE,
     $         inter_nb_NE)

          if(E_remove_first_dct.or.E_remove_last_dct) then

             call remove_overlap(
     $            this%E_dct_icoords,
     $            this%E_dct_rcoords,
     $            E_remove_first_dct,
     $            E_remove_last_dct)

          end if

          ! recombine North detector list
          call finalize_dct_list(
     $         this%N_dct_icoords,
     $         this%N_dct_rcoords,
     $         .not.(N_in_W),
     $         icoord_NW,
     $         rcoord_NW,
     $         icoord_icr_NW,
     $         rcoord_icr_NW,
     $         inter_nb_NW,
     $         N_dct_list_n,
     $         .not.(N_in_E),
     $         icoord_NE,
     $         rcoord_NE,
     $         icoord_icr_NE,
     $         rcoord_icr_NE,
     $         inter_nb_NE)
             
        end subroutine combine_bf_idetector_lists  


        !construct the final detector list from the
        !multiple pieces: left detectors +
        !new detectors + right detectors
        subroutine finalize_dct_list(
     $     icoords_n,
     $     rcoords_n,
     $     add_detectors_left,
     $     icoord_left,
     $     rcoord_left,
     $     icoord_icr_left,
     $     rcoord_icr_left,
     $     inter_nb_left,
     $     dct_list,
     $     add_detectors_right,
     $     icoord_right,
     $     rcoord_right,
     $     icoord_icr_right,
     $     rcoord_icr_right,
     $     inter_nb_right)

          implicit none

          integer(ikind), dimension(:,:), allocatable, intent(inout) :: icoords_n
          real(rkind)   , dimension(:,:), allocatable, intent(inout) :: rcoords_n
          logical                                    , intent(in)    :: add_detectors_left
          integer(ikind), dimension(2)               , intent(in)    :: icoord_left
          real(rkind)   , dimension(2)               , intent(in)    :: rcoord_left
          real(rkind)   , dimension(2)               , intent(in)    :: icoord_icr_left
          real(rkind)   , dimension(2)               , intent(in)    :: rcoord_icr_left
          integer                                    , intent(in)    :: inter_nb_left
          type(bf_detector_icr_list)                 , intent(in)    :: dct_list
          logical                                    , intent(in)    :: add_detectors_right
          integer(ikind), dimension(2)               , intent(in)    :: icoord_right
          real(rkind)   , dimension(2)               , intent(in)    :: rcoord_right
          real(rkind)   , dimension(2)               , intent(in)    :: icoord_icr_right
          real(rkind)   , dimension(2)               , intent(in)    :: rcoord_icr_right
          integer                                    , intent(in)    :: inter_nb_right
          
          integer(ikind), dimension(2) :: icoord_inter
          real(rkind)   , dimension(2) :: rcoord_inter
          integer(ikind)               :: nb_dct
          integer(ikind)               :: k,k_start


          !determine the total number of detectors
          nb_dct = dct_list%get_nb_detectors()
          if(add_detectors_left) then
             nb_dct = nb_dct + inter_nb_left
          end if
          if(add_detectors_right) then
             nb_dct = nb_dct + inter_nb_right
          end if


          !allocate space to store the detector positions
          if(allocated(icoords_n)) then
             if(.not.(size(icoords_n,2).eq.nb_dct)) then
                deallocate(icoords_n)
                deallocate(rcoords_n)
                allocate(icoords_n(2,nb_dct))
                allocate(rcoords_n(2,nb_dct))
             end if
          else
             allocate(icoords_n(2,nb_dct))
             allocate(rcoords_n(2,nb_dct))
          end if


          !add the left detectors
          k_start = 1
          if(add_detectors_left) then
             do k=1, inter_nb_left
                call get_inter_detector_coords(
     $               icoord_left,
     $               rcoord_left,
     $               icoord_icr_left,
     $               rcoord_icr_left,
     $               k,
     $               icoord_inter,
     $               rcoord_inter)
                icoords_n(:,k) = icoord_inter
                rcoords_n(:,k) = rcoord_inter
             end do
             k_start = inter_nb_left+1
          end if

          !add the central detectors
          call dct_list%fill_new_detector_table(
     $         k_start,
     $         icoords_n,
     $         rcoords_n)

          k_start = k_start+dct_list%get_nb_detectors()

          !add the right detectors
          if(add_detectors_right) then
             do k=1, inter_nb_right
                call get_inter_detector_coords(
     $               icoord_right,
     $               rcoord_right,
     $               icoord_icr_right,
     $               rcoord_icr_right,
     $               k,
     $               icoord_inter,
     $               rcoord_inter)
                icoords_n(:,k_start+k-1) = icoord_inter
                rcoords_n(:,k_start+k-1) = rcoord_inter
             end do
          end if

        end subroutine finalize_dct_list


        subroutine remove_overlap(
     $     icoords,
     $     rcoords,
     $     remove_first_dct,
     $     remove_last_dct)
        
          implicit none

          integer(ikind), dimension(:,:), allocatable, intent(inout) :: icoords
          real(rkind)   , dimension(:,:), allocatable, intent(inout) :: rcoords
          logical                                    , intent(in)    :: remove_first_dct
          logical                                    , intent(in)    :: remove_last_dct

          integer(ikind), dimension(:,:), allocatable :: tmp_icoords
          real(rkind)   , dimension(:,:), allocatable :: tmp_rcoords

          
          if(remove_first_dct) then
             if(remove_last_dct) then
                
                allocate(tmp_icoords(2,size(icoords,2)-2))
                allocate(tmp_rcoords(2,size(rcoords,2)-2))

                tmp_icoords = icoords(:,2:size(icoords,2)-1)
                tmp_rcoords = rcoords(:,2:size(rcoords,2)-1)

             else
                
                allocate(tmp_icoords(2,size(icoords,2)-1))
                allocate(tmp_rcoords(2,size(rcoords,2)-1))

                tmp_icoords = icoords(:,2:size(icoords,2))
                tmp_rcoords = rcoords(:,2:size(rcoords,2))
                
             end if

          else

             allocate(tmp_icoords(2,size(icoords,2)-1))
             allocate(tmp_rcoords(2,size(rcoords,2)-1))

             tmp_icoords = icoords(:,1:size(icoords,2)-1)
             tmp_rcoords = rcoords(:,1:size(rcoords,2)-1)
             
          end if          

          call MOVE_ALLOC(tmp_icoords,icoords)
          call MOVE_ALLOC(tmp_rcoords,rcoords)

        end subroutine remove_overlap


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> process the list of current detectors, modify the buffer layers
        !> if they are activated by the detectors and determine the new list
        !> of detectors
        !
        !> @date
        !> 27_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_interface_icr object encapsulating the position of
        !> the increasing detectors and the subroutine controlling
        !> the extension of the computational domain
        !
        !>@param dct_icoords
        !> (x,y) indices identifying the position of the detectors as
        !> general indices (beyond the interior domain)
        !
        !>@param dct_rcoords
        !> (x,y) coordinates identifying the position of the detectors
        !> as general coordinates (beyong the interior domain)
        !
        !>@param dct_list_n
        !> list containing the temporary new list of detectors
        !
        !>@param p_model
        !> physical model
        !
        !>@param t
        !> time
        !
        !>@param dt
        !> time step
        !
        !>@param interior_x_map
        !> x-coordinates of the interior domain
        !
        !>@param interior_y_map
        !> y-coordinates of the interior domain
        !
        !>@param interior_nodes0
        !> table encapsulating the data of the grid points of the
        !> interior domain at t=t-dt
        !
        !>@param interior_nodes1
        !> table encapsulating the data of the grid points of the
        !> interior domain at t=t
        !
        !>@param cpt_coords_p
        !> general coordinates of the central point triggered by the
        !> last detector at the previous step to optimize the number
        !> of grid points checked
        !
        !>@param path
        !> bf_path_icr object gathering the data when grid points are
        !> activated by the detectors
        !--------------------------------------------------------------
        subroutine process_idetector_list(
     $     this,
     $     dct_icoords,
     $     dct_rcoords,
     $     dct_list_n,
     $     p_model,
     $     t,dt,
     $     interior_x_map,
     $     interior_y_map,
     $     interior_nodes0,
     $     interior_nodes1,
     $     cpt_coords_p,
     $     path)
        
          implicit none

          class(bf_interface_icr)                      , intent(inout) :: this
          integer(ikind)          , dimension(:,:)     , intent(in)    :: dct_icoords
          real(rkind)             , dimension(:,:)     , intent(in)    :: dct_rcoords
          type(bf_detector_icr_list)                   , intent(inout) :: dct_list_n
          type(pmodel_eq)                              , intent(in)    :: p_model
          real(rkind)                                  , intent(in)    :: t
          real(rkind)                                  , intent(in)    :: dt
          real(rkind)             , dimension(nx)      , intent(in)    :: interior_x_map
          real(rkind)             , dimension(ny)      , intent(in)    :: interior_y_map
          real(rkind)             , dimension(nx,ny,ne), intent(in)    :: interior_nodes0
          real(rkind)             , dimension(nx,ny,ne), intent(in)    :: interior_nodes1
          integer(ikind)          , dimension(2)       , intent(inout) :: cpt_coords_p
          type(bf_path_icr)                            , intent(inout) :: path

          integer(ikind), dimension(2)   :: cpt_coords
          integer                        :: k,l
          integer                        :: nb_mgrdpts
          integer       , dimension(2,9) :: mgrdpts

          !loop over the detectors
          do k=1, size(dct_icoords,2)

             !extract the list of bc_interior_pt that should
             !be turned into interior_pt due to the activation
             !of the detector k
             call get_modified_grdpts_list(
     $            this,
     $            dct_icoords(:,k),
     $            dct_rcoords(:,k),
     $            interior_x_map,
     $            interior_y_map,
     $            interior_nodes1,
     $            p_model,
     $            cpt_coords_p,
     $            cpt_coords,
     $            nb_mgrdpts,
     $            mgrdpts,
     $            dct_list_n)

             !the point used as center point to determine the
             !neighboring points in the analysis of bc_interior_pt
             !is updated
             cpt_coords_p = cpt_coords

             !loop over the list of grid points to be turned from
             !bc_interior_pt to interior_pt
             do l=1, nb_mgrdpts
                
                !gathering the changes to a buffer layer
                !(allocate/reallocate/merge)
                call path%analyze_pt(mgrdpts(:,l), this)

                !if the grid point that is currently analyzed
                !leads to changes on a buffer layer which is
                !independent of the buffer layer investigated
                !up to now, all the changes are implemented
                !on the current buffer layer
                if(path%is_ended()) then

                   !the buffer layers are updated
                   call path%process_path(
     $                  this,
     $                  p_model,
     $                  t,dt,
     $                  interior_x_map,
     $                  interior_y_map,
     $                  interior_nodes0,
     $                  interior_nodes1)

                   !the grid point that led to the path end
                   !is used to reinitialize the current path
                   call path%analyze_pt(mgrdpts(:,l), this)

                end if

             end do
          end do

        end subroutine process_idetector_list


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> from a detector position, get a list of bc_interior_pt activated
        !
        !> @date
        !> 27_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_interface_icr object encapsulating the position of
        !> the increasing detectors and the subroutine controlling
        !> the extension of the computational domain
        !
        !>@param d_coords
        !> detector general coordinates
        !
        !>@param interior_nodes
        !> table encapsulating the data of the grid points of the
        !> interior domain
        !
        !>@param cpt_coords_p
        !> general coordinates of the central point triggered by the
        !> last detector
        !
        !>@param nb_mgrdpts
        !> number of grid points to be modified
        !
        !>@param mgrdpts
        !> list of the bc_interior_pt grid points to be modified
        !
        !>@param ndt_list
        !> temporary new detector list after their position update
        !--------------------------------------------------------------
        subroutine get_modified_grdpts_list(
     $     this,
     $     d_icoord,
     $     d_rcoord,
     $     interior_x_map,
     $     interior_y_map,
     $     interior_nodes,
     $     p_model,
     $     cpt_coord_p,
     $     cpt_coord,
     $     nb_mgrdpts,
     $     mgrdpts,
     $     ndt_list)

          implicit none

          class(bf_interface_icr)             , intent(inout) :: this
          integer(ikind) , dimension(2)       , intent(in)    :: d_icoord
          real(rkind)    , dimension(2)       , intent(in)    :: d_rcoord
          real(rkind)    , dimension(nx)      , intent(in)    :: interior_x_map
          real(rkind)    , dimension(ny)      , intent(in)    :: interior_y_map
          real(rkind)    , dimension(nx,ny,ne), intent(in)    :: interior_nodes
          type(pmodel_eq)                     , intent(in)    :: p_model
          integer(ikind) , dimension(2)       , intent(in)    :: cpt_coord_p
          integer(ikind) , dimension(2)       , intent(out)   :: cpt_coord
          integer                             , intent(out)   :: nb_mgrdpts
          integer(ikind) , dimension(2,9)     , intent(out)   :: mgrdpts
          type(bf_detector_icr_list)          , intent(inout) :: ndt_list


          real(rkind)   , dimension(ne):: node_var
          real(rkind)   , dimension(2) :: velocity
          integer(ikind), dimension(2) :: d_icoord_n
          real(rkind)   , dimension(2) :: d_rcoord_n


          !initialization of the number of modified grid points
          nb_mgrdpts = 0


          !extract the nodes at the coordinates of the detector
          node_var = this%get_nodes(d_icoord, interior_nodes)


          !if the detector is activated, then we check
          !whether grid points need to be modified
          if(is_detector_icr_activated(node_var, p_model)) then

             !extract the velocity at the coordinates of the detector
             velocity = p_model%get_velocity(node_var)
             

             !get the first point from which we should look for a
             !bc_interior_pt to be activated and the new coordinates
             !from the detector
             cpt_coord = get_central_grdpt(
     $            d_icoord,
     $            d_rcoord,
     $            velocity,
     $            interior_x_map,
     $            interior_y_map,
     $            d_icoord_n,
     $            d_rcoord_n)
             
             !add the new coordinates of the detector of the ndt_list
             call ndt_list%add_new_detector(d_icoord_n, d_rcoord_n)

             !look for a bc_interior_pt around the point previously
             !computed whose coordinates are: cpt_coords
             !we make use of the previously checked neighboring points
             !whose center was cpt_coords_p to reduce the number of
             !grid points checked
             call check_neighboring_bc_interior_pts(
     $            this,
     $            cpt_coord_p,
     $            cpt_coord,
     $            nb_mgrdpts,
     $            mgrdpts)

          !otherwise, the coordinates of the new detector are simply
          !the previous ones, and are saved in the ndt_list
          else
             call ndt_list%add_new_detector(d_icoord,d_rcoord)
          end if

        end subroutine get_modified_grdpts_list


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> check whether the detector is activated
        !
        !> @date
        !> 27_06_2014 - initial version - J.L. Desmarais
        !
        !>@param nodes_var
        !> governing variables at the grid point
        !
        !>@return activated
        !> logical stating whether the detector is activated
        !--------------------------------------------------------------
        function is_detector_icr_activated(nodes, p_model)
     $     result(activated)
        
          implicit none
          
          real(rkind), dimension(ne), intent(in) :: nodes
          type(pmodel_eq)           , intent(in) :: p_model
          logical                                :: activated
          
          activated = p_model%are_openbc_undermined(nodes)

        end function is_detector_icr_activated


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> check whether the detector is activated
        !
        !> @date
        !> 27_06_2014 - initial version - J.L. Desmarais
        !
        !>@param d_coords
        !> detector general coordinates
        !
        !>@param velocity
        !> velocity vector at the detector position
        !
        !>@param dx
        !> grid size along the x-direction
        !
        !>@param dy
        !> grid size along the y-direction
        !
        !>@param d_coords_n
        !> new detector general coordinates
        !
        !>@return cpt_coords
        !> general coordinates of the grid point activated by the
        !> detector
        !--------------------------------------------------------------
        function get_central_grdpt(
     $     d_icoord,
     $     d_rcoord,
     $     velocity,
     $     interior_x_map,
     $     interior_y_map,
     $     d_icoord_n,
     $     d_rcoord_n)
     $     result(cpt_coords)

          implicit none

          integer(ikind), dimension(2) , intent(in)  :: d_icoord
          real(rkind)   , dimension(2) , intent(in)  :: d_rcoord
          real(rkind)   , dimension(2) , intent(in)  :: velocity
          real(rkind)   , dimension(nx), intent(in)  :: interior_x_map
          real(rkind)   , dimension(ny), intent(in)  :: interior_y_map
          integer(ikind), dimension(2) , intent(out) :: d_icoord_n
          real(rkind)   , dimension(2) , intent(out) :: d_rcoord_n
          integer(ikind), dimension(2)               :: cpt_coords

          real(rkind)               :: dx,dy
          real(rkind)               :: dir_x, dir_y
          real(rkind)               :: norm_velocity
          real(rkind), dimension(2) :: d_icoord_r

          dx = interior_x_map(2)-interior_x_map(1)
          dy = interior_y_map(2)-interior_y_map(1)

          !1) get the direction to look for a bc_interior_pt
          norm_velocity = SQRT(velocity(1)**2+velocity(2)**2)
          
          if(rkind.eq.4) then

             !2) get the point indices in the direction given
             !   by the velocity vector
             cpt_coords(1) = d_icoord(1) + nint(velocity(1)/norm_velocity*REAL(dct_icr_distance))
             cpt_coords(2) = d_icoord(2) + nint(velocity(2)/norm_velocity*REAL(dct_icr_distance))

          else

             !2) get the point indices in the direction given
             !   by the velocity vector
             cpt_coords(1) = d_icoord(1) + idnint(velocity(1)/norm_velocity*DBLE(dct_icr_distance))
             cpt_coords(2) = d_icoord(2) + idnint(velocity(2)/norm_velocity*DBLE(dct_icr_distance))
             
          end if


          !3) compute the new detector position
          dir_x  = velocity(1)*dt
          dir_y  = velocity(2)*dt

          d_rcoord_n(1) = d_rcoord(1) + dir_x
          d_rcoord_n(2) = d_rcoord(2) + dir_y

          
          !determine the coordinates of the detector according
          !to its general index coordinates
          if(d_icoord(1).le.0) then
             dx = interior_x_map(2) - interior_x_map(1)
             d_icoord_r(1) = interior_x_map(1)+(d_icoord(1)-1)*dx
          else
             if(d_icoord(1).le.nx) then
                d_icoord_r(1) = interior_x_map(d_icoord(1))
             else
                dx = interior_x_map(nx) - interior_x_map(nx-1)
                d_icoord_r(1) = interior_x_map(nx) + (d_icoord(1)-nx)*dx
             end if
          end if

          if(d_icoord(2).le.0) then
             dy = interior_y_map(2) - interior_y_map(1)
             d_icoord_r(2) = interior_y_map(1)+(d_icoord(2)-1)*dy
          else
             if(d_icoord(2).le.ny) then
                d_icoord_r(2) = interior_y_map(d_icoord(2))
             else
                dy = interior_y_map(ny) - interior_y_map(ny-1)
                d_icoord_r(2) = interior_y_map(ny) + (d_icoord(2)-ny)*dy
             end if
          end if


          !update of the x-index for the detector
          if((d_rcoord_n(1)-d_icoord_r(1)).gt.dx) then
             d_icoord_n(1) = d_icoord(1) + 1
          else
             if((d_rcoord_n(1)-d_icoord_r(1)).lt.(-dx)) then
                d_icoord_n(1) = d_icoord(1)-1
             else
                d_icoord_n(1) = d_icoord(1)
             end if
          end if

          !update of the y-index for the detector
          if((d_rcoord_n(2)-d_icoord_r(2)).gt.dy) then
             d_icoord_n(2) = d_icoord(2) + 1
          else
             if((d_rcoord_n(2)-d_icoord_r(2)).lt.(-dy)) then
                d_icoord_n(2) = d_icoord(2)-1
             else
                d_icoord_n(2) = d_icoord(2)
             end if
          end if

        end function get_central_grdpt


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> check the identity of the grid points surrounding a central
        !> point: this function encapsulates the function used if the
        !> central point is at the interface between the interior and
        !> the buffer layers and the function checking the grid points
        !> in case all the grid points are inside a buffer layer
        !
        !> @date
        !> 27_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_interface_icr object encapsulating the position of
        !> the increasing detectors and the subroutine controlling
        !> the extension of the computational domain
        !
        !>@param cpt_coords_p
        !> previous central point whose neighboring grid points
        !> have been tested
        !
        !>@param cpt_coords
        !> central point whose neighboring grid points should be 
        !> tested
        !
        !>@param nb_mgrdpts
        !> number of grid points to be modified
        !
        !>@param mgrdpts
        !> list of the bc_interior_pt grid points to be modified
        !--------------------------------------------------------------
        subroutine check_neighboring_bc_interior_pts(
     $     this,
     $     cpt_coords_p, cpt_coords,
     $     nb_mgrdpts, mgrdpts)

          implicit none

          class(bf_interface_icr)     , intent(in)  :: this
          integer(ikind), dimension(2), intent(in)  :: cpt_coords_p
          integer(ikind), dimension(2), intent(in)  :: cpt_coords
          integer                     , intent(out) :: nb_mgrdpts
          integer, dimension(:,:)     , intent(out) :: mgrdpts


          type(bf_sublayer), pointer :: sublayer
          integer(ikind), dimension(2) :: l_coords

          !1) analyze the coordinates of the point
          !   check if the point is located inside the interior domain
          !   or if it is located outside the interior and eventually
          !   in a buffer layer

          !if it is inside the border layer, the procedure creating
          !a template neighboring grid point is used
          if(is_inside_border_layer(cpt_coords)) then
             call check_neighboring_bc_interior_pts_for_interior(
     $            this,
     $            cpt_coords_p,
     $            cpt_coords,
     $            nb_mgrdpts,
     $            mgrdpts)
             
          !otherwise, the neighboring grid points to be tested are
          !outside the interior and only a buffer layer can be used
          !to test it
          else
             sublayer => this%get_sublayer(cpt_coords, l_coords)
             if(associated(sublayer)) then
                call sublayer%check_neighboring_bc_interior_pts(
     $               cpt_coords_p(1), cpt_coords_p(2),
     $               cpt_coords(1), cpt_coords(2),
     $               nb_mgrdpts,
     $               mgrdpts)
             end if

          end if
          
        end subroutine check_neighboring_bc_interior_pts    


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> check the identity of the grid points surrounding a central
        !> point: this function encapsulates the function used if the
        !> central point is at the interface between the interior and
        !> the buffer layers and the function checking the grid points
        !> in case all the grid points are inside a buffer layer
        !
        !> @date
        !> 27_06_2014 - initial version - J.L. Desmarais
        !
        !>@param cpt_coords
        !> central point whose neighboring grid points should be 
        !> tested
        !
        !>@return is_border
        !> check whether the central point to be tested is at the
        !> interface between the interiro domain and the buffer layers
        !--------------------------------------------------------------
        function is_inside_border_layer(cpt_coords) result(is_border)

          implicit none

          integer(ikind), dimension(2), intent(in) :: cpt_coords
          logical                                  :: is_border


          logical :: is_interior_and_border
          logical :: is_interior


          is_interior_and_border =
     $         ((cpt_coords(1)).ge.1).and.
     $         ((cpt_coords(1)).le.nx).and.
     $         ((cpt_coords(2)).ge.1).and.
     $         ((cpt_coords(2)).le.ny)

          is_interior =
     $         (cpt_coords(1).ge.(bc_size+2)).and.
     $         (cpt_coords(1).le.(nx-bc_size-1)).and.
     $         (cpt_coords(2).ge.(bc_size+2)).and.
     $         (cpt_coords(2).le.(ny-bc_size-1))
          
          is_border = is_interior_and_border.and.(.not.is_interior)

        end function is_inside_border_layer


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> check the neighboring bc_interior_pt around the central
        !> point identified by its general coordinates
        !
        !> @date
        !> 27_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_interface_icr object encapsulating the position of
        !> the increasing detectors and the subroutine controlling
        !> the extension of the computational domain
        !
        !>@param cpt_coords_p
        !> previous central point whose neighboring grid points
        !> have been tested
        !
        !>@param cpt_coords
        !> central point whose neighboring grid points should be 
        !> tested
        !
        !>@param nb_mgrdpts
        !> number of grid points to be modified
        !
        !>@param mgrdpts
        !> list of the bc_interior_pt grid points to be modified        
        !--------------------------------------------------------------
        subroutine check_neighboring_bc_interior_pts_for_interior(
     $     this,
     $     cpt_coords_p,
     $     cpt_coords,
     $     nb_mgrdpts,
     $     mgrdpts)

          implicit none

          class(bf_interface_icr)       , intent(in)    :: this
          integer(ikind), dimension(2)  , intent(in)    :: cpt_coords_p
          integer(ikind), dimension(2)  , intent(in)    :: cpt_coords
          integer                       , intent(inout) :: nb_mgrdpts
          integer(ikind), dimension(:,:), intent(out)   :: mgrdpts


          integer, dimension(3,3) :: nbc_template


          !1) initialize an array containing the grid points
          !   identity around the central point and update this
          !   array using the potential buffer layers overlapping
          !   this array
          nbc_template = create_nbc_interior_pt_template(this, cpt_coords)


          !2) identify which grid points are bc_interior_pt
          !   and save them in the mgrdpts array with their general
          !   coordinates
          call check_nbc_interior_pt_template(
     $         nbc_template,
     $         cpt_coords_p(1), cpt_coords_p(2),
     $         cpt_coords(1), cpt_coords(2),
     $         nb_mgrdpts,
     $         mgrdpts)

        end subroutine check_neighboring_bc_interior_pts_for_interior


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> check if the grid points around the center point are
        !> bc_interior_pt
        !
        !> @date
        !> 27_06_2014 - initial version - J.L. Desmarais
        !
        !>@param nbc_template
        !> temporary array created to combine information on the
        !> role of the grid points at the interface between the interior
        !> domain and the buffer layers
        !
        !>@param i_prev
        !> x-index of the previous central point whose neighboring grid
        !> points have been tested
        !
        !>@param j_prev
        !> y-index of the previous central point whose neighboring grid
        !> points have been tested
        !
        !>@param i_center
        !> x-index of the central point whose neighboring grid
        !> points should be tested
        !
        !>@param j_center
        !> y-index of the central point whose neighboring grid
        !> points should be tested
        !
        !>@param nb_mgrdpts
        !> number of grid points to be modified
        !
        !>@param mgrdpts
        !> list of the bc_interior_pt grid points to be modified        
        !--------------------------------------------------------------
        subroutine check_nbc_interior_pt_template(
     $     nbc_template,
     $     i_prev, j_prev,
     $     i_center, j_center,
     $     nb_mgrdpts,
     $     mgrdpts)

          implicit none

          integer, dimension(3,3)        , intent(in)    :: nbc_template
          integer(ikind)                 , intent(in)    :: i_prev
          integer(ikind)                 , intent(in)    :: j_prev
          integer(ikind)                 , intent(in)    :: i_center
          integer(ikind)                 , intent(in)    :: j_center
          integer                        , intent(inout) :: nb_mgrdpts
          integer(ikind) , dimension(:,:), intent(out)   :: mgrdpts


          !radius for the search of bc_interior_pt around the
          !central point identified by (i_center, j_center)
          integer, parameter :: search_r = 1

          integer(ikind), dimension(2) :: match_table
          integer(ikind) :: min_j, max_j
          integer(ikind) :: size_x, size_y
          integer(ikind) :: i,j


          !get the match table converting the general coords
          !into local coords
          match_table = [i_center-2, j_center-2]

          !get the borders of the loops
          min_j = min(j_center-j_prev,0)
          max_j = max(j_center-j_prev,0)

          size_x = size(nbc_template,1)
          size_y = size(nbc_template,2)


          do j=max(1,-search_r+j_center-match_table(2)),
     $         min(size_y, j_prev-search_r-1-match_table(2))

             do i=max(1,-search_r+i_center-match_table(1)),
     $            min(size_x, i_center+search_r-match_table(1))
                
                call check_bc_interior_pt(
     $               i,j,
     $               match_table,
     $               nbc_template,
     $               nb_mgrdpts,
     $               mgrdpts)
                
             end do
          end do


          do j=max(1,-search_r+j_center+min_j-match_table(2)),
     $         min(size_y, j_center+search_r-max_j-match_table(2))

             do i=max(1,-search_r+i_center-match_table(1)),
     $            min(size_x,i_prev-search_r-1-match_table(1))
                
                call check_bc_interior_pt(
     $               i,j,
     $               match_table,
     $               nbc_template,
     $               nb_mgrdpts,
     $               mgrdpts)

             end do
          end do


          do j=max(1,j_center-search_r-min_j-match_table(2)),
     $         min(size_y,j_center+search_r-max_j-match_table(2))

             do i=max(1,i_prev+search_r+1-match_table(1)),
     $            min(size_x,i_center+search_r-match_table(1))
                
                call check_bc_interior_pt(
     $               i,j,
     $               match_table,
     $               nbc_template,
     $               nb_mgrdpts,
     $               mgrdpts)
                
             end do
          end do


          do j=max(1,j_prev+search_r+1-match_table(2)),
     $         min(size_y,j_center+search_r-match_table(2))

             do i=max(1,i_center-search_r-match_table(1)),
     $            min(size_x,i_center+search_r-match_table(1))
                
                call check_bc_interior_pt(
     $               i,j,
     $               match_table,
     $               nbc_template,
     $               nb_mgrdpts,
     $               mgrdpts)
                
             end do
          end do

        end subroutine check_nbc_interior_pt_template


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> check whether the grid point tested is a bc_interior_pt
        !> and if so save the general coordinates of the grid point
        !> in mgrdpts
        !
        !> @date
        !> 27_06_2014 - initial version - J.L. Desmarais
        !
        !>@param i
        !> x-index of the grid point tested
        !
        !>@param j
        !> y-index of the grid point tested
        !
        !>@param match_table
        !> table converting the general coordinates into local coordinates
        !
        !>@param nbc_template
        !> temporary array created to combine information on the
        !> role of the grid points at the interface between the interior
        !> domain and the buffer layers
        !
        !>@param nb_mgrdpts
        !> number of grid points to be modified
        !
        !>@param mgrdpts
        !> list of the bc_interior_pt grid points to be modified        
        !--------------------------------------------------------------
        subroutine check_bc_interior_pt(
     $     i,j,
     $     match_table,
     $     nbc_template,
     $     nb_mgrdpts,
     $     mgrdpts)

          implicit none

          integer(ikind)                , intent(in)    :: i,j
          integer(ikind), dimension(2)  , intent(in)    :: match_table
          integer(ikind), dimension(3,3), intent(in)    :: nbc_template
          integer                       , intent(inout) :: nb_mgrdpts
          integer(ikind), dimension(:,:), intent(out)   :: mgrdpts

          if(nbc_template(i,j).eq.bc_interior_pt) then

             nb_mgrdpts = nb_mgrdpts+1
             mgrdpts(1,nb_mgrdpts) = i+match_table(1)
             mgrdpts(2,nb_mgrdpts) = j+match_table(2)
             
          end if

        end subroutine check_bc_interior_pt


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> create the template for the neighboring points around
        !> the central point asked: as the central is located in
        !> a layer at the interface between the interior points
        !> and the boundary layers, it is required to initialize
        !> the template using the coordinates as if there were no
        !> boundary layers, then data are exchanged with the
        !> neighboring buffer layers
        !
        !> @date
        !> 27_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_interface_icr object encapsulating the position of
        !> the increasing detectors and the subroutine controlling
        !> the extension of the computational domain
        !
        !>@param cpt_coords
        !> central point whose neighboring grid points should
        !> be tested
        !
        !>@return nbc_template
        !> temporary array created to combine information on the
        !> role of the grid points at the interface between the interior
        !> domain and the buffer layers
        !--------------------------------------------------------------
        function create_nbc_interior_pt_template(this, cpt_coords)
     $     result(nbc_template)

          implicit none

          class(bf_interface_icr)       , intent(in) :: this
          integer(ikind), dimension(2)  , intent(in) :: cpt_coords
          integer       , dimension(3,3)             :: nbc_template

          integer, parameter :: i_lim0  = 1
          integer, parameter :: i_lim1  = bc_size
          integer, parameter :: i_lim2  = bc_size+1
          integer, parameter :: i_lim31 = bc_size+3
          integer, parameter :: i_lim32 = nx-bc_size-1
          integer, parameter :: i_lim4  = nx-bc_size
          integer, parameter :: i_lim5  = nx-bc_size+1
          integer, parameter :: i_lim6  = nx

          integer, parameter :: j_lim0  = 1
          integer, parameter :: j_lim1  = bc_size
          integer, parameter :: j_lim2  = bc_size+1
          integer, parameter :: j_lim31 = bc_size+3
          integer, parameter :: j_lim32 = ny-bc_size-1
          integer, parameter :: j_lim4  = ny-bc_size
          integer, parameter :: j_lim5  = ny-bc_size+1
          integer, parameter :: j_lim6  = ny

          
          select case(cpt_coords(1))

            case(i_lim0)
               select case(cpt_coords(2))
                 case(j_lim0)
                    nbc_template = make_nbc_template_00()
                    call update_grdpts_id_for_template(
     $                   this, S, cpt_coords, nbc_template)
                 case(j_lim1)
                    nbc_template = make_nbc_template_01()
                    call update_grdpts_id_for_template(
     $                   this, S, cpt_coords, nbc_template)

                 case(j_lim2, j_lim31)
                    nbc_template = make_nbc_template_02()
                    call update_grdpts_id_for_template(
     $                   this, S, cpt_coords, nbc_template)

                 case(j_lim32, j_lim4)
                    nbc_template = make_nbc_template_02()
                    call update_grdpts_id_for_template(
     $                   this, N, cpt_coords, nbc_template)

                 case(j_lim5)
                    nbc_template = make_nbc_template_05()
                    call update_grdpts_id_for_template(
     $                   this, N, cpt_coords, nbc_template)

                 case(j_lim6)
                    nbc_template = make_nbc_template_06()
                    call update_grdpts_id_for_template(
     $                   this, N, cpt_coords, nbc_template)

                 case default
                    nbc_template = make_nbc_template_02()
               end select

               call update_grdpts_id_for_template(
     $              this, W, cpt_coords, nbc_template)

            case(i_lim1)

               select case(cpt_coords(2))
                 case(j_lim0)
                    nbc_template = make_nbc_template_10()
                    call update_grdpts_id_for_template(
     $                   this, S, cpt_coords, nbc_template)
                 case(j_lim1)
                    nbc_template = make_nbc_template_11()
                    call update_grdpts_id_for_template(
     $                   this, S, cpt_coords, nbc_template)

                 case(j_lim2)
                    nbc_template = make_nbc_template_12()
                    call update_grdpts_id_for_template(
     $                   this, S, cpt_coords, nbc_template)

                 case(j_lim31)
                    nbc_template = make_nbc_template_13()
                    call update_grdpts_id_for_template(
     $                   this, S, cpt_coords, nbc_template)

                 case(j_lim32)
                    nbc_template = make_nbc_template_13()
                    call update_grdpts_id_for_template(
     $                   this, N, cpt_coords, nbc_template)

                 case(j_lim4)
                    nbc_template = make_nbc_template_14()
                    call update_grdpts_id_for_template(
     $                   this, N, cpt_coords, nbc_template)

                 case(j_lim5)
                    nbc_template = make_nbc_template_15()
                    call update_grdpts_id_for_template(
     $                   this, N, cpt_coords, nbc_template)

                 case(j_lim6)
                    nbc_template = make_nbc_template_16()
                    call update_grdpts_id_for_template(
     $                   this, N, cpt_coords, nbc_template)

                 case default
                    nbc_template = make_nbc_template_13()
               end select

               call update_grdpts_id_for_template(
     $              this, W, cpt_coords, nbc_template)

            case(i_lim2)
               select case(cpt_coords(2))
                 case(j_lim0)
                    nbc_template = make_nbc_template_20()
                    call update_grdpts_id_for_template(
     $                   this, S, cpt_coords, nbc_template)

                 case(j_lim1)
                    nbc_template = make_nbc_template_21()
                    call update_grdpts_id_for_template(
     $                   this, S, cpt_coords, nbc_template)

                 case(j_lim2)
                    nbc_template = make_nbc_template_22()
                    call update_grdpts_id_for_template(
     $                   this, S, cpt_coords, nbc_template)

                 case(j_lim31)
                    nbc_template = make_nbc_template_23()
                    call update_grdpts_id_for_template(
     $                   this, S, cpt_coords, nbc_template)

                 case(j_lim32)
                    nbc_template = make_nbc_template_23()
                    call update_grdpts_id_for_template(
     $                   this, N, cpt_coords, nbc_template)

                 case(j_lim4)
                    nbc_template = make_nbc_template_24()
                    call update_grdpts_id_for_template(
     $                   this, N, cpt_coords, nbc_template)

                 case(j_lim5)
                    nbc_template = make_nbc_template_25()
                    call update_grdpts_id_for_template(
     $                   this, N, cpt_coords, nbc_template)

                 case(j_lim6)
                    nbc_template = make_nbc_template_26()
                    call update_grdpts_id_for_template(
     $                   this, N, cpt_coords, nbc_template)

                 case default
                    nbc_template = make_nbc_template_23()
               end select

               call update_grdpts_id_for_template(
     $              this, W, cpt_coords, nbc_template)

            case(i_lim31)
               select case(cpt_coords(2))
                 case(j_lim0)
                    nbc_template = make_nbc_template_20()
                    call update_grdpts_id_for_template(
     $                   this, S, cpt_coords, nbc_template)

                 case(j_lim1)
                    nbc_template = make_nbc_template_31()
                    call update_grdpts_id_for_template(
     $                   this, S, cpt_coords, nbc_template)

                 case(j_lim2)
                    nbc_template = make_nbc_template_32()
                    call update_grdpts_id_for_template(
     $                   this, S, cpt_coords, nbc_template)

                 case(j_lim4)
                    nbc_template = make_nbc_template_34()
                    call update_grdpts_id_for_template(
     $                   this, N, cpt_coords, nbc_template)

                 case(j_lim5)
                    nbc_template = make_nbc_template_35()
                    call update_grdpts_id_for_template(
     $                   this, N, cpt_coords, nbc_template)

                 case(j_lim6)
                    nbc_template = make_nbc_template_26()
                    call update_grdpts_id_for_template(
     $                   this, N, cpt_coords, nbc_template)
               end select

               call update_grdpts_id_for_template(
     $              this, W, cpt_coords, nbc_template)

            case(i_lim32)
               select case(cpt_coords(2))
                 case(j_lim0)
                    nbc_template = make_nbc_template_20()
                    call update_grdpts_id_for_template(
     $                   this, S, cpt_coords, nbc_template)

                 case(j_lim1)
                    nbc_template = make_nbc_template_31()
                    call update_grdpts_id_for_template(
     $                   this, S, cpt_coords, nbc_template)

                 case(j_lim2)
                    nbc_template = make_nbc_template_32()
                    call update_grdpts_id_for_template(
     $                   this, S, cpt_coords, nbc_template)

                 case(j_lim4)
                    nbc_template = make_nbc_template_34()
                    call update_grdpts_id_for_template(
     $                   this, N, cpt_coords, nbc_template)

                 case(j_lim5)
                    nbc_template = make_nbc_template_35()
                    call update_grdpts_id_for_template(
     $                   this, N, cpt_coords, nbc_template)

                 case(j_lim6)
                    nbc_template = make_nbc_template_26()
                    call update_grdpts_id_for_template(
     $                   this, N, cpt_coords, nbc_template)
               end select

               call update_grdpts_id_for_template(
     $              this, E, cpt_coords, nbc_template)

            case(i_lim4)
               select case(cpt_coords(2))
                 case(j_lim0)
                    nbc_template = make_nbc_template_20()
                    call update_grdpts_id_for_template(
     $                   this, S, cpt_coords, nbc_template)

                 case(j_lim1)
                    nbc_template = make_nbc_template_41()
                    call update_grdpts_id_for_template(
     $                   this, S, cpt_coords, nbc_template)

                 case(j_lim2)
                    nbc_template = make_nbc_template_42()
                    call update_grdpts_id_for_template(
     $                   this, S, cpt_coords, nbc_template)

                 case(j_lim31)
                    nbc_template = make_nbc_template_43()
                    call update_grdpts_id_for_template(
     $                   this, S, cpt_coords, nbc_template)

                 case(j_lim32)
                    nbc_template = make_nbc_template_43()
                    call update_grdpts_id_for_template(
     $                   this, N, cpt_coords, nbc_template)

                 case(j_lim4)
                    nbc_template = make_nbc_template_44()
                    call update_grdpts_id_for_template(
     $                   this, N, cpt_coords, nbc_template)

                 case(j_lim5)
                    nbc_template = make_nbc_template_45()
                    call update_grdpts_id_for_template(
     $                   this, N, cpt_coords, nbc_template)

                 case(j_lim6)
                    nbc_template = make_nbc_template_26()
                    call update_grdpts_id_for_template(
     $                   this, N, cpt_coords, nbc_template)

                 case default
                    nbc_template = make_nbc_template_43()
               end select

               call update_grdpts_id_for_template(
     $              this, E, cpt_coords, nbc_template)

            case(i_lim5)
               select case(cpt_coords(2))
                 case(j_lim0)
                    nbc_template = make_nbc_template_50()
                    call update_grdpts_id_for_template(
     $                   this, S, cpt_coords, nbc_template)

                 case(j_lim1)
                    nbc_template = make_nbc_template_51()
                    call update_grdpts_id_for_template(
     $                   this, S, cpt_coords, nbc_template)

                 case(j_lim2)
                    nbc_template = make_nbc_template_52()
                    call update_grdpts_id_for_template(
     $                   this, S, cpt_coords, nbc_template)

                 case(j_lim31)
                    nbc_template = make_nbc_template_53()
                    call update_grdpts_id_for_template(
     $                   this, S, cpt_coords, nbc_template)

                 case(j_lim32)
                    nbc_template = make_nbc_template_53()
                    call update_grdpts_id_for_template(
     $                   this, N, cpt_coords, nbc_template)

                 case(j_lim4)
                    nbc_template = make_nbc_template_54()
                    call update_grdpts_id_for_template(
     $                   this, N, cpt_coords, nbc_template)

                 case(j_lim5)
                    nbc_template = make_nbc_template_55()
                    call update_grdpts_id_for_template(
     $                   this, N, cpt_coords, nbc_template)

                 case(j_lim6)
                    nbc_template = make_nbc_template_56()
                    call update_grdpts_id_for_template(
     $                   this, N, cpt_coords, nbc_template)

                 case default
                    nbc_template = make_nbc_template_53()
               end select

               call update_grdpts_id_for_template(
     $              this, E, cpt_coords, nbc_template)

            case(i_lim6)
               select case(cpt_coords(2))
                 case(j_lim0)
                    nbc_template = make_nbc_template_60()
                    call update_grdpts_id_for_template(
     $                   this, S, cpt_coords, nbc_template)

                 case(j_lim1)
                    nbc_template = make_nbc_template_61()
                    call update_grdpts_id_for_template(
     $                   this, S, cpt_coords, nbc_template)

                 case(j_lim2)
                    nbc_template = make_nbc_template_62()
                    call update_grdpts_id_for_template(
     $                   this, S, cpt_coords, nbc_template)

                 case(j_lim31)
                    nbc_template = make_nbc_template_62()
                    call update_grdpts_id_for_template(
     $                   this, S, cpt_coords, nbc_template)

                 case(j_lim32)
                    nbc_template = make_nbc_template_62()
                    call update_grdpts_id_for_template(
     $                   this, N, cpt_coords, nbc_template)

                 case(j_lim4)
                    nbc_template = make_nbc_template_62()
                    call update_grdpts_id_for_template(
     $                   this, N, cpt_coords, nbc_template)

                 case(j_lim5)
                    nbc_template = make_nbc_template_65()
                    call update_grdpts_id_for_template(
     $                   this, N, cpt_coords, nbc_template)

                 case(j_lim6)
                    nbc_template = make_nbc_template_66()
                    call update_grdpts_id_for_template(
     $                   this, N, cpt_coords, nbc_template)

                 case default
                    nbc_template = make_nbc_template_62()
               end select

               call update_grdpts_id_for_template(
     $              this, E, cpt_coords, nbc_template)

            case default
               select case(cpt_coords(2))
                 case(j_lim0)
                    nbc_template = make_nbc_template_20()
                    call update_grdpts_id_for_template(
     $                   this, S, cpt_coords, nbc_template)

                 case(j_lim1)
                    nbc_template = make_nbc_template_31()
                    call update_grdpts_id_for_template(
     $                   this, S, cpt_coords, nbc_template)

                 case(j_lim2)
                    nbc_template = make_nbc_template_32()
                    call update_grdpts_id_for_template(
     $                   this, S, cpt_coords, nbc_template)

                 case(j_lim31)
                    nbc_template = make_nbc_template_32()
                    call update_grdpts_id_for_template(
     $                   this, S, cpt_coords, nbc_template)

                 case(j_lim32)
                    nbc_template = make_nbc_template_32()
                    call update_grdpts_id_for_template(
     $                   this, N, cpt_coords, nbc_template)

                 case(j_lim4)
                    nbc_template = make_nbc_template_34()
                    call update_grdpts_id_for_template(
     $                   this, N, cpt_coords, nbc_template)

                 case(j_lim5)
                    nbc_template = make_nbc_template_35()
                    call update_grdpts_id_for_template(
     $                   this, N, cpt_coords, nbc_template)

                 case(j_lim6)
                    nbc_template = make_nbc_template_26()
                    call update_grdpts_id_for_template(
     $                   this, N, cpt_coords, nbc_template)
               end select

          end select

        end function create_nbc_interior_pt_template


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> copy the content of the grdpts_id table from neighboring
        !> buffer layers to the nbc_template
        !
        !> @date
        !> 27_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_interface_icr object encapsulating the position of
        !> the increasing detectors and the subroutine controlling
        !> the extension of the computational domain
        !
        !>@param mainlayer_id
        !> cardinal coordinate locating where the neighboring
        !> buffer layers are located
        !
        !>@param cpt_coords
        !> central point whose neighboring grid points should
        !> be tested
        !
        !>@param nbc_template
        !> temporary array created to combine information on the
        !> role of the grid points at the interface between the interior
        !> domain and the buffer layers
        !--------------------------------------------------------------
        subroutine update_grdpts_id_for_template(
     $     this, mainlayer_id, cpt_coords, nbc_template)

          implicit none

          class(bf_interface_icr)       , intent(in) :: this
          integer                       , intent(in) :: mainlayer_id
          integer(ikind), dimension(2)  , intent(in) :: cpt_coords
          integer       , dimension(3,3), intent(out):: nbc_template


          type(bf_sublayer), pointer   :: sublayer
          integer(ikind), dimension(2) :: local_coords


          sublayer => this%get_sublayer(
     $         cpt_coords,
     $         local_coords,
     $         tolerance_i=1,
     $         mainlayer_id_i=mainlayer_id)

          if(associated(sublayer)) then
             call sublayer%copy_grdpts_id_to_temp(
     $            cpt_coords, nbc_template)
          end if

        end subroutine update_grdpts_id_for_template


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> remove a bf_sublayer
        !
        !> @date
        !> 27_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_interface_icr object encapsulating the position of
        !> the increasing detectors and the subroutine controlling
        !> the extension of the computational domain
        !
        !>@param sublayer_ptr
        !> reference to the bf_sublayer which is removed
        !
        !>@param bf_mainlayer_id
        !> cardinal coordinate locating the buffer layer removed
        !--------------------------------------------------------------
        subroutine remove_sublayer(
     $     this,
     $     sublayer_ptr,
     $     interior_x_map,
     $     interior_y_map,
     $     bf_mainlayer_id)

          implicit none
          
          class(bf_interface_icr)         , intent(inout) :: this
          type(bf_sublayer), pointer      , intent(inout) :: sublayer_ptr
          real(rkind)      , dimension(nx), intent(in)    :: interior_x_map
          real(rkind)      , dimension(ny), intent(in)    :: interior_y_map
          integer, optional               , intent(in)    :: bf_mainlayer_id
          
          integer :: mainlayer_id


          !cardinal coordinate of the sublayer removed
          if(present(bf_mainlayer_id)) then
             mainlayer_id = bf_mainlayer_id
          else
             mainlayer_id = sublayer_ptr%get_localization()
          end if


          !reoganize the increasing detectors belonging
          !to the sublayer removed
          call update_icr_detectors_after_removal(
     $         this,
     $         mainlayer_id,
     $         sublayer_ptr%get_alignment_tab(),
     $         interior_x_map,
     $         interior_y_map)
          
          !remove the sublayer
          call this%bf_interface%remove_sublayer(
     $         sublayer_ptr,
     $         interior_x_map,
     $         interior_y_map,
     $         mainlayer_id)

        end subroutine remove_sublayer


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> update the position of the increasing detectors
        !> if a sublayer is removed
        !
        !> @date
        !> 27_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_interface_icr object encapsulating the position of
        !> the increasing detectors and the subroutine controlling
        !> the extension of the computational domain
        !
        !>@param bf_align
        !> alignment of the bf_sublayer which is removed
        !
        !>@param bf_mainlayer_id
        !> cardinal coordinate locating the buffer layer removed
        !--------------------------------------------------------------
        subroutine update_icr_detectors_after_removal(
     $     this,
     $     bf_mainlayer_id,
     $     bf_align,
     $     interior_x_map,
     $     interior_y_map)

          class(bf_interface_icr)       , intent(inout) :: this
          integer                       , intent(in)    :: bf_mainlayer_id
          integer(ikind), dimension(2,2), intent(in)    :: bf_align
          real(rkind)   , dimension(nx) , intent(in)    :: interior_x_map
          real(rkind)   , dimension(ny) , intent(in)    :: interior_y_map


          !temporary objects used to store the parameters
          !when removing detectors from the detector list
          type(bf_detector_dcr_param) :: N_dcr_param
          type(bf_detector_dcr_param) :: S_dcr_param
          type(bf_detector_dcr_param) :: E_dcr_param
          type(bf_detector_dcr_param) :: W_dcr_param

          logical :: N_remove_first_dct
          logical :: N_remove_last_dct
          logical :: S_remove_first_dct
          logical :: S_remove_last_dct
          logical :: E_remove_first_dct
          logical :: E_remove_last_dct
          logical :: W_remove_first_dct
          logical :: W_remove_last_dct          

          logical :: E_in_N
          logical :: E_in_S
          logical :: W_in_N
          logical :: W_in_S

          integer(ikind), dimension(2) :: icoord_1
          integer(ikind), dimension(2) :: icoord_2

          real(rkind)   , dimension(2) :: rcoord_1
          real(rkind)   , dimension(2) :: rcoord_2

          integer(ikind), dimension(2) :: N_first_dct_icoord
          integer(ikind), dimension(2) :: N_last_dct_icoord
          integer(ikind), dimension(2) :: S_first_dct_icoord
          integer(ikind), dimension(2) :: S_last_dct_icoord
          integer(ikind), dimension(2) :: E_first_dct_icoord
          integer(ikind), dimension(2) :: E_last_dct_icoord
          integer(ikind), dimension(2) :: W_first_dct_icoord
          integer(ikind), dimension(2) :: W_last_dct_icoord

          real(rkind), dimension(2) :: N_first_dct_rcoord
          real(rkind), dimension(2) :: N_last_dct_rcoord
          real(rkind), dimension(2) :: S_first_dct_rcoord
          real(rkind), dimension(2) :: S_last_dct_rcoord
          real(rkind), dimension(2) :: E_first_dct_rcoord
          real(rkind), dimension(2) :: E_last_dct_rcoord
          real(rkind), dimension(2) :: W_first_dct_rcoord
          real(rkind), dimension(2) :: W_last_dct_rcoord


          !determine the parameters for the removal of the
          !detectors belonging to the buffer layer removed
          call N_dcr_param%compute_new_list_param(
     $         bf_mainlayer_id,
     $         bf_align,
     $         interior_x_map,
     $         interior_y_map,
     $         this%N_dct_icoords,
     $         this%N_dct_rcoords)

          call S_dcr_param%compute_new_list_param(
     $         bf_mainlayer_id,
     $         bf_align,
     $         interior_x_map,
     $         interior_y_map,
     $         this%S_dct_icoords,
     $         this%S_dct_rcoords)

          call E_dcr_param%compute_new_list_param(
     $         bf_mainlayer_id,
     $         bf_align,
     $         interior_x_map,
     $         interior_y_map,
     $         this%E_dct_icoords,
     $         this%E_dct_rcoords)

          call W_dcr_param%compute_new_list_param(
     $         bf_mainlayer_id,
     $         bf_align,
     $         interior_x_map,
     $         interior_y_map,
     $         this%W_dct_icoords,
     $         this%W_dct_rcoords)          


          !determine the first and last detector of
          !each list to finalize the new etector lists
          !if there is an overlapping between two detector
          !lists (last detector of one list is the first
          !detector of another one for example), it has to
          !be removed also

          !============================================================
          !initialization for the overlap
          !============================================================
          N_remove_first_dct = .false.
          N_remove_last_dct  = .false.
          S_remove_first_dct = .false.
          S_remove_last_dct  = .false.
          E_remove_first_dct = .false.
          E_remove_last_dct  = .false.
          W_remove_first_dct = .false.
          W_remove_last_dct  = .false.          
          

          !============================================================
          !NW linking
          !============================================================
          call W_dcr_param%get_last_detector( icoord_1, rcoord_1)
          call N_dcr_param%get_first_detector(icoord_2, rcoord_2)

          if((icoord_2(2)-icoord_1(2)).gt.0) then
             W_in_N = .false.

             W_last_dct_icoord  = icoord_2
             W_last_dct_rcoord  = rcoord_2
             N_first_dct_icoord = icoord_2
             N_first_dct_rcoord = rcoord_2

          else
             W_in_N = .true.

             W_last_dct_icoord  = icoord_1
             W_last_dct_rcoord  = rcoord_1
             N_first_dct_icoord = icoord_1
             N_first_dct_rcoord = rcoord_1
          end if


          !overlap between N and W
          if(
     $         (icoord_1(1).eq.icoord_2(1)).and.
     $         (icoord_1(2).eq.icoord_2(2))
     $    ) then
             W_remove_last_dct = .true.
          end if
             

          !============================================================
          !NE linking
          !============================================================
          call E_dcr_param%get_last_detector(icoord_1, rcoord_1)
          call N_dcr_param%get_last_detector(icoord_2, rcoord_2)

          if((icoord_2(2)-icoord_1(2)).ge.0) then
             E_in_N = .false.

             E_last_dct_icoord = icoord_2
             E_last_dct_rcoord = rcoord_2
             N_last_dct_icoord = icoord_2
             N_last_dct_rcoord = rcoord_2

          else
             E_in_N = .true.

             E_last_dct_icoord  = icoord_1
             E_last_dct_rcoord  = rcoord_1
             N_first_dct_icoord = icoord_1
             N_first_dct_rcoord = rcoord_1
          end if


          !overlap between N and E
          if(
     $         (icoord_1(1).eq.icoord_2(1)).and.
     $         (icoord_1(2).eq.icoord_2(2))
     $    ) then
             E_remove_last_dct = .true.
          end if
          

          !============================================================
          !SW linking
          !============================================================
          call W_dcr_param%get_first_detector(icoord_1, rcoord_1)
          call S_dcr_param%get_first_detector(icoord_2, rcoord_2)

          if((icoord_2(2)-icoord_1(2)).ge.0) then
             W_in_S = .true.

             W_first_dct_icoord = icoord_1
             W_first_dct_rcoord = rcoord_1
             S_first_dct_icoord = icoord_1
             S_first_dct_rcoord = rcoord_1

          else
             W_in_S = .false.

             W_first_dct_icoord = icoord_2
             W_first_dct_rcoord = rcoord_2
             S_first_dct_icoord = icoord_2
             S_first_dct_rcoord = rcoord_2

          end if


          !overlap between S and W
          if(
     $         (icoord_1(1).eq.icoord_2(1)).and.
     $         (icoord_1(2).eq.icoord_2(2))
     $    ) then
             W_remove_first_dct = .true.
          end if


          !============================================================
          !SE linking
          !============================================================
          call S_dcr_param%get_last_detector(icoord_1, rcoord_1)
          call E_dcr_param%get_first_detector(icoord_2, rcoord_2)

          if((icoord_2(2)-icoord_1(2)).ge.0) then
             E_in_S = .false.

             S_last_dct_icoord  = icoord_1
             S_last_dct_rcoord  = rcoord_1
             E_first_dct_icoord = icoord_1
             E_first_dct_rcoord = rcoord_1

          else
             E_in_S = .true.

             S_last_dct_icoord  = icoord_2
             S_last_dct_rcoord  = rcoord_2
             E_first_dct_icoord = icoord_2
             E_first_dct_rcoord = rcoord_2

          end if


          !overlap between S and E
          if(
     $         (icoord_1(1).eq.icoord_2(1)).and.
     $         (icoord_1(2).eq.icoord_2(2))
     $    ) then
             E_remove_first_dct = .true.
          end if


          !now that the first and last detector of each
          !detector list is determined, the detector lists
          !can be finalized
          call N_dcr_param%finalize_new_list(
     $         bf_mainlayer_id,
     $         interior_x_map,
     $         interior_y_map,
     $         this%N_dct_icoords,
     $         this%N_dct_rcoords,
     $         N_first_dct_icoord,
     $         N_first_dct_rcoord,
     $         N_last_dct_icoord,
     $         N_last_dct_rcoord,
     $         N_remove_first_dct,
     $         N_remove_last_dct)

          call S_dcr_param%finalize_new_list(
     $         bf_mainlayer_id,
     $         interior_x_map,
     $         interior_y_map,
     $         this%S_dct_icoords,
     $         this%S_dct_rcoords,
     $         S_first_dct_icoord,
     $         S_first_dct_rcoord,
     $         S_last_dct_icoord,
     $         S_last_dct_rcoord,
     $         S_remove_first_dct,
     $         S_remove_last_dct)

          call E_dcr_param%finalize_new_list(
     $         bf_mainlayer_id,
     $         interior_x_map,
     $         interior_y_map,
     $         this%E_dct_icoords,
     $         this%E_dct_rcoords,
     $         E_first_dct_icoord,
     $         E_first_dct_rcoord,
     $         E_last_dct_icoord,
     $         E_last_dct_rcoord,
     $         E_remove_first_dct,
     $         E_remove_last_dct)

          call W_dcr_param%finalize_new_list(
     $         bf_mainlayer_id,
     $         interior_x_map,
     $         interior_y_map,
     $         this%W_dct_icoords,
     $         this%W_dct_rcoords,
     $         W_first_dct_icoord,
     $         W_first_dct_rcoord,
     $         W_last_dct_icoord,
     $         W_last_dct_rcoord,
     $         W_remove_first_dct,
     $         W_remove_last_dct)

        end subroutine update_icr_detectors_after_removal

      
        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> print the increasing detector positions on a matrix
        !
        !> @date
        !> 27_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_interface_icr object encapsulating the position of
        !> the increasing detectors and the subroutine controlling
        !> the extension of the computational domain
        !
        !>@param matrix
        !> array on which the position of the increasing detectors
        !> is indicated
        !--------------------------------------------------------------
        subroutine print_idetectors_on(this, matrix)

          implicit none

          class(bf_interface_icr)    , intent(in)  :: this
          real(rkind), dimension(:,:), intent(out) :: matrix

          real(rkind), parameter :: N_detector_color = 0.9d0
          real(rkind), parameter :: S_detector_color = 0.7d0
          real(rkind), parameter :: E_detector_color = 0.5d0
          real(rkind), parameter :: W_detector_color = 0.2d0
          integer(ikind) :: i,j,k


          if(allocated(this%N_dct_icoords)) then
             do k=1, size(this%N_dct_icoords,2)
                i = this%N_dct_icoords(1,k)
                j = this%N_dct_icoords(2,k)
                matrix(i,j) = N_detector_color
             end do
          end if

          if(allocated(this%S_dct_icoords)) then
             do k=1, size(this%S_dct_icoords,2)
                i = this%S_dct_icoords(1,k)
                j = this%S_dct_icoords(2,k)
                matrix(i,j) = S_detector_color
             end do
          end if

          if(allocated(this%E_dct_icoords)) then
             do k=1, size(this%E_dct_icoords,2)
                i = this%E_dct_icoords(1,k)
                j = this%E_dct_icoords(2,k)
                matrix(i,j) = E_detector_color
             end do
          end if
          
          if(allocated(this%W_dct_icoords)) then
             do k=1, size(this%W_dct_icoords,2)
                i = this%W_dct_icoords(1,k)
                j = this%W_dct_icoords(2,k)
                matrix(i,j) = W_detector_color
             end do
          end if

        end subroutine print_idetectors_on


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> print the increasing detector positions on formatted
        !> output files
        !
        !> @date
        !> 27_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_interface_icr object encapsulating the position of
        !> the increasing detectors and the subroutine controlling
        !> the extension of the computational domain
        !
        !>@param index
        !> integer identifying the file
        !--------------------------------------------------------------
        subroutine print_idetectors_on_formatted_file(this, index)

          implicit none

          class(bf_interface_icr), intent(in) :: this
          integer                , intent(in) :: index

          character(len=11) :: filename_format
          character(len=20) :: filename
          integer           :: index_format
          

          if(index.le.9) then
             index_format = 1
          else
             if(index.le.99) then
                index_format = 2
             else
                index_format = 3
             end if
          end if

          write(filename_format, '(''(A11,I'',I1,'',A6)'')') index_format


          !N detectors
          print *, filename
          write(filename, filename_format)
     $         'N_detectors',
     $         index,
     $         '.curve'
          call open_formatted_file(filename,unit=1)
          call write_detectors_on_formatted_file(this%N_dct_rcoords,unit=1)
          close(unit=1)

          !S detectors
          write(filename, filename_format)
     $         'S_detectors',
     $         index,
     $         '.curve'
          call open_formatted_file(filename,unit=1)
          call write_detectors_on_formatted_file(this%S_dct_rcoords,unit=1)
          close(unit=1)

          !E detectors
          write(filename, filename_format)
     $         'E_detectors',
     $         index,
     $         '.curve'
          call open_formatted_file(filename,unit=1)
          call write_detectors_on_formatted_file(this%E_dct_rcoords,unit=1)
          close(unit=1)

          !W detectors
          write(filename, filename_format)
     $         'W_detectors',
     $         index,
     $         '.curve'
          call open_formatted_file(filename,unit=1)
          call write_detectors_on_formatted_file(this%W_dct_rcoords,unit=1)
          close(unit=1)
          
        end subroutine print_idetectors_on_formatted_file


        !open formatted output file for writing
        subroutine open_formatted_file(filename,unit)

          implicit none

          character(*)     , intent(in) :: filename
          integer, optional, intent(in) :: unit

          integer :: unit_op
          integer :: ios

          if(present(unit)) then
             unit_op = unit
          else
             unit_op = 1
          end if

          open(unit=unit_op,
     $          file=filename,
     $          action="write", 
     $          status="unknown",
     $          form='formatted',
     $          access='sequential',
     $          position='rewind',
     $          iostat=ios)

          if(ios.ne.0) then
             print '(''bf_interface_icr_class'')'
             print '(''open_formatted_file'')'
             stop 'file opening pb'
          end if

        end subroutine open_formatted_file


        !write the detector coordinates on formatted output file
        subroutine write_detectors_on_formatted_file(dct_rcoords,unit)

          implicit none

          real(rkind), dimension(:,:), intent(in) :: dct_rcoords
          integer    , optional      , intent(in) :: unit

          integer :: unit_op
          integer :: j
          integer :: ios

          if(present(unit)) then
             unit_op = unit
          else
             unit_op = 1
          end if

          if(size(dct_rcoords,1).ne.2) then
             print '(''bf_interface_icr_class.f'')'
             print '(''write_detectors'')'
             print '(''size(dct_rcoords,1).ne.2'')'
             stop 'not a detector array'
          end if

          do j=1,size(dct_rcoords,2)

             write(unit=unit_op, iostat=ios, FMT='(2F8.4)')
     $            dct_rcoords(1,j), dct_rcoords(2,j)

             if(ios.ne.0) then
                print '(''bf_interface_icr_class.f'')'
                print '(''write_detectors'')'
                stop 'error writing'
             end if

          end do

        end subroutine write_detectors_on_formatted_file


        subroutine print_netcdf(
     $     this,
     $     timestep_written,
     $     name_var,
     $     longname_var,
     $     unit_var,
     $     time)

         implicit none

         class(bf_interface_icr)    , intent(in) :: this
         integer                    , intent(in) :: timestep_written
         character(*), dimension(ne), intent(in) :: name_var
         character(*), dimension(ne), intent(in) :: longname_var
         character(*), dimension(ne), intent(in) :: unit_var
         real(rkind)                , intent(in) :: time


         call this%bf_interface%print_netcdf(
     $        timestep_written,
     $        name_var,
     $        longname_var,
     $        unit_var,
     $        time)

         if(write_detectors) then
            call print_idetectors_on_formatted_file(
     $           this,
     $           timestep_written)
         end if

        end subroutine print_netcdf


        subroutine get_dct_coords(
     $     this,
     $     N_icoords,
     $     S_icoords,
     $     E_icoords,
     $     W_icoords,
     $     N_rcoords,
     $     S_rcoords,
     $     E_rcoords,  
     $     W_rcoords)

          implicit none

          class(bf_interface_icr)                    , intent(in)  :: this
          integer(ikind), dimension(:,:), allocatable, intent(out) :: N_icoords
          integer(ikind), dimension(:,:), allocatable, intent(out) :: S_icoords
          integer(ikind), dimension(:,:), allocatable, intent(out) :: E_icoords
          integer(ikind), dimension(:,:), allocatable, intent(out) :: W_icoords
          real(rkind)   , dimension(:,:), allocatable, intent(out) :: N_rcoords
          real(rkind)   , dimension(:,:), allocatable, intent(out) :: S_rcoords
          real(rkind)   , dimension(:,:), allocatable, intent(out) :: E_rcoords
          real(rkind)   , dimension(:,:), allocatable, intent(out) :: W_rcoords


          call copy_iarray(N_icoords,this%N_dct_icoords)
          call copy_iarray(S_icoords,this%S_dct_icoords)
          call copy_iarray(E_icoords,this%E_dct_icoords)
          call copy_iarray(W_icoords,this%W_dct_icoords)

          call copy_rarray(N_rcoords,this%N_dct_rcoords)
          call copy_rarray(S_rcoords,this%S_dct_rcoords)
          call copy_rarray(E_rcoords,this%E_dct_rcoords)
          call copy_rarray(W_rcoords,this%W_dct_rcoords)

c$$$          allocate(N_icoords, source=this%N_dct_icoords)
c$$$          allocate(S_icoords, source=this%S_dct_icoords)
c$$$          allocate(E_icoords, source=this%E_dct_icoords)
c$$$          allocate(W_icoords, source=this%W_dct_icoords)
          
c$$$          allocate(N_rcoords, source=this%N_dct_rcoords)
c$$$          allocate(S_rcoords, source=this%S_dct_rcoords)
c$$$          allocate(E_rcoords, source=this%E_dct_rcoords)
c$$$          allocate(W_rcoords, source=this%W_dct_rcoords)

        end subroutine get_dct_coords


        subroutine copy_iarray(icoords,icoords_source)

          implicit none

          integer(ikind), dimension(:,:), allocatable, intent(out) :: icoords
          integer(ikind), dimension(:,:)             , intent(in)  :: icoords_source


          integer(ikind) :: i,j


          allocate(icoords(size(icoords_source,1),size(icoords_source,2)))

          do j=1, size(icoords_source,2)
             do i=1, size(icoords_source,1)
                icoords(i,j) = icoords_source(i,j)
             end do
          end do

        end subroutine copy_iarray


        subroutine copy_rarray(rcoords,rcoords_source)

          implicit none

          real(rkind), dimension(:,:), allocatable, intent(out) :: rcoords
          real(rkind), dimension(:,:)             , intent(in)  :: rcoords_source


          integer(ikind) :: i,j


          allocate(rcoords(size(rcoords_source,1),size(rcoords_source,2)))

          do j=1, size(rcoords_source,2)
             do i=1, size(rcoords_source,1)
                rcoords(i,j) = rcoords_source(i,j)
             end do
          end do

        end subroutine copy_rarray

      end module bf_interface_icr_class
