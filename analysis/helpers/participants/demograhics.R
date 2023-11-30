library(tidyverse)
dots.dir = file.path("../../../experiment/dots/recruitment")
numeric.dir = file.path("../../../experiment/numeric/recruitment")
food.dir = file.path("../../../experiment/food/recruitment")
tempdir = file.path("../../outputs/temp")
textdir = file.path("../../outputs/text")

## Import data

dots.subs <- read.csv(file.path(tempdir, "dots_subject_list.csv"))[,2] # second column is subject ID
dots_demographics = read.csv(file.path(dots.dir, "participant demographics simplified.csv"))
dots_demographics = dots_demographics[dots_demographics$ID %in% dots.subs, ]

numeric.subs <- read.csv(file.path(tempdir, "numeric_subject_list.csv"))[,2] # second column is subject ID
numeric_demographics = read.csv(file.path(numeric.dir, "participant demographics.csv"))
numeric_demographics = numeric_demographics[numeric_demographics$Participant.ID %in% numeric.subs, ]

#food.subs <- read.csv(file.path(tempdir, "food_subject_list.csv"))[,2] # second column is subject ID
#food_demographics = read.csv(file.path(food.dir, "participant demographics.csv"))
#food_demographics = food_demographics[food_demographics$Participant.ID %in% food.subs, ]

#######
# Age
#######

write(mean(dots_demographics$Age), file = file.path(textdir, "dots_age_mean.txt"))
write(min(dots_demographics$Age), file = file.path(textdir, "dots_age_min.txt"))
write(max(dots_demographics$Age), file = file.path(textdir, "dots_age_max.txt"))

write(mean(numeric_demographics$Age), file = file.path(textdir, "numeric_age_mean.txt"))
write(min(numeric_demographics$Age), file = file.path(textdir, "numeric_age_min.txt"))
write(max(numeric_demographics$Age), file = file.path(textdir, "numeric_age_max.txt"))


#######
# Gender
#######

dots.gender = table(dots_demographics$Gender)
write(as.numeric(dots.gender["Female"]), file = file.path(textdir, "dots_gender_female.txt"))
write(as.numeric(dots.gender["Male"]), file = file.path(textdir, "dots_gender_male.txt"))
write(as.numeric(dots.gender["Non-binary"]), file = file.path(textdir, "dots_gender_nonbinary.txt"))

numeric.gender = table(numeric_demographics$Gender)
write(as.numeric(numeric.gender["Female"]), file = file.path(textdir, "numeric_gender_female.txt"))
write(as.numeric(numeric.gender["Male"]), file = file.path(textdir, "numeric_gender_male.txt"))
write(as.numeric(numeric.gender["Non-binary"]), file = file.path(textdir, "numeric_gender_nonbinary.txt"))

#######
# Race
#######

dots.race = table(dots_demographics$Ethnicity)
write(as.numeric(dots.race["Abstain"]), file = file.path(textdir, "dots_race_abstain.txt"))
write(as.numeric(dots.race["Asian"]), file = file.path(textdir, "dots_race_asian.txt"))
write(as.numeric(dots.race["Black"]), file = file.path(textdir, "dots_race_black.txt"))
write(as.numeric(dots.race["Hispanic"]), file = file.path(textdir, "dots_race_hispanic.txt"))
write(as.numeric(dots.race["Middle Eastern"]), file = file.path(textdir, "dots_race_middleEast.txt"))
write(as.numeric(dots.race["White"]), file = file.path(textdir, "dots_race_white.txt"))

numeric.race = table(numeric_demographics$Race.Ethnicity)
write(as.numeric(numeric.race["Abstain"]), file = file.path(textdir, "numeric_race_abstain.txt"))
write(as.numeric(numeric.race["Asian"]), file = file.path(textdir, "numeric_race_asian.txt"))
write(as.numeric(numeric.race["Black"]), file = file.path(textdir, "numeric_race_black.txt"))
write(as.numeric(numeric.race["Hispanic"]), file = file.path(textdir, "numeric_race_hispanic.txt"))
write(as.numeric(numeric.race["Middle Eastern"]), file = file.path(textdir, "numeric_race_middleEast.txt"))
write(as.numeric(numeric.race["White"]), file = file.path(textdir, "numeric_race_white.txt"))

