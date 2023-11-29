edatadir.dots <- file.path("../../data/processed_data/dots/e")
edatadir.food <- file.path("../../data/processed_data/food/e")
cdatadir.food <- file.path("../../data/processed_data/food/c")
jdatadir.food <- file.path("../../data/processed_data/food/j")
load(file.path(edatadir.dots, "cfr_dots.RData"))
cfr_food = cfr_dots[1:10,]
cfr_food$dataset = "food"

save(cfr_food, file=file.path(edatadir.food, "cfr_food.Rdata"))
save(cfr_food, file=file.path(cdatadir.food, "cfr_food.Rdata"))
save(cfr_food, file=file.path(jdatadir.food, "cfr_food.Rdata"))