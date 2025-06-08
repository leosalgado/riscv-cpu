`timescale 1ps/1ps
`include "ula.v"

module ula_tb ;

    reg [31:0] A, B;
    reg [3:0] UlaOp;
    wire [31:0] S;

    ula uut(A, B, UlaOp, S);

    initial begin
        
        $dumpfile("waveforms/ula_tb.vcd");
        $dumpvars(0, ula_tb);

        A = 32'd20; B= 32'd12;
        UlaOp = 4'b0000; #20
        UlaOp = 4'b0001; #20
        UlaOp = 4'b0010; #20
        UlaOp = 4'b0110; #20
        UlaOp = 4'b1111; #20

        $display("Teste Completo");

    end

endmodule
