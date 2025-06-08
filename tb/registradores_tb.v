`timescale 1ps/1ps
`include "registradores.v"

module registradores_tb;

    reg [4:0] rs1;
    reg [4:0] rs2;
    reg [4:0] rd;
    reg [31:0] wr_data;
    reg wr;
    wire [31:0] read1;
    wire [31:0] read2;

    registradores uut(rs1, rs2, rd, wr_data, wr, read1, read2);

    initial begin
        
        $dumpfile("waveforms/registradores_tb.vcd");
        $dumpvars(0, registradores_tb);

        rs1 = 5'd0;       
        rs2 = 5'd0;       
        rd  = 5'd0;       
        wr_data = 32'h0;  
        wr = 1'b0;        
        #10;

        rd      = 5'd10;         
        wr_data = 32'hAAAABBBB;  
        wr      = 1'b1;          
        #10;                     
        wr      = 1'b0;

        rs1 = 5'd10;             
        rs2 = 5'd20;             
        #10; 

        rd      = 5'd20;         
        wr_data = 32'hCCCCDDDD;   
        wr      = 1'b1;          
        #10;                     
        wr      = 1'b0;

        rs1 = 5'd0;              
        rs2 = 5'd20;             
        #10;

        $display("Teste Completo");

    end

endmodule
