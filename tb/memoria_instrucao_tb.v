`timescale 1ps/1ps
`include "memoria_instrucao.v"

module memoria_instrucao_tb ;

    reg [7:0] endereco;
    wire [31:0] dado;

    memoria_instrucao uut(endereco, dado);

    initial begin

        $dumpfile("waveforms/memoria_instrucao_tb.vcd");
        $dumpvars(0, memoria_instrucao_tb);

        endereco[0] = 32'h001101B3;
        endereco[1] = 32'd12;
        endereco[2] = 32'h5fd3;

        $display("Teste Completo");

    end

endmodule
