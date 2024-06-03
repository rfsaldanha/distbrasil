# library(tidyverse)
library(spdep)
library(geobr)

# Leitura do data frame de distâncias
dist_brasil <- readRDS(file = "export/dist_brasil.rds")
dist_brasil$orig <- as.character(dist_brasil$orig)
dist_brasil$dest <- as.character(dist_brasil$dest)

# Remove NAs
dist_brasil <- na.omit(dist_brasil)

# IDs dos municípios
nameVals <- sort(unique(unlist(dist_brasil[1:2])))

# Matriz de zeros nas dimensões
m_dist <- matrix(0, length(nameVals), length(nameVals), dimnames = list(nameVals, nameVals))

# Preenche matrix
m_dist[as.matrix(dist_brasil[c("orig", "dest")])] <- dist_brasil[["dist"]]

# Matriz simétrica
m_dist <- ('+'(m_dist, t(m_dist)))

# Checa dimensões
dim(m_dist)

# Converte a matriz um objeto do tipo listw
dist_listw <- mat2listw(x = m_dist, row.names = nameVals)

saveRDS(object = dist_listw, file = "dist_listw.rds")

# listw para sn
dist_sn <- spdep::listw2sn(listw = dist_listw)

# sn para arquivo GWT do Geoda
write.sn2gwt(sn = dist_sn, file = "dist.gwt", ind = "code_mn", useInd = TRUE)


# Exporta shapefile compatível com a matriz
mun_map <- read_municipality() %>%
  filter(code_muni %in% unique(dist_brasil3$orig)) %>%
  mutate(code_muni = as.integer(code_muni))

st_write(mun_map, "mun_shapefile/brasil_mun.shp", driver = "ESRI Shapefile")


