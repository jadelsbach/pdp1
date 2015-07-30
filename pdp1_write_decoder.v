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
module pdp1_write_decoder(ma_op, ma_ac, ma_io, ma_cd, ma_w, ma_r);
   input [0:4] ma_op;
   input [0:17] ma_ac;
   input [0:17] ma_io;
   input [0:17] ma_cd;
   output reg	ma_w;
   output reg [0:17] ma_r;

   always @(ma_op or ma_ac or ma_io or ma_cd) begin
      ma_w = 1'b1;
      case(ma_op)
	`PDP1_OP_CAL:
	  ma_r <= ma_ac;
	`PDP1_OP_DAC:
	  ma_r <= ma_ac;
	`PDP1_OP_DAP:
	  ma_r <= {ma_cd[0:5], ma_ac[6:17]};
	`PDP1_OP_DIP:
	  ma_r <= {ma_ac[0:5], ma_cd[6:17]};
	`PDP1_OP_DIO:
	  ma_r <= ma_io;
	`PDP1_OP_DZM:
	  ma_r <= 0;
	default:
	  ma_w <= 0;
      endcase // case (ma_op)
   end
   
endmodule // pdp1_write_decoder
