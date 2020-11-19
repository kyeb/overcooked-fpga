module time_remaining #(parameter GIVEN_TIME = 8'd150,
                                  ONE_SEC = 24'd10000000) //clock speed
                      (input clock,
                       input timer_go,
                       input restart,
                       output logic [7:0] time_left); //in seconds in hex
    
    logic [24:0] counter;
    
    always_ff @(posedge clock) begin
        if (restart) begin //reset time left and seconds counter
            time_left <= GIVEN_TIME;
            counter <= 0;
        //once one second pass, decrease time remaining unless already 0
        end else if ((counter == ONE_SEC)&&(time_left != 0)) begin
            time_left <= time_left-1;
            counter <= 1;
        // else count clock cycles till next second passes
        end else if ((timer_go)&&(time_left != 0)) begin
            counter <= counter+1;
        end
    end                   

endmodule