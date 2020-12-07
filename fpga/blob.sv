module blob
   #(parameter COLOR = 12'h070) 
   (input[8:0] width, height,
    input [10:0] x_in,hcount_in,
    input [9:0] y_in,vcount_in,
    output logic [11:0] pixel_out);

   always_comb begin
      if ((hcount_in >= x_in && hcount_in < (x_in+width)) && (vcount_in >= y_in && vcount_in < (y_in+height)))
        pixel_out = COLOR;
      else 
        pixel_out = 0;
   end
endmodule