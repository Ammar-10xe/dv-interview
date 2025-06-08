//This file is prepared from PROV Logic "UVM Specific Interview questions pdf" file. I only extracted the questions that i found interesting

/*
1. Write a UVM testbench that implements a producer and a
consumer using TLM blocking ports. Ensure that the producer
generates 10 integer values, and the consumer retrieves and
logs them.
*/

class producer extends uvm_component;

        uvm_blocking_put_port #(int) put_port;

        function new(input string path = "producer", uvm_component parent = null);
            super.new(path, parent);
            put_port = new("put_port", this);
        endfunction

        task run_phase(uvm_phase phase);
            for(int i = 0; i < 10; i++) begin
                int val = $urandom_range(0, 10);
                put_port.put(val);
                `uvm_info("PRODUCER", $sformatf("value: %0d", val), UVM_MEDIUM)
            end
        endtask
    endclass

    class consumer extends uvm_component;

        uvm_blocking_get_port #(int) get_port;

        function new(input string path = "consumer", uvm_component parent = null);
            super.new(path, parent);
            get_port = new("get_port", this);
        endfunction

        task run_phase(uvm_phase phase);
            int data;
            while(1) begin
                get_port.get(data);
                `uvm_info("CONSUMER", $sformatf("Data recv: %0d", data), UVM_MEDIUM)
            end
        endtask
    endclass

    class top_env extends uvm_env;
        producer prod;
        consumer cons;

        //function new

        virtual function void build_phase(uvm_phase phase);
            prod = producer::type_id::create("prod", this);
            cons = consumer::type_id::create("cons", this);
        endfunction

        virtual function void connect_phase(uvm_phase phase);
            super.build_phase(phase);
            prod.put_port.connect(cons.get_port);
        endfunction
    endclass

    class top_test extends uvm_test;

        top_env env;

        //function new

        virtual function void build_Phase(uvm_phase phase);
            super.build_Phase(phase);
            env = top_env::type_id::create("env", this);
        endfunction

endclass

/*
2. Create a UVM environment where a producer sends data to
two subscribers using analysis ports. Implement the producer to
broadcast 10 data values and verify that both subscribers
receive the data correctly.
*/

class producer extends uvm_component;

        uvm_analysis_port #(int) analysis_port;

        //function new

        virtual task run_phase (uvm_phase phase);
            analysis_port = new("analysis_port", this);
            for(int i = 0; i < 10; i++) begin
                int data = $urandom_range(0, 10);
                analysis_port.write(data);
            end
        endtask
    endclass

    class subscriber extends uvm_component;

        uvm_analysis_imp #(int, subscriber) analysis_imp;

        //function new

        task write();
            $uvm_info("SUBSCRIBER", $sformatf("recv data: %0d", data), UVM_MEDIUM)
        endtask
    endclass

    class top_env extends uvm_env;

        producer prod;
        subscriber sub1, sub2;

        //function new

        virtual function build_Phase(uvm_phase phase);
            super.build_Phase(phase);
            prod = producer::type_id::create("prod", this);
            sub1 = subscriber::type_id::create("sub1", this);
            sub2 = subscriber::type_id::create("sub2", this);
        endfunction

        virtual function void connect_phase(uvm_phase phase);
            super.connect_phase(uvm_phase phase);
            prod.analysis_port.connect(sub1.analysis_imp);
            prod.analysis_port.connect(sub2.analysis_imp);
        endfunction
    endclass

    class top_test extends uvm_test;
        top_env env;

        //function new

        virtual function build_Phase(uvm_phase phase);
            super.build_Phase(phase);
            env = top_env::type_id::create("env", this);
        endfunction

endclass


/*
3. Demonstrate how to use the UVM factory mechanism to
override a base sequence with an extended sequence in a
testbench. Ensure that the overridden sequence runs during
the simulation.
*/

class base_sequence extends uvm_sequence#(uvm_sequence_item);
        `uvm_object_utils(base_sequence)

        //function new

        task body();
            `uvm_info("BASE", "Base sequence executed", UVM_MEDIUM)
        endtask
    endclass

    class extended_sequence extends uvm_sequence#(uvm_sequence_item);
        `uvm_object_utils(extended_sequence)

        //new

        task body();
            `uvm_info("EXT", "Extended sequence executed", UVM_MEDIUM)
        endtask
    endclass

    class top_test extends uvm_test;
        `uvm_component_utils(top_test)

        //function new

        virtual task run_phase(uvm_phase phase);    
            base_sequence::type_id::_override(extended_sequence::get_type());
            base_sequence seq;
            seq = base_sequence::type_id::create("seq");
            seq.start(null);
        endtask
endclass

/*
4. Implement a UVM testbench where an agent retrieves its
configuration settings from the UVM configuration database.
Set the configuration to specify a data
_
width parameter and
log its value in the agent.
*/

class agent_config extends uvm_object;
        `uvm_object_utils(agent_config)

        int data_width;

        //new

    endclass

    class agent extends uvm_component;
        agent_config config;

        //new

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(agent_config)#get(this, "", "config", config))
                `uvm_fatal("CONFIG", "Unable to access the config")
        endfunction

        virtual task run_phase(uvm_phase phase);
            `uvm_info("AGENT", $sformatf("USing data width : %0d", config.data_width))
        endtask
endclass


/*
6. In UVM, how would you implement phase jumping to skip
directly to the shutdown phase from the run phase? Provide a
complete example.
*/

class tb_test extends uvm_test;
    //new
    function new(string name = "tb_test");
        super.new(name);
    endfunction

    task run_phase(uvm_phase phase);
        phase.jump(uvm_shutdown_phase::get());
    endtask
endclass

/*
7. Write a UVM virtual sequence that coordinates two agents.
Each agent must execute a child sequence. Use a fork-join
construct to run the child sequences in parallel.
*/

class virtual_sequence extends uvm_sequence;

        uvm_sequencer seqr1, seqr2;

        child_seq1 seq1;
        child_seq2 seq2;

        function new(string name = "virtual_sequence");
            super.new(name);
        endfunction

        virtual task body();
            seqr1 = uvm_sequencer::type_id::create("seqr1", this);
            seqr2 = uvm_sequencer::type_id::create("seqr2", this);
            seq1 = child_seq1::type_id::create("seq1");
            seq2 = child_seq2::type_id::create("seq2");

            fork
                seq1.start(seqr1);
                seq2.start(seqr2);
            join
        endtask
    endclass

    class top_test extends uvm_test;

        virtual_sequence vseq;

        function new(string name = "tb_test");
            super.new(name);
        endfunction

        virtual function void build_Phase(uvm_phase phase);
            super.build_phase(phase);
            vseq = virtual_sequence::type_id::create("vseq");
        endfunction

        virtual task run_phase(phase);
            vseq.start(vseqr);
        endtask
endclass

/*
8. Design a scoreboard in UVM that compares incoming data
with a predefined golden reference using an analysis FIFO. Log
a mismatch if the data does not match the golden reference.
*/

class scoreboard extends uvm_scoreboard;

    uvm_analysis_fifo #(int) fifo;
    int golden_model[10];

    function new(string name, uvm_component parent);
        super.new(name, parent);
        fifo = new("fifo", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        int golden_data;
        for(int i = 0; i < 10; i++) begin
            fifo.get(golden_data);
            if(golden_data != golden_model[i]) begin
                `uvm_error()
            end
            else begin
                `uvm_info()
            end
        end
    endtask
endclass

/*
11. Write a UVM sequence that generates randomized
transactions. The sequence should randomize a transaction
item and send it to the sequencer. Ensure the randomization
is controlled via a random seed and log the transaction data.
*/

class random_sequence extends uvm_sequence#(packet_transaction);
        `uvm_object_utils(random_sequence)

        function new(string name = "random_sequence");
            super.new(name);
        endfunction

        task body();
            packet_transaction tr;
            tr = packet_transaction::type_id::create("tr");
            start_item(tr);
            assert(tr.randomize());
            finish_item(tr);
        endtask
    endclass

    class top_test extends uvm_test;
        `uvm_component_utils(top_test)

        function new(string name = "top_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        virtual task run_phase(uvm_phase phase);
            random_sequence seq;
            seq = random_sequence::type_id::create("seq");
            seq.start(env.agent.seqr);
        endtask
endclass

/*
17. Write a UVM testbench that demonstrates the reuse and
chaining of sequences. Sequence A should start after Sequence B completion.
*/

class sequence_A extends uvm_sequence#(packet_transaction);
        `uvm_object_utils(sequence_A)

        function new(string name = "sequence_A");
            super.new(name);
        endfunction

        task body();
            packet_transaction tr;
            tr = packet_transaction::type_id::create("tr");
            start_item(tr);
            assert(tr.randomize());
            finish_item(tr);

            //chain to sequence B
            sequence_B seq_b;
            seq_b = sequence_B::type_id::create("seq_b");
            seq_b.start(null);
        endtask
    endclass

    class sequence_B extends uvm_sequence#(packet_transaction);
        `uvm_object_utils(sequence_B)

        function new(string name = "sequence_B");
            super.new(name);
        endfunction

        task body();
            packet_transaction tr;
            tr = packet_transaction::type_id::create("tr");
            start_item(tr);
            assert(tr.randomize());
            finish_item(tr);
        endtask
    endclass

    class top_test extends uvm_test;

        sequence_A seq_A;

        function new(string name = "top_test");
            super.new(name);
        endfunction

        virtual task run_phase(uvm_phase phase);
            seq_A = sequence_A::type_id::create("seq_A");
            seq_A.start(null); //seq B is chained to seq A
        endtask
endclass

/*
18. Write a UVM testbench that implements an analysis FIFO
for passing data between components. The producer generates
data, and the consumer retrieves it using an analysis FIFO.
*/

class producer extends uvm_component;

        uvm_analysis_fifo #(int) fifo;

        function new(string name = "producer", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        virtual task run_phase(uvm_phase phase);
            fifo = new("fifo", this);
            for(int i = 0; i < 10; i++) begin
                int data = $urandom_range(0, 10);
                fifo.write(data);
            end
        endtask
    endclass

    class consumer extends uvm_component;

        uvm_analysis_fifo #(int) fifo;

        function new(string name = "consumer", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        task write();
            fifo = new("fifo", this);
            int data;
            while(1) begin
                fifo.get(data);
                `uvm_info()
            end
        endtask
endclass

//////////////////////////////////////////////////

//How to control sequence execution order using arbitration

class high_seq extends uvm_sequence;

    task body();
        `uvm_info()
    endtask
endclass

class low_seq extends uvm_sequence;

    task body();
        `uvm_info()
    endtask
endclass

class arb_test extends uvm_test;

    high_seq s1;
    low_seq s2;

    virtual task run_phase(uvm_phase phase);
        s1 = high_seq::type_id::create("s1");
        s2 = low_seq::type_id::create("s2");

        fork 
            begin
                s1.set_priority(200);
                s1.start(seqr);
            end
            begin
                s2.set_priority(100);
                s2.start(seqr);
            end   
        join
    endtask
endclass