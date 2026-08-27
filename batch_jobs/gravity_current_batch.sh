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

module load gcc/14.2.0
module load openmpi/5.0.6
module load fftw
module load boost
module load openblas
module load cmake   # only needed if rebuilding dependencies (make_deps.sh)

echo "== Starting gravity_current =="
mpirun -np $SLURM_NTASKS ./gravity_current.x
echo "== End of Job =="