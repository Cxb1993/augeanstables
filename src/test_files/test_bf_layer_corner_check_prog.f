      program test_bf_layer_corner_check_prog

        use bf_layer_corner_check_module, only : check_corner_bf_layer_neighbors
        use bf_layer_path_class         , only : bf_layer_path

        use interface_abstract_class    , only : interface_abstract

        use parameters_constant         , only : N_E,N_W,S_E,S_W
        use parameters_input            , only : nx,ny,ne
        use parameters_kind             , only : rkind

        use test_bf_layer_module        , only : print_nodes,
     $                                           print_sizes,
     $                                           ini_nodes
        use test_cases_interface_module , only : ini_interface
        use test_cases_path_module      , only : ini_path
        use interface_print_module      , only : print_interface

        implicit none


        integer, parameter               :: corner_tested = 4
        integer, parameter               :: corner_order = 2
        integer, parameter               :: test_case_id = 1
        integer, parameter               :: bf_corner_distance = 6
        integer, parameter               :: over_allocated = 3
        integer, parameter               :: current_path_use = 0

        integer, dimension(4)            :: corner_table
        integer                          :: corner_id

        real(rkind), dimension(nx,ny,ne) :: nodes
        type(interface_abstract)         :: interface_used
        type(bf_layer_path)              :: current_path

        integer, parameter :: interface_before=0
        integer, parameter :: interface_after=1

        !choose the corner tested
        corner_table       = [N_E,N_W,S_E,S_W]
        corner_id          = corner_table(corner_tested)

        !initialize the nodes for the test
        call ini_nodes(nodes)
        call print_sizes(nodes,'interior_sizes.dat')
        call print_nodes(nodes,'interior_nodes.dat')

        !initialize the interface
        call ini_interface(
     $       interface_used,
     $       test_case_id,
     $       nodes,
     $       corner_id,
     $       corner_order,
     $       bf_corner_distance,
     $       over_allocated)

        !initialize the current path
        call ini_path(
     $       current_path,
     $       corner_id,
     $       corner_order,
     $       bf_corner_distance)        

        !print interface before
        call print_interface(interface_used, interface_before)

        !check corner
        if(current_path_use.eq.0) then
           call check_corner_bf_layer_neighbors(
     $          corner_id,
     $          nodes,
     $          interface_used)

        else
           call check_corner_bf_layer_neighbors(
     $          corner_id,
     $          nodes,
     $          interface_used,
     $          current_path)

        end if

        !print interface after
        call print_interface(interface_used, interface_after)

      end program test_bf_layer_corner_check_prog
