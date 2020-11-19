module orders_and_points (input clock,
                          input reset,
                          input [1:0][3:0] check_spaces,
                          input timer_go,
                          output logic [1:0][3:0] out_spaces,
                          output logic [9:0] point_total,
                          output logic [3:0] orders,
                          output logic [3:0][4:0] order_times);
                          
    parameter NEW_ORDER_TIME = 21000000*20;
    
    logic [29:0] counter;

//check order spots
//if correct order, add points, remove an order
    always_ff @(posedge clock) begin
        if (reset) begin
            orders <= 10'b0;
            point_total <= 4'b0;
            order_times <= {4{{5'h1e}}};
            out_spaces <= check_spaces;
            counter <= 0;
        end else if ((check_spaces[1] == 4'd4)&&(timer_go)) begin
            //remove the object from the space
            out_spaces[1] <= 4'b0;
            //remove order
            orders <= orders>>1;
            order_times <= {5'h1e, order_times[3:1]};
            //increase points
            if (order_times[0] > 15) begin
                point_total <= point_total+20+6;
            end else if (order_times[0] > 10) begin
                point_total <= point_total+20+4;
            end else if (order_times[0] > 5) begin
                point_total <= point_total+20+2;
            end else begin
                point_total <= point_total+20;
            end           
        end else if ((check_spaces[0] == 4'd4)&&(timer_go)) begin
        //if order time runs out, subtract points, remove order
        end else if (order_times[0] == 0) begin
            point_total <= point_total - 10;
            orders <= orders>>1;
            order_times <= {5'h1e, order_times[3:1]};
        end else if (order_times[1] == 0) begin
            point_total <= point_total - 10;
            orders <= orders>>1;
            order_times <= {5'h1e, order_times[3:1]};
        //if no orders, add an order
        end else if (orders == 0) begin
            orders <= 4'b1;
            counter <= 0;
        //add order every 20 seconds unless already 4 
        end else if (counter == NEW_ORDER_TIME) begin
            if (orders == 4'b0001) begin
                orders <= 4'b0011;
            end else if (orders == 4'b0011) begin
                orders <= 4'b0111;
            end else if (orders == 4'b0111) begin
                orders <= 4'b1111;
            end 
        end
    end

endmodule