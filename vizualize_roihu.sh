#!/bin/bash 
#SBATCH --time=01:00:00
#SBATCH --job-name=vizualize
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err
#SBATCH --partition=small
#SBATCH --account=project_2001659
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1

# DEFINE PATHS

module load python-data

CASE_PATH=Navier/WinkelStructured
# CASE_PATH=Poisson/WinkelUnstructured
SCRIPT_PATH=python-scripts
# PROBLEM=Navier
PARTITIONS=4
FORMAT=png
MESH_LEVELS=(2)

# Define the name and location where the scalability plot should be saved
SCALE_NAME=scalability_test
SCALE_PATH=$PWD/results/roihu/Navier-AMGX-WinkelStructured
# SCALE_PATH=$PWD/results/roihu/Poisson-AMGX-WinkelUnstructured

# Define the name and location where the timing plots should be saved
# (these will be incremented with the mesh level)
TIME_NAME=timing_test
TIME_PATH=$SCALE_PATH

# USER CAN IF WANTED CHANGE FOLLOWING CONSTANTS:

# Define the path where resulting .dat files are stored (no need to change)
RET_PATH=$PWD/$CASE_PATH/results_amgx

# Define the resulting .dat file (no need to change)
RET_FILE=f72_$PARTITIONS.dat

# Define the used tolerance (no need to change)
TOL=0.000001

# Define if the total times should be plotted as well (no need to change)
VIZ_TOT_TIME=false

# Remove the result files if they already exist
# rm -f $CASE_PATH/results/f$PARTITIONS.*


ORG_DIR=$PWD




# VISUALIZE THE RESULTS

mkdir -p $SCALE_PATH
mkdir -p $TIME_PATH

cd $SCRIPT_PATH

echo "Plotting scalability..."
echo

save_as=$SCALE_PATH/$SCALE_NAME.$FORMAT

python3 plot_scalability_bar.py -p $RET_PATH -f $RET_FILE -s $save_as -t $TOL

cd $ORG_DIR

echo "Plotting timings..."
echo

cd $SCRIPT_PATH

for mesh_level in "${MESH_LEVELS[@]}"; do
    
    echo "-----------------------------------"
    echo "Plotting timings with mesh level $mesh_level"
    echo
    
    save_as=$TIME_PATH/$TIME_NAME-$mesh_level.$FORMAT

    if $VIZ_TOT_TIME; then
	python3 plot_times.py -p $RET_PATH -f $RET_FILE -s $save_as -t $TOL -m $mesh_level -v
    else
	python3 plot_times.py -p $RET_PATH -f $RET_FILE -s $save_as -t $TOL -m $mesh_level
    fi
    
    echo "------------------------------------"
    echo

done

cd $ORG_DIR

echo "DONE"
