#!/usr/bin/env tclsh

########################################################################
#
# line-listener.tcl
# Copyright (C) 2011 Scott Simmerman
#
# This file is part of Eden.
#
# Eden is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# Eden is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Eden.  If not, see <http://www.gnu.org/licenses/>.
#
########################################################################

set usage "usage:$argv0 <cmd_count> <run_dir>"
if { ![expr $argc == 2] } { puts $usage; exit 1 }

set cmd_count [lindex $argv 0]
set run_dir [lindex $argv 1]
set counter 0
set debug 0
set exit_condition false

proc serve {chan addr port} {
    global debug
    global cmd_count run_dir counter exit_condition
    #if { $debug } { puts "Connected from $addr\:$port on $chan" }
    #puts "line-listener - Connected from $addr\:$port on $chan"
    set f [open $run_dir/commands_done a]
    puts $f [read -nonewline $chan]
    close $f
    incr counter
    if { $counter >= $cmd_count } { set exit_condition true }
    #puts "counter = $counter, exit_condition = $exit_condition"
    close $chan }

set sock [socket -server serve 0]

# get port number and append to eden.config
set sock_info [fconfigure $sock -sockname]
set port [lindex $sock_info 2]
set f [open $run_dir/eden.config a]
puts $f "export adam_readport=$port"
close $f

vwait exit_condition
