//=========================================================
// SYSTEMVERILOG ASSERTIONS (SVA)
//=========================================================

/**********************************************************

               BASIC LEVEL QUESTIONS
**********************************************************/

// Q1: What are SystemVerilog assertions (SVA)? Why are they used?
// Q2: What is the difference between immediate and concurrent assertions?
// Q3: Explain the syntax of an immediate assertion.
// Q4: What are the key components of a concurrent assertion?
// Q5: What is a property in SystemVerilog? How is it different from a sequence?
// Q6: How do you disable an assertion during simulation?
// Q7: Write an immediate assertion to check if data is always > 0.
// Q8: What does disable iff do in concurrent assertions?
// Q9: Explain the difference between |-> and |=>.
// Q10: What is $fatal, $error, and $warning in assertions?

/**********************************************************
            INTERMEDIATE LEVEL QUESTIONS
**********************************************************/

// Q1: What is the role of temporal operators in assertions? Examples?
// Q2: Explain the ## operator and its significance.
// Q3: What happens if an assertion fails during simulation?
// Q4: Write a concurrent assertion: a must be high for 2 cycles.
// Q5: Advantages of using assertions in functional verification?
// Q6: Use assertions to verify an AMBA protocol (e.g., AXI).
// Q7: Difference between sequence, property, and assert property?
// Q8: How to debug assertion failures in simulation?
// Q9: Significance of cover property?
// Q10: Difference between overlapped and non-overlapped sequences?

/**********************************************************
              ADVANCED LEVEL QUESTIONS
**********************************************************/

// Q1: How to integrate assertions in UVM?
// Q2: Strong vs Weak operators in concurrent assertions?
// Q3: What are sampled values in SVA and their importance?
// Q4: Write a handshake protocol property: req -> ack in 3 cycles.
// Q5: Verifying low-power designs (e.g., UPF) using assertions?
// Q6: Role of first_match and throughout operators?
// Q7: Assertion: rst remains low for 5 cycles after deassert.
// Q8: Difference between always and eventually temporal ops?
// Q9: Assertion testing in formal tools like JasperGold or Questa Formal?
// Q10: What are SVA checker libraries? How to use them?

/**********************************************************
      PRACTICAL & SCENARIO-BASED QUESTIONS
**********************************************************/

// Functional Coverage using Assertions?
// Common pitfalls in writing assertions?
// AXI: Ensure burst length is not exceeded.
// Detect glitches or setup/hold violations using assertions.
// Managing assertion failures in regressions?
// Toggle pattern check: valid -> data?
// Explain overlapping sequences with example.
// Optimize assertions for sim performance?
// Scenario: How assertions helped detect a complex bug?
// Use assertions to verify pipeline stages?

/**********************************************************
     BASIC SCENARIO-BASED ASSERTIONS
**********************************************************/

// Clock stability check:
assert property (@(posedge clk) $stable(clk)[*1:$]);

// Reset active for 2+ cycles:
assert property (@(posedge clk) reset[*2:$]);

// Data not X/Z during operation:
assert property (@(posedge clk) normal_op |-> !(data === 1'bx || data === 1'bz));

// Enable goes high only after reset deasserted:
assert property (@(posedge clk) disable iff (reset) $rose(en));

// Output only valid if input ready + data valid:
assert property (@(posedge clk) disable iff (reset) (in_ready && data_valid) |-> out_valid);

/**********************************************************
   INTERMEDIATE SCENARIO-BASED ASSERTIONS
**********************************************************/

// Sequence Monitoring (start -> a -> b -> c in 5 cycles):
sequence seq_a; a ##1 b ##1 c; endsequence
property p1; @(posedge clk) start |-> ##[1:5] seq_a; endproperty
assert property (p1);

// FIFO Overflow:
assert property (@(posedge clk) (wr_en && fifo_full) |-> 0);

// Handshake: req followed by ack in 3 cycles:
property p1; @(posedge clk) req |-> ##[1:3] ack; endproperty
assert property (p1) else $error("Handshake error");

// Bus idle when en is low:
property p1; @(posedge clk) !en |-> !(rd || wr); endproperty
assert property (p1);

// Power-up sequence: power_good only after voltage_stable 3+ cycles:
property p1; @(posedge clk) disable iff (reset) power_good |-> ##[1:3] voltage_stable; endproperty
assert property (p1);

/**********************************************************
   ADVANCED SCENARIO-BASED ASSERTIONS
**********************************************************/

// AXI ARREADY within 2 cycles of ARVALID:
property p1; @(posedge clk) $rose(ARVALID) |-> ##[1:2] ARREADY; endproperty
assert property (p1) else $error("ARREADY timeout");

// AWVALID and ARVALID not high together:
property p2; @(posedge clk) !(AWVALID && ARVALID); endproperty
assert property (p2);

// Disable during reset: data_out 0xFF -> 0xAA:
property p1; @(posedge clk) disable iff (reset) (data_out == 8'hFF) |-> (data_out == 8'hAA); endproperty
assert property (p1);

// If mode==1, output must toggle within 4 cycles of input:
property p1; @(posedge clk) mode==1 |-> ##[1:4] !$stable(output) |=> ##1 !$stable(input); endproperty
assert property (p1);

// Data stays stable across valid/ready handshake:
property p1; @(posedge clk) disable iff (reset) (valid && ready) |-> ##1 $stable(data); endproperty
assert property (p1);

// Read/Write mutual exclusivity:
assert property (@(posedge clk) !(RD_EN && WR_EN));

/**********************************************************
PROTOCOL-SPECIFIC / REAL-WORLD ASSERTIONS
**********************************************************/

// AMBA APB: PREADY only after PSEL & PENABLE:
property p1; @(posedge clk) disable iff (reset) (PSEL && PENABLE) |=> PREADY; endproperty
assert property (p1);

// DDR: Two-cycle delay between read_enable and data_out:
property p1; @(posedge clk) disable iff (reset) rd_en |=> ##[2] data_out; endproperty
assert property (p1);

// UART: Start bit followed by 8 data bits and stop bit:
property p1; @(posedge clk) disable iff (reset) start_bit |=>
(data[0] ##1 data[1] ##1 data[2] ##1 data[3] ##1
data[4] ##1 data[5] ##1 data[6] ##1 data[7]) ##1 stop_bit; endproperty
assert property (p1);

// Interrupt serviced within 5 cycles:
property p1; @(posedge clk) disable iff (reset) irq |-> ##[1:5] irq; endproperty
assert property (p1);

// Pipeline: valid must wait for ready:
property p1; @(posedge clk) disable iff (reset) valid |-> ##[1:$] ready; endproperty
assert property (p1);

/**********************************************************
CORNER CASES & DEBUGGING ASSERTIONS
**********************************************************/

// Power management: clk stable when power_down:
property p1; @(posedge clk) disable iff (reset) power_down |-> $stable(clk); endproperty
assert property (p1);

// FSM illegal state detection:
typedef enum logic [2:0] {IDLE=3'b000, RUN=3'b001, STOP=3'b010} f_state_t;
f_state_t fsm_state;
property p1; @(posedge clk) disable iff (reset) (fsm_state inside {IDLE, RUN, STOP}); endproperty
assert property (p1) else $fatal("Illegal FSM state");

// Error cleared within 2 cycles:
property p1; @(posedge clk) disable iff (reset) error |-> ##[1:2] !$isunknown(error); endproperty
assert property (p1);

// Cross-domain synchronization:
property p1; @(posedge clk1) disable iff (reset) async_sig |-> ##1 @(posedge clk2) $stable(async_sig); endproperty
assert property (p1);

// Protocol timeout: req must be followed by resp in 10 cycles:
property p1; @(posedge clk) disable iff (reset) req |-> ##[1:10] resp; endproperty
assert property (p1);

// Branch misprediction: ensure pipeline flushes properly (user to specify signal semantics)


// Exercise 1: Signal Stability
// Question:
// Write an assertion to check that a signal clk remains stable during the simulation (no glitches).

assert property @(posedge clk) $stable(clk) else $error(“glitch”);

// Exercise 2: Active High Signal
// Question:
// Write an assertion to ensure that a signal enable is always high during normal operation.

assert property @(posedge clk) normal_op |-> en;

// Exercise 3: Range Check
// Question:
// Write an assertion to verify that a signal data always lies between 0 and 255.

assert(data>0 && data<255);

// Exercise 4: Signal Toggle
// Question:
// Write an assertion to check that a signal flag toggles its value (changes from 0 to 1 or 1 to 0) every clock cycle.

assert property @(posedge clk) !($stable(flag)) else $error(“”);

// Exercise 5: Reset assertion
// Question:
// Write an assertion to ensure that a reset signal remains active for at least 3 clock cycles after it is asserted.

property p1;
@(posedge clk) reset |-> ##[*3:$] reset 
endproperty
assert property (p1) else $error(“”);

// Exercise 6: Rising Edge Detection
// Question:
// Write an assertion to check that a signal start transitions from low to high ($rose(start)).

assert property @(posedge clk) $rose(start) else $error(“error”);

// Exercise 7: Mutual Exclusivity
// Question:
// Write an assertion to ensure that two signals write_enable and read_enable are not high at the same time.

property p1;
@(posedge clk) !(wr_en && rd_en) |-> $error(“”);
endproperty
assert property (p1);


// Exercise 8: Sequence Check
// Question:
// Write an assertion to verify that after a signal start is asserted, the sequence of signals (a, then b, then c) occurs in order.

property p1;
@(posedge clk) start |-> (a ##1 b ##1 c);
endproperty
assert property (p1) else $error(“”);

// Exercise 9: FIFO Overflow
// Question:
// Write an assertion to detect when a write_enable signal is asserted while the FIFO is full (fifo_full).

property p1;
@(posedge clk) 
FIFO_FULL |-> !(WRITE_ENABLE)
endproperty
assert property (p1);

// Exercise 10: Data Validity
// Question:
// Write an assertion to ensure that a data signal is never in an unknown state (X or Z) during normal operation.

property p1;
@(posedge clk) normal_op |-> !($isunknown(data));
Endproprty
assert property (p1) else $error(“”);

// Exercise 11: Timing Window
// Question:
// Write an assertion to ensure that a signal ready goes high within 3 clock cycles after valid is asserted.

property p1;
@(posedge clk) valid |-> ##[1:3] $rose(ready);
endProperty
assert property (p1)  else $error(“”);


// Exercise 12: One-Hot Encoding
// Question:
// Write an assertion to check that out of three signals (s0, s1, s2), only one signal is high at any given time.

property p1 ;
@(posedge clk) $onehot({s0,s1,s2});
endproperty
assert property (p1) else $fatal(“error”);


// Exercise 13: Handshake Protocol
// Question:
// Write an assertion to verify that when a req signal is high, an ack signal becomes high in the next clock cycle.

property p1 ;
@(posedge clk) req |=> $rose(ack);
endproperty
assert property (p1)
else $fatal(“error”);


// Exercise 14: Conditional assertion

// Question:
// Write an assertion to ensure that when mode is high, the signal output is always greater than input.

property p1;
@(posedge clk) mode |-> (output>input);
endproperty
assert property (p1)
else $fatal(“assertion failed”);

// Exercise 15: Event Count
// Question:
// Write an assertion to check that a signal event goes high exactly 5 times during a simulation.

property p1;
@(posedge clk) $rose(event) [=5];
endproperty
assert property (p1)
else $fatal(“assertion failed”);
