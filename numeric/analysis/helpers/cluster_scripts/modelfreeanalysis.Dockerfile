FROM rocker/tidyverse:4
RUN install2.r --error --skipinstalled --ncpus -1 remotes here foreach optparse doParallel
