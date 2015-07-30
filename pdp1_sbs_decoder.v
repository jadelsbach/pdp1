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

/*
 * FIXME: I assume that the storage location for channel exchange packets is
 * always on core memory bank 0. Is this corrent?
 * 
 * TODO: Replace logic buffer with regs quirk with system verilog "logic"
 */

/*
 * The module behaves the same for channel 1 independently of whether it is
 * initiated with SBS or SBS16, however if only using a normal SBS 
 * instantiating the module with the latter decreases LUT usage.
 */
module pdp1_sbs_decoder(sb_ireq1, sb_ireq2, sb_ireq3, sb_ireq4,
			sav_ac, sav_io, sav_pc, sav_jmp);
   parameter sbs_model = "SBS";

   input sb_ireq1;
   input sb_ireq2;
   input sb_ireq3;
   input sb_ireq4;

   output [0:11] sav_ac;
   output [0:11] sav_io;
   output [0:11] sav_pc;
   output [0:11] sav_jmp;
   
   generate
      if(sbs_model == "SBS") begin
	 assign sav_ac  = 12'o0000;
	 assign sav_io  = 12'o0002;
	 assign sav_pc  = 12'o0001;
	 assign sav_jmp = 12'o0003;
      end
      else begin
	 reg [0:11] r_ac;
	 reg [0:11] r_pc;
	 reg [0:11] r_io;
	 reg [0:11] r_jmp;

	 assign sav_ac = r_ac;
	 assign sav_io = r_io;
	 assign sav_jmp = r_jmp;
	 assign sav_pc = r_pc;
	 
	 always @(sb_ireq1 or sb_ireq2 or sb_ireq3 or sb_ireq4) begin
	    case({sb_ireq1, sb_ireq2, sb_ireq3, sb_ireq4})
	      4'b1XXX:
		begin
		   r_ac  <= 12'o0000;
		   r_pc  <= 12'o0001;
		   r_io  <= 12'o0002;
		   r_jmp <= 12'o0003;
		end
	      4'bX1XX:
		begin
		   r_ac  <= 12'o0004;
		   r_pc  <= 12'o0005;
		   r_io  <= 12'o0006;
		   r_jmp <= 12'o0007;		   
		end
	      4'bXX1X:
		begin
		   r_ac  <= 12'o0010;
		   r_pc  <= 12'o0011;
		   r_io  <= 12'o0012;
		   r_jmp <= 12'o0013;		   
		end	      
	      4'bXXX1:
		begin
		   r_ac  <= 12'o0014;
		   r_pc  <= 12'o0015;
		   r_io  <= 12'o0016;
		   r_jmp <= 12'o0017;		   
		end
	      default:
		begin
		   r_ac  <= 12'o0000;
		   r_pc  <= 12'o0000;
		   r_io  <= 12'o0000;
		   r_jmp <= 12'o0000;		   
		end
	    endcase // case ({sb_ireq1, sb_ireq2, sb_ireq3, sb_ireq4})
	 end
      end
   endgenerate
      
endmodule // pdp1_sbs_decoder

   
