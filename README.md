# Basics of FIFO 
A FIFO (First-In, First-Out) is a type of data buffer or queue where the first piece of data entered is the first one to be removed. This order-preserving mechanism is essential in various digital systems, where data must be processed or transmitted in the exact sequence it was received.FIFOs are fundamental components in digital systems, offering a simple yet powerful mechanism for managing data flow across various applications.

# Types of FIFO
## Synchronous FIFO (First-In, First-Out)

A **Synchronous FIFO (First-In, First-Out)** is a type of data buffer or queue used in digital systems where both the writing and reading of data are controlled by the same clock signal. This synchronization ensures that all operations occur in lockstep with the clock, making it easier to design and analyze compared to asynchronous FIFOs.

### Key Concepts

1. **Single Clock Domain**:
   - In a synchronous FIFO, both the write and read operations are governed by the same clock signal. This simplifies the design since there’s no need to deal with clock domain crossing issues.
   - The common clock signal ensures that data is written and read in a predictable and consistent manner.

2. **FIFO Control Signals**:
   - **Write Enable (WE)**: This signal, when asserted, allows data to be written into the FIFO on the rising edge of the clock.
   - **Read Enable (RE)**: This signal, when asserted, allows data to be read from the FIFO on the rising edge of the clock.
   - **Full Flag**: This status signal indicates that the FIFO is full, meaning no more data can be written until space is made by reading data out.
   - **Empty Flag**: This status signal indicates that the FIFO is empty, meaning there is no data available to read.

3. **Operation**:
   - **Writing Data**: Data is written into the FIFO when the write enable signal is asserted. The FIFO pointer advances to the next location after each write.
   - **Reading Data**: Data is read out of the FIFO when the read enable signal is asserted. The read pointer advances to the next location after each read.
   - **Full and Empty Conditions**: The FIFO is considered full when the write pointer catches up to the read pointer, and it is considered empty when the read pointer catches up to the write pointer.

4. **Status Flags**:
   - The full and empty flags prevent invalid operations, such as writing data when the FIFO is full or reading data when the FIFO is empty. These flags help manage the flow of data efficiently.


     <b>BLOCK DIAGRAM OF SYNCHRONOUS FIFO</B>
<img width="678" alt="Screenshot 2024-08-29 at 1 29 47 PM" src="https://github.com/user-attachments/assets/a44ef50c-f1db-4188-86bc-3463004c23f9">


  

  ## Asynchronous FIFO (First-In, First-Out)

An **Asynchronous FIFO (First-In, First-Out)** is a type of data buffer where the writing and reading operations are controlled by different clock signals. This allows for data transfer between two clock domains that operate at different frequencies.

### Key Concepts

1. **Dual Clock Domains**:
   - The write and read operations are governed by independent clock signals, allowing the FIFO to interface between two systems operating at different clock rates.

2. **Clock Domain Crossing (CDC)**:
   - Special synchronization techniques are employed to handle data transfer across the two clock domains, ensuring that data integrity is maintained despite the asynchronous nature.

3. **FIFO Control Signals**:
   - **Write Enable (WE)**: Allows data to be written into the FIFO on the rising edge of the write clock.
   - **Read Enable (RE)**: Allows data to be read from the FIFO on the rising edge of the read clock.
   - **Full Flag**: Indicates that the FIFO is full, meaning no more data can be written until space is made by reading data out.
   - **Empty Flag**: Indicates that the FIFO is empty, meaning there is no data available to read.

4. **Synchronization Logic**:
   - **Gray Code Pointers**: Often used for the write and read pointers to minimize timing issues when crossing clock domains.
   - **Metastability**: Special circuits are employed to reduce the risk of metastability, a condition that can occur when signals are transferred between clock domains.

5. **Operation**:
   - **Writing Data**: Data is written into the FIFO when the write enable signal is asserted, advancing the write pointer.
   - **Reading Data**: Data is read out of the FIFO when the read enable signal is asserted, advancing the read pointer.
   - **Full and Empty Conditions**: The FIFO is considered full when the write pointer is one position behind the read pointer (in Gray code), and empty when the pointers are equal.

 
<img width="911" alt="Screenshot 2024-08-29 at 1 34 48 PM" src="https://github.com/user-attachments/assets/c0444b02-8cfb-440b-8192-c1425fba4c8a">

## Parameterized FIFO Design in SystemVerilog

This project implements a parameterized First-In, First-Out (FIFO) memory buffer with a depth of 4 and a data width of 8 bits, using SystemVerilog. The design is synchronous, meaning both read and write operations are controlled by the same clock signal. This FIFO is ideal for applications requiring temporary data storage in a controlled sequence.

### Project Overview

- **FIFO Depth**: 4 entries
- **Data Width**: 8 bits
- **Design Language**: SystemVerilog
- **Design Type**: Synchronous FIFO with Parameterized Depth and Width

### Features

- **Parameterized Design**: The FIFO's depth and data width are parameterized, allowing easy adjustments for different requirements.
- **Synchronous Operation**: The FIFO uses a single clock domain for both read and write operations, ensuring reliable and predictable data management.
- **Status Signals**: The design includes empty (`e_o`) and full (`f_o`) flags to prevent overflow and underflow, ensuring efficient data flow management.
- **Efficient Memory Management**: The FIFO efficiently handles memory read and write operations using pointers and wrapped pointer logic to manage circular buffer behavior.

### Key Components

- **Control Logic**: Manages the reading and writing of data based on input signals (`push_i` and `pop_i`).
- **Memory Array**: Stores the FIFO data, which is indexed by read and write pointers.
- **Pointer Management**: Read and write pointers, along with wrapped pointers, control access to the FIFO memory, ensuring correct data sequencing.
- **Case Handling**: The design handles different operational states (`ST_PUSH`, `ST_POP`, `ST_BOTH`) using a case structure to determine the appropriate actions.

### Usage

This FIFO design is suitable for digital systems where data needs to be queued and processed in a strict sequence. Its parameterization allows for easy customization, making it adaptable for various applications that require different FIFO depths or data widths.


# RTL Design Code for Parameterized FIFO
```systemverilog
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

} state_t;


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
```

This module implements a Parameterized Synchronous FIFO in SystemVerilog. The design is parameterized to allow flexibility in defining the data width and FIFO depth.

Module Parameters

	•	data_w: Specifies the width of the data to be stored in the FIFO. Default is 8 bits.
	•	depth: Specifies the depth (number of entries) in the FIFO. Default is 4 entries.

Ports

	•	clock: The clock signal for synchronous operations.
	•	reset: A reset signal that initializes the FIFO pointers and flags.
	•	push_i: Control signal to write data into the FIFO (push operation).
	•	push_data_i: The data input to be written into the FIFO.
	•	pop_i: Control signal to read data from the FIFO (pop operation).
	•	pop_data_o: The data output read from the FIFO.
	•	e_o: Output flag indicating if the FIFO is empty.
	•	f_o: Output flag indicating if the FIFO is full.

Internal Logic

	•	fifo_data: An array representing the FIFO memory, with a size determined by the depth and data_w parameters.
	•	rd_ptr and wr_ptr: Pointers used to track the current read and write locations within the FIFO.
	•	wrapped_rd_ptr and wrapped_wr_ptr: Flags that indicate when the read and write pointers have wrapped around the FIFO memory (useful for determining the full and empty conditions).
	•	empty and full: Logic signals that determine if the FIFO is empty or full, respectively.

State Machine

	•	The state machine handles three cases:
	•	ST_PUSH: Writing data into the FIFO.
	•	ST_POP: Reading data from the FIFO.
	•	ST_BOTH: Simultaneously writing and reading data from the FIFO.

Key Operations

	•	Reset Operation:
	•	On reset, the read and write pointers (rd_ptr and wr_ptr) are initialized to zero, and the wrapped pointers (wrapped_rd_ptr and wrapped_wr_ptr) are set to 0.
	•	Push Operation:
	•	Data is written into the FIFO at the location pointed to by wr_ptr. If wr_ptr reaches the last entry (depth - 1), it wraps around to zero, and the wrapped_wr_ptr flag is toggled.
	•	Pop Operation:
	•	Data is read from the FIFO at the location pointed to by rd_ptr. If rd_ptr reaches the last entry, it also wraps around to zero, and the wrapped_rd_ptr flag is toggled.
	•	Status Flags:
	•	The empty flag is asserted when the rd_ptr equals the wr_ptr and the wrapped_rd_ptr matches wrapped_wr_ptr.
	•	The full flag is asserted when the rd_ptr equals the wr_ptr, but the wrapped_rd_ptr is different from wrapped_wr_ptr.

Data Handling

	•	Writing Data:
	•	Data is stored in fifo_data[wr_ptr] on the rising edge of the clock during a push operation.
	•	Reading Data:
	•	The data at fifo_data[rd_ptr] is output via pop_data_o during a pop operation.

# Testbench Code
```systemverilog
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
     pop_i = 1'b1;
    `clk;
     pop_i = 1'b1;
     `clk;
    repeat (2) `clk;
    $finish();

end
initial begin 
    $dumpfile("dump.vcd");
    $dumpvars;
end


endmodule
```
In this Testbench code we have generated the control signals and given some inputs to verify the RTL design of the FIFO.
1. Global signals like CLOCK  signal is generated for a  time period of 10 ns with 50% duty cycle.RESET is also generated in the testbench .Initialy RESET is HIGH for 20ns and then goes LOW . 
2. In the initial block we have the initialzed the Push_i which is write_enable and pop_i which is read_enable for reading and writing purpose .
3. At first active edge of clock we making push_i high and then writing data at that clock edge and also the next edge . Push_i goes Low.
4. For Further Clock edges we are reading from the FIFO and finaly after 2 active edge of the clock after the last read $finish is invoked

# Output 
<img width="1440" alt="Screenshot 2024-08-29 at 2 01 24 PM" src="https://github.com/user-attachments/assets/c2283454-4688-4edb-8779-2c219c4f8446">




