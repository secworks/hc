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
          s_reg       <= 32'h00000000;
          s_valid_reg <= 1'b0;
        end
      else
        begin
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
    begin : hc_ctrl
      update    = 1'b0;
      init_mode = 1'b0;
    end


endmodule // hc_core

//======================================================================
// EOF hc_core.v
//======================================================================
