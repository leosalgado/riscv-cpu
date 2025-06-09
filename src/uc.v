module uc (opcode, alu_op, mem_read, mem_write, reg_write, mem_to_reg, alu_src, branch);

    input [6:0] opcode;
    output reg [1:0] alu_op;
    output reg mem_read;
    output reg mem_write;
    output reg reg_write;
    output reg mem_to_reg;
    output reg alu_src;
    output reg branch;

    always @(*) begin
        
        alu_op = 2'bxx;
        mem_read = 1'b0;
        mem_write = 1'b0;
        reg_write = 1'b0;
        mem_to_reg = 1'b0;
        alu_src = 1'b0;
        branch = 1'b0;

        case (opcode)

            7'b0000011: begin
                alu_op = 2'b00; 
                mem_read = 1'b1;   
                mem_write = 1'b0;   
                reg_write = 1'b1;   
                mem_to_reg = 1'b1;   
                alu_src = 1'b1;   
                branch = 1'b0;  
            end

            7'b0100011: begin 
                alu_op = 2'b00; 
                mem_read = 1'b0;   
                mem_write = 1'b1;   
                reg_write = 1'b0;   
                mem_to_reg = 1'b0;  
                alu_src = 1'b1;   
                branch = 1'b0;   
            end

            7'b1100011: begin 
                alu_op     = 2'b01; 
                mem_read   = 1'b0;   
                mem_write  = 1'b0;  
                reg_write  = 1'b0;   
                mem_to_reg = 1'b0;   
                alu_src    = 1'b0;   
                branch     = 1'b1;   
            end

            7'b0110011: begin 
                alu_op     = 2'b10;  
                mem_read   = 1'b0;   
                mem_write  = 1'b0;   
                reg_write  = 1'b1;   
                mem_to_reg = 1'b0;  
                alu_src    = 1'b0;   
                branch     = 1'b0;   
            end

            default: begin
                alu_op     = 2'b00; 
                mem_read   = 1'b0;
                mem_write  = 1'b0;
                reg_write  = 1'b0;
                mem_to_reg = 1'b0;
                alu_src    = 1'b0;
                branch     = 1'b0;
            end

        endcase

    end

endmodule
