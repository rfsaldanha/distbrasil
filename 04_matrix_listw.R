library(tidyverse)

dist_brasil <- readRDS(file = "dist_brasil.rds")

dist_brasil2 <- dist_brasil %>% 
  distinct(orig, dest, .keep_all = TRUE) %>%
  na.omit()

freqs <- dist_brasil2 %>%
  group_by(orig) %>%
  summarise(freq = n()) %>%
  ungroup() %>%
  filter(freq < max(freq))

dist_brasil3 <- dist_brasil2 %>%
  filter(!(orig %in% freqs$orig))

m_dist <- matrix(data = dist_brasil3$dist, 
                 ncol = 5553, byrow = TRUE,
                 dimnames = list(unique(dist_brasil3$orig), unique(dist_brasil3$dest)))

m_listw <- spdep::mat2listw(x = m_dist, row.names = unique(dist_brasil3$orig))

m_sn <- spdep::listw2sn(listw = m_listw)

spdep::write.sn2gwt(sn = m_sn, file = "wdat.gwt")
