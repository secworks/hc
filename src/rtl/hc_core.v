//======================================================================
//
// hc_core.v
// ---------
// Hardware implementation of the HC stream cipher.
//
//
// Author: Joachim Strombergson
// Copyright (c) 2017, Assured AB
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or
// without modification, are permitted provided that the following
// conditions are met:
//
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in
//    the documentation and/or other materials provided with the
//    distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
// COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//======================================================================

module hc_core (
                input wire           clk,
                input wire           reset_n,

                input wire           init,
                input wire           next,
                output wire          ready,

                input wire [127 : 0] iv,
                input wire [127 : 0] key,
                input wire           keylen,

                output wire [32 : 0] result,
                output wire          result_valid
               );


  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  localparam CTRL_IDLE = 3'h0


  //----------------------------------------------------------------
  // Internal functions.
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

  function [31 : 0] h1(input [31 : 00] x);
    begin
      h1 = Q[{1'b0, x[7 : 0]}] + Q[{1'b1, x[23 : 16]}];
    end
  endfunction // h1

  function [31 : 0] h1(input [31 : 00] x);
    begin
      h2 = P[{1'b0, x[7 : 0]}] + P[{1'b1, x[23 : 16]}];
    end
  endfunction // h2


  //----------------------------------------------------------------
  // Registers
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
  reg          update_s;

  reg          s_valid_reg;
  reg          s_valid_new;
  reg          s_valid_we;

  reg [9 : 0]  i_ctr_reg;
  reg [9 : 0]  i_ctr_new;
  reg          i_ctr_inc;
  reg          i_ctr_rst;
  reg          i_ctr_we;

  reg [2 : 0]  hc_core_ctrl_reg;
  reg [2 : 0]  hc_core_ctrl_new;
  reg          hc_core_ctrl_we;


  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  reg update_state;
  reg init_mode;


  //----------------------------------------------------------------
  // Asssignmengts to ports.
  //----------------------------------------------------------------
  assign result       = s_reg;
  assign result_valid = s_valid_reg;


  //----------------------------------------------------------------
  // reg_update
  //
  // Update functionality for all registers in the core.
  // All registers are positive edge triggered with asynchronous
  // active low reset.
  //----------------------------------------------------------------
  always @ (posedge clk or negedge reset_n)
    begin : reg_update
      if (!reset_n)
        begin
          i_ctr_reg   <= 10'h0;
          s_reg       <= 32'h0;
          s_valid_reg <= 0;
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
  // state_update
  //
  // Logic for updating the state tables P and Q.
  //----------------------------------------------------------------
  always @*
    begin : state_update
      reg  [8 : 0] j_000;
      reg  [8 : 0] j_003;
      reg  [8 : 0] j_010;
      reg  [8 : 0] j_511;

      reg [31 : 0] P_000;
      reg [31 : 0] P_002;
      reg [31 : 0] P_010;
      reg [31 : 0] P_511;

      reg [31 : 0] Q_000;
      reg [31 : 0] Q_002;
      reg [31 : 0] Q_010;
      reg [31 : 0] Q_511;

      // TODO: These indices are quite probably wrong. Fix.
      j_000 = i_reg[8 : 0];
      j_003 = i_reg[8 : 0] - 3;
      j_010 = i_reg[8 : 0] - 10;
      j_511 = i_reg[8 : 0] - 511;

      P_addr = i_reg[8 : 0];
      Q_addr = i_reg[8 : 0];

      P_000 = P[j_000];
      P_003 = P[j_003];
      P_010 = P[j_010];
      P_511 = P[j_511];

      Q_000 = Q[j_000];
      Q_003 = Q[j_003];
      Q_010 = Q[j_010];
      Q_511 = Q[j_511];

      P_new = P_000 + g1(P_003, P_010, P_511)
      Q_new = Q_000 + g2(Q_003, Q_010, Q_511)

      if (update)
        begin
          if (init_mode)
            begin
              // Init update.
            end
          else
            begin
              // Normal update.
              Q_we = i_ctr_reg[9];
              P_we = ~i_ctr_reg[9];
            end
        end
    end // block: state_update


  //----------------------------------------------------------------
  // s_generate
  //
  // The keystream word s generation logic.
  //----------------------------------------------------------------
  always @*
    begin : s_generate
      reg  [8 : 0] j_000;
      reg  [8 : 0] j_012;

      reg [31 : 0] P_000;
      reg [31 : 0] P_012;

      reg [31 : 0] Q_000;
      reg [31 : 0] Q_012;

      // TODO: These indices are quite probably wrong. Fix.
      j_000 = i_reg[8 : 0];
      j_010 = i_reg[8 : 0] - 12;

      P_000 = P[j_000];
      P_511 = P[j_511];

      Q_000 = Q[j_000];
      Q_012 = Q[j_012];

      P_new = P_000 + g1(P_003, P_010, P_511)
      Q_new = Q_000 + g2(Q_003, Q_010, Q_511)

      s_we = 1'b0;

      if (update_s)
        begin
          s_we = 1'b1;

          if (i_ctr_reg[9])
            s_new = h2(Q_012) ^ Q_000;
          else
            s_new = h1(P_012) ^ P_000;
        end
    end


  //----------------------------------------------------------------
  // i_ctr
  //
  // Monotonically increasing iteration counter with reset.
  //----------------------------------------------------------------
  always @*
    begin : i_ctr
      i_ctr_new = 10'h0;
      i_ctr_we  = 0;

      if (i_ctr_rst)
          i_ctr_we  = 1;

      if (i_ctr_inc)
        begin
          i_ctr_new = i_ctr_reg + 1'b1;
          i_ctr_we  = 1;
        end
    end


  //----------------------------------------------------------------
  // hc_ctrl
  //
  // Control FSM for the core.
  //----------------------------------------------------------------
  always @*
    begin : hc_ctrl
      update_s         = 0;
      update_state     = 0;
      init_mode        = 0;
      i_ctr_rst        = 0;
      i_ctr_inc        = 0;
      s_valid_new      = 0;
      s_valid_we       = 0;
      hc_core_ctrl_new = CTRL_IDLE;
      hc_core_ctrl_we  = 0;

      case (hc_core_ctrl_reg)
        CTRL_IDLE:
          begin
          end

        default:
          begin
          end
      endcase // case (hc_core_ctrl_reg)

    end

endmodule // hc_core

//======================================================================
// EOF hc_core.v
//======================================================================
