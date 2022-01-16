library(tidyverse)

dist_brasil %>%
  filter(orig == 1503804) %>%
  View()

# https://stackoverflow.com/questions/9617348/reshape-three-column-data-frame-to-matrix-long-to-wide-format

teste <- with(dist_brasil, Matrix::sparseMatrix(i = as.numeric(orig), j=as.numeric(dest), x=dist,
                                                dimnames=list(levels(orig), levels(dest))))

teste2 <- mat2listw(teste)




example(columbus)
coords <- coordinates(columbus)
col005 <- dnearneigh(coords, 0, 0.5, attr(col.gal.nb, "region.id"))
summary(col005)
col005.w.mat <- nb2mat(col005, zero.policy=TRUE)
col005.w.b <- mat2listw(col005.w.mat)
summary(col005.w.b$neighbours)
diffnb(col005, col005.w.b$neighbours)