dist_brasil <- readRDS(file = "scripts/dist_brasil.rds")

m_dist <- matrix(data = dist_brasil$dist, 
                  ncol = 3, byrow = TRUE,
                  dimnames = list(unique(dist_brasil$orig), unique(dist_brasil$dest)))

