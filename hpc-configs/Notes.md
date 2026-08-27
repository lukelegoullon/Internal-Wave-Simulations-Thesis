# SPINS on Alpine -- Setup Notes

Last updated: 2026-08-17

## Status

Full SPINS toolchain is built and validated on CU Boulder's Alpine cluster
(CURC). The example case `gravity_current` compiled cleanly end-to-end
(compiler, MPI, FFTW, LAPACK/BLAS, Blitz++, UMFPACK, Boost all linking
correctly). Nothing has been *run* yet -- only compiled on an `acompile`
session. No Slurm batch job script exists yet.

## Repo layout

```
Internal-Wave-Simulations-Thesis/
  hpc-configs/
    alpine.sh        <- canonical SPINS system config, tracked in this repo
    env_setup.sh      <- module load convenience script, tracked in this repo
  external/
    SPINS/            <- git submodule, points to git.uwaterloo.ca/SPINS/SPINS_main
      systems/alpine.sh   <- NOT tracked here; copied in from hpc-configs/ each time
      src/              <- run `make cases/<dir>/<name>.x` from here
    DJLES/            <- git submodule (not yet touched)
```

Important: `alpine.sh` must live in `hpc-configs/` in the main repo, not be
committed inside the `SPINS`/`DJLES` submodules -- those submodules point
at Waterloo's GitLab, and committing there would try to push to their repo,
not ours.

## Toolchain (Alpine, GCC path per CURC's AMD-hardware recommendation)

- GCC 14.2.0 + OpenMPI 5.0.6 (module-provided)
- FFTW 3.3.10, Boost 1.86.0, OpenBLAS 0.3.28 (module-provided)
- Blitz++ 1.0.2, UMFPACK, AMD, Boost 1.51.0 program_options (self-built by
  `make_deps.sh` into `external/SPINS/{include,lib}`)
- cmake module (only needed for rebuilding Blitz++ via `make_deps.sh`)

## Standard session routine

```bash
module load slurm/alpine
acompile
source ~/Internal-Wave-Simulations-Thesis/hpc-configs/env_setup.sh
```

Whenever `hpc-configs/alpine.sh` changes:
```bash
cd ~/Internal-Wave-Simulations-Thesis
git pull
cp hpc-configs/alpine.sh external/SPINS/systems/alpine.sh
cd external/SPINS/systems
./makemake.sh alpine       # regenerates system.mk -- required after any alpine.sh change
```

To compile a case:
```bash
cd ~/Internal-Wave-Simulations-Thesis/external/SPINS/src
make cases/<dir>/<name>.x
```

To leave the compile node: `exit` (releases the interactive Slurm allocation).
Verify with `squeue -u $USER`.

## Key fixes made to alpine.sh (all present in current hpc-configs/alpine.sh)

- `CC=gcc`, `CXX=g++`, `LD=mpic++`, `MPICXX=mpic++` -- wrapper name confirmed
  via `which mpicxx mpic++` on Alpine, not guessed.
- `BLAS_LIB`/`BLAS_LIBDIR`/`BLAS_INCDIR` must be populated **identically**
  to `LAPACK_LIB`/etc, even though OpenBLAS provides both. UMFPACK's build
  substitutes them into two *separate* Makefile variables (`BLAS=` and
  `LAPACK=`) rather than merging them -- leaving BLAS blank caused undefined
  references to `dtrsv_`, `dgemv_`, `dtrsm_`, `dgemm_`, `dger_` at link time.
- `LAPACK_INCDIR`/`LIBDIR`, `BLAS_INCDIR`/`LIBDIR`, `FFTW_INCDIR`/`LIBDIR`
  all need literal `-I`/`-L` prefixes baked into the string values (e.g.
  `LAPACK_LIBDIR="-L/path/to/lib"`, not just `"/path/to/lib"`) -- these get
  substituted RAW into `UFconfig.mk` by `make_deps.sh`, no auto-prefixing.
- `SYSTEM_LDFLAGS="-Wl,-rpath,<openblas lib dir>"` -- the OpenBLAS module
  doesn't export `LD_LIBRARY_PATH` (unlike FFTW/Boost's modules), so this
  rpath is needed or the binary can't find `libopenblas.so` at runtime.
- `OPTIM_CFLAGS="-O3"` (NOT `-march=native`) -- Alpine's compute fleet is
  heterogeneous (different CPU generations from different contributors);
  `-march=native` risks "illegal instruction" crashes if a batch job lands
  on a different node than the one you compiled on.

## Bugs found/patched locally in make_deps.sh (not upstream -- local only)

1. `mkdir build` -> `mkdir -p build`. The original `mkdir build && pushd
   build && cmake && make && make install && popd` chain silently
   no-ops on any rerun once `build/` already exists from a prior failed
   attempt, but still prints "Blitz++ built!" regardless. `mkdir -p` fixes
   this. If you ever see the "mkdir: cannot create directory 'build'"
   message again, it means this got reverted somehow (e.g. redoing this
   patch after a fresh submodule pull) -- reapply the sed:
   ```bash
   sed -i 's/mkdir build &&/mkdir -p build \&\&/' make_deps.sh
   ```
2. Added `-DCMAKE_POLICY_VERSION_MINIMUM=3.5` to Blitz's cmake invocation
   -- Blitz 1.0.2's CMakeLists.txt targets a CMake version too old for
   Alpine's installed cmake to accept otherwise.
3. Added `-DCMAKE_INSTALL_LIBDIR=lib` to Blitz's cmake invocation -- without
   it, CMake's GNUInstallDirs defaults to `lib64` on this RHEL8-based
   system, which doesn't match where every other dependency lands (`lib`),
   making `libblitz.a` look "missing" even after a successful build.
4. Known latent bug, NOT patched (just understood): if the cmake/make/make
   install chain fails partway *after* `pushd build` succeeds, the
   trailing unconditional `popd` only unwinds one directory level, leaving
   you one directory too deep when the script moves on to the FFTW
   section -- causes a spurious "cannot stat redist_libs/fftw-3.3.9.tar.gz"
   error that looks unrelated but isn't. If this recurs: `rm -rf
   blitz-1.0.2/build` and rerun `make_deps.sh` from a clean state.

All of these fixes need to be reapplied if `external/SPINS` is ever wiped
and recreated from a fresh submodule clone, since they live in the
submodule's working copy, not in anything tracked by our repo.

## Plan for next session

1. Compile a second, simple case as a build sanity check -- `wave_reader`
   is the priority since it's the case file designed to ingest a
   DJLES-generated initial condition (density/velocity fields), which is
   what we'll eventually need for the real topography case.
2. Write an actual Slurm batch job script (`#SBATCH` directives + module
   loads + `mpirun`/`srun` invocation) -- haven't done this yet, only
   compiled interactively on `acompile`. Need to check CURC's docs for
   their preferred `mpirun` vs `srun` convention on Alpine.
3. Locate Alpine's scratch/project storage tier before running anything
   real -- SPINS's own docs warn against running cases out of the home
   directory due to output volume and home-directory quotas.
4. Submit that batch job, and while it runs, start drafting the actual
   topography + DJLES-coupling case file.
5. Eventually: get DJLES itself building (separate submodule, not touched
   yet) and write the script that converts its output into the
   grid/density/velocity format `wave_reader` expects.