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

`define PDP1_SBS_ESM 11'o0055
`define PDP1_SBS_LSM 11'o0054
`define PDP1_SBS_CBS 11'o0056
`define PDP1_SBS_CKS 11'o0033

module pdp1_sbs(i_clk, i_rst,
		sb_ireq, sb_dne,
		pb_att, pb_op, pb_sqb,
		tr_lp, tr_ptr, tr_tyo, tr_tyi, tr_tp, tr_drm);
   input i_clk;
   input i_rst;

   output reg sb_ireq;
   input      sb_dne;

   input  pb_att;
   input  [0:10] pb_op;
   output [0:5]  pb_sqb;

   input 	 tr_lp;
   input 	 tr_ptr;
   input 	 tr_tyo;
   input 	 tr_tyi;
   input 	 tr_tp;
   input 	 tr_drm;
      
   reg 		 r_en;
   wire 	 w_tr_any;
   
   assign pb_sqb = {tr_lp, tr_ptr, tr_tyo, tr_tyi, tr_tp, tr_drm, r_en};
   assign  w_tr_any = (|pb_sqb[0:4]);
   
   always @(posedge i_clk) begin
      if(i_rst) begin
	 sb_ireq <= 1'b0;
	 r_en <= 1'b0;
      end
      else begin
	 if(pb_att) begin
	    case(pb_op)
	      `PDP1_SBS_ESM:
		r_en <= 1'b1;
	      `PDP1_SBS_LSM:
		r_en <= 1'b0;
	      `PDP1_SBS_CBS:
		sb_ireq <= 1'b0;
	    endcase // case (pb_op)
	 end
	 else begin
	    if(w_tr_any & ~sb_dne)
	      sb_ireq <= 1'b1;
	    else if(sb_dne & sb_ireq)
	      sb_ireq <= 1'b0;
	 end
      end
   end
   
endmodule // pdp1_sbs
