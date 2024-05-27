# Bibliotecas
library(geobr)
library(cli)
library(progress)

# Coordenadas dos municípios
mun_coords <- read_municipal_seat(year = "2010")
mun_coords <- subset(mun_coords, select = "code_muni")
row.names(mun_coords) <- mun_coords$code_muni

# Pares de municípios
mun_pairs <- combn(x = mun_coords$code_muni, m = 2, simplify = F)
mun_pairs <- as.data.frame(matrix(unlist(mun_pairs), ncol = 2, byrow = TRUE))

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

# Objeto vazio para acumular respostas
# dist_brasil <- data.frame()
# saveRDS(object = dist_brasil, file = "dist_brasil.rds", compress = FALSE)
# m <- 0
# saveRDS(object = m, file = "last_m.rds", compress = FALSE)

# Carrega último arquivo salvo
dist_brasil <- readRDS("dist_brasil.rds")

# Inicia consulta
for(m in 1:nrow(mun_coords)){
  timestamp()
  cli_inform("Município {m} de {nrow(mun_coords)}")
  
  # Verifica se o município já foi consultado
  last_m <- readRDS("last_m.rds")
  if(m <= last_m){
    cli_alert_info("Município {m} já foi consultado. Indo para o seguinte.")
    next
  } else {
    # Isola município de origem
    orig <- mun_coords[m,]
    
    # Isola municípios de destino
    dest <- subset(mun_pairs, V1 == orig$code_muni)$V2
    
    # Cria lista de municípios de destino
    dest_chunk <- split(dest, ceiling(seq_along(dest)/200))
    
    # Barra de progresso
    pb <- progress_bar$new(
      format = "[:bar] :percent in :elapsed",
      total = length(dest_chunk), clear = FALSE, width= 60)
    
    for(n in 1:length(dest_chunk)){
      # Inicia barra de progresso
      pb$tick(0)
      
      # Subset de coordenadas dos municípios de destino
      dest_tmp <- subset(mun_coords, code_muni %in% dest_chunk[[n]])
      
      # Espera w segundos em respeito a API
      Sys.sleep(time = runif(1, 1, 5))
      
      # Obtem tabela de distâncias entre município i e pacote de municípios p
      tmp_res_pack <- osrm::osrmTable(
        src = orig, # Origem
        dst = dest_tmp, # Destino
        measure = c("distance", "duration") # Medidas
      )
      
      # Isola resposta das distâncias
      tmp_res_pack_dist <- tmp_res_pack[["distances"]]
      tmp_res_pack_dist <- matrix_converter(m = tmp_res_pack_dist, 
                                            i = m,
                                            name_var = "dist")
      
      # Isola resposta das durações
      tmp_res_pack_dur <- tmp_res_pack[["durations"]]
      tmp_res_pack_dur <- matrix_converter(m = tmp_res_pack_dur, 
                                           i = m,
                                           name_var = "dur")
      
      # Junta respostas
      tmp_res_pack_df <- merge(tmp_res_pack_dist, tmp_res_pack_dur)
      
      # Guarda respostas no data.frame principal
      dist_brasil <- rbind(dist_brasil, tmp_res_pack_df)
      
      # Atualiza barra de progresso
      pb$tick()
    }
    
    # Ao concluir todos os chunks
    saveRDS(object = dist_brasil, file = "dist_brasil.rds", compress = FALSE)
    saveRDS(object = m, file = "last_m.rds", compress = FALSE)
  }
  
  
}
