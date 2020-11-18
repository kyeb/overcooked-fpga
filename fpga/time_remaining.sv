module time_remaining(input clock,
                      input timer_go,
                      input restart,
                      output logic [7:0] time_left); //in seconds in hex
                      
    parameter given_time = 8'd150;
    parameter one_sec = 24'd10; //24'd10000000; //clock speed
    
    logic [24:0] counter;
    
    always_ff @(posedge clock) begin
        if (restart) begin //reset time left and seconds counter
            time_left <= given_time;
            counter <= 0;
        //once one second pass, decrease time remaining unless already 0
        end else if ((counter == one_sec)&&(time_left != 0)) begin
            time_left <= time_left-1;
            counter <= 1;
        // else count clock cycles till next second passes
        end else if ((timer_go)&&(time_left != 0)) begin
            counter <= counter+1;
        end
    end                   

endmodule