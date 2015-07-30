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
module pdp1_flg_offset(fl_n, fl_mask);
   input [0:2] fl_n;
   output reg [0:5] fl_mask;
   
   always @(fl_n) begin
      case(fl_n)
	3'b000:
	  fl_mask <= 6'b000000;
	3'b001:
	  fl_mask <= 6'b000001;
	3'b010:
	  fl_mask <= 6'b000010;
	3'b011:
	  fl_mask <= 6'b000100;
	3'b100:
	  fl_mask <= 6'b001000;
	3'b101:
	  fl_mask <= 6'b010000;
	3'b110:
	  fl_mask <= 6'b100000;
	3'b111:
	  fl_mask <= 6'b111111;
      endcase // case (op_mask[9:11])
   end // always @ (w_pf_immed or sk_pf)
   
endmodule // pdp1_flg_offset

module pdp1_skp_decoder(sk_mask, sk_i, sk_ac, sk_io, sk_ov, 
			sk_sw, sk_pf, sk_skp);
   parameter pdp_model = "PDP-1"; // Or PDP-1D

   input [0:11] sk_mask;
   input 	sk_i;
   input [0:17] sk_ac;
   input [0:17] sk_io;
   input 	sk_ov;
   input [0:5] 	sk_sw;
   input [0:5] 	sk_pf;
   output 	sk_skp;
      
   wire 	w_io_p;
   wire 	w_ac_p;
   wire 	w_pf_p;
   wire 	w_sw_p;
   wire 	w_or;
   wire [0:2] 	w_pf_immed;
   wire [0:2] 	w_sw_immed;
   wire [6:0] 	w_pf_off;
   wire [0:6] 	w_sw_off;

   wire [0:5] 	w_pf_mask;
   wire [0:5] 	w_sw_mask;

   assign w_pf_immed = sk_mask[9:11];
   assign w_sw_immed = sk_mask[6:8];

   pdp1_flg_offset pf(w_pf_immed, w_pf_mask);
   pdp1_flg_offset sw(w_sw_immed, w_sw_mask);
         
   assign sk_skp = (sk_i) ? ~w_or : w_or;
   assign w_or = w_io_p | w_ac_p | (sk_mask[2] & ~sk_ov) | w_pf_p | w_sw_p;
   
   generate 
      if(pdp_model == "PDP-1D")
	assign w_io_p = (sk_mask[0] & (|sk_io[1:17])) | 
			(sk_mask[1] & ~sk_io[0]);
      else
	assign w_io_p = (sk_mask[1] & ~sk_io[0]);
   endgenerate

   assign w_ac_p = (sk_mask[3] & sk_ac[0])  |
		   (sk_mask[4] & ~sk_ac[0]) |
		   (sk_mask[5] & ~(|sk_ac));
      
   assign w_pf_p = ~(|w_pf_immed) ? 1'b0 :
		   (&w_pf_immed) ? ~(&sk_pf) : ~(|(sk_pf & w_pf_mask));

   assign w_sw_p = ~(|w_sw_immed) ? 1'b0 :
		   (&w_sw_immed) ? ~(&sk_sw) : ~(|(sk_sw & w_sw_mask));

   
endmodule // pdp1_skp_decoder
