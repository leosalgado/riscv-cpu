`timescale 1ps/1ps
`include "memoria_dados.v"

module memoria_dados_tb;

    reg [31:0] rs;
    reg [31:0] wd;
    reg wr;
    wire [31:0] rd;

    memoria_dados uut(rs, wd, wr, rd);
    initial begin

        $dumpfile("waveforms/memoria_dados_tb.vcd");
        $dumpvars(0, memoria_dados_tb);

        rs = 32'd0;         
        wd = 32'hFEEDF00D;  
        wr = 1'b1;          
        #20;                
        wr = 1'b0; 

        rs = 32'd1;         
        wd = 32'hBEEFCAFE;  
        wr = 1'b1;          
        #20;                
        wr = 1'b0;

        rs = 32'd0;
        #20;

        rs = 32'd1;
        #20;

        $display("Teste Completo");

    end

endmodule
