module orders_and_points_tb();

//inputs
logic clock;
logic vsync;
logic reset;
logic [1:0][3:0] check_spaces;
logic timer_go;


//outputs
logic [9:0] point_total;
logic [3:0] orders;
logic [3:0][4:0] order_times;
logic clear_space0;
logic clear_space1;


orders_and_points uut (.clock(clock), .reset(reset), .vsync(vsync), .timer_go(timer_go), 
                       .check_spaces(check_spaces), .point_total(point_total), .orders(orders), 
                       .clear_space0(clear_space0), .clear_space1(clear_space1), .order_times(order_times));

always #5 clock = !clock;
always #5 vsync = !vsync;
   
    initial begin
    reset = 0;
    vsync = 0;
    clock = 0;
    check_spaces = 0;
    timer_go = 0;
    #10
    reset = 1;
    #10
    reset = 0;
    timer_go = 1;
    
    #500
    check_spaces[0] = 4'd4;
    #10
    check_spaces[0] = 4'd0;
    
    end
    
endmodule