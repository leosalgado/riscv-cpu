`timescale 1ps/1ps
`include "uc.v"

module uc_tb;

    reg [3:0] opcode;
    wire [1:0] alu_op;
    wire mem_read;
    wire mem_write;

    uc uut(opcode, alu_op, mem_read, mem_write);

    initial begin

        $dumpfile("waveforms/uc_tb.vcd");
        $dumpvars(0, uc_tb);

        opcode = 4'b0000; #20 // ADD
        opcode = 4'b0001; #20 // SUB
        opcode = 4'b0010; #20 // LOAD
        opcode = 4'b0011; #20 // STORE
        opcode = 4'b0100; #20 // DEFAULT (invalid opcode)

        $display("Teste Completo");

    end

endmodule

