`timescale 1ns / 1ps

module clk_div_output(
    input clk,
    output fast_clk
    );
    
    //reg [1:0] COUNT;  //for simulation
    reg [11:0] COUNT;
    
    //changing this changes the output to sseg (flashy)
    
    //assign slow_clk = COUNT[1];   //for simulation
    assign fast_clk = COUNT[11];
    
    always @ (posedge clk)
    begin
        COUNT = COUNT + 1;
    end
    
endmodule
