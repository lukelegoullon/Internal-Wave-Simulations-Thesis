#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --time=00:30:00
#SBATCH --partition=acpu
#SBATCH --qos=cpu-normal
#SBATCH --chdir=/home/lule1957/Internal-Wave-Simulations-Thesis/external/SPINS/src/cases/gravity_current
#SBATCH --output=gravity_current.%j.out
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=lule1957@colorado.edu

module purge

source /home/lule1957/Internal-Wave-Simulations-Thesis/hpc-configs/env_setup.sh

echo "== Starting gravity_current =="
mpirun -np $SLURM_NTASKS ./gravity_current.x
echo "== End of Job =="