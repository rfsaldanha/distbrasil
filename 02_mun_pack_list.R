# Coordenadas das sedes dos municípios
mun_coords <- readRDS(file = "mun_coords_df.rds")

# Divide as coordenadas dos municípios em 28 partes
# (para atender os limites da API)
pack01 <- mun_coords[1:200,]
pack02 <- mun_coords[201:400,]
pack03 <- mun_coords[401:600,]
pack04 <- mun_coords[601:800,]
pack05 <- mun_coords[801:1000,]
pack06 <- mun_coords[1001:1200,]
pack07 <- mun_coords[1201:1400,]
pack08 <- mun_coords[1401:1600,]
pack09 <- mun_coords[1601:1800,]
pack10 <- mun_coords[1801:2000,]
pack11 <- mun_coords[2001:2200,]
pack12 <- mun_coords[2201:2400,]
pack13 <- mun_coords[2401:2600,]
pack14 <- mun_coords[2601:2800,]
pack15 <- mun_coords[2801:3000,]
pack16 <- mun_coords[3001:3200,]
pack17 <- mun_coords[3201:3400,]
pack18 <- mun_coords[3401:3600,]
pack19 <- mun_coords[3601:3800,]
pack20 <- mun_coords[3801:4000,]
pack21 <- mun_coords[4001:4200,]
pack22 <- mun_coords[4201:4400,]
pack23 <- mun_coords[4401:4600,]
pack24 <- mun_coords[4601:4800,]
pack25 <- mun_coords[4801:5000,]
pack26 <- mun_coords[5001:5200,]
pack27 <- mun_coords[5201:5400,]
pack28 <- mun_coords[5401:nrow(mun_coords),]

# Coloca os pacotes em uma lista
mun_pack_list <- list(pack01, pack02, pack03, pack04, pack05,
                  pack06, pack07, pack08, pack09, pack10,
                  pack11, pack12, pack13, pack14, pack15,
                  pack16, pack17, pack18, pack19, pack20,
                  pack21, pack22, pack23, pack24, pack25,
                  pack26, pack27, pack28)

saveRDS(object = mun_pack_list, file = "mun_pack_list_cod.rds")
