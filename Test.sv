// Code your testbench here
// or browse Examples
`define clk @(posedge clock);
module tb();


  localparam data_w = 8;
  localparam depth = 4;

     logic clock;
     logic reset;  

     logic push_i;  
     logic [data_w-1:0] push_data_i; 

      logic pop_i; 
  logic [data_w-1:0] pop_data_o;
      

    logic e_o;
    logic f_o;


  FIFO #(.data_w(data_w),.depth(depth)) DUT (.*);

always begin
    clock=1'b1;
    #5;
    clock=1'b0;
    #5;
end

initial begin
reset=1'b1;
push_i=1'b0;
pop_i=1'b0;
  repeat(2)`clk
reset=1'b0;
   `clk;
    push_i = 1'b1;
    push_data_i = 8'hAB;
    `clk;
    push_data_i = 8'hCC;
    `clk;
    push_i = 1'b0;
    `clk;
   // push_i = 1'b0;
    //push_data_i = 8'hx;
     pop_i = 1'b1;
    `clk;
     pop_i = 1'b1;
     `clk;
    pop_i = 1'b0;
    `clk
    repeat (2) `clk;
    $finish();

end
initial begin 
    $dumpfile("dump.vcd");
    $dumpvars;
end


endmodule