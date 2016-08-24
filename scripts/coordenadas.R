# Coordenadas dos municípios obtidas através da API do Nominatim
# respeitando as condições de uso
# http://wiki.openstreetmap.org/wiki/Nominatim_usage_policy

# Pasta de trabalho
setwd("scripts/")

# Pacotes
library(jsonlite)

# Listagem de municípios
mun <- read.csv2("mun.csv", header=TRUE)

# Variáveis de coordenadas
mun$lat <- NA
mun$lon <- NA

# Loop
pb <- txtProgressBar(min = 1, max = nrow(mun), style = 3)
for(i in 1:nrow(mun)){
  Sys.sleep(runif(1, 1, 3))
  municipio <-  gsub("\\ ", "+", as.character(mun[i,2]))
  estado <-  gsub("\\ ", "+", as.character(mun[i,3]))
  url <- paste0("http://nominatim.openstreetmap.org/search?city=",municipio,
                "&state=",estado,
                "&country=Brazil&format=json")
  data <- fromJSON(readLines(url, warn=FALSE))
  if(length(data)>0){
    mun[i,5] <- data$lat[1]
    mun[i,6] <- data$lon[1]
  }
  setTxtProgressBar(pb, i)
}

# Backup consulta
mun_bkp <- mun

# Adequação dos campos
mun$lat <- as.numeric(mun$lat)
mun$lon <- as.numeric(mun$lon)

# Municípios sem coordenadas
library(ggmap)
for(i in 1:nrow(mun)){
  if(is.na(mun[i,5])){
    municipio <- gsub("\\ ", "+", as.character(mun[i,4]))
    data <- geocode(municipio)
    mun[i,5] <- data$lat 
    mun[i,6] <- data$lon
  }
}

# Salva imagem
save.image("mun_image.RData")

# Salva mun
save(mun, file="mun.RData")