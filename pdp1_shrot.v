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
module pdp1_shrot(sh_cnt, sh_dir, sh_rot, sh_d, sh_q);
   input [0:8] sh_cnt;
   input       sh_dir;
   input       sh_rot;
   input [0:17] sh_d;
   output [0:17] sh_q;

   wire [0:3] 	 w_cnt;
   wire [0:17] 	 w_ror[0:9];
   wire [0:17] 	 w_rol[0:9];
   wire [0:17] 	 w_rmask[0:9];
   wire [0:17] 	 w_lmask[0:9];   
   wire [0:17] 	 w_shft_immed1;
   wire [0:17] 	 w_shft_immed2;   
   wire [0:17] 	 w_rot_immed;
      
   pdp1_shrot_cnt_lut lut(.sh_cnt(sh_cnt), 
			  .sh_out(w_cnt));

   
   assign w_ror[0] = sh_d;
   assign w_ror[1] = {sh_d[17], sh_d[0:16]};
   assign w_ror[2] = {sh_d[16:17], sh_d[0:15]};
   assign w_ror[3] = {sh_d[15:17], sh_d[0:14]};
   assign w_ror[4] = {sh_d[14:17], sh_d[0:13]};
   assign w_ror[5] = {sh_d[13:17], sh_d[0:12]};
   assign w_ror[6] = {sh_d[12:17], sh_d[0:11]};
   assign w_ror[7] = {sh_d[11:17], sh_d[0:10]};
   assign w_ror[8] = {sh_d[10:17], sh_d[0:9]};
   assign w_ror[9] = {sh_d[9:17], sh_d[0:8]};

   assign w_rol[0] = sh_d;
   assign w_rol[1] = {sh_d[1:17], sh_d[0]};
   assign w_rol[2] = {sh_d[2:17], sh_d[0:1]};
   assign w_rol[3] = {sh_d[3:17], sh_d[0:2]};
   assign w_rol[4] = {sh_d[4:17], sh_d[0:3]};
   assign w_rol[5] = {sh_d[5:17], sh_d[0:4]};
   assign w_rol[6] = {sh_d[6:17], sh_d[0:5]};
   assign w_rol[7] = {sh_d[7:17], sh_d[0:6]};
   assign w_rol[8] = {sh_d[8:17], sh_d[0:7]};
   assign w_rol[9] = {sh_d[9:17], sh_d[0:8]};

   assign w_rmask[0] = 18'b111111_111111_111111;
   assign w_rmask[1] = 18'b011111_111111_111111;
   assign w_rmask[2] = 18'b001111_111111_111111;
   assign w_rmask[3] = 18'b000111_111111_111111;
   assign w_rmask[4] = 18'b000011_111111_111111;
   assign w_rmask[5] = 18'b000001_111111_111111;
   assign w_rmask[6] = 18'b000000_111111_111111;
   assign w_rmask[7] = 18'b000000_011111_111111;
   assign w_rmask[8] = 18'b000000_001111_111111;
   assign w_rmask[9] = 18'b000000_000111_111111;

   assign w_lmask[0] = 18'b111111_111111_111111;
   assign w_lmask[1] = 18'b111111_111111_111110;
   assign w_lmask[2] = 18'b111111_111111_111100;
   assign w_lmask[3] = 18'b111111_111111_111000;
   assign w_lmask[4] = 18'b111111_111111_110000;
   assign w_lmask[5] = 18'b111111_111111_100000;
   assign w_lmask[6] = 18'b111111_111111_000000;
   assign w_lmask[7] = 18'b111111_111110_000000;  
   assign w_lmask[8] = 18'b111111_111100_000000; 
   assign w_lmask[9] = 18'b111111_111000_000000; 
  
   assign w_rot_immed  = (sh_dir) ? w_ror[w_cnt] : w_rol[w_cnt];
   assign w_shft_immed1 = (sh_dir) ? w_rmask[w_cnt] : w_lmask[w_cnt];
   assign w_shft_immed2 = (sh_d[0]) ? ~w_shft_immed1 : 0;
   assign sh_q = (sh_rot) ? w_rot_immed : {sh_d[0], (w_rot_immed[1:17] & w_shft_immed1[1:17]) | w_shft_immed2[1:17]};
   
endmodule // pdp1_shrot
