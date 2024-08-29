// Code your design here
module FIFO #(parameter data_w=8,parameter depth=4)(
    input logic clock,
    input logic reset,  // global signals

     input logic push_i,   // case variable for writing in FIFO
  input logic [data_w-1:0] push_data_i, // data that i want to push or write

     input logic pop_i,  //case variable for reading in FIFO
  output logic [data_w-1:0] pop_data_o, // data that i want to read from the FIFO

     output logic e_o,
     output logic f_o

);


typedef enum logic [1:0]{
    /////// case values for push and pop (read and write)
     ST_PUSH=2'b10,
     ST_POP=2'b01,
     ST_BOTH=2'b11 

} case_t;


 localparam ptr_w=$clog2(depth);

 logic [data_w-1:0] fifo_data [depth-1:0];  // FIFO memory decclared
/////// used for pointing to next read and write locations
  logic [ptr_w-1:0] rd_ptr;
 logic [ptr_w-1:0]  wr_ptr;
 logic [ptr_w-1:0]  next_rd_ptr;
 logic [ptr_w-1:0]  next_wr_ptr;
////// used for handling empty and full conditions
 logic   wrapped_rd_ptr;   
 logic   wrapped_wr_ptr;
 logic   next_wrapped_rd_ptr;
 logic   next_wrapped_wr_ptr;


logic empty;
logic full;
  
 
  logic [data_w-1:0] next_fifo_data;
  
  logic [data_w-1:0] pop_data;




always_ff  @(posedge clock or posedge reset)
begin
    if(reset) begin
    rd_ptr<=ptr_w'(1'b0);
    wr_ptr<=ptr_w'(1'b0);
    wrapped_rd_ptr<=1'b0;
    wrapped_wr_ptr<=1'b0;

    end   
 else begin
    rd_ptr<=next_rd_ptr;
    wr_ptr<=next_wr_ptr;
    wrapped_rd_ptr<=next_wrapped_rd_ptr;
    wrapped_wr_ptr<=next_wrapped_wr_ptr;
    end
end

always_comb begin
//////// initialization of signals for error free design
  
next_fifo_data=fifo_data[wr_ptr[ptr_w-1:0]];
next_rd_ptr=rd_ptr;
next_wr_ptr=wr_ptr;
next_wrapped_wr_ptr=wrapped_wr_ptr;
next_wrapped_rd_ptr=wrapped_rd_ptr;
  
case({push_i,pop_i}) 
 ST_PUSH: begin
    next_fifo_data=push_data_i;
    if (wr_ptr==ptr_w'(depth-1)) begin
        next_wr_ptr=ptr_w'(1'b0);
        next_wrapped_wr_ptr = ~(wrapped_wr_ptr);
    end  else begin
        next_wr_ptr=wr_ptr+ptr_w'(1'b1);

    end
    end
  ST_POP: begin
     pop_data=fifo_data[rd_ptr[ptr_w-1:0]];
     if (rd_ptr==ptr_w'(depth-1)) begin
        next_rd_ptr=ptr_w'(1'b0);
        next_wrapped_rd_ptr = ~(wrapped_rd_ptr);
    end  else begin
        next_rd_ptr=rd_ptr+ptr_w'(1'b1);
       
    end
  end
  ST_BOTH: begin
 ///case ST_PUSH
     next_fifo_data=push_data_i;
    if (wr_ptr==ptr_w'(depth-1)) begin
        next_wr_ptr=ptr_w'(1'b0);
        next_wrapped_wr_ptr = ~(wrapped_wr_ptr);
    end  else begin
        next_wr_ptr=wr_ptr+ptr_w'(1'b1);

    end

    ////// case ST_POP

    pop_data=fifo_data[rd_ptr[ptr_w-1:0]];
     if (rd_ptr==ptr_w'(depth-1)) begin
        next_rd_ptr=ptr_w'(1'b0);
        next_wrapped_rd_ptr = ~(wrapped_rd_ptr);
    end  else begin
        next_rd_ptr=rd_ptr+ptr_w'(1'b1);
       
    end

  end
  
 default:begin
    next_fifo_data=fifo_data[wr_ptr[ptr_w-1:0]];
    next_rd_ptr=rd_ptr;
    next_wr_ptr=wr_ptr;
 end
endcase
end
  
   assign empty= (rd_ptr==wr_ptr)&(wrapped_rd_ptr==wrapped_wr_ptr);
  assign full=  (rd_ptr==wr_ptr)&(wrapped_rd_ptr!=wrapped_wr_ptr);

  always_ff @(posedge clock)     
  fifo_data[wr_ptr[ptr_w-1:0]]<=next_fifo_data;   ///// writing to FIFO memory


assign pop_data_o=pop_data;   /////reading from the FIFO memory
assign e_o=empty;
assign f_o=full;

endmodule