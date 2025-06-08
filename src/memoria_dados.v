module memoria_dados(rs, wd, wr, rd);

    input [31:0] rs;
    input [31:0] wd;
    input wr;
    output [31:0] rd;

    reg [31:0] memoria[0:1023];

    always @(posedge wr) begin
        if (wr) begin
            memoria[rs[9:0]] <= wd; 
        end
    end

    assign rd = memoria[rs[9:0]]; 

endmodule