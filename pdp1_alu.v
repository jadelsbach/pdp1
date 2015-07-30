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

`include "pdp1_defs.v"

module pdp1_alu(al_op, al_a, al_b, al_r, al_ovfl, al_w);
   parameter pdp_model = "PDP-1D";
      
   input [0:4] al_op;
   input [0:17] al_a;
   input [0:17] al_b;
   output reg [0:17] al_r;
   output reg 	     al_ovfl;
   output reg 	     al_w;

   wire [0:17] w_add_opa;
   wire [0:17] w_add_opb;
   
   assign w_add_opa = (al_op == `PDP1_OP_ISP | 
		       al_op == `PDP1_OP_IDX) ? 18'h1 : al_a;
   assign w_add_opb = (al_op == `PDP1_OP_SUB) ? ~al_b : al_b;

   wire [0:17] w_add_immed1;
   wire [0:17] w_add_result;
   wire [0:17] w_add_normalized;
   wire        w_add_ovfl;
   
   assign {w_add_ovfl, w_add_immed1} = w_add_opa + w_add_opb;
   assign w_add_result = (w_add_ovfl) ? (w_add_immed1) + 1 : w_add_immed1;
   assign w_add_normalized = (&w_add_result) ? 18'h0 : w_add_result;
      
   always @(al_op or al_a or al_b or w_add_result or 
	    w_add_normalized or w_add_ovfl) begin
      al_w = 1'b1;
      case(al_op)
	`PDP1_OP_ADD,
	`PDP1_OP_SUB:
	  begin
             al_r <= w_add_normalized;
	     al_ovfl <= (~w_add_opa[0] ^ w_add_opb[0]) & 
			(w_add_opa[0] ^ w_add_result[0]);
	  end
	`PDP1_OP_ISP,
	`PDP1_OP_IDX:
	  begin
	    al_r <= w_add_normalized;
            al_ovfl <= 0;
	  end
	`PDP1_OP_AND:
	  al_r <= al_a & al_b;
	`PDP1_OP_XOR:
	  al_r <= al_a ^ al_b;
	`PDP1_OP_IOR:
	  al_r <= al_a | al_b;
	default:
	  {al_ovfl, al_r, al_w} <= 0;
      endcase // case (al_op)
   end
endmodule // pdp1_alu
