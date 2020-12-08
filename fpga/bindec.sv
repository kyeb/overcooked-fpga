module bin_to_decimal(
    input [7:0] bin, //only works if equiv to [0,99] in decimal
    output logic [11:0] dec
    );
    
    //Temporary variables
    logic [3:0] hundreds;
    logic [3:0] tens;
    logic [3:0] ones;
    
    logic [7:0] bin_left;
    
    //Case statements used to differentiate places
    always_comb begin

        if (bin >= 'd900) begin
            hundreds = 9;
            bin_left = bin - 900; 
        end else if (bin >= 'd800) begin
            hundreds = 8;
            bin_left = bin - 800; 
        end else if (bin >= 'd700) begin
            hundreds = 7;
            bin_left = bin - 700; 
        end else if (bin >= 'd600) begin
            hundreds = 6;
            bin_left = bin - 600; 
        end else if (bin >= 'd500) begin
            hundreds = 5;
            bin_left = bin - 500; 
        end else if (bin >= 'd400) begin
            hundreds = 4;
            bin_left = bin - 400; 
        end else if (bin >= 'd300) begin
            hundreds = 3;
            bin_left = bin - 300; 
        end else if (bin >= 'd200) begin
            hundreds = 2;
            bin_left = bin - 200; 
        end else if (bin >= 'd100) begin
            hundreds = 1;
            bin_left = bin - 100; 
        end else begin
            hundreds = 0;
        end

        if (bin_left >= 90) begin
            tens = 4'd9;
            ones = bin_left - 90;
        end else if (bin_left >= 80) begin 
            tens = 4'd8;
            ones = bin_left - 80;
        end else if (bin_left >= 70) begin 
            tens = 4'd7;
            ones = bin_left - 70;
        end else if (bin_left >= 60) begin 
            tens = 4'd6;
            ones = bin_left - 60;
        end else if (bin_left >= 50) begin 
            tens = 4'd5;
            ones = bin_left - 50;
        end else if (bin_left >= 40) begin 
            tens = 4'd4;
            ones = bin_left - 40;
        end else if (bin_left >= 30) begin 
            tens = 4'd3;
            ones = bin_left - 30;
        end else if (bin_left >= 20) begin 
            tens = 4'd2;
            ones = bin_left - 20;
        end else if (bin_left >= 10) begin 
            tens = 4'd1;
            ones = bin_left - 10;
        end else begin 
            tens = 0;
            ones = bin_left;
        end

        //Assigning decimal_out
        dec = {hundreds, tens, ones};    
    end
endmodule