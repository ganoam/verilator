import uvm_pkg::*;

interface intf ();
  int id;

  logic [15:0] sig;

  function automatic string gfn();
    return $sformatf("%m (id = %0d)", id);
  endfunction

  function string probe();
    return $sformatf("%m (id = %0d), sig=0x%h", id, sig);
  endfunction
endinterface



class agt extends uvm_agent;

  `uvm_component_utils(agt)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual intf vif;

  function void build_phase(uvm_phase phase);

    if (!uvm_config_db#(virtual intf)::get(this, "", "vif", vif)) begin
      `uvm_fatal("BUILD",
          $sformatf("\nClass %s line %0d: failed to get vif.\n",
                      this.get_type_name(), `__LINE__))
    end else begin
      `uvm_info(get_full_name, $sformatf("Connected to interface: %s", vif.gfn()), UVM_NONE)
      `uvm_info(get_full_name(),
          $sformatf("vif.id=%0d, probe=%s", vif.id, vif.probe()), UVM_NONE)

    end

  endfunction

endclass

class env extends uvm_env;

  `uvm_component_utils(env)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  agt agt_a;
  agt agt_b;


  // --- Build Phase ---
  function void build_phase(uvm_phase phase);

    agt_a = agt::type_id::create("agt_a", this);
    agt_b = agt::type_id::create("agt_b", this);

  endfunction

endclass

class test extends uvm_test;
  `uvm_component_utils(test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  env e;

  function void build_phase(uvm_phase phase);

    e = env::type_id::create("e", this);

  endfunction

  // (6) Print the topology for easier debugging
  function void end_of_elaboration_phase(uvm_phase phase);
    $display("agt_a vif.id=%0d  ==t.if_a: %0b", e.agt_a.vif.id, e.agt_a.vif == t.if_a);
    $display("agt_b vif.id=%0d  ==t.if_b: %0b", e.agt_b.vif.id, e.agt_b.vif == t.if_b);
    $display("\n");            // add some white space before topology report
    // uvm_top.print_topology();  // prints out the UVM component hierarchy
  endfunction

endclass


module t;
  logic [15:0] sig_a;
  logic [15:0] sig_b;

  intf if_a();
  intf if_b();

  assign if_a.sig = sig_a;
  assign if_b.sig = sig_b;

  initial begin
    if_a.id = 1;
    if_b.id = 2;
    sig_a = 16'hcafe;
    sig_b = 16'h6666;
    uvm_config_db #(virtual intf)::set(null, "*agt_a*", "vif", if_a);
    uvm_config_db #(virtual intf)::set(null, "*agt_b*", "vif", if_b);

    #10;
    run_test("test");
  end


endmodule
