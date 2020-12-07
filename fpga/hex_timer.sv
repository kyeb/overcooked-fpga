module bin_to_decimal(
    input [7:0] bin, //only works if equiv to [0,99] in decimal
    output logic [11:0] dec
    );
    
    //Temporary variables
    logic [3:0] hundreds;
    logic [3:0] tens;
    logic [3:0] ones;
    
    //Case statements used to differentiate places
    always_comb begin

        if (bin >= 'd100) begin
            hundreds = 1;
            bin = bin - 100; 
        end else begin
            hundreds = 0;
        end

        if (bin >= 90) begin
            tens = 4'd9;
            ones = bin - 90;
        end else if (bin >= 80) begin 
            tens = 4'd8;
            ones = bin - 80;
        end else if (bin >= 70) begin 
            tens = 4'd7;
            ones = bin - 70;
        end else if (bin >= 60) begin 
            tens = 4'd6;
            ones = bin - 60;
        end else if (bin >= 50) begin 
            tens = 4'd5;
            ones = bin - 50;
        end else if (bin >= 40) begin 
            tens = 4'd4;
            ones = bin - 40;
        end else if (bin >= 30) begin 
            tens = 4'd3;
            ones = bin - 30;
        end else if (bin >= 20) begin 
            tens = 4'd2;
            ones = bin - 20;
        end else if (bin >= 10) begin 
            tens = 4'd1;
            ones = bin - 10;
        end else begin 
            tens = 0;
            ones = bin;
        end

        //Assigning decimal_out
        dec = {hundreds, tens, ones};    
    end
endmodule