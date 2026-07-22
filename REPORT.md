## CPU testing

### FETI errors
logs/run_complete_301387.out shows some errors when using Feti. Is this expected?

** Error/warning return ** from Analysis *  INFO(1:2)=   1           37020

Seems to converge to a solution though for 128 cores.

### Solver elmer_iter_GCR_BP_CMG_SGS.sif
Not sure what this solver is supposed to be - sets both GCR and FETI. FETI overrides GCR

### Total Feti?

In feti solver, total feti is set to true. But in elmer source code examples, Total Feti is set to False with a comment that it provides incorrect results

### Small test case for Navier (1 node)
comparing: 
linsys/elmer_iter_BiCGStab2_ILU0.sif
linsys/elmer_feti_mumps_10.sif
linsys/elmer_iter_CG_ILU0.sif
linsys/elmer_iter_Idrs5_ILU0.sif

For 384 cores (full 1 node)
linsys/elmer_iter_BiCGStab2_ILU0.sif doesnt converge
linsys/elmer_feti_mumps_10.sif runs out of memory

Test log: logs/run_complete_302717.out (no BiCGStab2)

Next: try to test same mesh, but only CG and Idrs5





## GPU testing

### Containers
Container needs to be used when running on the GPU partition. The usage is 

` srun apptainer run --nv --bind="$(csc-common-bind)" $container_path ElmerSolver case.sif -ipar 2 $mesh_level $partitions `

### Solvers incorrect solutions
In the case of Poisson/WinkelUnstructured - amgx-block_jacobi gives an incorrect solution
In the case of Navier/WinkelStructured - amgx-bicgstab_amg, amgx-gmres, amgx-block_jacobi, amgx-fgmres_none give incorrect solutions

### Tips
- When writing a new test case, read the README of each test case to see how to invoke ElmerGrid (what parameters)


### Failing test cases when running Navier problem with gpu solvers

WARNING:: CompareToReferenceSolution: Solver 1 FAILED:  Norm = 1.89078666E-02  RefNorm = 2.33900606E-02
CompareToReferenceSolution: Relative Error to reference norm: 1.916281E-01
WARNING:: CompareToReferenceSolution: FAILED 1 tests out of 1!
MAIN: *** Elmer Solver: ALL DONE ***
MAIN: The end
SOLVER TOTAL TIME(CPU,REAL):        17.52       15.66
ELMER SOLVER FINISHED AT: 2026/07/16 11:08:45

Ending linsysAMGX/amgx_bicgstab_amg.sif with mesh level 1
Elapsed time: 19 s

-----------------------------------

CompareToReferenceSolution: Solver 1 PASSED:  Norm = 2.33900607E-02  RefNorm = 2.33900606E-02
CompareToReferenceSolution: Relative Error to reference norm: 5.018953E-09
CompareToReferenceSolution: PASSED all 1 tests!
MAIN: *** Elmer Solver: ALL DONE ***
MAIN: The end
SOLVER TOTAL TIME(CPU,REAL):         6.06        3.30
ELMER SOLVER FINISHED AT: 2026/07/16 11:08:52

Ending linsysAMGX/amgx_bicgstab_none.sif with mesh level 1
Elapsed time: 6 s

-----------------------------------
CompareToReferenceSolution: Solver 1 PASSED:  Norm = 2.33900606E-02  RefNorm = 2.33900606E-02
CompareToReferenceSolution: Relative Error to reference norm: 1.167048E-09
CompareToReferenceSolution: PASSED all 1 tests!
MAIN: *** Elmer Solver: ALL DONE ***
MAIN: The end
SOLVER TOTAL TIME(CPU,REAL):         5.94        3.17
ELMER SOLVER FINISHED AT: 2026/07/16 11:08:58

Ending linsysAMGX/amgx_cg_dilu.sif with mesh level 1
Elapsed time: 6 s

-----------------------------------

CompareToReferenceSolution: Solver 1 PASSED:  Norm = 2.33900605E-02  RefNorm = 2.33900606E-02
CompareToReferenceSolution: Relative Error to reference norm: 4.615594E-09
CompareToReferenceSolution: PASSED all 1 tests!
MAIN: *** Elmer Solver: ALL DONE ***
MAIN: The end
SOLVER TOTAL TIME(CPU,REAL):        19.31       16.59
ELMER SOLVER FINISHED AT: 2026/07/16 11:09:17

Ending linsysAMGX/amgx_fgmres_dilu.sif with mesh level 1
Elapsed time: 20 s

-----------------------------------

WARNING:: CompareToReferenceSolution: Solver 1 FAILED:  Norm = 2.33865718E-02  RefNorm = 2.33900606E-02
CompareToReferenceSolution: Relative Error to reference norm: 1.491590E-04
WARNING:: CompareToReferenceSolution: FAILED 1 tests out of 1!
MAIN: *** Elmer Solver: ALL DONE ***
MAIN: The end
SOLVER TOTAL TIME(CPU,REAL):        17.89       15.11
ELMER SOLVER FINISHED AT: 2026/07/16 11:09:35

Ending linsysAMGX/amgx_fgmres_none.sif with mesh level 1
Elapsed time: 18 s

-----------------------------------
CompareToReferenceSolution: Solver 1 PASSED:  Norm = 2.33900604E-02  RefNorm = 2.33900606E-02
CompareToReferenceSolution: Relative Error to reference norm: 7.029097E-09
CompareToReferenceSolution: PASSED all 1 tests!
MAIN: *** Elmer Solver: ALL DONE ***
MAIN: The end
SOLVER TOTAL TIME(CPU,REAL):         6.52        4.42
ELMER SOLVER FINISHED AT: 2026/07/16 11:09:43

Ending linsysAMGX/amgx_gmres_amg.sif with mesh level 1
Elapsed time: 7 s

-----------------------------------
WARNING:: CompareToReferenceSolution: Solver 1 FAILED:  Norm = 1.77382387E-03  RefNorm = 2.33900606E-02
CompareToReferenceSolution: Relative Error to reference norm: 9.241633E-01
WARNING:: CompareToReferenceSolution: FAILED 1 tests out of 1!
MAIN: *** Elmer Solver: ALL DONE ***
MAIN: The end
SOLVER TOTAL TIME(CPU,REAL):         5.49        3.21
ELMER SOLVER FINISHED AT: 2026/07/16 11:09:49

Ending linsysAMGX/amgx_gmres_none.sif with mesh level 1
Elapsed time: 6 s

-----------------------------------

CompareToReferenceSolution: Solver 1 PASSED:  Norm = 2.33900607E-02  RefNorm = 2.33900606E-02
CompareToReferenceSolution: Relative Error to reference norm: 3.284875E-09
CompareToReferenceSolution: PASSED all 1 tests!
MAIN: *** Elmer Solver: ALL DONE ***
MAIN: The end
SOLVER TOTAL TIME(CPU,REAL):         8.43        5.77
ELMER SOLVER FINISHED AT: 2026/07/16 11:09:57

Ending linsysAMGX/amgx_idr_dilu.sif with mesh level 1
Elapsed time: 9 s

-----------------------------------
WARNING:: CompareToReferenceSolution: Solver 1 FAILED:  Norm = 4.22435863E+16  RefNorm = 2.33900606E-02
CompareToReferenceSolution: Relative Error to reference norm: 1.806049E+18
WARNING:: CompareToReferenceSolution: FAILED 1 tests out of 1!
MAIN: *** Elmer Solver: ALL DONE ***
MAIN: The end
SOLVER TOTAL TIME(CPU,REAL):         5.83        3.05
ELMER SOLVER FINISHED AT: 2026/07/16 11:10:03

Ending linsysAMGX/amgx_jacobi_none.sif with mesh level 1
Elapsed time: 6 s

-----------------------------------

### Memory leaks
When ran with multi-GPUs on one node:
!!! detected some memory leaks in the code: trying to free non-empty temporary device pool !!!
ptr:        0x62d202000 size: 4096
ptr:        0x62d203000 size: 24576
ptr:        0x62e90c000 size: 106496
ptr:        0x62d201000 size: 4096
ptr:        0x62e9aa000 size: 8192
ptr:        0x62e9ac000 size: 8192
ptr:        0x62e9ae000 size: 8192
ptr:        0x62d209000 size: 4096
ptr:        0x62e9b2000 size: 4096
ptr:        0x62e940000 size: 12288
ptr:        0x62d200000 size: 4096
ptr:        0x62e9b0000 size: 4096
ptr:        0x62e943000 size: 118784
ptr:        0x62e960000 size: 118784







