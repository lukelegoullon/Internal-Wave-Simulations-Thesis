#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --time=00:30:00
#SBATCH --partition=acpu
#SBATCH --qos=cpu-normal
#SBATCH --output=gravity_current.%j.out
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=lule1957@colorado.edu

module purge

source ../hpc_configs/env-setup.sh

echo "== This is the scripting step! =="
sleep 30
/home/lule1957/Internal-Wave-Simulations-Thesis/external/SPINS/src/cases/gravity_current/gravity_current.x
echo "== End of Job =="