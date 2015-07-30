module pdp1_lp(i_clk, i_rst,
	       io_att, io_op, io_pulse, io_sword, io_rword);
   input i_clk;
   input i_rst;

   input io_att;
   input [0:11] io_op;
   output      io_pulse;
   
   input  [0:17] io_sword;   
   output [0:17] io_rword;
   
   assign io_rword = 18'hzzzzz;     
   assign io_pulse = (i==10)|(i==11);
   integer 	 i;
   
 
   always @(posedge i_clk) begin
      if(i_rst)
	i= 0;
      
      if(io_att & io_op[6:11] == 6'o45) begin
	 $display("Print! %o", io_sword);
	 i=1;
	 
      end
      if(i>0)
	i = i+1;
    	
   end
endmodule // pdp1_lp
