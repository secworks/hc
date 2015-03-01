//======================================================================
//
// hc_core.v
// ---------
// Hardware implementation of the HC stream cipher.
//
//
// Author: Joachim Strömbergson
//
//======================================================================

module hc_core (
                input wire           clk,
                input wire           reset_n,

                input wire [127 : 0] key,
                input wire [127 : 0] iv,

                input wire           init,
                input wire           next,

                output wire [32 : 0] s,
                output wire          s_valid
               );


  //----------------------------------------------------------------
  //----------------------------------------------------------------
  function [31 : 0] f1(input [31 : 00] x);
    begin
      f1 = {x[06 : 00], x[31 : 07]} ^
           {x[17 : 00], x[31 : 18]} ^
           {x[02 : 00], x[31 : 03]};
    end
  endfunction // f1


  function [31 : 0] f2(input [31 : 00] x);
    begin
      f2 = {x[16 : 00], x[31 : 17]} ^
           {x[18 : 00], x[31 : 19]} ^
           {x[09 : 00], x[31 : 10]};
    end
  endfunction // f2


  function [31 : 0] g1(input [31 : 00] x,
                       input [31 : 00] y
                       input [31 : 00] z);
    begin
      g1 = {x[09 : 00], x[31 : 10]} ^
           {y[22 : 00], y[31 : 23]} ^
           {z[07 : 00], z[31 : 08]};
    end
  endfunction // g1


  function [31 : 0] g2(input [31 : 00] x,
                       input [31 : 00] y
                       input [31 : 00] z);
    begin
      g2 = {x[22 : 00], x[31 : 23]} ^
           {y[09 : 00], y[31 : 10]} ^
           {z[24 : 00], z[31 : 25]};
    end
  endfunction // g2


  //----------------------------------------------------------------
  //----------------------------------------------------------------
  reg [31 : 0] P [0 : 511];
  reg [31 : 0] P_new;
  reg  [8 : 0] P_addr;
  reg          P_we;

  reg [31 : 0] Q [0 : 511];
  reg [31 : 0] Q_new;
  reg  [8 : 0] Q_addr;
  reg          Q_we;

  reg [31 : 0] s_reg;
  reg [31 : 0] s_new;
  reg          s_we;

  reg          s_valid_reg;
  reg          s_valid_new;
  reg          s_valid_we;

  reg [9 : 0]  i_ctr_reg;
  reg [9 : 0]  i_ctr_new;
  reg          i_ctr_inc;
  reg          i_ctr_rst;
  reg          i_ctr_we;


  //----------------------------------------------------------------
  //----------------------------------------------------------------
  reg update;
  reg init_mode;


  //----------------------------------------------------------------
  //----------------------------------------------------------------
  assign s       = s_reg;
  assign s_valid = s_valid_reg;


  //----------------------------------------------------------------
  //----------------------------------------------------------------
  always @ (posedge clk)
    begin
      if (reset_n = 0)
        begin
          i_ctr_reg   <= 10'h000;
          s_reg       <= 32'h00000000;
          s_valid_reg <= 1'b0;
        end
      else
        begin
          if (i_ctr_we)
            i_ctr_reg <= i_ctr_new;

          if (P_we)
            P[P_addr] <= P_new;

          if (Q_we)
            Q[Q_addr] <= Q_new;

          if (s_we)
            s_reg <= s_new;

          if (s_valid_we)
            s_valid_reg <= s_valid_new;
        end
    end


  //----------------------------------------------------------------
  //----------------------------------------------------------------
  always @*
    begin : cipher_update
      reg  [8 : 0]  j;
      reg  [31 : 0] j_0;
      reg  [31 : 0] j_3;
      reg  [31 : 0] j_10;
      reg  [31 : 0] j_511;

      j = i_reg[8 : 0];

      if (update)
        if (init_mode)
          begin

          end
        else
          begin

          end
    end


  //----------------------------------------------------------------
  //----------------------------------------------------------------
  always @*
    begin : i_ctr
      i_ctr_new = 10'h000;
      i_ctr_we  = 1'b0;

      if (i_ctr_rst)
        begin
          i_ctr_new = 10'h000;
          i_ctr_we  = 1'b1;
        end

      if (i_ctr_inc)
        begin
          i_ctr_new = i_ctr_reg + 1'b1;
          i_ctr_we  = 1'b1;
        end
    end


  //----------------------------------------------------------------
  //----------------------------------------------------------------
  always @*
    begin : hc_ctrl
      update    = 1'b0;
      init_mode = 1'b0;
      i_ctr_rst = 1'b0;
      i_ctr_inc = 1'b0;
    end

endmodule // hc_core

//======================================================================
// EOF hc_core.v
//======================================================================
