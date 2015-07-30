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

module pdp1_memory(i_clk, i_rst,
		   mm_we, mm_adr, mm_din, mm_dout);
   input i_clk;
   input i_rst;
   
   input             mm_we;
   input      [0:11] mm_adr;
   output     [0:17] mm_din;
   input      [0:17] mm_dout;

   reg [0:18] 	     m_memory [0:4095];
   integer 	     i;

   assign mm_din = (~mm_we) ? m_memory[mm_adr] : 18'h00000;
         
   always @(posedge i_clk) begin
      if(i_rst) begin
	 for(i = 0; i < 4095; i = i + 1)
	   m_memory[i] = 0;

	 $readmemh("test.hex", m_memory);  ///XXX
      end
      else begin
	 if(mm_we) begin
	   m_memory[mm_adr] <= mm_dout;
           //$display("%m @%o <= %o", mm_adr, mm_dout);
         end
      end
   end
   
endmodule // pdp1_memory
