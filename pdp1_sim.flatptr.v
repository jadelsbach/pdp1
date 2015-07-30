module pdp1_flatptr(i_clk, i_rst,
		bs_stb, bs_adr, bs_wait, bs_din, bs_dout, bs_inh);
   input i_clk;
   input i_rst;

   input         bs_stb;
   input [0:10]   bs_adr;
   input 	 bs_wait;
   input [0:17]  bs_din;
   output [0:17] bs_dout;
   output 	 bs_inh;

   reg [7:0] 	 m_buffer[0:1023]; // Reversed bit order!
   reg [0:9] 	 r_rdbuf;
            
   wire w_itsme = (bs_adr == 10'o001 |
		   bs_adr == 10'o002 |
		   bs_adr == 10'o030);

   reg [0:17] r_dout;
   
   assign bs_dout = (w_itsme & bs_wait) ? r_dout : 18'hzzzz;

      
   always @(posedge i_clk) begin
      if(i_rst) begin
	 r_rdbuf <= 0;
	 r_dout <= 0;
      end
      else begin
	 if(bs_stb) begin
	    case(bs_adr)
	      10'o001,
	      10'o030:
		begin
		   r_dout <= m_buffer[r_rdbuf];
		   r_rdbuf = r_rdbuf;
		end
	    endcase // case (bs_adr)
	 end
      end
   end
      
endmodule // pdp1_ptr

