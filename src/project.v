/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
module tt_um_addermultiplier(
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
    wire [3:0] adder_output;
    wire [5:0] multiplier_output;

    // 3-bit Kogge-Stone Adder
    kogge_stone_adder_3bit adder_inst(
        .A(ui_in[2:0]),
        .B(ui_in[5:3]),
        .Sum_Carry(adder_output)
    );

    // 3-bit Array Multiplier
    array_multiplier_3bit multiplier_inst(
        .A(ui_in[2:0]),
        .B(ui_in[5:3]),
        .Product(multiplier_output)
    );

    // Output Selection: ui_in[6] = 1 for Adder, 0 for Multiplier
    assign uo_out[5:0] = ui_in[6] ? {2'b00, adder_output} : multiplier_output;
    assign uo_out[7:6] = 2'b00;

    // Unused IOs
    assign uio_out =0;
    assign uio_oe  =0;

    // Prevent unused signal warnings
    wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule



// ----------------- 3-BIT KOGGE-STONE ADDER -----------------
module kogge_stone_adder_3bit (
    input  wire [2:0] A, B,
    output wire [3:0] Sum_Carry  // {Cout, Sum[2:0]}
);
    wire [2:0] G, P, C;
    wire [2:0] sum;
    wire cout;

    // Generate and Propagate signals
    assign G = A & B;
    assign P = A ^ B;

    // Carry Computation
    wire G1_0 = G[1] | (P[1] & G[0]);
    wire P1_0 = P[1] & P[0];

    wire G2_0 = G[2] | (P[2] & G1_0);

    assign C[0] = 1'b0;
    assign C[1] = G[0];
    assign C[2] = G1_0;
    assign cout = G2_0;

    // Sum Calculation
    assign sum = P ^ C;

    // Assign Outputs
    assign Sum_Carry = {cout, sum};

endmodule

// ----------------- Array Multiplier (3-bit x 3-bit) -----------------
module array_multiplier_3bit (
    input wire [2:0] A,    
    input wire [2:0] B,    
    output wire [5:0] Product  
);
    wire [2:0] pp0, pp1, pp2;
    wire [5:0] sum1, sum2;

    assign pp0 = A[0] ? B : 3'b000;
    assign pp1 = A[1] ? B : 3'b000;
    assign pp2 = A[2] ? B : 3'b000;

    assign sum1 = {2'b00, pp0} + {pp1, 1'b0};
    assign sum2 = sum1 + {pp2, 2'b00};

    assign Product = sum2;
    
endmodule
