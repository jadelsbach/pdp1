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

`define PDP1_OP_AND 5'o01
`define PDP1_OP_IOR 5'o02
`define PDP1_OP_XOR 5'o03
`define PDP1_OP_XCT 5'o04 // Appendix
//`define PDP1_OP_LCH 5'o05 // PDP-1D
//`define PDP1_OP_DCH 5'o06 // PDP-1D
`define PDP1_OP_CAL 5'o07 // Also JDA Appendix
`define PDP1_OP_LAC 5'o10
`define PDP1_OP_LIO 5'o11
`define PDP1_OP_DAC 5'o12
`define PDP1_OP_DAP 5'o13
`define PDP1_OP_DIP 5'o14
`define PDP1_OP_DIO 5'o15
`define PDP1_OP_DZM 5'o16 // Appendix
//`define PDP1_OP_TAD 5'o17 // PDP-1D
`define PDP1_OP_ADD 5'o20
`define PDP1_OP_SUB 5'o21
`define PDP1_OP_IDX 5'o22
`define PDP1_OP_ISP 5'o23
`define PDP1_OP_SAD 5'o24
`define PDP1_OP_SAS 5'o25
`define PDP1_OP_MUL 5'o26 // MUS
`define PDP1_OP_DIV 5'o27 // DIS
`define PDP1_OP_JMP 5'o30
`define PDP1_OP_JSP 5'o31 
`define PDP1_OP_SKP 5'o32
`define PDP1_OP_SFT 5'o33
`define PDP1_OP_LAW 5'o34
`define PDP1_OP_IOT 5'o35
//`define PDP1_OP_SPO 5'o36 // PDP-1D
`define PDP1_OP_OPR 5'o37

`define PDP1_SOP_RAL 4'o01
`define PDP1_SOP_RIL 4'o02
`define PDP1_SOP_RCL 4'o03
`define PDP1_SOP_SAL 4'o05
`define PDP1_SOP_SIL 4'o06
`define PDP1_SOP_SCL 4'o07
`define PDP1_SOP_RAR 4'o11
`define PDP1_SOP_RIR 4'o12
`define PDP1_SOP_RCR 4'o13
`define PDP1_SOP_SAR 4'o15
`define PDP1_SOP_SIR 4'o16
`define PDP1_SOP_SCR 4'o17
