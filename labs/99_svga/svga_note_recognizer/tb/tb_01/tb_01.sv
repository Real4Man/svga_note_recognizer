
import tb_01_pkg::*;

module tb
();

int       test_id=0;

string	test_name[1:0]=
{
 "randomize", 
 "direct" 
};

initial begin  : create_time_diagram
$dumpfile("dump.vcd");
$dumpvars(2);
end


task test_finish;
        input int 	test_id;
        input string	test_name;
        input int		result;
begin

  automatic int fd = $fopen( "global.txt", "a" );

  $display("");
  $display("");

  if( 1==result ) begin
      $fdisplay( fd, "test_id=%-5d test_name: %15s         TEST_PASSED", 
      test_id, test_name );
      $display(      "test_id=%-5d test_name: %15s         TEST_PASSED", 
      test_id, test_name );
  end else begin
      $fdisplay( fd, "test_id=%-5d test_name: %15s         TEST_FAILED *******", 
      test_id, test_name );
      $display(      "test_id=%-5d test_name: %15s         TEST_FAILED *******", 
      test_id, test_name );
  end

  $fclose( fd );
  
  $display("");
  $display("");

  $finish();
end endtask  

/////////////////////////////////////////////////////////////////


logic               clk=0;
logic               reset_n;

logic               test_start=0;
logic               test_timeout=0;
logic               test_done=0;

real               cv_all;


initial begin : check_timeout
//  #100000;
  #300ms;
  $display( "Timeout");
  test_timeout = '1;
end


// Main process  
initial begin  : main_process

  automatic int args=-1;
  
  if( $value$plusargs( "test_id=%0d", args )) begin
      if( args>=0 && args<2 )
      test_id = args;

      $display( "args=%d  test_id=%d", args, test_id );

  end

  $display("tb_01  test_id=%d  name:", test_id, test_name[test_id] );
  
  //reset_n = '0;

  #100;

  //reset_n = '1;

  repeat (100) @(posedge clk );

  test_start <= #1 '1;


  @(posedge clk iff test_done=='1 || test_timeout=='1);

  if( test_timeout ) 
      _cnt_error++;

  $display( "cnt_wr: %d", _cnt_wr );
  $display( "cnt_rd: %d", _cnt_rd );
  $display( "cnt_ok: %d", _cnt_ok );
  $display( "cnt_error: %d", _cnt_error );

  //$display("overall coverage = %0f", $get_coverage());
  // $display("coverage of covergroup cg = %0f", uut.dut.cg.get_coverage());
  // $display("coverage of covergroup cg.in_tready  = %0f", uut.dut.cg.in_tready.get_coverage());
  // $display("coverage of covergroup cg.in_tvalid  = %0f", uut.dut.cg.in_tvalid.get_coverage());
  // $display("coverage of covergroup cg.out_tready = %0f", uut.dut.cg.out_tready.get_coverage());
  // $display("coverage of covergroup cg.out_tvalid = %0f", uut.dut.cg.out_tvalid.get_coverage());
  // $display("coverage of covergroup cg.i_vld_rdy  = %0f", uut.dut.cg.i_vld_rdy.get_coverage());
  // $display("coverage of covergroup cg.o_vld_rdy  = %0f", uut.dut.cg.o_vld_rdy.get_coverage());

  if( 0==_cnt_error && _cnt_ok>0 )
      test_finish( test_id, test_name[test_id], 1 );
  else
      test_finish( test_id, test_name[test_id], 0 );

end

//always @(posedge clk ) cv_all = $get_coverage();


//  Unit under test



// Unit under test

// insert the component bind_user_axis into the component user_axis for simulation purpose

always #5 clk = ~clk; 

task tb_init;


    reset_n = '0;

    tb_01_init();

endtask

// Generate test sequence 
initial begin : generate_test_sequence


  tb_init();

  @(posedge clk iff test_start=='1); #1;

  reset_n = '1;
      
  case( test_id )
    0: begin

        tb_01_prepare();
        // fork
        //     tb_02_seq_direct();
        //     tb_02_monitor( _st1 );
        // join


        //#500;
        #250000000;

        test_done=1;        

     end

    1: begin

       test_done=1;        
    end


  endcase
end

logic           mic_sck;
logic           mic_ws;
logic           mic_sdo;

logic [23:0]    mic;
logic           mic_we;

logic [15:0]        mic16;

assign mic16 = mic [23:8];


localparam integer  freq_100_C  = 26163,
                    freq_100_Cs = 27718,
                    freq_100_D  = 29366,
                    freq_100_Ds = 31113,
                    freq_100_E  = 32963,
                    freq_100_F  = 34923,
                    freq_100_Fs = 36999,
                    freq_100_G  = 39200,
                    freq_100_Gs = 41530,
                    freq_100_A  = 44000,
                    freq_100_As = 46616,
                    freq_100_B  = 49388;

// localparam int      s_freq_100[5]= { freq_100_C, freq_100_D, freq_100_Ds, freq_100_E, freq_100_F };
// localparam int      s_time_ms[5]= { 1, 45, 90, 135, 180 };
// localparam int      s_ampl[5]= { 30000, 20000, 31000, 22000, 26000 };
// localparam int      s_cnt=5;
localparam int      s_freq_100[8]= { freq_100_C, 100, freq_100_D, 100, freq_100_E, 100, freq_100_F, 100 };
localparam int      s_time_ms[8]= {  1,          61,  63,         123, 125,        185, 187,        247 };
localparam int      s_ampl[8]= {     30000,      0,   20000,      0,   10000,      0,   10000,      0 };
localparam int      s_cnt=8;
sim_inn441 
#(
    //parameter int       sck_period=320,  //! период тактового сигнала sck, [ns]
  .s_freq_100     (   s_freq_100    ),
  .s_time_ms      (   s_time_ms     ),
  .s_ampl         (   s_ampl        ),
  .s_cnt          (   s_cnt         )
)
sim_inn441
(
    .sck      (   mic_sck   ),    //! частота получения данных Fws * 64
    .ws       (   mic_ws    ),     //! частота дискретизации АЦП
    .lr       (   0         ),
    .sdo      (   mic_sdo   )
);


inmp441_mic_spi_receiver_65m
i_microphone
(
    .clk        (     clk         ),
    .reset      (     ~reset_n    ),
    .cs         (     mic_ws      ),
    .sck        (     mic_sck     ),
    .sdo        (     mic_sdo     ),
                    
    .value      (     mic         ),
    .value_we   (     mic_we      )
);
   
endmodule