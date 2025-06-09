`timescale 1ps/1ps
`include "imediato.v"

module imediato_tb ;

    reg [31:0] instrucao;
    wire [31:0] imediato_out;

    imediato uut (instrucao, imediato_out);

    initial begin
        
        $dumpfile("waveforms/imediato_tb.vcd");
        $dumpvars(0, imediato_tb);

        instrucao = 32'h0;
        #10;

        instrucao = 32'h0001210B;
        instrucao = 32'h0123000B;
        instrucao = 32'h01230000 | 7'b0000011;
        #10;

        instrucao = {5'b10101, 5'h0, 5'h0, 3'h0, 5'b11100, 7'b0100011};
        #10;

        instrucao = {1'b0, 6'b110111, 5'h0, 5'h0, 3'h0, 4'b1110, 1'b0, 7'b1100011};
        #10;

        instrucao = {1'b0, 6'b110111, 5'd2, 5'd1, 3'h0, 4'b1110, 1'b0, 7'b1100011};
        #10;

        instrucao = 32'h00310133; 
        #10;

        $display("Teste Completo");

    end

endmodule
