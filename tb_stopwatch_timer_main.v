`timescale 1ns / 1ps

module tb_stopwatch_timer_main;
    reg clk;  //clock for changing sseg values
    reg [1:0] mode;   //2 switches for mode select
    reg startstop;    //button for start and stop
    reg resetload;    //button for reset and load
    reg [7:0] switch; //8 switches for external load
    wire [3:0] an;
    wire [6:0] sseg;
    wire dp;
    wire slow_clk;
    wire fast_clk;

    stopwatch_timer_main ul(
        .clk(clk),
        .mode(mode),
        .startstop(startstop),
        .resetload(resetload),
        .switch(switch),
        .an(an),
        .sseg(sseg),
        .dp(dp),
        .slow_clk(slow_clk),
        .fast_clk(fast_clk)
    );
    
    initial begin
    
    clk = 0;
    resetload = 0;
    mode = 2'b00;
    startstop = 0;
    switch = 8'b00000000;
    
    #50
    
    resetload = 1;
    
    #50
    resetload = 0;
    #50
    resetload = 0;
    #50
    startstop = 1;
    
    #50
    
    startstop = 0;
    #50
    resetload = 0;
    #50
    
    startstop = 1;
    
    #50
    
    startstop = 0;
    #50
    resetload = 0;
    #50
    
    startstop = 1;
    
    #50
    
    startstop = 0;
    #50
    resetload = 0;
    #50
   
    startstop = 1;
    
    #50
    
    startstop = 0;
    
    #50
    
    mode = 2'b11;
    
    #50
    
    switch = 8'b10001000;
    
    #50
    
    resetload = 1;
    
    #50
    
    resetload = 0;
    
    #50
    
    startstop = 1;
    
    #50
    
    startstop = 0;
    
    end
    
    always
    #5 clk = ~clk;

endmodule
