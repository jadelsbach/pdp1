module tb;
   reg clk = 0;
   reg rst = 1;

   wire mm_we;
   wire [0:11] mm_adr;
   wire [0:17] mm_din;
   wire [0:17] mm_dout;
   wire [0:3]  mm_unit;

   reg [0:5]   sw_sn = 6'b0;
   reg [0:17]  sw_tw = 18'o777777;
   reg        cntrl_stop = 0;
   reg 	      cntrl_halt = 0;
   wire       cntrl_paused;
   wire [0:1] cntrl_reason;
   reg 	      cntrl_resume = 0;

   wire        intr_disarm;

   wire        bs_stb;
   wire [0:10] bs_adr;
   wire        bs_wait;
   wire [0:17] bs_din;
   wire [0:17] bs_dout;
   wire        bs_inh;
   
   
   always #10 clk = ~clk;
   
   pdp1_memory mem(clk, rst,
		   mm_we, mm_adr, mm_din, mm_dout);
   pdp1_cpu cpu(clk, rst, 
		mm_we, mm_adr, mm_unit, mm_din, mm_dout,
		bs_stb, bs_adr, bs_wait, bs_din, bs_dout, bs_inh,
		sw_sn, sw_tw,
		cntrl_stop, cntrl_halt, cntrl_paused, 
		cntrl_resume, cntrl_reason, 4'b0000, intr_grant);

   always @(posedge clk)
     if(cntrl_paused)
       $finish();
   

   initial begin
      $dumpfile("pdp1.vcd");
      $dumpvars(0, cpu);
      $dumpvars(0, mem);
      #100 rst = 0;
      
      
      #1000000000 $finish();
   end
   
endmodule // tb
