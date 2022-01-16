# Pacotes
library(osrm)

# Coordenadas dos municípios
mun_coords <- readRDS(file = "scripts/mun_coords_df.rds")
mun_pack_list <- readRDS(file = "scripts/mun_pack_list_cod.rds")

# Função para tratar matriz
matrix_converter <- function(m, i, name_var){
  # Transpõe matriz
  m <- t(m)
  
  # Converte em data frame
  m <- as.data.frame(m)
  
  # Adiciona coluna destino e remove row.names
  m$dest <- row.names(m)
  row.names(m) <- NULL
  
  # Adiciona coluna origem
  m$orig <- sf::st_drop_geometry(mun_coords)[i,"code_muni"]
  
  # Nome coluna distancia
  names(m) <- c(name_var, "dest", "orig")
  
  # Reordena colunas
  m <- m[, c(3, 2, 1)]
  
  # Retorna resultado
  return(m)
}



# Função para coletar distâncias e durações para um município
mun_table <- function(i, w = 1){
  res <- data.frame()
  
  for(p in 1:length(mun_pack_list)){
    
    # Espera 3 segundos para respeitar a API
    Sys.sleep(time = w)
    
    # Obtem tabela de distâncias entre município i e pacote de municípios p
    tmp_res_pack <- osrm::osrmTable(
      src = mun_coords[i,], # Origem
      dst = mun_pack_list[[p]], # Destino
      measure = c("distance", "duration") # Medidas
    )
    
    # Isola resposta das distâncias
    tmp_res_pack_dist <- tmp_res_pack[["distances"]]
    tmp_res_pack_dist <- matrix_converter(m = tmp_res_pack_dist, 
                                          i = i,
                                          name_var = "dist")
    
    # Isola resposta das durações
    tmp_res_pack_dur <- tmp_res_pack[["durations"]]
    tmp_res_pack_dur <- matrix_converter(m = tmp_res_pack_dur, 
                                         i = i,
                                         name_var = "dur")
    
    # Junta respostas
    tmp_res_pack_df <- merge(tmp_res_pack_dist, tmp_res_pack_dur)
    
    # Guarda respostas no data.frame principal
    res <- rbind(res, tmp_res_pack_df)
    
    message(paste0(round(p/length(mun_pack_list)*100, 2), "% "), appendLF = FALSE)
  }
  
  # Retorna resultado
  return(res)
}


# Objeto vazio para acumular respostas
# dist_brasil <- data.frame()

# Obtem respostas
for(i in 5453:nrow(mun_coords)){
  message(paste0(Sys.time(), " Município: ", i))
  res <- mun_table(i = i, w = 3)
  dist_brasil <- rbind(dist_brasil, res)
  saveRDS(object = dist_brasil, file = "scripts/dist_brasil.rds", compress = FALSE)
  saveRDS(object = i, file = "scripts/last_i.rds", compress = FALSE)
}

saveRDS(object = dist_brasil, file = "scripts/dist_brasil_compress.rds", compress = TRUE)


