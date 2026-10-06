// SCL 1.2um digital standard cell models
// Formatted for compatibility with Fault parser and Icarus Verilog
`timescale 1ns/1ps

module NOR200 ( OUT1 , IN1 , IN2 );
  output OUT1 ;
  input IN1 ;
  input IN2 ;
  wire nor_w ;
  or ( nor_w , IN1 , IN2 );
  not ( OUT1 , nor_w );
endmodule

module ADNR01 ( OUT1 , A , B , C );
  output OUT1 ;
  input A ;
  input B ;
  input C ;
  wire scl_net_not_0 ;
  wire scl_net_not_1 ;
  wire scl_net_not_2 ;
  wire scl_net_and_02 ;
  wire scl_net_and_12 ;
  not ( scl_net_not_0 , A );
  not ( scl_net_not_1 , B );
  not ( scl_net_not_2 , C );
  and ( scl_net_and_02 , scl_net_not_0 , scl_net_not_2 );
  and ( scl_net_and_12 , scl_net_not_1 , scl_net_not_2 );
  or ( OUT1 , scl_net_and_02 , scl_net_and_12 );
endmodule
