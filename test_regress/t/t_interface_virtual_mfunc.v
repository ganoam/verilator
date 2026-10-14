// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Wilson Snyder
// SPDX-License-Identifier: CC0-1.0

interface intf ();
  int id;

  function automatic string gfn();
    return $sformatf("%m (id = %0d)", id);
  endfunction
endinterface

class Agt;
  virtual intf vif;
  string name;

  function new(string name);
    this.name = name;
  endfunction

  function void check();
    string got;
    got = vif.gfn();
    $display("%s: vif.id=%0d gfn=%s", name, vif.id, got);
    // %m must report the instance the vif was bound to, not a fixed one
    if (vif.id == 1 && got != "t.if_a.gfn (id = 1)") $stop;
    if (vif.id == 2 && got != "t.if_b.gfn (id = 2)") $stop;
  endfunction
endclass

module t;
  intf if_a ();
  intf if_b ();

  initial begin
    automatic Agt agt_a = new("agt_a");
    automatic Agt agt_b = new("agt_b");
    if_a.id = 1;
    if_b.id = 2;
    agt_a.vif = if_a;
    agt_b.vif = if_b;
    agt_a.check();
    agt_b.check();
    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule
