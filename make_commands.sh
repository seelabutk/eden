#!/bin/sh

########################################################################
#
# make_commands.sh
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

# set up cmd line and parameter variables
i=0
nc=1
cmd=''
while read line; do
    # get number of fields
    nf=$(echo $line | awk '{print NF}')

    # skip blank lines
    if test $nf -eq 0; then
      continue
    fi
    # get command from first line
    if test $i -eq 0; then
        cmd="$line"
        i=$(($i+1))
        continue
    fi
    # keep track of num of fields in c 'array'
    eval "c$(($i-1))=$(($nf-1))"
    # total num of combinations
    nc=$(($nc * ($nf-1)))
    # get first field, name of parameter
    eval "pname=\$(echo \$line | awk '{print \$1}')"
    # substitute parameter name in cmd string with pv#
    cmd=$(echo "$cmd" | eval "sed s/\\\$$pname/\\\$pv$(($i-1))/g")
    # get values for parameter and set p#_v#
    j=2
    while test $j -le $nf; do
        eval "field=\$(echo \$line | awk '{print \$$j}')"
        if test X"$field" = X"NULL"; then
            field=''
        fi
        eval "p$(($i-1))_v$(($j-2))='$field'"
        j=$(($j+1))
    done

    i=$(($i+1))
    
done 

np=$(($i - 1))

# initialize parameter value holders
i=0
while test $i -lt $np; do
    eval "v$i=\$((\$c$i - 1))"
    i=$(($i+1))
done

# get number of digits in nc (for padding below)
nd=$(( $(echo $nc | wc -c) - 1))

# generate all possibile combos and make commands
ii=0
while test $ii -lt $nc; do
    pi=$(($np - 1))
    while test $pi -ge 0; do
        eval "v$pi=\$((\$v$pi + 1))"
        eval "if test \$v$pi -eq \$c$pi; then v$pi=0; pi=\$((\$pi-1));else break;fi"
    done
    pi=0
    while test $pi -lt $np; do
        eval "val=\$v$pi"
        eval "pv$pi=\$p${pi}_v$val"
        pi=$(($pi+1))
    done

    # make padded version of ii
    i=$(eval "printf \"%0${nd}d\" \$ii")
    eval "echo \"$cmd\""

    ii=$(($ii+1))
done

