module memoria_instrucao(endereco, dado);

    input [7:0] endereco;
    output reg [31:0] dado;

    reg [31:0] memoria[0:255];

    initial begin
        memoria[0] = 32'h001101B3;
        memoria[1] = 32'd12;
        memoria[2] = 32'h5fd3;
    end

    always @(*) begin
        dado = memoria[endereco];
    end



endmodule  