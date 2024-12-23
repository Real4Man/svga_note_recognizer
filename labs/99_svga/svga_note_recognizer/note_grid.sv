
`default_nettype none 

module note_grid
#(
    parameter               is_simulation=0
)
(
  
    input   wire            clk,
    input   wire            reset_p,



    input   wire [11:0]     x,
    input   wire [10:0]     y,
    output  wire [3:0]      vga_r,
    output  wire [3:0]      vga_g,
    output  wire [3:0]      vga_b

    
);

logic [9:0]     line_x[7] = { 96, 128, 160, 192, 224, 256, 288 };

logic [3:0]         color;

assign vga_r = color;
assign vga_b = color;
assign vga_g = color;

assign color = 
 ( 
    
    y[9:2]==line_x[0][9:2] 

 ) ?   4'b0000 : 4'b1111;

endmodule

`default_nettype wire