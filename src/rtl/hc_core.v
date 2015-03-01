module hc_core (
                input wire clk,
                input wire reset_n,

                input wire [127 : 0] key,
                input wire [127 : 0] iv,

                input wire           init,
                input wire           next,

                output wire [32 : 0] keystream_data,
                output wire [32 : 0] keystream_valid
               );

  //----------------------------------------------------------------
  //----------------------------------------------------------------
  reg [31 : 0] P [0 : 511];
  reg [31 : 0] P_new;
  reg          P_we;

  reg [31 : 0] Q [0 : 511];
  reg [31 : 0] Q_new;
  reg          Q_we;


  //----------------------------------------------------------------
  //----------------------------------------------------------------
  assign keystram_data = 32'h00000000;
  assign keystram_vali = 1'b0;

  //----------------------------------------------------------------
  //----------------------------------------------------------------
  always @ (posedge clk)
    begin
      if (reset_n = 0)
        begin

        end
      else
        begin

        end
    end


  //----------------------------------------------------------------
  //----------------------------------------------------------------
  always @*

endmodule // hc_core
