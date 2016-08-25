# Rotas entre os municípios utilizando o OSRM

# Pasta de trabalho
setwd("scripts/")

# Municípios
load("mun.RData")

# Função route
route <- function(origem, destino){
  require(jsonlite)
  origem <- subset(mun, codmun==origem, select = c("lat", "lon"))
  destino <- subset(mun, codmun==destino, select = c("lat", "lon"))
  url <- paste0("http://192.241.148.145:5000/route/v1/driving/",
                origem[2],",",origem[1],";",destino[2],",",destino[1])
  data <- NA
  tempo <- NA
  distancia <- NA
  try(data <- fromJSON(readLines(url, warn=FALSE)))
  if(length(data)>1){
      tempo <- as.data.frame(data$routes$legs)$duration
      distancia <- as.data.frame(data$routes$legs)$distance
      return(list(tempo, distancia))
  } else {
    return(NA)
  }
}



# Pares de municipios
pares <- combn(mun$codmun,2, simplify = TRUE)

# Conferência
choose(nrow(mun),2)
nrow(pares)
ncol(pares)

# Matriz de distância e tempo

# Função para processamento em blocos
matrixRoutes <- function(target){
  matriz <- data.frame()
  for(i in 1:ncol(target)){
    result <- route(target[1,i], target[2,i])
    if(length(result)==1){
      result <- data.frame(origem=target[1,i], destino=target[2,i], tempo=NA, distancia=NA)
    } else {
      result <- data.frame(origem=target[1,i], destino=target[2,i], tempo=result[[1]], distancia=result[[2]])  
    }
    matriz <- rbind(matriz, result)
  }
  return(matriz)
}

# Bloco de teste
teste <- pares[,1:100]
ptm <- proc.time()
matriz <- matrixRoutes(teste)
proc.time() - ptm


# Processa blocos de tamanho k e salva
k <- 1000
target <- pares
n <- ncol(target)

count <- 0
faltam <- n
matriz <- data.frame()

for(i in 1:n){
  #print(paste("Coluna",i,"de",n))
  count <- count+1 # Contador
  result <- route(target[1,i], target[2,i]) # Resultado da rota
  faltam <- faltam-1
  if(length(result)==1){ # Sem resultado
    result <- data.frame(origem=target[1,i], destino=target[2,i], tempo=NA, distancia=NA)
  } else { # Com resultado
    result <- data.frame(origem=target[1,i], destino=target[2,i], tempo=result[[1]], distancia=result[[2]])  
  }
  matriz <- rbind(matriz, result)
  if(count == k){
    print(paste0(date()," Salvando ", k, " consultas... Faltam: ",faltam))
    save(matriz, file="matriz.RData")
    save(i, file="last_i.RData")
    count <- 0
  }
}
save(matriz, file="matriz.RData")
save(i, file="last_i.RData")