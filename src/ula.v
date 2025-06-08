module ula (A, B, UlaOp, Out);

    input [31:0] A, B;
    input [3:0] UlaOp;
    output reg [31:0] Out;

    always @(*) begin
        
        case (UlaOp)
            4'b0000: Out <= A & B;
            4'b0001: Out <= A | B;
            4'b0010: Out <= A + B;
            4'b0110: Out <= A - B;
            default: Out <= 32'bz;
        endcase

    end

endmodule