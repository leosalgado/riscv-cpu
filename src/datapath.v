module datapath (clk, reset);
    input clk;
    input reset;
    
    // Sinais internos
    wire [31:0] pc_next;
    reg [31:0] pc_current;
    wire [31:0] instruction;
    wire [1:0] alu_op;          // Corrigido: reduzido para 2 bits
    wire mem_read;
    wire mem_write;
    wire reg_write;
    wire mem_to_reg;
    wire alu_src;
    wire branch;
    wire [31:0] read_data1;
    wire [31:0] read_data2;
    wire [4:0] rs1_addr;
    wire [4:0] rs2_addr;
    wire [4:0] rd_addr;
    wire [31:0] immediate;
    wire [31:0] alu_result;
    wire alu_zero;
    wire [31:0] data_memory_read_data;
    wire [31:0] alu_src_mux_out;
    wire [31:0] mem_to_reg_mux_out;
    wire [31:0] pc_plus_4;
    wire [31:0] branch_target;
    
    // Registrador PC
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_current <= 32'h00000000;
        end else begin
            pc_current <= pc_next;
        end
    end
    
    // PC + 4
    assign pc_plus_4 = pc_current + 4;
    
    // Memória de instruções
    memoria_instrucao instr_mem (
        .endereco(pc_current[9:2]), 
        .dado(instruction)
    );
    
    // Unidade de controle (removido funct3 e funct7)
    uc control_unit (
        .opcode(instruction[6:0]),
        .alu_op(alu_op), 
        .mem_read(mem_read),
        .mem_write(mem_write),
        .reg_write(reg_write),
        .mem_to_reg(mem_to_reg),
        .alu_src(alu_src),
        .branch(branch)
    );
    
    // Decodificação dos endereços dos registradores
    assign rs1_addr = instruction[19:15]; 
    assign rs2_addr = instruction[24:20]; 
    assign rd_addr = instruction[11:7];
    
    // Banco de registradores (removido clk)
    registradores reg_file (
        .rs1(rs1_addr),
        .rs2(rs2_addr),
        .rd(rd_addr),
        .wr_data(mem_to_reg_mux_out),
        .wr(reg_write),
        .read1(read_data1),
        .read2(read_data2)
    );
    
    // Gerador de imediato
    imediato imm_gen (
        .instrucao(instruction),
        .imediato_out(immediate)
    );
    
    // MUX para fonte da ALU
    mux alu_src_mux (
        .in0(read_data2),  
        .in1(immediate),  
        .sel(alu_src),
        .out(alu_src_mux_out)
    );
    
    // ALU (removido Zero)
    ula alu (
        .A(read_data1),
        .B(alu_src_mux_out),
        .UlaOp(alu_op), 
        .Out(alu_result)
    );
    
    // Lógica para flag Zero (implementada externamente)
    assign alu_zero = (alu_result == 32'b0) ? 1'b1 : 1'b0;
    
    // Memória de dados (removido clk)
    memoria_dados data_mem (
        .rs(alu_result), 
        .wd(read_data2), 
        .wr(mem_write),
        .rd(data_memory_read_data)
    );
    
    // MUX para write-back
    mux mem_to_reg_mux (
        .in0(alu_result),          
        .in1(data_memory_read_data),  
        .sel(mem_to_reg),
        .out(mem_to_reg_mux_out)
    );
    
    // Cálculo do endereço de branch
    assign branch_target = pc_current + immediate;
    
    // MUX para próximo PC
    mux pc_mux (
        .in0(pc_plus_4),    
        .in1(branch_target), 
        .sel(branch && alu_zero), 
        .out(pc_next)
    );
    
endmodule
