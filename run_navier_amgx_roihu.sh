#!/bin/bash
#SBATCH --job-name=amgx_all
#SBATCH --account=project_2001659
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --partition=gpularge
#SBATCH --nodes=2
#SBATCH --time=00:45:00
#SBATCH --ntasks-per-node=4 --cpus-per-task=1 # The product should be 72 if requesting 1 GPU per node
#SBATCH --gres=gpu:gh200:4
#SBATCH --mem=0


set -euo pipefail

#More threads don't really increase performance
export OMP_NUM_THREADS=1


# Define the path to the case folder
path=Navier/WinkelStructured

# Define the problem type
problem=NavierAMGX

# Define the number of partitions (should be nodes * ntasks-per-node)
partitions=$SLURM_NTASKS
threads=$SLURM_CPUS_PER_TASK


container_path=/scratch/project_2001659/danieree/elmer-linsys/containers/container.sif

# Job-specific filenames so a concurrently-running job that shares this same
# case directory (e.g. the CPU sweep) can't clobber this job's linsys.sif /
# config.json / case file while both are in flight.
ORG_DIR=$PWD
JOB_TAG=${SLURM_JOB_ID:-$$}
LINSYS_FILE=linsys_$JOB_TAG.sif
CONFIG_FILE=config_$JOB_TAG.json
CASE_FILE=case_gpu_$JOB_TAG.sif

# Anchored to $ORG_DIR (not a relative $path) since a mid-loop srun failure
# under `set -e` exits before the trailing `cd ../..` restores the cwd.

# Background host RAM + per-GPU memory poller, sampled every 2s for the
# whole job so usage around a crash can be checked after the fact.
# MEM_LOG="$ORG_DIR/logs/mem_poll_$JOB_TAG.csv"
# mkdir -p "$ORG_DIR/logs"
# {
#     echo "timestamp,host_used_MB,host_total_MB,gpu_index,gpu_used_MB,gpu_total_MB"
#     while true; do
#         ts=$(date +%s)
#         read -r used total < <(free -m | awk '/Mem:/{print $3, $2}')
#         nvidia-smi --query-gpu=index,memory.used,memory.total --format=csv,noheader,nounits \
#             | while IFS=', ' read -r idx gused gtotal; do
#                 echo "$ts,$used,$total,$idx,$gused,$gtotal"
#               done
#         sleep 2
#     done
# } > "$MEM_LOG" &
# MONITOR_PID=$!
# trap 'kill $MONITOR_PID 2>/dev/null; rm -f "$ORG_DIR/$path/$LINSYS_FILE" "$ORG_DIR/$path/$CONFIG_FILE" "$ORG_DIR/$path/$CASE_FILE"' EXIT

# Remove the result files if they already exist
# rm -f $path/results_amgx/f$result_file.*

# Copy the valid case file into the case.sif file
# This can be commented out if there is only a single
# default case file in the folder
# cp $path/case_amgx.sif $path/case.sif


cd $path
# Commands for Poisson/WinkelUnstructured mesh
# srun apptainer run --bind="$(csc-common-bind)" $container_path gmsh winkel.geo -3 -clscale 1.0 -v 5
# srun apptainer run --bind="$(csc-common-bind)" $container_path ElmerGrid 14 2 winkel.msh -autoclean -partdual -metiskway $partitions


# -n1: ElmerGrid itself isn't MPI-parallel, so without this srun launches one
# redundant copy per task (4-8x concurrent writers into the same
# winkel/partitioning.$partitions/ directory).
srun -n1 apptainer run --bind="$(csc-common-bind)" $container_path ElmerGrid 1 2 winkel.grd -partdual -metiskway $partitions

cd ../..

for mesh_level in 3; do

    for solver in linsysAMGX/*.sif; do
	if grep -Fxq "$solver" solver-lists/$problem-Solvers.txt
	then

        cp $solver $path/$LINSYS_FILE
	    # Assumes that the config file is named similarly to .sif file
	    filename=$(basename "$solver" ".sif")
	    cp linsysAMGX/$filename.json $path/$CONFIG_FILE
	    sed -i "s/config\.json/$CONFIG_FILE/" $path/$LINSYS_FILE
	    sed "s/include linsys\.sif/include $LINSYS_FILE/" $path/case_gpu.sif > $path/$CASE_FILE

            cd $path

            start=$(date +%s)

            echo
            echo
            echo "-----------------------------------"
            echo "Starting $solver with mesh level $mesh_level"
            echo

            # echo "Diagnostic: UCX_RNDV_THRESH as seen inside the container:"
            # srun apptainer exec --nv --bind="$(csc-common-bind)" $container_path env | grep UCX_RNDV_THRESH || echo "  (not set inside container)"

            # echo "Diagnostic: ulimits on the host (compute node, outside container):"
            # ulimit -a

            # echo "Diagnostic: ulimits as seen inside the container (per task):"
            # srun apptainer exec --nv --bind="$(csc-common-bind)" $container_path bash -c 'ulimit -a'

            srun --cpus-per-task=$threads apptainer run --nv --bind="$(csc-common-bind)" $container_path ElmerSolver $CASE_FILE -ipar 2 $mesh_level $partitions


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


