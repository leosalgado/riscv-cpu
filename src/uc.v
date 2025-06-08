module uc (opcode, alu_op, mem_read, mem_write);

    input [3:0] opcode;
    output reg [1:0] alu_op;
    output reg mem_read;
    output reg mem_write;

    always @(*) begin

        case (opcode)
            4'b0000: begin // ADD
                alu_op = 2'b00;
                mem_read = 0;
                mem_write = 0;
            end
            4'b0001: begin // SUB
                alu_op = 2'b01;
                mem_read = 0;
                mem_write = 0;
            end
            4'b0010: begin // LOAD
                alu_op = 2'b10;
                mem_read = 1;
                mem_write = 0;
            end
            4'b0011: begin // STORE
                alu_op = 2'b10;
                mem_read = 0;
                mem_write = 1;
            end
            default: begin
                alu_op = 2'bxx;
                mem_read = 0;
                mem_write = 0;
            end
        endcase

    end
endmodule
