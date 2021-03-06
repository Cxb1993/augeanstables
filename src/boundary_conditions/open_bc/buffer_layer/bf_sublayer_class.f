      !> @file
      !> module implementing the bf_sublayer object. It is
      !> a bf_layer object which is part of a double chained
      !> list
      !
      !> @author
      !> Julien L. Desmarais
      !
      !> @brief
      !> module implementing the bf_sublayer object. It is
      !> a bf_layer object which is part of a double chained
      !> list
      !
      !> @date
      ! 11_04_2014 - initial version      - J.L. Desmarais
      ! 26_06_2014 - documentation update - J.L. Desmarais
      !-----------------------------------------------------------------
      module bf_sublayer_class

        use bf_layer_class, only :
     $       bf_layer

        use parameters_kind, only :
     $       ikind

        implicit none

        private
        public :: bf_sublayer


        !> @class bf_sublayer
        !> class implementing the bf_layer object as an element
        !> of a doubled chained list
        !
        !> @param next
        !> pointer of the next element of the double chained list
        !
        !> @param prev
        !> pointer of the previous element of the double chained list
        !
        !> @param ini
        !> initialize the bf_layer parent and nullify the pointers
        !> to the prev and next elements of the doubled chained list
        !
        !>@param get_prev
        !> access the previous element of the list
        !
        !>@param get_next
        !> access the next element of the list
        !
        !>@param set_prev
        !> set the link to the previous element of the list
        !
        !>@param set_next
        !> set the link to the next element of the list
        !
        !>@param nullify_prev
        !> remove the link to the previous element of the list
        !
        !>@param nullify_next
        !> remove the link to the next element of the list
        !
        !>@param remove
        !> remove the element of the list by removing the bf_layer
        !> parent object and the links to the previous and next
        !> elements in the list
        !---------------------------------------------------------------
        type, extends(bf_layer) :: bf_sublayer

          type(bf_sublayer), pointer, private :: next
          type(bf_sublayer), pointer, private :: prev

          contains

          procedure, pass   :: ini

          procedure, pass   :: get_prev
          procedure, pass   :: get_next
          procedure, pass   :: set_prev
          procedure, pass   :: set_next
          procedure, pass   :: nullify_prev
          procedure, pass   :: nullify_next

          procedure, pass   :: remove

        end type bf_sublayer

        contains

        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> initialize the bf_layer parent and nullify the pointers
        !> to the prev and next elements of the doubled chained list
        !
        !> @date
        !> 26_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_sublayer object encapsulating the bf_layer and
        !> its neighbors in the doubled chained list
        !
        !>@param localization
        !> localization of the buffer layer (N,S,E, or W)
        !--------------------------------------------------------------
        subroutine ini(this, localization)

          implicit none

          class(bf_sublayer), intent(inout) :: this
          integer(ikind)    , intent(in)    :: localization

          call this%bf_layer%ini(localization)

          nullify(this%prev)
          nullify(this%next)

        end subroutine ini


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> access the previous element of the list
        !
        !> @date
        !> 26_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_sublayer object encapsulating the bf_layer and
        !> its neighbors in the doubled chained list
        !
        !>@return get_prev
        !> pointer to the previous element of the list
        !--------------------------------------------------------------
        function get_prev(this)

          implicit none

          class(bf_sublayer), intent(in) :: this
          type(bf_sublayer) , pointer    :: get_prev

          if(associated(this%prev)) then
             get_prev => this%prev
          else
             nullify(get_prev)
          end if

        end function get_prev


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> access the next element of the list
        !
        !> @date
        !> 26_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_sublayer object encapsulating the bf_layer and
        !> its neighbors in the doubled chained list
        !
        !>@return get_next
        !> pointer to the next element of the list
        !--------------------------------------------------------------
        function get_next(this)

          implicit none

          class(bf_sublayer), intent(in) :: this
          type(bf_sublayer) , pointer    :: get_next

          if(associated(this%next)) then
             get_next => this%next
          else
             nullify(get_next)
          end if

        end function get_next


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> set the link to the previous element of the list
        !
        !> @date
        !> 26_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_sublayer object encapsulating the bf_layer and
        !> its neighbors in the doubled chained list
        !
        !>@param bf_sublayer_prev
        !> pointer to the previous element of the list
        !--------------------------------------------------------------
        subroutine set_prev(this, bf_sublayer_prev)

          implicit none

          class(bf_sublayer)         , intent(inout) :: this
          type(bf_sublayer) , pointer, intent(in)    :: bf_sublayer_prev

          this%prev => bf_sublayer_prev

        end subroutine set_prev


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> set the link to the next element of the list
        !
        !> @date
        !> 26_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_sublayer object encapsulating the bf_layer and
        !> its neighbors in the doubled chained list
        !
        !>@param bf_sublayer_prev
        !> pointer to the next element of the list
        !--------------------------------------------------------------
        subroutine set_next(this, bf_sublayer_next)

          implicit none

          class(bf_sublayer)         , intent(inout) :: this
          type(bf_sublayer) , pointer, intent(in)    :: bf_sublayer_next

          this%next => bf_sublayer_next

        end subroutine set_next


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> remove the link to the previous element of the list
        !
        !> @date
        !> 26_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_sublayer object encapsulating the bf_layer and
        !> its neighbors in the doubled chained list
        !--------------------------------------------------------------
        subroutine nullify_prev(this)

          implicit none

          class(bf_sublayer), intent(inout) :: this

          nullify(this%prev)

        end subroutine nullify_prev


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> remove the link to the next element of the list
        !
        !> @date
        !> 26_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_sublayer object encapsulating the bf_layer and
        !> its neighbors in the doubled chained list
        !--------------------------------------------------------------
        subroutine nullify_next(this)

          implicit none

          class(bf_sublayer), intent(inout) :: this

          nullify(this%next)

        end subroutine nullify_next


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> remove the element of the list by removing the bf_layer
        !> parent object and the links to the previous and next
        !> elements in the list
        !
        !> @date
        !> 26_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_sublayer object encapsulating the bf_layer and
        !> its neighbors in the doubled chained list
        !--------------------------------------------------------------
        subroutine remove(this)

          implicit none

          class(bf_sublayer), intent(inout) :: this


          !remove bf_layer
          call this%bf_layer%remove()

          !nullify the links
          if(associated(this%prev)) then
             if(associated(this%next)) then
                this%prev%next => this%next
                this%next%prev => this%prev
             else
                nullify(this%prev%next)
             end if
          else
             if(associated(this%next)) then
                nullify(this%next%prev)
             end if
          end if

        end subroutine remove        

      end module bf_sublayer_class
