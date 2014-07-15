      !> @file
      !> module implementing the temporary object used to reorganize
      !> the increasing detector list when a west buffer layer is
      !> removed
      !
      !> @author
      !> Julien L. Desmarais
      !
      !> @brief
      !> module implementing the temporary object used to reorganize
      !> the increasing detector list when a west buffer layer is
      !> removed
      !
      !> @date
      ! 27_06_2014 - documentation update - J.L. Desmarais
      !----------------------------------------------------------------
      module bf_detector_dcr_list_W_class

        use bf_detector_dcr_list_EW_class, only : bf_detector_dcr_list_EW
        use parameters_bf_layer          , only : align_N, align_S,
     $                                            dct_icr_W_default
        use parameters_input             , only : bc_size
        use parameters_kind              , only : ikind

        implicit none


        !> @class bf_detector_dcr_list_W
        !> class encapsulating the temporary variables needed
        !> to create a new detector list out of the previous
        !> detector list when a west buffer layer is removed
        !----------------------------------------------------------------
        type, extends(bf_detector_dcr_list_EW) :: bf_detector_dcr_list_W

          contains

          procedure, nopass :: should_be_removed
          procedure, nopass :: get_border_detector

        end type bf_detector_dcr_list_W


        contains


        function should_be_removed(bf_align, g_coords) result(remove)
          
          implicit none

          integer(ikind), dimension(2,2), intent(in) :: bf_align
          integer(ikind), dimension(2)  , intent(in) :: g_coords
          logical                                    :: remove
          
          logical :: lower_border_condition
          logical :: upper_border_condition

          
          if(bf_align(2,1).eq.(align_S+1)) then
             lower_border_condition = .true.
          else
             lower_border_condition = g_coords(2).ge.(bf_align(2,1)-bc_size)
          end if

          if(bf_align(2,2).eq.(align_N-1)) then
             upper_border_condition = .true.
          else
             upper_border_condition = g_coords(2).le.(bf_align(2,2)+bc_size)
          end if

          remove = lower_border_condition.and.upper_border_condition
          remove = remove.and.(g_coords(1).lt.dct_icr_W_default)

        end function should_be_removed


        function get_border_detector(g_coords) result(dct_g_coords)

          implicit none

          integer(ikind), dimension(2), intent(in) :: g_coords
          integer(ikind), dimension(2)             :: dct_g_coords

          dct_g_coords(1) = dct_icr_W_default
          dct_g_coords(2) = g_coords(2)

        end function get_border_detector

      end module bf_detector_dcr_list_W_class