`timescale 1ns / 1ps

module testbench_datapath;

    reg clk;
    reg reset;

    datapath dut (
        .clk(clk),
        .reset(reset)
    );

    task apply_clock;
        begin
            #5 clk = ~clk;
            #5 clk = ~clk;
        end
    endtask

    initial begin
        $dumpfile("waveforms/datapath_tb.vcd");
        $dumpvars(0, testbench_datapath);

        clk = 0;
        reset = 1;
        apply_clock;
        apply_clock;
        reset = 0;
        apply_clock;

        $display("--- Inicio da Simulação ---");

        $display("Tempo %0t: PC = %h", $time, dut.pc_current);
        apply_clock;

        $display("Tempo %0t: PC = %h", $time, dut.pc_current);
        apply_clock;

        $display("Tempo %0t: PC = %h", $time, dut.pc_current);
        apply_clock;

        apply_clock;
        apply_clock;
        apply_clock;
        apply_clock;
        apply_clock;
        apply_clock;

        $display("--- Teste Completo ---");

        $finish;
    end

endmodule
