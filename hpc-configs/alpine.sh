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

# Compiler flags for optimization. Deliberately NOT using -march=native:
# Alpine's compute nodes are heterogeneous (different CPU generations from
# different contributors), and a binary compiled with -march=native on one
# node can crash with "illegal instruction" if the batch job later lands
# on a different node. Plain -O3 runs correctly on any Alpine node.
OPTIM_CFLAGS="-O3"
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

# Library names/locations for LAPACK (OpenBLAS provides both LAPACK and BLAS).
# NOTE: make_deps.sh substitutes these RAW into UFconfig.mk (no automatic
# -I/-L prefixing), e.g. "LAPACK = ${LAPACK_INCDIR} ${LAPACK_LIBDIR} ${LAPACK_LIB}"
# -- so INCDIR/LIBDIR must already contain the -I/-L flags themselves, or
# the linker will try to treat the bare directory path as an input file.
LAPACK_LIB="-lopenblas"
LAPACK_LIBDIR="-L/curc/sw/install/openblas/0.3.28/gcc/14.2.0/lib"
LAPACK_INCDIR="-I/curc/sw/install/openblas/0.3.28/gcc/14.2.0/include"

# Library locations for blitz; leave blank to use system-installed
# or compiled-with-this-package version
BLITZ_LIBDIR=
BLITZ_INCDIR=

# Library locations for fftw. Prefixed with -I/-L for the same reason as
# LAPACK/BLAS above; also, the fftw module does not export CPATH, so an
# unprefixed bare path would not even be picked up implicitly by gcc.
FFTW_LIBDIR="-L/curc/sw/install/fftw/3.3.10/openmpi/5.0.6/gcc/14.2.0/lib"
FFTW_INCDIR="-I/curc/sw/install/fftw/3.3.10/openmpi/5.0.6/gcc/14.2.0/include"

# Library locations for UMFPACK
UMF_INCDIR=
UMF_LIBDIR=

# Location/library for BLAS. NOTE: even though OpenBLAS provides both
# LAPACK and BLAS symbols, UMFPACK's build (make_deps.sh) substitutes
# BLAS_LIB and LAPACK_LIB into two SEPARATE Makefile variables (BLAS=
# and LAPACK=) rather than combining them -- leaving this blank left
# UMFPACK's BLAS= line empty, causing undefined references to dtrsv_,
# dgemv_, dtrsm_, dgemm_, dger_ at link time. Must match LAPACK_LIB above.
BLAS_LIB="-lopenblas"
BLAS_LIBDIR="-L/curc/sw/install/openblas/0.3.28/gcc/14.2.0/lib"
BLAS_INCDIR="-I/curc/sw/install/openblas/0.3.28/gcc/14.2.0/include"