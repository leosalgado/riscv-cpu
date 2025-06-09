`timescale 1ps/1ps
`include "uc.v"

module uc_tb;

    reg [6:0] opcode;
    wire [1:0] alu_op;
    wire mem_read;
    wire mem_write;
    wire reg_write;
    wire mem_to_reg;
    wire alu_src;
    wire branch;

    uc uut (opcode, alu_op, mem_read, mem_write, reg_write, mem_to_reg, alu_src, branch);

    initial begin
        
        $dumpfile("waveforms/uc_tb.vcd");
        $dumpvars(0, uc_tb);

        opcode = 7'b0000000;
        #10;

        opcode = 7'b0000011;
        #10;

        opcode = 7'b0100011;
        #10;

        opcode = 7'b1100011;
        #10;

        opcode = 7'b0110011;
        #10;

        opcode = 7'b1111111;
        #10;

        $display("Teste Completo");

    end

endmodule
