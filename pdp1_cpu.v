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

`define PDP1_IOT_RPA 12'o0001


/*
 * For the ease of implementation the lower 4 bits of extended memory address
 * are given by an extra signal (mm_unit). The latter is zero if extended
 * mode is off (core memory bank 0)
 *
 *
 * Control Pins: (assert until cntrl_paused):
 * 
 *      cntrl_stop    - Input - Finish executing this instruction and stop
 *      cntrl_halt    - Input - Same as above but also interrupts indirection
 *      cntrl_resume  - Input - Continue
 *      cntrl_paused  - Output - Stopped
 *      cntrl_reason  - Output - See below
 * 
 * cntrl_halt will interrupt an indirection resolve and set the PC back so that 
 * when operation is resumed the indirection resolve is started again. This is
 * useful for fixing an endless looping resolve manually.
 * 
 * cntrl_reason:
 *     2'b00:    cntrl_halt or cntrl_stop
 *     2'b01:    Operate
 *     2'b10:    Invalid instruction
 *     2'b11:    Reserved
 */
module pdp1_cpu(i_clk, i_rst, 
		mm_we, mm_adr, mm_unit, mm_din, mm_dout,
		bs_stb, bs_adr, bs_wait, bs_din, bs_dout, bs_inh,
		sw_sn, sw_tw,
		cntrl_stop, cntrl_halt, cntrl_paused, 
		cntrl_resume, cntrl_reason,
		sb_ireq, sb_disarm);
   
   parameter pdp_model = "PDP-1"; // Or "PDP-1D"
   parameter sbs_model = "SBS";   // Or "" or "SBS16"
   parameter start_addr = 12'h000;
       
   input i_clk;
   input i_rst;

   output reg mm_we;
   output reg [0:11] mm_adr;
   output reg [0:3]  mm_unit;
   input [0:17]      mm_din;
   output reg [0:17] mm_dout;

   output reg 	     bs_stb;
   output [0:10]     bs_adr;
   output 	     bs_wait;
   output [0:17]     bs_dout;
   input [0:17]      bs_din;
   input 	     bs_inh;
      


   input [0:5] 	     sw_sn;
   input [0:17]      sw_tw;

   input 	     cntrl_stop;
   input 	     cntrl_halt;
   output 	     cntrl_paused;
   input 	     cntrl_resume;
   output reg [0:1]  cntrl_reason;

   input [0:3] 	     sb_ireq;
   output reg 	     sb_disarm;
   
      
   // Registers
   reg [0:11] 	     r_PC;
   reg [0:3] 	     r_PCU;
   reg [0:17] 	     r_AC;
   reg [0:17] 	     r_IO;
   reg 		     r_OV;
   reg [0:5] 	     r_PF;
   reg 		     r_EXTM;
   reg 		     r_IOP;
   reg 		     r_IOH;
   
   // Instruction decoding
   reg [0:17] 	     r_inst;
   wire [0:4]	     w_inst_op;
   wire 	     w_inst_i;
   wire [0:11]	     w_inst_adr;
   wire 	     w_inst_w;
   wire 	     w_inst_p;
   wire [0:4] 	     w_inst_sop;
   wire [0:5] 	     w_inst_dev;
   wire [0:8] 	     w_inst_shftcnt;
   wire [0:3] 	     w_inst_shftop;
   
      
   assign w_inst_op  = r_inst[0:4];
   assign w_inst_i   = r_inst[5];
   assign w_inst_adr = r_inst[6:17];
   assign w_inst_w   = r_inst[5];
   assign w_inst_p   = r_inst[6];
   assign w_inst_sop = r_inst[7:11];
   assign w_inst_dev = r_inst[12:17];
   assign w_inst_shftcnt = r_inst[9:17];
   assign w_inst_shftop  = r_inst[5:8];
   
   wire [0:5] 	     w_din_op;
   wire 	     w_din_i;
   wire [0:12] 	     w_din_adr;

   assign w_din_op  = mm_din[0:4];
   assign w_din_i   = mm_din[5];
   assign w_din_adr = mm_din[6:17];
   
   // Sequence Break System
   wire [0:11] 	     sb_sav_pc;
   wire [0:11] 	     sb_sav_ac;
   wire [0:11] 	     sb_sav_io;
   wire [0:11] 	     sb_sav_jmp;
   wire 	     sb_intr;
   wire [0:5] 	     sb_sqb;
   
   
   assign sb_intr = |sb_ireq;
      
   generate
      if(sbs_model == "") begin
	 assign sb_intr = 0;
      end
      else begin
	 assign sb_intr = |sb_ireq;
      end
   endgenerate

   pdp1_sbs_decoder #(sbs_model) sbs_dec(.sb_ireq1(sb_ireq[0]), 
					 .sb_ireq2(sb_ireq[1]), 
					 .sb_ireq3(sb_ireq[2]), 
					 .sb_ireq4(sb_ireq[3]),
					 .sav_ac(sb_sav_ac), 
					 .sav_io(sb_sav_io), 
					 .sav_pc(sb_sav_pc), 
					 .sav_jmp(sb_sav_jmp));

   wire [0:17] 	     opr_ac;
   wire [0:17] 	     opr_io;
   wire [0:5] 	     opr_pf;
      
   pdp1_opr_decoder #(pdp_model) odecode(.op_i(w_inst_i), 
					 .op_mask(w_inst_adr), 
					 .op_ac(r_AC), 
					 .op_io(r_IO), 
					 .op_pf(r_PF), 
					 .op_tw(sw_tw), 
					 .op_r_ac(opr_ac), 
					 .op_r_io(opr_io), 
					 .op_r_pf(opr_pf));

   wire 	     w_alu_op;
   wire [0:17] 	     w_alu_result;
   wire 	     w_alu_ovfl;
      
   pdp1_alu alu(.al_op(w_inst_op), 
		.al_a(r_AC), 
		.al_b(mm_din), 
		.al_r(w_alu_result), 
		.al_ovfl(w_alu_ovfl),
		.al_w(w_alu_op));

   wire 	     w_write_op;
   wire [0:17]	     w_write_data;
   
   
   pdp1_write_decoder ddecode(.ma_op(w_inst_op), 
			      .ma_ac(r_AC), 
			      .ma_io(r_IO), 
			      .ma_cd(mm_din), 
			      .ma_w(w_write_op), 
			      .ma_r(w_write_data));


   wire 	     w_skip;
   pdp1_skp_decoder #(pdp_model) sdecode(.sk_mask(w_inst_adr),
					 .sk_i(w_inst_i),
					 .sk_ac(r_AC), 
					 .sk_io(r_IO), 
					 .sk_ov(r_OV), 
					 .sk_sw(sw_sn), 
					 .sk_pf(r_PF), 
					 .sk_skp(w_skip));

   wire [0:17] 	     w_shrot_io;
   wire [0:17] 	     w_shrot_ac;
   wire 	     w_shrot_dir = w_inst_shftop[0];
   wire 	     w_shrot_rot = ~w_inst_shftop[1];
            
   pdp1_shrot ioshrot(.sh_cnt(w_inst_shftcnt),
		      .sh_dir(w_shrot_dir), 
		      .sh_rot(w_shrot_rot), 
		      .sh_d(r_IO), 
		      .sh_q(w_shrot_io));
   
   pdp1_shrot acshrot(.sh_cnt(w_inst_shftcnt), 
		      .sh_dir(w_shrot_dir), 
		      .sh_rot(w_shrot_rot), 
		      .sh_d(r_AC), 
		      .sh_q(w_shrot_ac));
      
   wire 	     w_intrisic_io;

   assign bs_dout = r_IO;
   assign bs_adr  = {w_inst_dev|w_inst_sop};
   assign bs_wait = w_inst_w|w_inst_p;
   		   
   reg [0:2] r_state;
   localparam SFETCH1 = 3'b000;
   localparam SFETCH2 = 3'b001;
   localparam SINDIR  = 3'b010;
   localparam SEXEC   = 3'b011;

   localparam SIEX1   = 3'b100; // (save IO) Interrupt exchange 
   localparam SIEX2   = 3'b101; // (save AC)
   localparam SHALT   = 3'b110;
   
   reg 	     r_cntrl_stop;
   wire      w_wrap_stop;
   assign w_wrap_stop = cntrl_halt | cntrl_stop | r_cntrl_stop;
   assign cntrl_paused = (r_state == SHALT);
            
   always @(posedge i_clk) begin
      if(i_rst) begin
	 r_PC <= start_addr; 
	 r_PCU <= 0;
	 r_AC <= 0;
	 r_IO <= 0;
	 r_OV <= 0;
	 r_PF <= 0;
	 r_EXTM <= 0;
	 r_IOP <= 0;
	 r_IOH <= 0;
	 
	 mm_dout <= 0;
	 mm_adr <= 0;
	 mm_unit <= 0;
	 mm_we <= 0;
	 
	 sb_disarm <= 0;

	 cntrl_reason <= 0;
	 
	 r_state <= SFETCH1;
	 r_cntrl_stop <= 0;
      end
      else begin
	 case(r_state)
	   SFETCH1:
	     begin
		$display("%o  %b  %o %o %o %o", 
			 r_PC-1, r_OV, r_AC, r_IO, r_PF, w_inst_op);
		sb_disarm <= 1'b0;
		if(w_wrap_stop) begin
		   mm_we <= 1'b0;
		   r_state <= SHALT;
		end
		else if(sb_intr) begin
		   mm_we <= 1'b1;
		   mm_adr <= sb_sav_pc;
		   mm_dout <= {r_OV, r_EXTM, r_PCU, r_PC};
		   r_state <= SIEX1;
		   r_EXTM <= 0;
		   mm_unit <= 0;
		end
		else begin
		   mm_we <= 1'b0;
		   mm_adr <= r_PC;
		   r_state <= SFETCH2;
		end
	     end // case: SFETCH1
	   SFETCH2:
	     begin
		r_inst <= mm_din;
		mm_adr <= w_din_adr;
		r_state <= (w_din_i & (w_din_op != `PDP1_OP_LAW &
				       w_din_op != `PDP1_OP_CAL &
				       w_din_op != `PDP1_OP_SFT &
				       w_din_op != `PDP1_OP_OPR &
				       w_din_op != `PDP1_OP_SKP &
				       w_din_op != `PDP1_OP_IOT)) ? 
			   SINDIR : SEXEC;
		r_PC = r_PC +1;
	     end
	   SINDIR:
	     begin
		if(cntrl_halt) begin
		   r_PC = r_PC-1;
		   r_state <= SFETCH1;
		end
		if(r_EXTM) begin
		   {mm_unit, mm_adr} <= mm_din;
		   r_state <= SEXEC;
		end
		else begin
		   if(w_din_i)
		     mm_adr <= w_din_adr;
		   else
		     r_state <= SEXEC;
		end
	     end
	   SIEX1:
	     begin
		mm_adr <= sb_sav_io;
		mm_dout <= r_IO;
		r_state <= SIEX2;
	     end
	   SIEX2:
	     begin
		mm_adr <= sb_sav_ac;
		mm_dout <= r_AC;
		r_PC <= sb_sav_jmp;
		r_state <= SFETCH1;
		sb_disarm <= 1'b1;
	     end
	   SEXEC:
	     begin
		r_state = SFETCH1;
		if(w_alu_op) begin
		   r_AC <= w_alu_result;
			   
		   if(w_inst_op == `PDP1_OP_IDX | 
		      w_inst_op == `PDP1_OP_ISP) begin
		      mm_we <= 1'b1;
		      mm_dout <= w_alu_result;
		      
		      if(w_inst_op == `PDP1_OP_ISP & ~w_alu_result[0])
			r_PC = r_PC + 1;
		   end
		   else
		     r_OV = (r_OV | w_alu_ovfl);
		end // if (w_alu_op)
		else if(w_write_op) begin
		   mm_dout <= w_write_data;
		   mm_we <= 1'b1;

		   if(w_inst_op == `PDP1_OP_CAL) begin
		      if(w_inst_i) begin
			 r_AC <= r_PC;
			 r_PC <= mm_adr+1;			     
		      end
		      else begin
			 mm_adr <= 12'o100;
			 r_AC <= r_PC;
			 r_PC <= 12'o101;			     
		      end
		   end
		end // if (w_write_op)
		else if(w_inst_op == `PDP1_OP_SKP) begin
		   if(w_skip)
		     r_PC = r_PC+1;
		   r_OV = w_inst_adr[2] ? 1'b0 : r_OV;
		end
		else if(w_inst_op == `PDP1_OP_IOT) begin
		   $display("IOT %o (%o) P=%b W=%b", w_inst_dev, w_inst_sop,
			    w_inst_p, w_inst_w);
		   
		   if(~(|{w_inst_sop, w_inst_dev}) | r_IOH) begin // IOT 0000
		      if(r_IOP | ~bs_inh) begin
			 r_IOH <= 1'b0;
			 r_IOP <= 1'b0;
			 r_state = SFETCH1;
			 bs_stb <= 1'b0;
		      end
		      else
			r_state = SEXEC;
		      
		   end
		   else if(w_inst_w & ~r_IOH) begin
		      r_IOP <= 1'b0;
		      r_IOH <= 1'b1;
		      r_state = SEXEC;
		      bs_stb <= 1'b1;
		   end
		end // if (w_inst_op == `PDP1_OP_IOT)
		else if(w_inst_op == `PDP1_OP_SFT) begin
		   if(w_inst_shftop[3]) // 1&3
		     r_AC <= w_shrot_ac;
		   if(w_inst_shftop[2]) // 2&3
		     r_IO <= w_shrot_io;
//		   $display("SFT %b %o %o",
//			    w_inst_shftop[2:3], w_shrot_ac, w_shrot_io);
		   
		end
		else begin
		   case(w_inst_op)
		     `PDP1_OP_XCT:
		       begin
			  r_inst <= mm_din;
			  r_state = SEXEC;
		       end
		     `PDP1_OP_LAC:
		       r_AC <= mm_din;
		     `PDP1_OP_LIO:
		       r_IO <= mm_din;
		     //TAD
		     `PDP1_OP_SAD:
		       begin
			  if(r_AC != mm_din)
			    r_PC = r_PC + 1;
		       end
		     `PDP1_OP_SAS:
		       begin
			  if(r_AC == mm_din)
			    r_PC = r_PC + 1;		     
		       end
		     // MUL, DIV
		     `PDP1_OP_JMP:
		       r_PC = w_inst_adr;
		     `PDP1_OP_JSP:
		       begin
			  r_PC <= w_inst_adr;
			  r_AC <= r_PC;
		       end
		     `PDP1_OP_OPR:
		       begin
			  if(w_inst_adr[3]) begin
			     r_cntrl_stop <= 1'b1;
			     cntrl_reason <= 2'b01;
			  end
			  r_AC <= opr_ac;
			  r_IO <= opr_io;
			  r_PF <= opr_pf;
		       end
		     `PDP1_OP_LAW:
		       r_AC <= (w_inst_i) ? ~w_inst_adr : w_inst_adr;
		     `PDP1_OP_CAL:
		       begin
			  if(w_inst_i) begin //JDA
			     mm_we <= 1'b1;
			     mm_dout <= r_AC;
			     r_AC <= r_PC;
			     r_PC <= w_inst_adr+1;			     
			  end
			  else begin //CAL
			     mm_adr <= 12'o100;
			     mm_we <= 1'b1;
			     mm_dout <= r_AC;
			     r_AC <= r_PC;
			     r_PC <= 12'o101;
			  end
		       end // case: `PDP1_OP_CAL
		     default:
		       begin
			  $display("Unknown OP=(%o %b %o) PC=%o", 
				   w_inst_op, w_inst_i, w_inst_adr, mm_adr, r_PC-1);
			  r_cntrl_stop <= 1;
			  cntrl_reason <= 2'b10;
			  $finish();
			  
		       end
		   endcase // case (w_inst_op)
		end // else: !if(w_alu_op)	
	     end
	   SHALT:
	     begin
		$display("%m Stopped! PC=%o %b", r_PC, cntrl_reason);
	     end
	 endcase // case (r_state)
      end
   end // always @ (posedge i_clk)
   
endmodule // pdp1_cpu

