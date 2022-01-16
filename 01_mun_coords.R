# Coordenadas das sedes dos municípios

library(geobr)

mun_coords <- read_municipal_seat(year = "2010")
mun_coords <- subset(mun_coords, select = "code_muni")
row.names(mun_coords) <- mun_coords$code_muni

saveRDS(object = mun_coords, file = "mun_coords_df.rds")
