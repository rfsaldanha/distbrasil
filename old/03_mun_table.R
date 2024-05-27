# Pacotes
library(osrm)
library(progress)
library(cli)

# Coordenadas das sedes dos municípios
mun_coords <- readRDS(file = "mun_coords_df.rds")
mun_pack_list <- readRDS(file = "mun_pack_list_cod.rds")

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
mun_table <- function(i, w = 3){
  res <- data.frame()
  
  # Barra de progresso
  pb <- progress_bar$new(
    format = "[:bar] :percent in :elapsed",
    total = length(mun_pack_list), clear = FALSE, width= 60)
  
  for(p in 1:length(mun_pack_list)){
    # Inicia barra de progresso
    pb$tick(0)
    
    # Espera w segundos em respeito a API
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
    
    # Atualiza barra de progresso
    pb$tick()
  }
  
  # Retorna resultado
  return(res)
}


# Objeto vazio para acumular respostas
# dist_brasil <- data.frame()
# saveRDS(object = dist_brasil, file = "dist_brasil.rds", compress = FALSE)
# i <- 0
# saveRDS(object = i, file = "last_i.rds", compress = FALSE)

# Carrega último arquivo salvo
dist_brasil <- readRDS("dist_brasil.rds")

# Obtem respostas
for(i in 1:nrow(mun_coords)){
  timestamp()
  cli_inform("Município {i} de {nrow(mun_coords)}")
  
  # Verifica se o município já foi consultado
  last_i <- readRDS("last_i.rds")
  if(i <= last_i){
    cli_alert_info("Município {i} já foi consultado. Indo para o seguinte.")
    next
  } else {
    res <- mun_table(i = i, w = runif(1, 1, 5))
    dist_brasil <- rbind(dist_brasil, res)
    saveRDS(object = dist_brasil, file = "dist_brasil.rds", compress = FALSE)
    saveRDS(object = i, file = "last_i.rds", compress = FALSE)
  }
}

saveRDS(object = dist_brasil, file = "dist_brasil_compress.rds", compress = TRUE)


