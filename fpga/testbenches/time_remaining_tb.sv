module time_remaining_tb ();

//inputs
logic clock;
logic timer_go;
logic restart;
//outputs
logic [7:0] time_left;

time_remaining uut (.clock(clock), .timer_go(timer_go), .restart(restart), .time_left(time_left));

always #5 clock = !clock;
   
    initial begin
    restart = 0;
    clock = 0;
    timer_go = 0;
    #10
    restart = 1;
    #10
    restart = 0;
    #10
    
    timer_go =1;
    #500
    timer_go = 0;
    #50
    timer_go = 1;
    
    end

endmodule