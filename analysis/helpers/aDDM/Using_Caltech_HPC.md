# Introduction

Author: Brenden Eum (2024)

Clusters work like external computers that you can send jobs to. You log onto a login node, which is sort of like a small virtual machine with a little bit of memory and CPU. This login node is shared amongst everyone who uses the HPC and is used to send jobs to compute nodes. 

Compute nodes do the heavy lifting computations. Login nodes communicate with compute nodes using SLURM. 
- [See this video for SLURM coding if you need a knowledge recap.](https://www.youtube.com/watch?v=U42qlYkzP9k) 
- [See this cheatsheet if you just need a quick reference.](https://slurm.schedmd.com/pdfs/summary.pdf)

# Instructions

Move files and scripts from my computer to cluster. This has to be done on local shell, not while ssh into cluster.

```
scp -r /Users/brenden/Toolboxes/ADDM.jl beum@login.hpc.caltech.edu:/central/groups/rnl/beum/

scp -r /Users/brenden/Desktop/2023-gain-loss-attention/analysis/helpers/aDDM/* beum@login.hpc.caltech.edu:/central/groups/rnl/beum/scripts
```

Log onto a login node on the Caltech HPC using shell.

```
ssh beum@login.hpc.caltech.edu
```

Put in your Caltech password and accept the Duo multi-factor authentication.

Navigate to your directory.

```
cd /central/groups/rnl/beum/
```

I made slurm, scripts, and toolbox subdirectories. Slurm is for output from HPC, like error logs. scripts is all the scripts. toolbox is for ADDM.jl toolbox.

Using nano, edit then save this code below as job_script.sh file in the /beum/ directory.

```
#!/bin/bash

#Submit this script with: sbatch thefilename

#SBATCH --time=4:00:00 # walltime
#SBATCH --ntasks=1 # number of processor cores (i.e. tasks)
#SBATCH --nodes=1 # number of nodes
#SBATCH --mem-per-cpu=8G # memory per CPU core
#SBATCH --mail-user=beum@caltech.edu # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --output=slurm/out_%x.%j.out
#SBATCH --error=slurm/err_%x.%j.err

export TMPDIR=/central/scratch/beum/tmp

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE
module load julia
julia --project=/central/groups/rnl/beum/ADDM.jl -e 'import Pkg; Pkg.instantiate()'
julia --project=/central/groups/rnl/beum/ADDM.jl scripts/fit_models.jl
```

Use Slurm to submit the job to compute nodes. Do this from /central/groups/rnl/beum/.

```
sbatch -A rnl job_script.sh
```

Check the status of your jobs.

```
squeue -u beum
```

Move files from cluster to my computer. This has to be done on local shell. Do this in the local directory that you want to store it in.

```
scp beum@login.hpc.caltech.edu:/central/groups/rnl/beum/<subfolder>/<remote_filename>
```