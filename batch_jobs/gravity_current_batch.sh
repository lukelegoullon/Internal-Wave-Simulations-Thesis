#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=00:10:00
#SBATCH --partition=atesting
#SBATCH --qos=testing
#SBATCH --output=sample-%j.out

module purge

source env-setup.sh

echo "== This is the scripting step! =="
sleep 30
../executable.exe
echo "== End of Job =="