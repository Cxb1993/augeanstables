      !> @file
      !> module implementing a pointer to a bf_sublayer object
      !> to be able to create table of pointers to bf_sublayer objects
      !
      !> @author
      !> Julien L. Desmarais
      !
      !> @brief
      !> module implementing a pointer to a bf_sublayer object
      !> to be able to create table of pointers to bf_sublayer objects
      !
      !> @date
      ! 27_06_2014 - documentation update - J.L. Desmarais
      !-----------------------------------------------------------------
      module bf_sublayer_pointer_class

        use bf_sublayer_class, only : bf_sublayer

        implicit none

        private
        public :: bf_sublayer_pointer

        
        !>@class bf_layer
        !> class encapsulating a pointer to a bf_sublayer object
        !
        !>@param ptr
        !> reference to a bf_sublayer object
        !
        !>@param get_ptr
        !> get the ptr attribute
        !
        !>@param set_ptr
        !> set the ptr attribute
        !
        !>@param associated_ptr
        !> check if the ptr attribute is associated
        !--------------------------------------------------------------
        type :: bf_sublayer_pointer

          type(bf_sublayer), pointer :: ptr

          contains

          procedure, pass :: get_ptr
          procedure, pass :: set_ptr
          procedure, pass :: associated_ptr

        end type bf_sublayer_pointer


        contains


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> get the ptr attribute
        !
        !> @date
        !> 27_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_sublayer_pointer object encapsulating a reference
        !> to a bf_sublayer object
        !
        !>@return ptr
        !> ptr attribute
        !--------------------------------------------------------------
        function get_ptr(this) result(ptr)
        
          implicit none

          class(bf_sublayer_pointer), intent(in) :: this
          type(bf_sublayer), pointer             :: ptr

          if(associated(this%ptr)) then
              ptr => this%ptr
          else
             nullify(ptr)
          end if

        end function get_ptr


        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> set the ptr attribute
        !
        !> @date
        !> 27_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_sublayer_pointer object encapsulating a reference
        !> to a bf_sublayer object
        !
        !>@param ptr
        !> value for the ptr attribute
        !--------------------------------------------------------------
        subroutine set_ptr(this, ptr)
        
          implicit none

          class(bf_sublayer_pointer), intent(inout) :: this
          type(bf_sublayer), pointer, intent(in)    :: ptr

          if(associated(ptr)) then
             this%ptr => ptr
          else
             nullify(this%ptr)
          end if

        end subroutine set_ptr

      
        !> @author
        !> Julien L. Desmarais
        !
        !> @brief
        !> check if the ptr attribute is associated
        !
        !> @date
        !> 27_06_2014 - initial version - J.L. Desmarais
        !
        !>@param this
        !> bf_sublayer_pointer object encapsulating a reference
        !> to a bf_sublayer object
        !
        !>@param ptr
        !> reference to a bf_sublayer object with which the ptr
        !> attribute is compared for the association check
        !--------------------------------------------------------------
        function associated_ptr(this, ptr)
        
          implicit none

          class(bf_sublayer_pointer)          , intent(in) :: this
          type(bf_sublayer), pointer, optional, intent(in) :: ptr
          logical                                          :: associated_ptr

          
          if(present(ptr)) then
             associated_ptr = associated(this%ptr, ptr)
          else
             associated_ptr = associated(this%ptr)
          end if        

        end function associated_ptr

      end module bf_sublayer_pointer_class
