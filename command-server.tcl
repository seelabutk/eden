#!/usr/bin/env tclsh

########################################################################
#
# command-server.tcl
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

proc streq {str1 str2} {string equal $str1 $str2}

set usage "usage:$argv0 <restart_flag> <run_dir>"
if { $argc < 2 } { puts $usage; exit 1 }

set restart_flag [lindex $argv 0]
set run_dir [lindex $argv 1]
set command_count 0
set exit_condition false

proc read_line {{fd stdin}} {
    global command_count exit_condition restart_flag run_dir
	if { [gets stdin line] < 0 } { set exit_condition true; return $line}
    # if we're doing a restart, need to check commands_done file; if command
    #   has already been completed, read another line
    if { $restart_flag == 1 } {
        while { ! [catch { exec grep ^0*$command_count$ $run_dir/commands_done } msg] } {
	        if { [gets stdin line] < 0 } { set exit_condition true; break }
            incr command_count 
        }
    }
    set result "$command_count $line"
    incr command_count
    return $result }
        
proc serve {chan addr port} {
    set line [read_line stdin]
    puts $chan $line
    close $chan }

set sock [socket -server {serve} 0] 

# get port number and append to eden.config
set sock_info [fconfigure $sock -sockname]
set port [lindex $sock_info 2]
set f [open $run_dir/eden.config a]
puts $f "export adam_hostport=$port"
close $f

vwait exit_condition
