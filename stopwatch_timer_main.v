`timescale 1ns / 1ps

module stopwatch_timer_main(
    input clk,  //clock for changing sseg values
    input [1:0] mode,   //2 switches for mode select
    input startstop,    //button for start and stop
    input resetload,    //button for reset and load
    input [7:0] switch, //8 switches for external load
    output [3:0] an,
    output [6:0] sseg,
    output dp
    //output wire slow_clk    //for simulation
    //output wire fast_clk    //for simulation
    );
    
    wire fast_clk;    //for real board
    wire slow_clk;    //for real board
    wire [6:0] in0, in1, in2, in3; //the four sseg digits
    //wire [6:0] swleft, swright;
    reg [3:0] dig0; //hold individual digits
    reg [3:0] dig1;
    reg [3:0] dig2;
    reg [3:0] dig3;
     
    reg [2:0] state;
    reg [2:0] next_state;          
        
    //Module Instantiation of sseg display
    hexto7seg c1 (.x(dig0), .r(in0));    
    hexto7seg c2 (.x(dig1), .r(in1)); 
    hexto7seg c3 (.x(dig2), .r(in2)); 
    hexto7seg c4 (.x(dig3), .r(in3)); 
    
    //Module Instantiation of the clock divider
    clk_div c5 (.clk(clk), .slow_clk(slow_clk));
    clk_div_output c7 (.clk(clk), .fast_clk(fast_clk));
    
    //Module Instantiation of the multiplexer
    state_machine c6(
        .clk(fast_clk),
        .resetload(resetload),
        .in0(in0),
        .in1(in1),
        .in2(in2),
        .in3(in3),
        .an(an),
        .sseg(sseg),
        .dp(dp)
    );
        
    initial begin
      state = 3'b000;
    end        
        
    always @ (posedge slow_clk) begin
        case (mode)
        2'b00: begin        //MODE 1 - Count up & Reset to 00.00
            case(state)
                3'b000: begin   //Reset 00.00 state
                  begin
                    dig0 <= 0;
                    dig1 <= 0;
                    dig2 <= 0;
                    dig3 <= 0; end
                  if(startstop)
                    next_state <= 3'b001;
                  else
                    next_state <= 3'b000; end
                    
                3'b001: begin   //Wait state
                  if(resetload)
                    next_state <= 3'b000;
                  else if(startstop != 1)
                    next_state <= 3'b010;
                  else begin
                    dig0 <= dig0;
                    dig1 <= dig1;
                    dig2 <= dig2;
                    dig3 <= dig3; 
                    next_state <= 3'b001; end
                  end

                3'b010: begin   //Counting Up state
                  if(resetload)
                    next_state <= 3'b000;
                  else if(startstop)
                    next_state <= 3'b011;
                  else begin
                  //check if 99.99
                  if((dig0==9)&&(dig1==9)&&(dig2==9)&&(dig3==9))
                    next_state <= 3'b101; 
                  else if((dig0 == 9)&&(dig1 != 9))
                    begin
                      dig0 <= 0;
                      dig1 <= dig1 + 1;
                      next_state <= 3'b010;
                    end
                  else if((dig0 == 9)&&(dig1 == 9))
                    begin
                    if((dig2 == 9)&&(dig3 <= 9))
                      begin
                        dig0 <= 0;
                        dig1 <= 0;
                        dig2 <= 0;
                        dig3 <= dig3 + 1;
                        next_state <= 3'b010;
                      end
                    else    //dig2 != 9
                      begin
                      dig0 <= 0;
                      dig1 <= 0;
                      dig2 <= dig2 + 1;
                      next_state <= 3'b010; end
                    end
                  else begin //dig0 != 9
                    dig0 <= dig0 + 1;
                    next_state <= 3'b010; end
                  end
                  end  
                  
                3'b011: begin   //Wait state
                  if(resetload)
                    next_state <= 3'b000;
                  else if(~startstop)
                    next_state <= 3'b100;
                  else begin
                  //check if 99.99
                  if((dig0==9)&&(dig1==9)&&(dig2==9)&&(dig3==9))
                    next_state <= 3'b101;
                  else if((dig0 == 9)&&(dig1 != 9))
                    begin
                      dig0 <= 0;
                      dig1 <= dig1 + 1;
                      next_state <= 3'b011;
                    end
                  else if((dig0 == 9)&&(dig1 == 9))
                    begin
                    if((dig2 == 9)&&(dig3 <= 9))
                      begin
                        dig0 <= 0;
                        dig1 <= 0;
                        dig2 <= 0;
                        dig3 <= dig3 + 1;
                        next_state <= 3'b011;
                      end
                    else begin   //dig2 != 9
                      dig0 <= 0;
                      dig1 <= 0;
                      dig2 <= dig2 + 1;
                      next_state <= 3'b011; end
                    end
                  else begin //dig0 != 9
                    dig0 <= dig0 + 1;
                    next_state <= 3'b011; end
                  end  
                  end  
                    
                3'b100: begin   //Stop state
                  if(resetload)
                    next_state <= 3'b000;
                  else if(startstop)
                    next_state <= 3'b001;
                  else begin
                    dig0 <= dig0;
                    dig1 <= dig1;
                    dig2 <= dig2;
                    dig3 <= dig3;
                    next_state <= 3'b100; end
                  end  
                  
                3'b101: begin   //Stay 99.99 state
                  if(resetload)
                    next_state <= 3'b000;
                  else begin
                    dig0 <= 9;
                    dig1 <= 9;
                    dig2 <= 9;
                    dig3 <= 9;
                    next_state <= 3'b101; end
                  end  
           endcase
           end
        2'b01: begin        //MODE 2 - Load external value & Count Up from there
            case(state)
                3'b000: begin   //Load external value state
                  begin
                    dig0 <= 0;
                    dig1 <= 0;
                    dig2 <= switch[3:0];
                    dig3 <= switch[7:4]; end
                  if(startstop)
                    next_state <= 3'b001;
                  else
                    next_state <= 3'b000; end
                    
                3'b001: begin   //Wait state
                  if(resetload)
                    next_state <= 3'b000;
                  else if(startstop != 1)
                    next_state <= 3'b010;
                  else begin
                    dig0 <= dig0;
                    dig1 <= dig1;
                    dig2 <= dig2;
                    dig3 <= dig3; 
                    next_state <= 3'b001; end
                  end

                3'b010: begin   //Counting Up state
                  if(resetload)
                    next_state <= 3'b000;
                  else if(startstop)
                    next_state <= 3'b011;
                  else begin
                  //check if 99.99
                  if((dig0==9)&&(dig1==9)&&(dig2==9)&&(dig3==9))
                    next_state <= 3'b101; 
                  else if((dig0 == 9)&&(dig1 != 9))
                    begin
                      dig0 <= 0;
                      dig1 <= dig1 + 1;
                      next_state <= 3'b010;
                    end
                  else if((dig0 == 9)&&(dig1 == 9))
                    begin
                    if((dig2 == 9)&&(dig3 <= 9))
                      begin
                        dig0 <= 0;
                        dig1 <= 0;
                        dig2 <= 0;
                        dig3 <= dig3 + 1;
                        next_state <= 3'b010;
                      end
                    else    //dig2 != 9
                      begin
                      dig0 <= 0;
                      dig1 <= 0;
                      dig2 <= dig2 + 1;
                      next_state <= 3'b010; end
                    end
                  else begin //dig0 != 9
                    dig0 <= dig0 + 1;
                    next_state <= 3'b010; end
                  end
                end  
                  
                3'b011: begin   //Wait state
                  if(resetload)
                    next_state <= 3'b000;
                  else if(~startstop)
                    next_state <= 3'b100;
                  else begin
                  //check if 99.99
                  if((dig0==9)&&(dig1==9)&&(dig2==9)&&(dig3==9))
                    next_state <= 3'b101;
                  else if((dig0 == 9)&&(dig1 != 9))
                    begin
                      dig0 <= 0;
                      dig1 <= dig1 + 1;
                      next_state <= 3'b011;
                    end
                  else if((dig0 == 9)&&(dig1 == 9))
                    begin
                    if((dig2 == 9)&&(dig3 <= 9))
                      begin
                        dig0 <= 0;
                        dig1 <= 0;
                        dig2 <= 0;
                        dig3 <= dig3 + 1;
                        next_state <= 3'b011;
                      end
                    else begin   //dig2 != 9
                      dig0 <= 0;
                      dig1 <= 0;
                      dig2 <= dig2 + 1;
                      next_state <= 3'b011; end
                    end
                  else begin //dig0 != 9
                    dig0 <= dig0 + 1;
                    next_state <= 3'b011; end
                  end  
                end  
                    
                3'b100: begin   //Stop state
                  if(resetload)
                    next_state <= 3'b000;
                  else if(startstop)
                    next_state <= 3'b001;
                  else begin
                    dig0 <= dig0;
                    dig1 <= dig1;
                    dig2 <= dig2;
                    dig3 <= dig3;
                    next_state <= 3'b100; end
                  end  
                  
                3'b101: begin   //Stay 99.99 state
                  if(resetload)
                    next_state <= 3'b000;
                  else begin
                    dig0 <= 9;
                    dig1 <= 9;
                    dig2 <= 9;
                    dig3 <= 9;
                    next_state <= 3'b101; end
                  end
            endcase
        end
        2'b10: begin        //MODE 3 - Count down to 00.00 & reset to 99.99
            case(state)
                  3'b000: begin //Reset to 99.99 state
                    begin
                    dig0 <= 9;
                    dig1 <= 9;
                    dig2 <= 9;
                    dig3 <= 9; end
                    if(startstop)
                      next_state <= 3'b001;
                    else
                      next_state <= 3'b000; end
                      
                  3'b001: begin     //Wait state
                    if(resetload)
                      next_state <= 3'b000;
                    else if(startstop != 1)
                      next_state <= 3'b010;
                    else begin
                      dig0 <= dig0;
                      dig1 <= dig1;
                      dig2 <= dig2;
                      dig3 <= dig3; 
                      next_state <= 3'b001; end
                  end
                  
                  
                  3'b010: begin     //Counting Down state
                    if(resetload)
                      next_state <= 3'b000;
                    else if(startstop)
                      next_state <= 3'b011;
                    else begin
                    //check if 00.00
                      if((dig3 == 0)&&(dig2 == 0)&&(dig1 == 0)&&(dig0 == 0))
                        next_state <= 3'b101;
                      else if((dig0 == 0)&&(dig1 != 0))
                        begin
                          dig0 <= 9;
                          dig1 <= dig1 - 1;
                          next_state <= 3'b010;
                        end
                      else if((dig0 == 0)&&(dig1 == 0))
                        begin
                        if((dig2 == 0)&&(dig3 != 0))         //!= sign
                          begin
                            dig0 <= 9;
                            dig1 <= 9;
                            dig2 <= 9;
                            dig3 <= dig3 - 1;
                            next_state <= 3'b010;
                          end
                        else    //dig2 != 0
                          begin
                            dig0 <= 9;
                            dig1 <= 9;
                            dig2 <= dig2 - 1;
                            next_state <= 3'b010;
                          end
                        end
                      else begin    //dig0 != 0
                        dig0 <= dig0 - 1;
                        next_state <= 3'b010; end
                    end
                  end
                  
                  3'b011: begin     //Wait state
                    if(resetload)
                      next_state <= 3'b000;
                    else if(~startstop)
                      next_state <= 3'b100;
                    else begin
                    //check if 00.00
                      if((dig3 == 0)&&(dig2 == 0)&&(dig1 == 0)&&(dig0 == 0))
                        next_state <= 3'b101;
                      else if((dig0 == 0)&&(dig1 != 0))
                        begin
                          dig0 <= 9;
                          dig1 <= dig1 - 1;
                          next_state <= 3'b011;
                        end
                      else if((dig0 == 0)&&(dig1 == 0))
                        begin
                        if((dig2 == 0)&&(dig3 != 0))         //!= sign
                          begin
                            dig0 <= 9;
                            dig1 <= 9;
                            dig2 <= 9;
                            dig3 <= dig3 - 1;
                            next_state <= 3'b011;
                          end
                        else    //dig2 != 0
                          begin
                            dig0 <= 9;
                            dig1 <= 9;
                            dig2 <= dig2 - 1;
                            next_state <= 3'b011;
                          end
                        end
                      else begin    //dig0 != 0
                        dig0 <= dig0 - 1;
                        next_state <= 3'b011; end
                    end
                  end
                  3'b100: begin
                    if(resetload)
                      next_state <= 3'b000;
                    else if(startstop)
                      next_state <= 3'b001;
                    else begin
                      dig0 <= dig0;
                      dig1 <= dig1;
                      dig2 <= dig2;
                      dig3 <= dig3;
                      next_state <= 3'b100; end
                  end  
                  
                  3'b101: begin     //Stay in 00.00 state
                    if(resetload)
                      next_state <= 3'b000;
                    else begin
                      dig0 <= 0;
                      dig1 <= 0;
                      dig2 <= 0;
                      dig3 <= 0;
                      next_state <= 3'b101; end
                  end  
            endcase      
        end  
        2'b11: begin        //MODE 4 - Count down to 00.00 & load from value
            case(state)
                  3'b000: begin //Load external value
                    begin
                    dig0 <= 0;
                    dig1 <= 0;
                    dig2 <= switch[3:0];
                    dig3 <= switch[7:4]; end
                    if(startstop)
                      next_state <= 3'b001;
                    else
                      next_state <= 3'b000; end
                      
                  3'b001: begin     //Wait state
                    if(resetload)
                      next_state <= 3'b000;
                    else if(startstop != 1)
                      next_state <= 3'b010;
                    else begin
                      dig0 <= dig0;
                      dig1 <= dig1;
                      dig2 <= dig2;
                      dig3 <= dig3; 
                      next_state <= 3'b001; end
                  end
                  
                  
                  3'b010: begin     //Counting Down state
                    if(resetload)
                      next_state <= 3'b000;
                    else if(startstop)
                      next_state <= 3'b011;
                    else begin
                    //check if 00.00
                      if((dig3 == 0)&&(dig2 == 0)&&(dig1 == 0)&&(dig0 == 0))
                        next_state <= 3'b101;
                      else if((dig0 == 0)&&(dig1 != 0))
                        begin
                          dig0 <= 9;
                          dig1 <= dig1 - 1;
                          next_state <= 3'b010;
                        end
                      else if((dig0 == 0)&&(dig1 == 0))
                        begin
                        if((dig2 == 0)&&(dig3 != 0))         //!= sign
                          begin
                            dig0 <= 9;
                            dig1 <= 9;
                            dig2 <= 9;
                            dig3 <= dig3 - 1;
                            next_state <= 3'b010;
                          end
                        else    //dig2 != 0
                          begin
                            dig0 <= 9;
                            dig1 <= 9;
                            dig2 <= dig2 - 1;
                            next_state <= 3'b010;
                          end
                        end
                      else begin    //dig0 != 0
                        dig0 <= dig0 - 1;
                        next_state <= 3'b010; end
                    end
                  end
                  
                  3'b011: begin     //Wait state
                    if(resetload)
                      next_state <= 3'b000;
                    else if(~startstop)
                      next_state <= 3'b100;
                    else begin
                    //check if 00.00
                      if((dig3 == 0)&&(dig2 == 0)&&(dig1 == 0)&&(dig0 == 0))
                        next_state <= 3'b101;
                      else if((dig0 == 0)&&(dig1 != 0))
                        begin
                          dig0 <= 9;
                          dig1 <= dig1 - 1;
                          next_state <= 3'b011;
                        end
                      else if((dig0 == 0)&&(dig1 == 0))
                        begin
                        if((dig2 == 0)&&(dig3 != 0))         //!= sign
                          begin
                            dig0 <= 9;
                            dig1 <= 9;
                            dig2 <= 9;
                            dig3 <= dig3 - 1;
                            next_state <= 3'b011;
                          end
                        else    //dig2 != 0
                          begin
                            dig0 <= 9;
                            dig1 <= 9;
                            dig2 <= dig2 - 1;
                            next_state <= 3'b011;
                          end
                        end
                      else begin    //dig0 != 0
                        dig0 <= dig0 - 1;
                        next_state <= 3'b011; end
                    end
                  end
                  3'b100: begin     //Hold values
                    if(resetload)
                      next_state <= 3'b000;
                    else if(startstop)
                      next_state <= 3'b001;
                    else begin
                      dig0 <= dig0;
                      dig1 <= dig1;
                      dig2 <= dig2;
                      dig3 <= dig3;
                      next_state <= 3'b100; end
                  end  
                  
                  3'b101: begin     //Stay in 00.00 state
                    if(resetload)
                      next_state <= 3'b000;
                    else begin
                      dig0 <= 0;
                      dig1 <= 0;
                      dig2 <= 0;
                      dig3 <= 0;
                      next_state <= 3'b101; end
                  end
            endcase
        end
        endcase
    end
        
    always @ (posedge slow_clk) begin
        case (mode)
          2'b00: begin  //Mode 1
              state <= next_state; end   
          2'b01: begin  //Mode 2
              state <= next_state; end
          2'b10: begin  //Mode 3
              state <= next_state; end
          2'b11: begin  //Mode 4
              state <= next_state; end    
        endcase
    end
endmodule
