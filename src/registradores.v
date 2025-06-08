module registradores(rs1, rs2, rd, wr_data, wr, read1, read2);

    input [4:0] rs1;
    input [4:0] rs2;
    input [4:0] rd;
    input [31:0] wr_data;
    input wr;
    output [31:0] read1;
    output [31:0] read2;

    reg [31:0] registradores[0:31];

    always @(posedge wr) begin
        if (wr) begin
            // Condição para evitar escrita no registrador 0 (x0 em RISC-V), que é hardwired para zero
            if (rd != 5'h0) begin
                registradores[rd] <= wr_data; // Escreve o dado 'wr_data' no registrador 'rd'
            end
        end
    end

    assign read1 = (rs1 == 5'h0) ? 32'h0 : registradores[rs1];
    assign read2 = (rs2 == 5'h0) ? 32'h0 : registradores[rs2];

endmodule