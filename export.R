library(readr)
library(arrow)

dist_brasil <- readRDS("dist_brasil.rds")

dist_brasil$dest <- as.numeric(dist_brasil$dest)

saveRDS(object = dist_brasil, file = "export/temp_dist_brasil_compressed.rds", compress = "xz")

write_csv2(x = dist_brasil, file = "export/temp_dist_brasil.csv")

write_parquet(x = dist_brasil, sink = "export/temp_dist_brasil.parquet")
