module time_remaining_tb ();

//inputs
logic vsync;
logic timer_go;
logic restart;
//outputs
logic [7:0] time_left;

time_remaining #(.GIVEN_TIME(150), .ONE_SEC(10)) 
                uut (.vsync(vsync), .timer_go(timer_go), .restart(restart), .time_left(time_left));

always #5 vsync = !vsync;
   
    initial begin
    restart = 0;
    vsync = 0;
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