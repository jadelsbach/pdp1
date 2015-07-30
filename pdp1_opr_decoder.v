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

module pdp1_opr_decoder(op_i, op_mask, op_ac, op_io, 
			op_pf, op_tw, op_r_ac, op_r_io, op_r_pf);
   parameter pdp_model = "PDP-1";
   
   input op_i;
   input [0:11] op_mask;
   input [0:17] op_ac;
   input [0:17] op_io;
   input [0:5] 	op_pf;
   input [0:17] op_tw;
   output [0:17] op_r_ac;
   output [0:17] op_r_io;
   output [0:5]  op_r_pf;
   
   wire [0:18] 	 w_ac_immed1;
   wire [0:18] 	 w_ac_immed2;
   wire [0:18] 	 w_ac_immed3;
   wire [0:18] 	 w_ac_immed4;

   wire [0:18] 	 w_io_immed1;

   reg [0:5] 	 r_pf_mask;
     
   assign w_ac_immed4 = (op_mask[4]) ? 18'b0 : op_ac;
   assign w_ac_immed3 = (op_mask[1]) ? (w_ac_immed4 | op_tw) : w_ac_immed4;
   assign w_ac_immed2 = (op_mask[5]) ? (w_ac_immed3 | op_pf) : w_ac_immed3;
   assign w_ac_immed1 = (op_mask[2]) ? ~w_ac_immed2 : w_ac_immed2;
      
   assign w_io_immed1 = (op_mask[0]) ? 18'b0 : op_io;

   generate
      if(pdp_model == "PDP-1D") begin
	 assign w_io_immed1 = (op_i) ? ~w_io_immed2 : w_io_immed2;

	 assign op_r_ac = (op_mask[6]) ? w_io_immed1 : w_ac_immed1;
	 assign op_r_io = (op_mask[7]) ? w_ac_immed1 : w_io_immed1;
      end
      else begin
	 assign op_r_io = w_io_immed1;
	 assign op_r_ac = w_ac_immed1;
      end
   endgenerate

   assign op_r_pf = (|op_mask[8:11]) ?
		    ((op_mask[8]) ? op_pf | r_pf_mask : 
		     op_pf & ~r_pf_mask) :
		    op_pf;
   
   always @(op_mask or op_pf) begin
      case(op_mask[9:11])
	3'b000:
	  r_pf_mask = 6'b000000;
	3'b001:
	  r_pf_mask = 6'b000001;
	3'b010:
	  r_pf_mask = 6'b000010;
	3'b011:
	  r_pf_mask = 6'b000100;
	3'b100:
	  r_pf_mask = 6'b001000;
	3'b101:
	  r_pf_mask = 6'b010000;
	3'b110:
	  r_pf_mask = 6'b100000;
	3'b111:
	  r_pf_mask = 6'b111111;
      endcase // case (op_mask[9:11])
   end
   
endmodule // pdp1_opr_decoder
