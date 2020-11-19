module orders_and_points_tb();

//inputs
logic clock;
logic reset;
logic [1:0][3:0] check_spaces;
logic timer_go;


//outputs
logic [1:0][3:0] out_spaces;
logic [9:0] point_total;
logic [3:0] orders;
logic [3:0][4:0] order_times;


orders_and_points uut (.clock(clock), .reset(reset), .check_spaces(check_spaces), .timer_go(timer_go), 
                       .out_spaces(out_spaces),
                       . point_total(point_total), .orders(orders), .order_times(order_times));

always #5 clock = !clock;
   
    initial begin
    reset = 0;
    clock = 0;
    check_spaces = 0;
    timer_go = 0;
    #10
    reset = 1;
    #10
    reset = 0;
    timer_go = 1;
    
    
    end
    
endmodule