#!/bin/bash
#SBATCH --job-name=amgx_all
#SBATCH --account=project_2001659
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --partition=gputest
#SBATCH --nodes=1
#SBATCH --time=00:15:00
#SBATCH --ntasks-per-node=4 --cpus-per-task=72  # The product should be 72 if requesting 1 GPU per node
#SBATCH --gres=gpu:gh200:4

set -euo pipefail


# export OMP_NUM_THREADS=32

# Define the path to the case folder
path=Navier/WinkelStructured

# Define the problem type
problem=NavierAMGX

# Define the number of partitions (should be nodes * ntasks-per-node)
partitions=$SLURM_NTASKS
result_file=$partitions


container_path=/scratch/project_2001659/danieree/containers/container.sif

# Remove the result files if they already exist
rm -f $path/results_amgx/f$result_file.*

# Copy the valid case file into the case.sif file
# This can be commented out if there is only a single
# default case file in the folder
# cp $path/case_amgx.sif $path/case.sif


cd $path
# Commands for Poisson/WinkelUnstructured mesh
# srun apptainer run --bind="$(csc-common-bind)" $container_path gmsh winkel.geo -3 -clscale 1.0 -v 5
# srun apptainer run --bind="$(csc-common-bind)" $container_path ElmerGrid 14 2 winkel.msh -autoclean -partdual -metiskway $partitions


# if $partitions -gt 1; then
# srun apptainer run --bind="$(csc-common-bind)" $container_path ElmerGrid 1 2 winkel.grd -partdual -metiskway $partitions
# else
srun apptainer run --bind="$(csc-common-bind)" $container_path ElmerGrid 1 2 winkel.grd
# fi

cd ../..

for mesh_level in 4; do

    for solver in linsysAMGX/*.sif; do
	if grep -Fxq "$solver" solver-lists/$problem-Solvers.txt
	then

        cp $solver $path/linsys.sif
	    # Assumes that the config file is named similarly to .sif file
	    filename=$(basename "$solver" ".sif")
	    cp linsysAMGX/$filename.json $path/config.json
	    
            cd $path

            start=$(date +%s)

            echo
            echo
            echo "-----------------------------------"
            echo "Starting $solver with mesh level $mesh_level"
            echo
    
            srun apptainer run --nv --bind="$(csc-common-bind)" $container_path ElmerSolver case_gpu.sif -ipar 2 $mesh_level $result_file


            end=$(date +%s)

            echo
            echo "Ending $solver with mesh level $mesh_level"
            echo "Elapsed time: $(($end-$start)) s"
            echo "-----------------------------------"
            echo

	    cd ../..

	else
	    echo
	    echo "Solver $solver not recommended for given problem. Ignoring it"
	    echo
	fi
    
   done

done


