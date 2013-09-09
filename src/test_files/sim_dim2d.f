      !> @file
      !> program for the simulation of the Diffuse Interface
      !> Model in 2D
      !
      !> @author 
      !> Julien L. Desmarais
      !
      !> @brief
      !> run the simulation using the Diffuse Interface Model,
      !> the cg_operators for the spatial discretization,
      !> and finite volume and the Runge-Kutta 3rd order TVD
      !> as time integration methods
      !
      !> @date
      ! 19_08_2013 - initial version - J.L. Desmarais
      !-----------------------------------------------------------------
      program sim_dim2d

        use bc_operators_class     , only : bc_operators
        use cg_operators_class     , only : cg_operators
        use dim2d_eq_class         , only : dim2d_eq
        use field_class            , only : field
        use fv_operators_class     , only : fv_operators
        use nf90_operators_wr_class, only : nf90_operators_wr
        use parameters_input       , only : nx,ny,ne
        use parameters_kind        , only : ikind, rkind
        use rk3tvd_class           , only : rk3tvd

        implicit none


        !<inputs for the simulation
        real(rkind) :: x_min, x_max, dx
        real(rkind) :: y_min, y_max, dy
        real(rkind) :: t_max, dt
        real(rkind) :: detail_print

        !<operators needed for the simulation
        type(field)             :: f_simulated !< field simulated
        type(cg_operators)      :: s           !< spatial discretisation
        type(dim2d_eq)          :: p_model     !< physical model
        type(fv_operators)      :: td          !< time discretisation
        type(bc_operators)      :: bc_used     !< boundary conditions
        type(rk3tvd)            :: ti          !< time integration
        type(nf90_operators_wr) :: io_writer   !< output management

        !<intermediate variables for the simulation
        integer(ikind) :: nt, output_print
        integer        :: bc_size
        integer(ikind) :: i,j,t
        real(rkind)    :: time
        !integer, parameter :: output_print=1

        !<CPU recorded times
        real :: time1, time2, time3


        !<get the initial CPU time
        call CPU_TIME(time1)

        if(ne.ne.p_model%get_eq_nb()) then
           stop 'ne is not correct considering the physical model'
        end if


        !<read the inputs
        x_min = -0.4000000000d0
        x_max = 0.4000000000d0

        y_min = -0.4000000000d0
        y_max = 0.4000000000d0

        t_max = 0.0002100000d0
        dt = 0.0000007000d0
        detail_print = 0.0000000000d0


        !<allocate the field
        bc_size      = s%get_bc_size()
        nt           = int(t_max/dt)
        output_print = int(1.0d0/detail_print)


        !<initialize the field
        time = 0
        call f_simulated%ini_coordinates(x_min,x_max,y_min,y_max,bc_size)
        call p_model%apply_ic(f_simulated)
        call bc_used%apply_bc_on_nodes(f_simulated,p_model,s)


        !<write the initial state in an output file
        call io_writer%initialize()
        call io_writer%write_data(f_simulated,p_model,bc_size,time)

        !<initialization time
        call CPU_TIME(time2)
        print *, 'time_elapsed: ', time2-time1

        !<integrate the field until t=t_max
        do t=1, nt
           time=(t-1)*dt

           !DEC$ FORCEINLINE RECURSIVE
           call ti%integrate(f_simulated,s,p_model,td,dt)

c$$$           if((output_print.eq.1).or.((output_print.ne.0).and.(mod(t,output_print).eq.0))) then
c$$$              call io_writer%write_data(f_simulated,p_model,bc_size,time)
c$$$           end if

        end do


        !<write the last timestep
c$$$        if(mod(nt,output_print).ne.0) then
c$$$           call io_writer%write_data(f_simulated,p_model,bc_size,time)
c$$$        end if


        !<print the time needed for the simulation
        call CPU_TIME(time3)
        print *, 'time_elapsed: ', time3-time1

      end program sim_dim2d
