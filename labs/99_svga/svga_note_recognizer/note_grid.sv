
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

//int      line_x[7] = { 96, 128, 160, 192, 224, 256, 288 };
const int line_0 = 96;
const int line_1 = 112;
const int line_2 = 128;
const int line_3 = 144;
const int line_4 = 160;
const int line_5 = 176;
const int line_6 = 192;

logic [3:0]         color;

assign vga_r = color;
assign vga_b = color;
assign vga_g = color;

assign color = 
 ( 
    
       y[9:1]==line_0[9:1] 
    || y[9:1]==line_1[9:1]
    || y[9:1]==line_2[9:1]
    || y[9:1]==line_3[9:1]
    || y[9:1]==line_4[9:1]
    || y[9:1]==line_5[9:1]
    || y[9:1]==line_6[9:1]
    
 ) ?   4'b0000 : 4'b1111;

endmodule

`default_nettype wire