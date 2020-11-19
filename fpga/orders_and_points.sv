module orders_and_points (input clock,
                          input reset,
                          input [1:0][3:0] check_spaces,
                          output logic [1:0][3:0] out_spaces,
                          output logic [9:0] point_total,
                          output logic [3:0] orders,
                          output logic [3:0][4:0] order_times);
                          
//    This module will keep track of the assigned orders. With a
//lower bound of one order and an upper bound of four, orders
//will keep being assigned every 20 seconds unless hitting a max
//or min causes this to be overridden and adjusted accordingly.
//One output array will consist of ones and zeros to mark
//assigned orders. A corresponding array will consist of the
//related times remaining on each order. When an order expires
//before being fulfilled, 10 points will be subtracted from total
//points.
//This module will also use the grid to check the designated
//turn in spot for completed orders. An order completed before
//it expires will remove the order from the current orders array
//and add 20 points. Orders completed very early will receive
//tips in the form of extra points.
//There will be several moving parts to this module but the
//math should remain relatively simple. In order to test, various
//order fulfilment scenarios may be introduced to ensure the
//correct point output and that orders are cleared appropriately.

//check order spots
//if correct order, add points, remove an order
    always_ff @(posedge clock) begin
        if (reset) begin
            orders <= 10'b0;
            point_total <= 4'b0;
            order_times <= {4{{5'h1e}}};
            out_spaces <= check_spaces;
        end else if (check_spaces[1] == 4'd4) begin
            //remove the object from the space
            //remove order
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
            
        end else if (check_spaces[0] == 4'd4) begin
        end
    end

//if order time runs out, subtract points, remove order

//if no orders, add an order
//add order every 20 seconds unless already 4 

endmodule