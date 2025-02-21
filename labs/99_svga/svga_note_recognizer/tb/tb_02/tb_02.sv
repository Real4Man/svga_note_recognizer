
import tb_02_pkg::*;

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
//logic               reset_n;

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

  $display("tb_02  test_id=%d  name:", test_id, test_name[test_id] );
  
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

tb_02_if    s( clk );

task tb_init;

    _s = s;

    _s.init();
//    reset_n = '0;

    tb_02_init();

endtask

// Generate test sequence 
initial begin : generate_test_sequence


  tb_init();

  @(posedge clk iff test_start=='1); #1;

  //reset_n = '1;
      
  case( test_id )
    0: begin

        tb_02_prepare();
        fork
            tb_02_seq_01();
        //     tb_02_seq_direct();
        //     tb_02_monitor( _st1 );
        join


        #500;

        test_done=1;        

     end

    1: begin

       test_done=1;        
    end


  endcase
end







note_combine    note_combine
(
  
    .clk                        (   clk                         ),
    .reset_p                    (   s.reset_p                   ),
    .d2_recognize_result        (   s.d2_recognize_result       ),
    .d2_recognize_result_step   (   s.d2_recognize_result_step  ),
    .d3_note_lenght             (   s.d3_note_lenght            ),
    .d3_note_index              (   s.d3_note_index             ), 
    .d3_note_step               (   s.d3_note_step              )
    
);


endmodule