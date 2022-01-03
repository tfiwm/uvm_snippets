import uvm_pkg::*;
`include "uvm_macros.svh"

class my_txn extends uvm_sequence_item;
    int in,out;
    function new(int i=0);
        in = i;
    endfunction
endclass

class my_driver extends uvm_driver #(my_txn);
    `uvm_component_utils(my_driver)
    `uvm_new_func
    int out;

    task run_phase(uvm_phase phase);
        my_txn txn,rsp;
        forever begin 
            seq_item_port.get_next_item(txn);
            send_to_dut(txn);
            rsp = new();
            rsp.set_id_info(txn);
            rsp.out = out;

            //send reponse using put_reponse()
            //seq_item_port.item_done();
            //seq_item_port.put_response(rsp);

            //send reponse using item_done()
            //seq_item_port.item_done(rsp);

            //send reponse using put()
            seq_item_port.item_done();
            seq_item_port.put(rsp);
        end
    endtask
    task send_to_dut(my_txn txn);
        `uvm_info("MYDRV",$sformatf("Sending transaction %0d to DUT",txn.in),UVM_MEDIUM)
        #10
        out = txn.in ** 2;
    endtask
endclass
class my_agent extends uvm_agent;
    `uvm_component_utils(my_agent)
    `uvm_new_func

    uvm_sequencer #(my_txn) sqr;
    my_driver dvr;
    
    function void build_phase(uvm_phase phase);
        //super.build_phase(phase);
        dvr = my_driver::type_id::create("dvr",this);
        sqr = new("sqr");
    endfunction
    function void connect_phase(uvm_phase phase);
        this.dvr.seq_item_port.connect(this.sqr.seq_item_export);
    endfunction

endclass

class my_sequence extends uvm_sequence #(my_txn);
    `uvm_object_utils(my_sequence)

    task body();
        my_txn txn,rsp;
        for( int i = 0 ; i < 10; i++) begin 
            //txn = my_txn::type_id::create("txn");
            txn = new(i);
            start_item(txn);
            finish_item(txn);
            //`uvm_info("MYSQNCE","finish_item() returned",UVM_MEDIUM)
            get_response(rsp);
            `uvm_info("MYSQNCE",$sformatf("Got reponse: %0d",rsp.out),UVM_MEDIUM)
        end
    endtask

endclass

class my_test extends uvm_test;
    `uvm_component_utils(my_test)
    my_sequence sqc;
    my_agent agt;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        agt = my_agent::type_id::create("agt",this);
        sqc = my_sequence::type_id::create("sqc");
    endfunction
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        //do_work();
        sqc.start(agt.sqr);
        phase.drop_objection(this);
    endtask
    task do_work();
        `uvm_info("MYTEST","doing some work",UVM_NONE)
    endtask
endclass

module test();

    initial begin 
        run_test("my_test");
    end
endmodule
