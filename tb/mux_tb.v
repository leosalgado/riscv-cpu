`timescale 1ps/1ps
`include "mux.v"

module mux_tb ;

    reg [31:0] in0;
    reg [31:0] in1;
    reg sel;

    wire [31:0] out;

    mux uut (in0, in1, sel, out);

    initial begin
        
        $dumpfile("waveforms/mux_tb.vcd");
        $dumpvars(0, mux_tb);

        in0 = 32'hAAAA0000;
        in1 = 32'hBBBB1111;
        sel = 1'b0; 
        #10;

        sel = 1'b1; 
        #10;

        in0 = 32'hCCCC2222;
        in1 = 32'hDDDD3333;
        #10; 

        sel = 1'b0; 
        #10;

        $display("Teste Completo");

    end

endmodule
