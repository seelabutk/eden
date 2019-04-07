#!/bin/sh

########################################################################
#
# eve.sh
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

echo "#command_index,real_time,user_time,sys_time,stdout_filesize,stderr_filesize,command_line"
IFS="
"
i=0
command=asdf
ls -l outfiles | for command in `cat commands`; do
        IFS=" "
        read line
        echo "$i,"
        j=`printf "%0*d" $1 $i`
        #awk '{ printf $2"," }' < outfiles/$j.time
        while read one two; do
                echo "$two,"
        done < outfiles/$j.time
        #stat --printf="%s," outfiles/$j.out
        #stat --printf="%s," outfiles/$j.err
        read one two three four five rest
        echo "$five,"
        read one two three four five rest
        echo "$five,"
        echo "$command"
        i=$((i + 1))
done | sed '
N
N
N
N
N
N
s/\n//g
'
