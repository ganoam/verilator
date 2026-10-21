// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Wilson Snyder
// SPDX-License-Identifier: CC0-1.0
interface intf (
    input logic clk
);
  logic [7:0] sig;

  clocking cb @(posedge clk);
    input sig;
  endclocking

  // Bound statically to ONE instance's clone; the clocking event and the
  // sampled 'sig' must come from the instance vif points to.
  task automatic sample(output logic [7:0] got, output time t);
    @(cb);
    got = cb.sig;
    t   = $time;
  endtask
endinterface

class Mon;
  virtual intf vif;
  task automatic run(output logic [7:0] got, output time t);
    vif.sample(got, t);
  endtask
endclass

module t;
  logic clk_a = 0, clk_b = 0;

  intf if_a (.clk(clk_a));
  intf if_b (.clk(clk_b));

  always #5  clk_a = ~clk_a;   // posedges at 5, 15, 25...
  always #10 clk_b = ~clk_b;   // posedges at 10, 20, 30...

  initial begin
    automatic Mon ma = new;
    automatic Mon mb = new;
    automatic logic [7:0] ga, gb;
    automatic time ta, tb;

    if_a.sig = 8'haa;
    if_b.sig = 8'hbb;
    ma.vif = if_a;
    mb.vif = if_b;

    fork
      ma.run(ga, ta);
      mb.run(gb, tb);
    join

    $display("a: sig=%0x t=%0t   b: sig=%0x t=%0t", ga, ta, gb, tb);

    // Buggy binding: both calls wait on the last-linked instance's
    // clocking block -> wrong time and/or wrong sampled data.
    if (ta != 5  || ga != 8'haa) $stop;
    if (tb != 10 || gb != 8'hbb) $stop;

    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule
