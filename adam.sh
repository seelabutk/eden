#!/bin/sh

########################################################################
#
# adam.sh
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
[ $# -lt 1 ] && echo $usage && exit 1

# Import config file
. $1


# get command count
cmd_count=$(cat $commands_file | wc -l)
# if there is a commands_done file, subtract these from the count
#   and set restart_flag
if [ -f $run_dir/commands_done ]; then
    restart_flag=1
    cmd_count=$(($cmd_count - $(cat $run_dir/commands_done | wc -l) ))
else
    restart_flag=0
fi

# start command server
#   it will find open port and append number to eden.config
$(dirname $0)/command-server.tcl $restart_flag $run_dir < $commands_file &

# start line-listener
#     it will find open port and append number to eden.config
$(dirname $0)/line-listener.tcl $cmd_count $run_dir &

echo " EDEN: creating outfiles directory"
mkdir -p $outfiles_dir

if [ $mode = "qsub" ]; then

   cd $run_dir
   # make pbs script
   echo " EDEN: creating pbs script"

   cp header.pbs eden_job.pbs
   echo '' >> eden_job.pbs

   echo "cd \$PBS_O_WORKDIR" >> eden_job.pbs

   # produce commands to run abel; the number of abel processes depends on the
   #  value of $cores_per_abel; the default is $cores_per_abel = 1 which means
   #  one abel will run on each core allocated using dplace for specific
   #  placement; if $cores_per_abel is > 1, then ($num_procs / $cores_per_abel)
   #  abels will run with each abel using $cores_per_abel cores
   num=$(($ncpus / $cores_per_abel))
   while test $num -gt 0; do
      # dplace numbers need to be 0 indexed 
      if [ $cores_per_abel -eq 1 ]; then
         echo "dplace -c $(($num - 1)) $eden_path/abel.sh $run_dir/eden.config &"
      else
         echo "dplace -c $(($num * $cores_per_abel - $cores_per_abel))-$(($num * $cores_per_abel - 1)) $eden_path/abel.sh $run_dir/eden.config &"
      fi
      num=$(($num - 1))
    done >> eden_job.pbs

   echo wait >> eden_job.pbs
   echo "$eden_path/eve.sh $num_digits > summary.cvs" >> eden_job.pbs
   echo ja >> eden_job.pbs

   # submit pbs_script
   echo " EDEN: submitting batch job"
   qsub eden_job.pbs

elif [ "$mode" = "mp" ]; then
   # need to wait a second to make sure port numbers get written to
   #    config file
   sleep 1
   echo " EDEN: running commands"
   cd $run_dir
   num=$(($ncpus / $cores_per_abel))
   while test $num -gt 0; do
      $eden_path/abel.sh $run_dir/eden.config &
      num=$(($num - 1))
   done
   wait
   echo " EDEN: writing summary"
   $eden_path/eve.sh $num_digits > summary.cvs

elif [ "$mode" = "nodes" ]; then

   mkdir -p $ssh_dir
   # launch abel on hosts contained in hosts.config file
   while read host
   do ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $host "$eden_path/abel.sh $RC" >$ssh_dir/$host.out 2>$ssh_dir/$host.err &
   done < $hosts_config

fi

