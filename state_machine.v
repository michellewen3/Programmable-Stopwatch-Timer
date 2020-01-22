`timescale 1ns / 1ps

module state_machine(
    input clk,
    input resetload,
    input [6:0] in0,    //inputs are the 7 bit inputs for each digit
    input [6:0] in1,
    input [6:0] in2,
    input [6:0] in3,
    output reg [3:0] an,
    output reg [6:0] sseg,
    output reg dp
    );
    
    reg [1:0] state1;
    reg [1:0] nextstate;
    
    always @(*) begin
        case(state1)
          2'b00: nextstate = 2'b01;
          2'b01: nextstate = 2'b10;
          2'b10: nextstate = 2'b11;
          2'b11: nextstate = 2'b00;
        endcase
    end
    
    always @(*) begin
        case(state1)
          2'b00: sseg = in0;
          2'b01: sseg = in1;
          2'b10: sseg = in2;
          2'b11: sseg = in3;
        endcase
        case(state1)
          2'b00: begin an = 4'b1110; dp = 1; end //these lines only turn it on/off
          2'b01: begin an = 4'b1101; dp = 1; end
          2'b10: begin an = 4'b1011; dp = 0; end
          2'b11: begin an = 4'b0111; dp = 1; end
        endcase
    end
    
    always @(posedge clk) begin
        state1 <= nextstate;
    end
endmodule
