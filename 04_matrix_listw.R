library(tidyverse)
library(spdep)
library(geobr)

# Leitura do data frame de distâncias
dist_brasil <- readRDS(file = "dist_brasil_full.rds")

# Remove duplicidades e pares de municípios
# onde não foi possível determinar a distância rodoviária
dist_brasil2 <- dist_brasil %>% 
  distinct(orig, dest, .keep_all = TRUE) %>%
  na.omit()

# Lista frequencia de pares para cada município
freqs <- dist_brasil2 %>%
  group_by(orig) %>%
  summarise(freq = n()) %>%
  ungroup() %>%
  filter(freq < max(freq))

# Remove municípios onde não foi estabelecer distâncias
# para todos os pares
dist_brasil3 <- dist_brasil2 %>%
  filter(!(orig %in% freqs$orig))

# Transforma o data frame em uma matriz com as distâncias
m_dist <- matrix(data = dist_brasil3$dist, 
                 ncol = 5553, byrow = TRUE,
                 dimnames = list(unique(dist_brasil3$orig), unique(dist_brasil3$dest)))


# Converte a matriz um objeto do tipo listw
dist_listw <- mat2listw(x = m_dist, row.names = unique(dist_brasil3$orig))
saveRDS(object = dist_listw, file = "dist_listw.rds")

# listw para sn
dist_sn <- spdep::listw2sn(listw = dist_listw)

# sn para arquivo GWT do Geoda
write.sn2gwt(sn = dist_sn, file = "dist.gwt", ind = "code_mn", useInd = TRUE)

# Transforma o data frame em uma matriz com o tempo
m_temp <- matrix(data = dist_brasil3$dur, 
                 ncol = 5553, byrow = TRUE,
                 dimnames = list(unique(dist_brasil3$orig), unique(dist_brasil3$dest)))


# Converte a matriz um objeto do tipo listw
temp_listw <- mat2listw(x = m_temp, row.names = unique(dist_brasil3$orig))
saveRDS(object = temp_listw, file = "temp_listw.rds")

# listw para sn
temp_sn <- spdep::listw2sn(listw = temp_listw)

# sn para arquivo GWT do Geoda
write.sn2gwt(sn = temp_sn, file = "temp.gwt", ind = "code_mn", useInd = TRUE)


# Exporta shapefile compatível com a matriz
mun_map <- read_municipality() %>%
  filter(code_muni %in% unique(dist_brasil3$orig)) %>%
  mutate(code_muni = as.integer(code_muni))

st_write(mun_map, "mun_shapefile/brasil_mun.shp", driver = "ESRI Shapefile")


