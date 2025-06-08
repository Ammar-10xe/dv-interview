//Things to keep in mind
//Constraint won't allow the use of queue pushbacks, while, for and if, else procedural style blocks
//But you can use foreach, if, else with {} instead of begin and end but not for
//to implement your logic like queue pushbacks those can be done inside post_randomize()
/////////////////////////////////////////////////////////////
typedef enum {READ, WRITE} op_t;

class transaction extends uvm_sequence_item;
    rand bit [31:0] starting_address;
    rand bit [31:0] address;
    rand bit [7:0] data;
    rand op_t op;

    //1. keep track of which locations are you writing inside a queue
    static bit [31:0] write_history[$]; //to make sure it is shared among all

    constraint address_range {
        if(op == WRITE) {
            address inside {[starting_address:starting_address + 32'h200]};
        }
        else if(op == READ) {
            address inside {write_history}; //address should be inside the queue
        }
    }

    //2. function to update the queue with write address
    function void post_randomize();
        if(op == WRITE) begin
            write_history.push_back(address);
        end
    endfunction
endclass

////////////////////////////////////////////////////////
//3. randc functionality without using randc

class packet;
    rand bit [1:0] y;
    bit [1:0] q[$];

    constraint c1 {
        !(y inside {q});
    }

    function void post_randomize();
        q.push_back(y);
        if(q.size() == 4) q.delete();
    endfunction
endclass

//////////////////////////////////////////////////
//4. You have three variables x,y,z but we need to randomize only x & z but not y .

Class packet;
    rand bit [7:0] x,y,z;
    constraint c1 {x inside {[5:10]};}
    constraint c2 {y%5==0;}
    constraint c3 {z%2==1;}
endclass

module test;
    packet p;

    initial begin
        p.y.rand_mode(0);
        p.randomize();
    end
endmodule

////////////////////////////////////////////////////
//5. constraint for generating the 2 power numbers with out using  **
class packet;
    rand bit [6:0] a[];

    constraint c1 {
        a.size() inside {[5:10]};
        foreach (a[i]) {
            if( i < 10) {
                a[i] == 1 << (i+1);
            }
        }
    }
endclass

////////////////////////////////////////////////////
//6. Constraint for array size b/w 20 & 30 and the values of array in descending order
class packet;
    rand bit [7:0] a[];

    constraint c1 {
        a.size() inside {[20:30]};
        foreach(a[i]) {
            if( i < a.size() - 1) {
                a[i+1] < a[i];
            }
        }
    }
endclass

////////////////////////////////////////////////////
//7. constraint for generating the even index’s odd number and odd index’s even numbers

class packet;
    rand bit [7:0] a[];

    constraint c1 {
        a.size() inside {[5:10]};
        foreach (a[i]) {
            if(i%2 == 0) {
                //a[i]%2 != 0;
                a[i][0] == 1; //preferred
                //(a[i] << 1) >> 1 != a[i]; //alternate
            }
            else {
                (a[i] >> 1) << 1 == a[i];
            }
        }
    }
endclass

/////////////////////////////////////////////////////
//8: Constraint for generating the i%2==0(even) values in ascending order i%2==1(odd) values in descending order

class packet;
    rand bit [7:0] a[];

    constraint c1 {
        a.size() == 10;
        foreach(a[i]) {
            if(i >= 2){
                if(i%2==0) {
                    a[i] > a[i-2];
                }
                else if(i%2 == 1) {
                    a[i] < a[i-2];
                }
            }
        }
    }
endclass

////////////////////////////////////////////////////////
//9. constraint for generating the sequence 01002000300004000005.

class packet;
    rand int num;
    int q[$];
    constraint c1 {
        num == 5;
    }

    function void post_randomize();
        for(int i = 1; i <= num; i++) begin
            repeat(i) q.push_back(0);
            q.push_back(i);
        end
    endfunction
endclass

////////////////////////////////////////////////////////
//10. constraint for generating the two consecutive bits as 1.

class packet;
    rand bit [3:0] idx;
    rand bit [15:0] data;

    constraint c1 {
        idx < 15;
        data == 3 << idx;
        //alternate way
        foreach(a[i]) {
            if(i < a.size() - 1) {
                a[i] & a[i+1] == 1'b1;
            }
        } 
    }
endclass

module tes;
    packet pkt;

    initial begin
        pkt = new();
        pkt.randomize();
    end
endmodule

//alternate 
class packet;
    rand bit [7:0] a;  // 8-bit vector

    constraint c1 {
        // Ensure two consecutive bits are 1
        (a[0] && a[1]) ||  // Consecutive bits at positions 0-1
        (a[1] && a[2]) ||  // Consecutive bits at positions 1-2
        (a[2] && a[3]) ||  // Consecutive bits at positions 2-3
        (a[3] && a[4]) ||  
        (a[4] && a[5]) ||  
        (a[5] && a[6]) ||  
        (a[6] && a[7]);    // Consecutive bits at positions 6-7
    }
endclass

/////////////////////////////////////////////////////////
//11. Constraint for generating the 5,-10,15,-20,25,-30…

class packet;
    rand bit [7:0] a[10];

    constraint c1 {
        foreach(a[i]) {
            if(i%2 == 1) {
                a[i] == -5*(i+1);
            }
            else {
                a[i] == 5*(i+1);
            }
        }
    }
endclass

//alternative
class packet;
    bit [7:0] q[$];
    function void post_randomize();
        for(int i = 0; i < 10; i++) begin
            if(i%2 == 0) q.push_back(5*(i+1));
            else q.push_back(-5*(i+1));
        end
    endfunction
endclass

//12. Constraint for generating the even numbers b/w 1:100

class packet;
    rand int num;
    int q[$];

    constraint c0 {
        a inside {[2:2:100]};//start at 2, increment by 2 upto 100
    }

    constraint c2 {
        num >= 1;
        num <= 100;
        num % 2 == 0;
    }

    constraint c1 {
        num inside $urandom_range([1:100]);
    }
    //function that returns 1 if th given number is even
    function bit even(int num);
        for(int i = 1; i < num; i++) begin
            if(i%2 == 0) begin
                return 1;
            end
            else return 0;
        end
    endfunction

    function void post_randomize();
            if(even(num)) begin
                q.push_back(num);
            end
    endfunction

    //alternate 
    function void post_randomize();
        for(int i = 1; i <= 100; i++) begin
            if(i % 2 == 0) begin
                q.push_back(i);
            end
        end
    endfunction
endclass


//13. constraint for even or odd number

class packet;
    rand int num;

    constraint c0 {
        a inside {[2:2:100]};//start at 2, increment by 2 upto 100
    }

    constraint is_even {
        num inside {[1:100]};
        (num >> 1) << 1 == num; 
        num[0] == 0;
        a inside {[2:2:100]};
    }

    constraint is_odd {
        num inside {[1:100]};
        (num >> 1) << 1 != num;
        num[0] == 1;
        a inside {[1:2:99]};
    }
endclass

module test;
    packet p;
    initial begin
        p = new();
        repeat(10) begin
            p.is_even.constraint_mode(0);
            p.randomize();
            $display("Number: %0d", p.num);
        end
    end
endmodule

//14. generate even and odd values based on a flag is_even

/*
class packet;
    rand bit is_even;

    int q[$]; //using a queue
    rand bit [7:0] a[]; //using a dynamic vector

    constraint c1 {
        a.size() inside {[5:10]};
    }

    function void post_randomize();
        for(int i = 0; i < a.size(); i++) begin
            int val = $urandom_range(0, 100);
            if(is_even) begin
                val = val & ~1; //clear LSB to make it even
            end
            else begin
                val = (val & ~1) + 1;
            end
            q.push_back(val);
            a[i] = val;
        end
    endfunction
endclass

*/

//15. generate even and odd values based on even and odd index values

class packet:
    int q[$];
    rand bit [7:0] a[];

    constraint c1 {
        a.size() inside {[5:10]};
    }

    function void post_randomize();
        q.delete();

        for(int i = 0; i < a.size(); i++) begin
            int val = $urandom_range(0, 100);

            //check if it is even index or odd index
            if(i%2 == 0)
                val = (val >> 1) << 1;
            else 
                val = ((val >> 1) << 1) + 1; 
            q.push_back(val);
            a[i] = val;
        end
    endfunction
endclass

//16. probability distribution and implication operator 

class generator;

    randc bit [3:0] a;
    rand bit ce;
    rand bit rst;

    constraint control_rst {
        rst dist { 0 := 80, 1 := 20};
    }

    constraint control_ce {
        ce dist { 1 := 80, 1 := 20};
    }

    constraint constrol_rst_ce {
        (rst == 0) -> (ce == 1); //implecation operator if rst = 0 then ce must be 1
    }
endclass

module tb;
    generator g;
        initial begin
            g = new();

            repeat(10) begin
                assert(g.randomize());
            end
        end
endmodule

//17. constraint to only make 10 bits as one and these 10 bits shouldn't be adjacent

class transaction extends uvm_sequence_item;

    rand bit [31:0] addr;

    constraint c1 {
        $countones(addr) == 10;
    }

    constraint c2 {
        foreach(addr[i]) {
            if(i < 31) {
                !(addr[i] == 1 && addr[i+1] == 1);
            }
        }
    }
endclass

//18: fork - join question

    class A;
        task check(int delay);
        fork
            begin
            #30;
            $display(" end of process-1 %t\n",$time); 
            end
        join_none
        fork
            begin
                #10;
                $display(" end of process-2 %t\n",$time);
            end
            begin
                #20;
                $display(" end of process-3 %t\n",$time);
            end
        join_any
        disable fork; //this will disable all the other forks that are running
        $display(" end of -check task- %t\n",$time);
        endtask  
    endclass
    
    module test;
        A i_a;
        i_a = new;
        i_a.check();
        #100; 
    endmodule 

    /*
    end of process-2, 10ns
    end of -check task- 10ns
    */


 //19. Override a constraint from a based class in an extended class. The base class should have a constraint for length inside 1 to 15 
 //and extended class should have a constraint for length between 16 to 20

    //couple of ways to do this - inline constraints or inheritance
    class base_class;
        rand int length;

        constraint c1 {
            length inside {[1:15]};
        }
    endclass

    class extended_class extends base_class;

        constraint c1 {
            length inside {[16:20]};
        }
    endclass

    //inline constraint example this should be done inside the module
    item.randomize with {val1 > 150; val1 < 160;};
    item.randomize with {val2 inside {[10:15]};};

//20. constraint to check a power of 2 value

    constraint c1 {

        length inside {[1:64]}
        (length & (length - 1)) == 0; //only true for powers of two
    }


//21: only two bits should be flipped

    class bit_flip_constraint;
        rand bit [31:0] curr_val;
            bit [31:0] prev_val;
    
        constraint flip_two_bits {
        $countones(curr_val ^ prev_val) == 2;
        }
    endclass

//22: Write rand constraint on a 3 bit variable with distribution 60% for 0 to 5 and 40% for 6,7. Write coverpoint for the same.
    
    class rand_class;
        rand bit [2:0] a;

        constraint c1 {
            a dist {[0:5] := 60, [6:7] := 40};
        }

        covergroup cg;
            option.per_instance = 1;
            coverpoint a {
                bins low_range = {[0:5]};
                bins higher_range = {[6:7]};
            }
        endgroup

    endclass

////////////////////////////////////////////////////////////////


//23: check if the number is divisible for 5 or not

class div_by_5_class;
    rand int num;
    rand int k;

    constraint c1 {
        num == 5 * k; //for some k
    }

    //optionally constraint the range of k
    constraint range_k {
        k inside {[0:20]}; //if num max value is from 0 to 100
    }
endclass

///////////////////////////////////////////////////////////////////

//24: Write a constraint to generate only odd numbers between 5 and 15 excluding any consecutive odd numbers

class odd_constraint;
    rand bit [3:0] arr[]; // Array to hold the odd numbers
  
    constraint size_c {
      arr.size() inside {[1:6]}; // Optional: limit array size
    }

    constraint range_c {
        foreach(arr[i]){
            arr[i] inside {[5:2:15]};
        }
    }

    //alternate for range_c
    constraint range_c_alternative {
        foreach(arr[i]){
            arr[i] inside {[5:15]};
        }
        arr[i][0] == 1;
    }

    constraint non_consecutive {
        foreach(arr[i]){
            if(i > 0){
                arr[i] != arr[i-1] + 2; //prevent consecutive odd number
            }
        }
    }
endclass

///////////////////////////////////////////////////////////////////

//25: randomize 2D array in SV with each row sorted

constraint row_sorted {
    foreach(a[i]) {
        foreach(arr[i][j]) {
            if(j > 0) {
                arr[i][j] >= arr[i]arr[j-1];
            }
        }
    }
}

////////////////////////////////////////////////////////////////////

//26: assume there is a 1kb memory and 3 agents with 256 b where address should be unique for each agent 

rand bit [9:0] base_addr[3]; //3 agents , 10 bit address space

constraint c1 {
    foreach(base_addr[i]) {
        base_addr[i] inside {[0:255], [256:511], [512:767]};
    }
    //but the above might give an unaligned address that might start in any range specified 
    //but you the address to be aligned with 256 b then specify the start address as aligned values

    foreach(base_addr[i]) {
        base_addr[i] inside {0, 256, 512, 768};
    }
    
    unique {base_addr[0], base_addr[1], base_addr[2]};
    //alternate way
    base_addr[0] != base_addr[1];
    base_addr[1] != base_addr[2];
    base_addr[2] != base_addr[3];
}

//generate 32 bit random number with the 10 consecutive zero's
class random_constraingt_problem;
  
  rand bit [31:0] x;
  rand int position_of_zeros;
  
  constraint c_position_of_zeros { position_of_zeros >= 0; position_of_zeros <=22; }
  
  function void post_randomize();
    int y = (32'hffffffff << (position_of_zeros + 10) | 32'hffffffff >> (32 - position_of_zeros));
    $display("y = %0h, position of zeros = %0d, x&y = %0h", y, position_of_zeros, x&y);
    x = x & y;
    $display("x = %0h", x);
    if ($countones(x) >22) $error("Randomization failed");
  endfunction

endclass


module tb_top();
  random_constraingt_problem inst_1;
  
  initial begin
    inst_1 = new();
    
    repeat(10) begin
      inst_1.randomize();
    end
    
  end

endmodule

//random array of 25 numbers with odd numbers in even positions and even numbers in odd positions

class random_constraingt_problem;
  
  rand int arr [25];
  
  constraint c1 { foreach (arr[i])
    (i%2 == 0) -> arr[i] % 2 == 1;
                }
  
  constraint c2 { foreach (arr[i])
    (i%2 == 1) -> arr[i] % 2 == 0;
                }

  function void post_randomize();
    foreach (arr[i]) begin
      $write("arr[%0d] = %0d ", i, arr[i]);
    end
  endfunction

endclass


module tb_top();
  random_constraingt_problem inst_1;
  
  initial begin
    inst_1 = new();
    
    repeat(1) begin
      inst_1.randomize();
    end
    
  end

endmodule

//generate 32 bit random number with the 10 zero's

class random_constraingt_problem;
  
  rand bit [31:0] rand_var;
  
  constraint c1 { $countones(rand_var) == 22; }

  function void post_randomize();
    $display("rand_var = %0h", rand_var);
  endfunction

endclass


module tb_top();
  random_constraingt_problem inst_1;
  
  initial begin
    inst_1 = new();
    
    repeat(10) begin
      inst_1.randomize();
    end
    
  end

endmodule

//Write a constraint where you have a 32 bit value bit [31:0] val 
//where you'd want to randomize this to where every randomization 
//would only allow 2 bits to differ from the previous randomization.

class random_constraingt_problem;
  
  rand bit [31:0] rand_var;
  bit [31:0] inter_var;
  int count = 0;
  
  constraint c1 { $countones(rand_var ^ inter_var) == 2; }
  
  function void pre_randomize();
    if (count == 0) begin 
      c1.constraint_mode(0);
      count++;
    end
    else c1.constraint_mode(1);
  endfunction

  function void post_randomize();
    inter_var = rand_var;
    $display("rand_var = %0h", rand_var);
  endfunction

endclass


module tb_top();
  random_constraingt_problem inst_1;
  
  initial begin
    inst_1 = new();
    
    repeat(10) begin
      inst_1.randomize();
    end
    
  end

endmodule

//// Write code to emit random numbers between 1 and 10 (inclusive).
// The first number can be either odd or even. From that point onwards,
// the generator should alternate between even and odd numbers.

class random_constraingt_problem;
  
  rand int rand_var;
  bit [31:0] inter_var;
  int count = 0;
  
  constraint c1 { rand_var%2 != inter_var%2; }
  constraint c2 { rand_var>=1; rand_var <= 10; }
  
  function void pre_randomize();
    if (count == 0) begin 
      c1.constraint_mode(0);
      count++;
    end
    else c1.constraint_mode(1);
  endfunction

  function void post_randomize();
    inter_var = rand_var;
    $display("rand_var = %0h", rand_var);
  endfunction

endclass


module tb_top();
  random_constraingt_problem inst_1;
  
  initial begin
    inst_1 = new();
    
    repeat(10) begin
      inst_1.randomize();
    end
    
  end

endmodule


//// Write a code to randomize an array of length 6 20 times such that
// on every 5th call the all array elements has same value except for
// while on 20th call all the array elemnets have the same value
// on the rest of the calls which are niether 5th calls or 20th call completely randomize the array

class random_constraingt_problem;
  
  rand bit [4:0] arr[6];
  rand bit [4:0] random_index;
  rand bit [4:0] intr_var_1;
  rand bit [4:0] intr_var_2;
  int count = 1;
  
  constraint c_rand_index { random_index >=0; random_index<=5; }
  
  function void post_randomize();
    if ((count%5==0) && (count != 20)) begin
      arr[random_index] = intr_var_1;
      foreach (arr[i]) begin
        if (i == random_index) continue;
        else begin 
          arr[i] = intr_var_2;
        end
      end
    end
    else if (count == 20) begin
      foreach (arr[i]) begin
        arr[i] = intr_var_1;
      end
    end
    $write("%0d) ",count);
    foreach (arr[i]) begin
      $write("arr[%0d] = %0d ", i, arr[i]);
    end
    $display;
    count++;
  endfunction

endclass


module tb_top();
  random_constraingt_problem inst_1;
  
  initial begin
    inst_1 = new();
    
    repeat(20) begin
      inst_1.randomize();
    end
    
  end

endmodule