#!/bin/bash

errRate=0.001
echo ${errRate} 
cmd="./script.simulation.sh -y -o samples/polyester_${errRate} -v ./samples/rsem_sim_30M/sim.sim.isoforms.results -r ${errRate} -s 0"
echo $cmd
eval $cmd

errRate=0.01
echo ${errRate} 
cmd="./script.simulation.sh -y -o samples/polyester_${errRate} -v ./samples/rsem_sim_30M/sim.sim.isoforms.results -r ${errRate} -s 0"
echo $cmd
eval $cmd

errRate=0.02
echo ${errRate} 
cmd="./script.simulation.sh -y -o samples/polyester_${errRate} -v ./samples/rsem_sim_30M/sim.sim.isoforms.results -r ${errRate} -s 0"
echo $cmd
eval $cmd

errRate=0.05
echo ${errRate} 
cmd="./script.simulation.sh -y -o samples/polyester_${errRate} -v ./samples/rsem_sim_30M/sim.sim.isoforms.results -r ${errRate} -s 0"
echo $cmd
eval $cmd

errRate=0.1
echo ${errRate} 
cmd="./script.simulation.sh -y -o samples/polyester_${errRate} -v ./samples/rsem_sim_30M/sim.sim.isoforms.results -r ${errRate} -s 0"
echo $cmd
eval $cmd


