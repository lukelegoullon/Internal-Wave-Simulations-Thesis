#!/bin/bash
# env_setup.sh -- loads the module stack needed to build and run SPINS on
# Alpine (CU Boulder / CURC). Matches the toolchain baked into
# hpc-configs/alpine.sh: GCC 14.2.0 + OpenMPI 5.0.6 + OpenBLAS.
#
# Usage: source env_setup.sh
#
# NOTE: this does NOT get you onto a compile/compute node -- that's a
# separate step (module load slurm/alpine; acompile) that has to happen
# first, since it starts a new interactive session rather than just
# setting environment variables. Run that first, then source this file.
# In a Slurm batch script, put these module loads (or a source of this
# file) near the top, before invoking mpirun/srun -- the run-time
# environment must match the compile-time environment.
 
module load gcc/14.2.0
module load openmpi/5.0.6
module load fftw
module load boost
module load openblas
module load cmake   # only needed if rebuilding dependencies (make_deps.sh)
 
echo "Environment loaded: gcc/14.2.0, openmpi/5.0.6, fftw, boost, openblas, cmake"