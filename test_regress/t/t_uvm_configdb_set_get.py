#!/usr/bin/env python3
# DESCRIPTION: Verilator: Verilog Test driver/expect definition
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of either the GNU Lesser General Public License Version 3
# or the Perl Artistic License Version 2.0.
# SPDX-FileCopyrightText: 2024 Wilson Snyder
# SPDX-License-Identifier: LGPL-3.0-only OR Artistic-2.0

import vltest_bootstrap

test.priority(50)
test.scenarios('vlt')
test.top_filename = 't/t_uvm_configdb_set_get.v'
test.pli_filename = "t/uvm/v2017_1_0/dpi/uvm_dpi.cc"

test.compile(v_flags2=[
    "--binary",
    test.build_jobs_groups,
    "--vpi",
    "--CFLAGS -O0",
    "-Wall",
    "+incdir+t/uvm",  #
    "t/uvm/uvm_pkg_all_v2020_3_2_dpi.svh",
    test.pli_filename
])

test.execute(all_run_flags=['' if test.verbose else '+UVM_NO_RELNOTES'])

test.file_grep(test.run_log_filename, r'UVM TEST PASSED')

test.passes()
