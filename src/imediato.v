module imediato (instrucao, imediato_out);

    input [31:0] instrucao;
    output [31:0] imediato_out;

    wire [6:0] opcode = instrucao[6:0];
    wire [2:0] funct3 = instrucao[14:12];

    reg [31:0] temp_imediato;

    always @(*) begin
        
        case(opcode)

            7'b0000011: begin // I-type
                temp_imediato = {{20{instrucao[31]}}, instrucao[31:20]};
            end

            7'b0100011: begin // S-type
                temp_imediato = {{20{instrucao[31]}}, instrucao[31:25], instrucao[11:7]};
            end

            7'b1100011: begin // B-type
                temp_imediato = {{20{instrucao[31]}}, instrucao[31], instrucao[7], instrucao[30:25], instrucao[11:8], 1'b0};
            end

            7'b0110011: begin // R-type
                temp_imediato = 32'h0;
            end

            default: begin
                temp_imediato = 32'h0;
            end

        endcase

    end

    assign imediato_out = temp_imediato;

endmodule
