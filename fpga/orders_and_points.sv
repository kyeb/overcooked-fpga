module orders_and_points (input vsync,
                          input reset,
                          input [1:0][3:0] check_spaces,
                          input timer_go,
                          input [2:0] game_state,
                          output logic [1:0] clear_space,
                          output logic [9:0] point_total,
                          output logic [3:0] orders,
                          output logic [3:0][4:0] order_times);
                          
    parameter ONE_SEC = 60;
    parameter ORDER_TIME = 60*20;
    
    logic [31:0] add_order_counter;
    logic [25:0] second_counter;

//check order spots
//if correct order, add points, remove an order
    always_ff @(negedge vsync) begin
        if ((reset)||(game_state==0)) begin
            orders <= 4'b0;
            point_total <= 4'b0;
            order_times <= {4{{5'h1e}}};
            clear_space[1:0] <= 0;
            add_order_counter <= 0;
            second_counter <= 0;
        end else if ((check_spaces[0] == 4'd4)&&(timer_go)) begin
            orders <= {1'b0, orders[3:1]};
            order_times <= {5'h1e, order_times[3:1]};
            add_order_counter <= add_order_counter+1;
            second_counter <= second_counter+1;
            //increase points
            clear_space[0] <=  1;
            if (order_times[0] > 15) begin
                point_total <= point_total+20+6;
            end else if (order_times[0] > 10) begin
                point_total <= point_total+20+4;
            end else if (order_times[0] > 5) begin
                point_total <= point_total+20+2;
            end else begin
                point_total <= point_total+20;
            end           
        end else if ((check_spaces[1] == 4'd4)&&(timer_go)) begin
            orders <= {1'b0, orders[3:1]};
            order_times <= {5'h1e, order_times[3:1]};
            add_order_counter <= add_order_counter+1;
            second_counter <= second_counter+1;
            //increase points
            clear_space[1] <=  1;
            if (order_times[1] > 15) begin
                point_total <= point_total+20+6;
            end else if (order_times[1] > 10) begin
                point_total <= point_total+20+4;
            end else if (order_times[1] > 5) begin
                point_total <= point_total+20+2;
            end else begin
                point_total <= point_total+20;
            end     
        //if order time runs out, subtract points, remove order
        end else if ((order_times[0] == 0)&&(timer_go)) begin
            if (point_total>9) begin
                point_total <= point_total - 10;
            end
            orders <= {1'b0, orders[3:1]};
            order_times <= {5'h1e, order_times[3:1]};
            add_order_counter <= add_order_counter+1;
            clear_space[0] <=  0;
            clear_space[1] <=  0;
        end else if ((order_times[1] == 0)&&(timer_go)) begin
            if (point_total>9) begin
                point_total <= point_total - 10;
            end
            orders <= {1'b0, orders[3:1]};
            order_times <= {5'h1e, order_times[3:1]};
            add_order_counter <= add_order_counter+1;
            second_counter <= second_counter+1;
            clear_space[0] <=  0;
            clear_space[1] <=  0;
        //if no orders, add an order
        end else if ((orders == 0)&&(timer_go)) begin
            orders <= 4'b1;
            add_order_counter <= 32'b1;
            second_counter <= second_counter+1;
            clear_space[0] <=  0;
            clear_space[1] <=  0;
        //add order every 20 seconds unless already 4 
        end else if ((add_order_counter >= ORDER_TIME)&&(timer_go)) begin  
            add_order_counter <= 32'b1;
            clear_space[0] <=  0;
            clear_space[1] <=  0;    
            if (orders == 4'b0001) begin
                orders <= 4'b0011;
            end else if (orders == 4'b0011) begin
                orders <= 4'b0111;
            end else if (orders == 4'b0111) begin
                orders <= 4'b1111;
            end 
        end else if ((second_counter >= ONE_SEC)&&(timer_go)) begin
            second_counter <= 1;
            clear_space[0] <=  0;
            clear_space[1] <=  0;
            add_order_counter <= add_order_counter+1;
            if ((order_times[0]>0)&&(orders[0] == 1))begin
                order_times[0] <= order_times[0]-1;
            end
            if ((order_times[1]>0)&&(orders[1] == 1))begin
                order_times[1] <= order_times[1]-1;
            end
            if ((order_times[2]>0)&&(orders[2] == 1))begin
                order_times[2] <= order_times[2]-1;
            end
            if ((order_times[3]>0)&&(orders[3] == 1))begin
                order_times[3] <= order_times[3]-1;
            end
        end else if (timer_go) begin
            add_order_counter <= add_order_counter+1;
            second_counter <= second_counter+1;
            clear_space[0] <=  0;
            clear_space[1] <=  0;
        end
        
    end

endmodule