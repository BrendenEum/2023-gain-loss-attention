FROM rocker/tidyverse:4.3.0
RUN install2.r --error --skipinstalled --ncpus -1 remotes here foreach optparse doParallel effsize ggsci