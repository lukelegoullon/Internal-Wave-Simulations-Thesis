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

# SPINS-compiled executables dynamically link against libblitz.so, which
# lives in our self-built external/SPINS/lib/ -- not a system location the
# dynamic linker searches by default. Without this, the job fails with:
#   error while loading shared libraries: libblitz.so.0: cannot open
#   shared object file: No such file or directory
export LD_LIBRARY_PATH="$HOME/Internal-Wave-Simulations-Thesis/external/SPINS/lib:$LD_LIBRARY_PATH"

# SPINS has no -o / output-directory flag -- it just writes into whatever
# directory it's run from. Each job gets its own directory under runs/,
# created before mpirun starts, so output is never written into the
# shared case directory and two jobs can never collide or overwrite each
# other's data, no matter how they're timed relative to one another.
CASE_DIR="/home/lule1957/Internal-Wave-Simulations-Thesis/external/SPINS/src/cases/gravity_current"
RUN_DIR="$HOME/Internal-Wave-Simulations-Thesis/runs/gravity_current_job${SLURM_JOB_ID}"

mkdir -p "$RUN_DIR"
cp "$CASE_DIR/spins.conf" "$RUN_DIR/"
# NOTE: if this case reads other inputs at runtime (a restart file,
# forcing data, etc.), copy those in here too -- only spins.conf is
# copied above.
cd "$RUN_DIR"

echo "== Starting gravity_current =="
mpirun -np $SLURM_NTASKS "$CASE_DIR/gravity_current.x"
echo "== End of Job =="

# The SLURM log (SBATCH --output) is relative to --chdir, so it lands in
# CASE_DIR while the job runs. Move it in with everything else now that
# the job is done.
mv "$CASE_DIR/gravity_current.${SLURM_JOB_ID}.out" "$RUN_DIR/"