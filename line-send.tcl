#!/usr/bin/env tclsh

########################################################################
#
# line-send.tcl
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

set usage "usage:$argv0 <server> <port>"
if { $argc != 2 } { puts $usage; exit 1 }

set server [lindex $argv 0]
set port [lindex $argv 1]

set sock 0
for {set attempts 0} {$attempts < 9} {incr attempts} {
        if {0 != [catch {global sock; set sock [socket $server $port]}]} {
                after 5000; puts stderr "failed attempt"
        } { break }}

if {$sock == 0} {exit 1}
puts $sock [read -nonewline stdin]
close $sock
