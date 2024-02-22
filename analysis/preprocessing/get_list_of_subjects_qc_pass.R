library(tidyverse)
dots.dir = file.path("../../experiment/dots/recruitment")
numeric.dir = file.path("../../experiment/numeric/recruitment")
tempdir = file.path("../outputs/temp")
rawdatadir <- file.path("../../data/raw_data/good/dots")

## Dots

raw_subs <- list.files(path=rawdatadir)

dots.quality = read.csv(file.path(dots.dir, "good participants.csv"))

subs = c()
i = 1

for (sub in raw_subs) {
  if (sub %in% dots.quality$Good) {
    subs[i] = sub
    i = i+1
  }
}

dots.subjectList = sort(subs)
write.csv(dots.subjectList, file = file.path(tempdir, "dots_subject_list.csv"))


## Numeric

numeric.quality = read.csv(file.path(numeric.dir, "participant quality.csv"))
numeric.quality = numeric.quality[numeric.quality$Participant.ID>200,]
numeric.subjectList = numeric.quality$`Participant.ID`[numeric.quality$Quality=="Good"]
numeric.subjectList = sort(numeric.subjectList)
write.csv(numeric.subjectList, file = file.path(tempdir, "numeric_subject_list.csv"))