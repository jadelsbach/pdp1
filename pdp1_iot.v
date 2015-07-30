//
//    Copyright (c) 2015 Jan Adelsbach <jan@janadelsbach.com>.  
//    All Rights Reserved.
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

module pdp1_iot(i_clk, i_rst,
		pd_inst, pd_wait, pd_in, pd_out,
		bs_stb, bs_adr, bs_pout, bs_pin, bs_dout, bs_din);
   input i_clk;
   input i_rst;
   input [0:17] pd_inst;
   output 	pd_wait;
   input [0:17] pd_in;
   output [0:17] pd_out;
   
   output reg	bs_stb;
   output [0:10] bs_adr;
   output 	 bs_pout;
   input 	 bs_pin;
   output [0:17] bs_dout;
   input  [0:17] bs_din;


   wire [0:4] 	 w_inst_op;
   wire 	 w_inst_w;
   wire 	 w_inst_p;
   wire [0:4] 	 w_inst_sop;
   wire [0:5] 	 w_inst_dev;
   
      
   assign w_inst_op  = pd_inst[0:4];
   assign w_inst_w   = pd_inst[5];
   assign w_inst_p   = pd_inst[6];
   assign w_inst_sop = pd_inst[7:11];
   assign w_inst_dev = pd_inst[12:17];
   
   reg 		 r_IOH;
   reg 		 r_IOP;
   
   assign bs_adr = {w_inst_dev|w_inst_sop};
   assign bs_pout = w_inst_p|w_inst_w;

   assign pd_wait = r_IOH | ~r_IOP;
      
   always @(posedge i_clk) begin
      if(i_rst) begin
	 r_IOH <= 0;
	 r_IOP <= 0;
      end
      else begin
	 if(bs_pin)
	   r_IOP <= 1'b1;
	 
	 if(w_inst_op == `PDP1_OP_IOT) begin
	    if(~(|{w_inst_dev, w_inst_sop})) begin // IOT 0000
	       if(r_IOP)
		 r_IOP <= 1'b0;
	    end
	    if(~r_IOH) begin
	       bs_stb <= 1'b1;

	       if(w_inst_w|w_inst_p)
		 r_IOP <= 1'b0;
	       
	       if(w_inst_w)
		 r_IOH <= 1'b1;
	    end
	    else begin
	       if(bs_pin)
		 r_IOH <= 1'b0;
	    end
	 end // if (w_inst_op == `PDP1_OP_IOT)
      end // else: !if(i_rst)
   end // always @ (posedge i_clk)

endmodule // pdp1_iot

      
