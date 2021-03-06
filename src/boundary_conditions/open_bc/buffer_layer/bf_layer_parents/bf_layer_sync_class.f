      !> @file
      !> module encapsulating the bf_layer_sync object.
      !> bf_layer_print enhanced with synchronization procedures
      !
      !> @author
      !> Julien L. Desmarais
      !
      !> @brief
      !> bf_layer_print enhanced with synchronization procedures
      !
      !> @date
      ! 23_02_2015 - initial version - J.L. Desmarais
      !-----------------------------------------------------------------
      module bf_layer_sync_class

        use bf_layer_print_class, only :
     $       bf_layer_print

        use bf_layer_errors_module, only :
     $       error_mainlayer_id

        use bf_layer_exchange_module, only :
     $       do_grdpts_overlap_along_x_dir,
     $       get_match_indices_for_exchange_with_neighbor1,
     $       get_match_indices_for_exchange_with_neighbor2,
     $       copy_from_bf1_to_bf2,
     $       get_sync_indices_with_interior,
     $       sync_nodes,
     $       get_sync_indices_with_neighbor1,
     $       get_sync_indices_with_neighbor2

        use parameters_bf_layer, only :
     $       align_E,
     $       align_N,
     $       align_S,
     $       align_W,
     $       bf_neighbors,
     $       bf_neighbors_id,
     $       BF_SUCCESS,
     $       bc_interior_pt,
     $       bc_pt

        use parameters_constant, only :
     $       N,S,E,W,
     $       left,right

        use parameters_input, only :
     $       nx,ny,ne,
     $       bc_size

        use parameters_kind, only :
     $       ikind,
     $       rkind
        
        
        !> @class bf_layer_sync
        !> class encapsulating the synchronization procedures
        !> for the buffer layer object
        !
        !> @param shares_grdpts_with_neighbor1
        !> logical identifying whether the buffer layer can exchange
        !> grid points with its neighboring buffer layer of type 1
        !
        !> @param shares_grdpts_with_neighbor2
        !> logical identifying whether the buffer layer can exchange
        !> grid points with its neighboring buffer layer of type 2
        !
        !> @param set_neighbor1_share
        !> set whether the buffer layer is sharing grid points
        !> with its neighbor2
        !
        !> @param set_neighbor2_share
        !> set whether the buffer layer is sharing grid points
        !> with its neighbor2
        !
        !> @param can_exchange_with_neighbor1
        !> get the share_grdpts_with_neighbor1 attribute
        !
        !> @param can_exchange_with_neighbor2
        !> get the share_grdpts_with_neighbor2 attribute
        !
        !> @param get_neighbor1_id
        !> get the cardinal coordinate coresponding to the neighboring
        !> buffer layers of type 1
        !
        !> @param get_neighbor2_id
        !> get the cardinal coordinate coresponding to the neighboring
        !> buffer layers of type 2
        !
        !> @param shares_grdpts_along_x_dir_with
        !> check if a neighboring buffer layer (positioned such that
        !> it is either a potential neighboring buffer layer of type
        !> 1 or 2) has indeed grid points in common with another buffer
        !> layer by computing the x-size of the layer to be exchanged
        !
        !> @param copy_from_neighbor1
        !> copy the common layer to the current buffer layer
        !> from its neighboring buffer layer identified as of type 1
        !
        !> @param copy_from_neighbor2
        !> copy the common layer to the current buffer layer
        !> from its neighboring buffer layer identified as of type 2
        !
        !> @param copy_to_neighbor1
        !> copy the common layer from the current buffer layer
        !> to its neighboring buffer layer identified as of type 1
        !
        !> @param copy_to_neighbor2
        !> copy the common layer from the current buffer layer
        !> to its neighboring buffer layer identified as of type 2
        !
        !> @param copy_grdpts_id_to_temp
        !> create a truncated copy of the the grdpts_id. The copy is
        !> a 3x3 array whose center (2,2) is identified by its general
        !> coordinates cpt_coords
        !
        !> @param sync_nodes_with_interior
        !> synchronize the nodes at the interface with the interior
        !
        !> @param sync_nodes_with_neighbor1
        !> synchronize the nodes at the interface with the neighbor1
        !
        !> @param sync_nodes_with_neighbor2
        !> synchronize the nodes at the interface with the neighbor2
        !
        !> @param get_bc_overlap_x_border
        !> determine the grid-point where the first non-bc_interior_pt
        !> is obtained to set the correct overlap between buffer layers
        !> at the edge between two main layers
        !-------------------------------------------------------------
        type, extends(bf_layer_print) :: bf_layer_sync

          logical, private :: shares_grdpts_with_neighbor1
          logical, private :: shares_grdpts_with_neighbor2

          contains

          procedure,   pass :: set_neighbor1_share
          procedure,   pass :: set_neighbor2_share
          procedure,   pass :: can_exchange_with_neighbor1
          procedure,   pass :: can_exchange_with_neighbor2
          procedure,   pass :: get_neighbor1_id
          procedure,   pass :: get_neighbor2_id
          procedure,   pass :: shares_grdpts_along_x_dir_with

          procedure,   pass :: copy_from_neighbor1
          procedure,   pass :: copy_from_neighbor2
          procedure,   pass :: copy_to_neighbor1
          procedure,   pass :: copy_to_neighbor2

          procedure,   pass :: sync_nodes_with_interior
          procedure,   pass :: sync_nodes_with_neighbor1
          procedure,   pass :: sync_nodes_with_neighbor2

        end type bf_layer_sync

        contains


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> set the shares_grdpts_with_neighbor1 attribute
        !> or let the program compute whether the buffer layer
        !> may be exchanging grid points with the neighboring
        !> buffer layers of type 1
        !
        !> @date
        !> 26_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_layer object encapsulating the main
        !> tables extending the interior domain
        !
        !>@param neighbor1_share
        !> value set for the shares_grdpts_with_neighbor1 attribute
        !--------------------------------------------------------------
        subroutine set_neighbor1_share(this, neighbor1_share)
          
          implicit none
          
          class(bf_layer_sync)          , intent(inout) :: this
          logical             , optional, intent(in)    :: neighbor1_share

          if(present(neighbor1_share)) then
             this%shares_grdpts_with_neighbor1 = neighbor1_share
          else
             select case(this%localization)
               case(N,S)
                  this%shares_grdpts_with_neighbor1 = (this%alignment(1,1)-bc_size).le.(align_W+bc_size)
               case(E,W)
                  this%shares_grdpts_with_neighbor1 = (this%alignment(2,1)-bc_size).le.(align_S+bc_size)
               case default
                  call error_mainlayer_id(
     $                 'nbf_interface_class.f',
     $                 'share_grdpts_with_neighbor1',
     $                 this%localization)
             end select
          end if

        end subroutine set_neighbor1_share


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> set the shares_grdpts_with_neighbor2 attribute
        !> or let the program compute whether the buffer layer
        !> may be exchanging grid points with the neighboring
        !> buffer layers of type 2
        !
        !> @date
        !> 26_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_layer object encapsulating the main
        !> tables extending the interior domain
        !
        !>@param neighbor2_share
        !> value set for the shares_grdpts_with_neighbor1 attribute
        !--------------------------------------------------------------
        subroutine set_neighbor2_share(this, neighbor2_share)
          
          implicit none
          
          class(bf_layer_sync)          , intent(inout) :: this
          logical             , optional, intent(in)    :: neighbor2_share

          if(present(neighbor2_share)) then
             this%shares_grdpts_with_neighbor2 = neighbor2_share
          else
             select case(this%localization)
               case(N,S)
                  this%shares_grdpts_with_neighbor2 = (this%alignment(1,2)+bc_size).ge.(align_E-bc_size)
               case(E,W)
                  this%shares_grdpts_with_neighbor2 = (this%alignment(2,2)+bc_size).ge.(align_N-bc_size)
               case default
                  call error_mainlayer_id(
     $                 'nbf_interface_class.f',
     $                 'share_grdpts_with_neighbor2',
     $                 this%localization)
             end select
          end if

        end subroutine set_neighbor2_share


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> get the share_grdpts_with_neighbor1 attribute
        !
        !> @date
        !> 26_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_layer object encapsulating the main
        !> tables extending the interior domain
        !
        !>@param can_exchange
        !> share_grdpts_with_neighbor1 attribute
        !--------------------------------------------------------------
        function can_exchange_with_neighbor1(this) result(can_exchange)

          implicit none

          class(bf_layer_sync), intent(in) :: this
          logical                          :: can_exchange

          can_exchange = this%shares_grdpts_with_neighbor1

        end function can_exchange_with_neighbor1


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> get the share_grdpts_with_neighbor1 attribute
        !
        !> @date
        !> 26_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_layer object encapsulating the main
        !> tables extending the interior domain
        !
        !>@param can_exchange
        !> share_grdpts_with_neighbor1 attribute
        !--------------------------------------------------------------
        function can_exchange_with_neighbor2(this) result(can_exchange)

          implicit none

          class(bf_layer_sync), intent(in) :: this
          logical                          :: can_exchange

          can_exchange = this%shares_grdpts_with_neighbor2

        end function can_exchange_with_neighbor2


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> get the cardinal coordinate coresponding to the neighboring
        !> buffer layers of type 1
        !
        !> @date
        !> 26_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_layer object encapsulating the main
        !> tables extending the interior domain
        !
        !>@param neighbor1_id
        !> cardinal coordinate corresponding to neighboring buffer layers
        !> of type 1
        !
        !>@param neighbor_index
        !> index identifying if the original buffer layer is a neighbor
        !> of type 1 or 2 for the neighboring buffer layer
        !--------------------------------------------------------------
        subroutine get_neighbor1_id(this, neighbor1_id, neighbor_index)

          implicit none

          class(bf_layer_sync)          , intent(in) :: this
          integer                       , intent(out):: neighbor1_id
          integer             , optional, intent(out):: neighbor_index


          neighbor1_id    = bf_neighbors(this%localization,1)
          if(present(neighbor_index)) then
             neighbor_index  = bf_neighbors_id(this%localization)
          end if

        end subroutine get_neighbor1_id


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> get the cardinal coordinate coresponding to the neighboring
        !> buffer layers of type 2
        !
        !> @date
        !> 26_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_layer object encapsulating the main
        !> tables extending the interior domain
        !
        !>@param neighbor2_id
        !> cardinal coordinate corresponding to neighboring buffer layers
        !> of type 2
        !
        !>@param neighbor_index
        !> index identifying if the original buffer layer is a neighbor
        !> of type 1 or 2 for the neighboring buffer layer
        !--------------------------------------------------------------
        subroutine get_neighbor2_id(this, neighbor2_id, neighbor_index)

          implicit none

          class(bf_layer_sync)          , intent(in) :: this
          integer                       , intent(out):: neighbor2_id
          integer             , optional, intent(out):: neighbor_index

          neighbor2_id    = bf_neighbors(this%localization,2)

          if(present(neighbor_index)) then
             neighbor_index  = bf_neighbors_id(this%localization)
          end if

        end subroutine get_neighbor2_id


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> check if a neighboring buffer layer
        !> (positioned such that it is either a potential
        !> neighboring buffer layer of type 1 or 2)
        !> has indeed grid points in common with another
        !> buffer layer by computing the x-size of the
        !> layer to be exchanged
        !
        !> @date
        !> 26_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_layer object encapsulating the main
        !> tables extending the interior domain
        !
        !>@param neighbor
        !> second bf_layer object encapsulating the main
        !> tables extending the interior domain
        !
        !>@return share
        !> logical identifying if there are grid points in common
        !> along the x-direction
        !--------------------------------------------------------------
        function shares_grdpts_along_x_dir_with(this, neighbor)
     $     result(share)

          implicit none

          class(bf_layer_sync), intent(in) :: this
          class(bf_layer_sync), intent(in) :: neighbor
          logical                          :: share

          share = do_grdpts_overlap_along_x_dir(
     $         this%alignment, neighbor%alignment)
          
        end function shares_grdpts_along_x_dir_with


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> copy the common layer to the current buffer layer
        !> from its neighboring buffer layer identified as of type 1
        !
        !> @date
        !> 26_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_layer object encapsulating the main
        !> tables extending the interior domain
        !
        !>@param neighbor1
        !> second bf_layer object encapsulating the main
        !> tables extending the interior domain
        !--------------------------------------------------------------
        subroutine copy_from_neighbor1(this,neighbor1)

          implicit none

          class(bf_layer_sync), intent(inout) :: this
          class(bf_layer_sync), intent(in)    :: neighbor1

          integer(ikind) :: bf_i_min, bf_j_min
          integer(ikind) :: nbf_i_min, nbf_j_min
          integer(ikind) :: bf_copy_size_x, bf_copy_size_y
          
          !get the indices for the match between the tables
          !of the current buffer layer and the neighbor1
          call get_match_indices_for_exchange_with_neighbor1(
     $         this%alignment,
     $         neighbor1%alignment,
     $         bf_i_min, bf_j_min,
     $         nbf_i_min, nbf_j_min,
     $         bf_copy_size_x, bf_copy_size_y)
          
          !copy from neighbor1 to the current buffer layer
          call copy_from_bf1_to_bf2(
     $         nbf_i_min, nbf_j_min, bf_i_min, bf_j_min,
     $         bf_copy_size_x, bf_copy_size_y,
     $         neighbor1%nodes, neighbor1%grdpts_id,
     $         this%nodes, this%grdpts_id)

        end subroutine copy_from_neighbor1


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> copy the common layer from the current buffer layer
        !> to its neighboring buffer layer identified as of type 1
        !
        !> @date
        !> 26_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_layer object encapsulating the main
        !> tables extending the interior domain
        !
        !>@param neighbor1
        !> second bf_layer object encapsulating the main
        !> tables extending the interior domain
        !--------------------------------------------------------------
        subroutine copy_to_neighbor1(this, neighbor1)

          implicit none

          class(bf_layer_sync), intent(in)    :: this
          class(bf_layer_sync), intent(inout) :: neighbor1

          integer(ikind) :: bf_i_min, bf_j_min
          integer(ikind) :: nbf_i_min, nbf_j_min
          integer(ikind) :: bf_copy_size_x, bf_copy_size_y
          
          !get the indices for the match between the tables
          !of the current buffer layer and the neighbor1
          call get_match_indices_for_exchange_with_neighbor1(
     $         this%alignment,
     $         neighbor1%alignment,
     $         bf_i_min, bf_j_min,
     $         nbf_i_min, nbf_j_min,
     $         bf_copy_size_x, bf_copy_size_y)
          
          !copy from the current buffer layer to neighbor1
          call copy_from_bf1_to_bf2(
     $         bf_i_min, bf_j_min, nbf_i_min, nbf_j_min,
     $         bf_copy_size_x, bf_copy_size_y,
     $         this%nodes, this%grdpts_id,
     $         neighbor1%nodes, neighbor1%grdpts_id)

        end subroutine copy_to_neighbor1


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> copy the common layer to the current buffer layer
        !> from its neighboring buffer layer identified as of type 2
        !
        !> @date
        !> 26_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_layer object encapsulating the main
        !> tables extending the interior domain
        !
        !>@param neighbor2
        !> second bf_layer object encapsulating the main
        !> tables extending the interior domain
        !--------------------------------------------------------------
        subroutine copy_from_neighbor2(this, neighbor2)

          implicit none

          class(bf_layer_sync), intent(inout) :: this
          class(bf_layer_sync), intent(in)    :: neighbor2

          integer(ikind) :: bf_i_min, bf_j_min
          integer(ikind) :: nbf_i_min, nbf_j_min
          integer(ikind) :: bf_copy_size_x, bf_copy_size_y
          
          !get the indices for the match between the tables
          !of the current buffer layer and the neighbor1
          call get_match_indices_for_exchange_with_neighbor2(
     $         this%alignment,
     $         neighbor2%alignment,
     $         bf_i_min, bf_j_min,
     $         nbf_i_min, nbf_j_min,
     $         bf_copy_size_x, bf_copy_size_y)
          
          !copy from neighbor1 to the current buffer layer
          call copy_from_bf1_to_bf2(
     $         nbf_i_min, nbf_j_min, bf_i_min, bf_j_min,
     $         bf_copy_size_x, bf_copy_size_y,
     $         neighbor2%nodes, neighbor2%grdpts_id,
     $         this%nodes, this%grdpts_id)

        end subroutine copy_from_neighbor2


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> copy the common layer from the current buffer layer
        !> to its neighboring buffer layer identified as of type 2
        !
        !> @date
        !> 26_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_layer object encapsulating the main
        !> tables extending the interior domain
        !
        !>@param neighbor2
        !> second bf_layer object encapsulating the main
        !> tables extending the interior domain
        !--------------------------------------------------------------
        subroutine copy_to_neighbor2(this, neighbor2)

          implicit none

          class(bf_layer_sync), intent(in)    :: this
          class(bf_layer_sync), intent(inout) :: neighbor2

          integer(ikind) :: bf_i_min, bf_j_min
          integer(ikind) :: nbf_i_min, nbf_j_min
          integer(ikind) :: bf_copy_size_x, bf_copy_size_y
          
          !get the indices for the match between the tables
          !of the current buffer layer and the neighbor1
          call get_match_indices_for_exchange_with_neighbor2(
     $         this%alignment,
     $         neighbor2%alignment,
     $         bf_i_min, bf_j_min,
     $         nbf_i_min, nbf_j_min,
     $         bf_copy_size_x, bf_copy_size_y)
          
          !copy from the current buffer layer to neighbor1
          call copy_from_bf1_to_bf2(
     $         bf_i_min, bf_j_min, nbf_i_min, nbf_j_min,
     $         bf_copy_size_x, bf_copy_size_y,
     $         this%nodes, this%grdpts_id,
     $         neighbor2%nodes, neighbor2%grdpts_id)          

        end subroutine copy_to_neighbor2


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> update the common layers between the buffer
        !> layer and the interior domain
        !
        !> @date
        !> 29_10_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_layer object encapsulating the main
        !> tables extending the interior domain
        !
        !>@param interior_nodes
        !> grid points for the interior domain
        !--------------------------------------------------------------
        subroutine sync_nodes_with_interior(this, interior_nodes)

          implicit none

          class(bf_layer_sync)            , intent(inout) :: this
          real(rkind), dimension(nx,ny,ne), intent(inout) :: interior_nodes

          integer(ikind), dimension(2) :: in_send
          integer(ikind), dimension(2) :: in_recv
          integer(ikind), dimension(2) :: bf_send
          integer(ikind), dimension(2) :: bf_recv
          integer(ikind), dimension(2) :: ex_size

          !get the indices identifying which arrays are exchanged
          call get_sync_indices_with_interior(
     $         this%localization,
     $         this%alignment,
     $         [size(this%nodes,1),size(this%nodes,2)],
     $         in_send,
     $         in_recv,
     $         bf_send,
     $         bf_recv,
     $         ex_size)

          !exchange the arrays between the buffer layer
          !and the interior domain
          call sync_nodes(
     $         interior_nodes,
     $         in_send,
     $         in_recv,
     $         this%nodes,
     $         bf_send,
     $         bf_recv,
     $         ex_size)

        end subroutine sync_nodes_with_interior


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> update the common layers between the buffer
        !> layer and another buffer layer which must be
        !> of type neighbor1 for the first buffer layer
        !
        !> @date
        !> 30_10_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_layer object encapsulating the main
        !> tables extending the interior domain
        !
        !>@param neighbor1
        !> buffer layer which is of neighbor1 type
        !--------------------------------------------------------------
        subroutine sync_nodes_with_neighbor1(this, neighbor1)

          implicit none

          class(bf_layer_sync), intent(inout) :: this
          class(bf_layer_sync), intent(inout) :: neighbor1

          integer(ikind), dimension(2) :: bf_send
          integer(ikind), dimension(2) :: bf_recv
          integer(ikind), dimension(2) :: nbf_send
          integer(ikind), dimension(2) :: nbf_recv
          integer(ikind), dimension(2) :: ex_size

          !get the indices identifying which arrays are exchanged
          call get_sync_indices_with_neighbor1(
     $         this%localization,
     $         this%alignment,
     $         [size(this%nodes,1),size(this%nodes,2)],
     $         bf_send,
     $         bf_recv,
     $         neighbor1%alignment,
     $         [size(neighbor1%nodes,1),size(neighbor1%nodes,2)],
     $         nbf_send,
     $         nbf_recv,
     $         ex_size)

          !exchange the arrays between the buffer layer
          !and the interior domain
          call sync_nodes(
     $         this%nodes,
     $         bf_send,
     $         bf_recv,
     $         neighbor1%nodes,
     $         nbf_send,
     $         nbf_recv,
     $         ex_size)

        end subroutine sync_nodes_with_neighbor1


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> update the common layers between the buffer
        !> layer and another buffer layer which must be
        !> of type neighbor2 for the first buffer layer
        !
        !> @date
        !> 30_10_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_layer object encapsulating the main
        !> tables extending the interior domain
        !
        !>@param neighbor1
        !> buffer layer which is of neighbor1 type
        !--------------------------------------------------------------
        subroutine sync_nodes_with_neighbor2(this, neighbor2)

          implicit none

          class(bf_layer_sync), intent(inout) :: this
          class(bf_layer_sync), intent(inout) :: neighbor2

          integer(ikind), dimension(2) :: bf_send
          integer(ikind), dimension(2) :: bf_recv
          integer(ikind), dimension(2) :: nbf_send
          integer(ikind), dimension(2) :: nbf_recv
          integer(ikind), dimension(2) :: ex_size

          !get the indices identifying which arrays are exchanged
          call get_sync_indices_with_neighbor2(
     $         this%localization,
     $         this%alignment,
     $         [size(this%nodes,1),size(this%nodes,2)],
     $         bf_send,
     $         bf_recv,
     $         neighbor2%alignment,
     $         [size(neighbor2%nodes,1),size(neighbor2%nodes,2)],
     $         nbf_send,
     $         nbf_recv,
     $         ex_size)

          !exchange the arrays between the buffer layer
          !and the interior domain
          call sync_nodes(
     $         this%nodes,
     $         bf_send,
     $         bf_recv,
     $         neighbor2%nodes,
     $         nbf_send,
     $         nbf_recv,
     $         ex_size)

        end subroutine sync_nodes_with_neighbor2

      end module bf_layer_sync_class
