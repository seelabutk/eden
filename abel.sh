#!/bin/sh

########################################################################
#
# abel.sh
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

# Check for proper usage
usage="usage:$0 <conf-file>"
[ $# -ne 1 ] && echo $usage && exit 1

# Import config file
. $1

# Get first command from command-server.tcl
command=$($eden_path/command-client.tcl $adam_hostname $adam_hostport)

# process remainder of commands
while [ -n "$command" ]; do
    linenum=$(echo "$command" | cut -d' ' -f1)
    # pad linenum
    linenum=$(eval "printf \"%0${num_digits}d\" \$linenum")
    command=$(echo "$command" | cut -d' ' -f2-)

    # run command; timing goes to a file, stdout/stderr go to files
    /usr/bin/time -p sh -c "{ $command ; } >$outfiles_dir/$linenum.out 2>$outfiles_dir/$linenum.err" > $outfiles_dir/$linenum.time 2>&1

    # send line number back to line-listener
    echo "$linenum" | $eden_path/line-send.tcl $adam_hostname $adam_readport

    command=$($eden_path/command-client.tcl $adam_hostname $adam_hostport)
done

