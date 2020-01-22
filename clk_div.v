`timescale 1ns / 1ps

module clk_div(
    input clk,
    output slow_clk
    );
    
    //26 bits is 1Hz (1s)
    //Want clock divider to run at 100Hz = 19-20 bits
    
    //reg [1:0] COUNT;  //for simulation
    reg [19:0] COUNT;
    
    //changing this changes the output to sseg (flashy)
    
    //assign slow_clk = COUNT[1];   //for simulation
    assign slow_clk = COUNT[19];
    
    always @ (posedge clk)
    begin
        COUNT = COUNT + 1;
    end
    
endmodule
