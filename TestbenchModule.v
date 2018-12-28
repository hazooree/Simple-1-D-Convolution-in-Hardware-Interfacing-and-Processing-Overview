`timescale 1ns / 1ps
module TestBenchAssignment3;
    reg clk;
    reg Reset_in;
    reg Test;
    wire Test_Result;
    wire valid;
    wire invalid;
    wire finish;
    wire packet_Done;
    wire reset;
    wire ready;
    wire [15:0] Y;
    wire [15:0] HS_out;
    wire [8:0] count;
    wire [3:0] count1;
	 wire [15:0] avrg;

    XilinxAssignment3 uut (
        .clk(clk),
        .Reset_in(Reset_in),
        .Test(Test),
        .Test_Result(Test_Result),
        .valid(valid),
        .invalid(invalid),
        .finish(finish),
        .packet_Done(packet_Done),
        .reset(reset),
        .ready(ready),
        .Y(Y),
        .HS_out(HS_out),
        .count(count),
        .count1(count1),
		  .avrg(avrg)
    );
initial begin
clk=0;
forever #10 clk=~clk;
end
    initial begin
        Reset_in = 0;
        Test = 0;
        #10;
      Reset_in = 1;
        #15;
        Reset_in = 0;
        #8000;
        Test = 1;
      Reset_in = 1;
        #15;
        Reset_in = 0;
     end
endmodule