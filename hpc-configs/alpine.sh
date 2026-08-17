#!/bin/bash

# System-specific settings for the CU Boulder Alpine cluster (CURC)
# Toolchain: GCC 14.2.0 + OpenMPI 5.0.6 (CURC's recommended pairing for
# Alpine's AMD EPYC hardware, over Intel/Intel MPI)
#
# Before running makemake.sh, make_deps.sh, or make (and again in any
# Slurm job script that runs the compiled executable), load:
#   module load gcc/14.2.0
#   module load openmpi/5.0.6
#   module load fftw boost openblas

#Note, on github I can not store this in SPINS codebase. Before executing ./makemake.sh alpine, cp the file to systems.
CC=gcc
CXX=g++
LD=mpic++

# System-specific compiler flags
SYSTEM_CFLAGS=

# rpath bakes the OpenBLAS lib path into the executable itself, since
# (unlike fftw/boost) the openblas module does not add its lib dir to
# LD_LIBRARY_PATH -- without this, the binary may fail to find
# libopenblas.so at runtime even if compilation succeeds.
SYSTEM_LDFLAGS="-Wl,-rpath,/curc/sw/install/openblas/0.3.28/gcc/14.2.0/lib"

# Compiler flags for debugging
DEBUG_CFLAGS="-g -DBZ_DEBUG"
DEBUG_LDFLAGS="-g -DBZ_DEBUG"

# Compiler flags for optimization
OPTIM_CFLAGS="-O3 -march=native"
OPTIM_LDFLAGS=$OPTIM_CFLAGS

# Compiler flags for extra optimization (left blank for now -- get a
# working build first, revisit -flto etc. later once things compile)
EXTRA_OPTIM_CFLAGS=
EXTRA_OPTIM_LDFLAGS=$EXTRA_OPTIM_CFLAGS

# Library names/locations/flags for MPI-compilation. Blank besides
# MPICXX since the mpic++ wrapper already knows its own include/lib paths.
MPICXX=mpic++
MPI_CFLAGS=
MPI_LIB=
MPI_LIBDIR=
MPI_INCDIR=

# Library names/locations for LAPACK (OpenBLAS provides both LAPACK and BLAS)
LAPACK_LIB="-lopenblas"
LAPACK_LIBDIR="/curc/sw/install/openblas/0.3.28/gcc/14.2.0/lib"
LAPACK_INCDIR="/curc/sw/install/openblas/0.3.28/gcc/14.2.0/include"

# Library locations for blitz; leave blank to use system-installed
# or compiled-with-this-package version
BLITZ_LIBDIR=
BLITZ_INCDIR=

# Library locations for fftw
FFTW_LIBDIR="/curc/sw/install/fftw/3.3.10/openmpi/5.0.6/gcc/14.2.0/lib"
FFTW_INCDIR="/curc/sw/install/fftw/3.3.10/openmpi/5.0.6/gcc/14.2.0/include"

# Library locations for UMFPACK
UMF_INCDIR=
UMF_LIBDIR=

# Location/library for BLAS -- left blank on purpose. OpenBLAS (set
# above under LAPACK_LIB) already provides BLAS symbols; setting this
# too would just link -lopenblas twice.
BLAS_LIB=
BLAS_LIBDIR=
BLAS_INCDIR=
