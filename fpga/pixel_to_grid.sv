module pixel_to_grid(input [8:0] x_coord,
                     input [8:0] y_coord,
                     output logic [3:0] x_grid,
                     output logic [3:0] y_grid);
                     
    always_comb begin 
                    
        if ((x_coord >= 112)&&(x_coord <= 143)) begin
            x_grid = 4'd0;
        end else if ((x_coord >= 144)&&(x_coord <= 175)) begin
            x_grid = 4'd1;
        end else if ((x_coord >= 176)&&(x_coord <= 207)) begin
            x_grid = 4'd2;
        end else if ((x_coord >= 208)&&(x_coord <= 239)) begin
            x_grid = 4'd3;
        end else if ((x_coord >= 240)&&(x_coord <= 271)) begin
            x_grid = 4'd4;
        end else if ((x_coord >= 272)&&(x_coord <= 303)) begin
            x_grid = 4'd5;
        end else if ((x_coord >= 304)&&(x_coord <= 335)) begin
            x_grid = 4'd6;
        end else if ((x_coord >= 336)&&(x_coord <= 367)) begin
            x_grid = 4'd7;
        end else if ((x_coord >= 368)&&(x_coord <= 399)) begin
            x_grid = 4'd8;
        end else if ((x_coord >= 400)&&(x_coord <= 431)) begin
            x_grid = 4'd9;
        end else if ((x_coord >= 432)&&(x_coord <= 463)) begin
            x_grid = 4'd10;
        end else if ((x_coord >= 464)&&(x_coord <= 495)) begin
            x_grid = 4'd11;
        end else if ((x_coord >= 496)&&(x_coord <= 527)) begin
            x_grid = 4'd12;
        end
        
        if ((y_coord >= 112)&&(y_coord <= 143)) begin
            y_grid = 4'd0;
        end else if ((y_coord >= 144)&&(y_coord <= 175)) begin
            y_grid = 4'd1;
        end else if ((y_coord >= 176)&&(y_coord <= 207)) begin
            y_grid = 4'd2;
        end else if ((y_coord >= 208)&&(y_coord <= 239)) begin
            y_grid = 4'd3;
        end else if ((y_coord >= 240)&&(y_coord <= 271)) begin
            y_grid = 4'd4;
        end else if ((y_coord >= 272)&&(y_coord <= 303)) begin
            y_grid = 4'd5;
        end else if ((y_coord >= 304)&&(y_coord <= 335)) begin
            y_grid = 4'd6;
        end else if ((y_coord >= 336)&&(y_coord <= 367)) begin
            y_grid = 4'd7;
        end
        
    end

endmodule