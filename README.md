#DistBrasil
Matriz de distâncias rodoviárias entre os municípios brasileiros

## Objetivo
Construir e disponibilizar uma matriz de distâncias rodoviárias entre os 5.570 municípios brasileiros

## Desafio
Obter as distâncias para todas as 15.509.665 combinações possíveis. A utilização de APIs como a do Google Maps apresenta limitações diárias de requisições.

## Apoio
Recebemos U$ 100 em créditos da [Digital Ocean](https://www.digitalocean.com/) para hospedarmos um servidor.

## Metodologia

Com os créditos fornecidos pela Digital Ocean, foi criado um servidor Ubuntu 16.04 para hospedagem do serviço de roteirização [OSRM](http://project-osrm.org/)  e para execução de scripts do software [R](https://www.r-project.org/), através do [RStudio Server](https://www.rstudio.com/products/rstudio/download-server/) edição comunitária.

### Municípios
Foi considerada a lista de municípios brasileiros conforme a Divisão Territorial Brasileira (DTB/IBGE) de 2015  ([link](http://www.ibge.gov.br/home/geociencias/cartografia/default_dtb_int.shtm)).

### Coordenadas dos municípios
Para o cômputo da rotas, é necessário informar as coordenadas de origem e destino dos municípios. Importante notar que as coordenadas dos centróides dos municípios não fazem sentido para o cômputo de rotas, sendo necessária a utilização de coordenadas referentes ao centro econômico ou viário do município.

Desta forma, estas coordenadas foram obtidas junto ao serviço [Nominatim](http://wiki.openstreetmap.org/wiki/Nominatim) através da API disponibilizada, respeitando as [limitações de uso](http://wiki.openstreetmap.org/wiki/Nominatim_usage_policy).

Exemplo de query utilizando a API:

```
http://nominatim.openstreetmap.org/search?city=Juiz+de+Fora&state=Minas+Gerais&country=Brazil&format=json
```

Os municípios não localizados pelo Nominatim tiveram suas coordenadas obtidas através da API do Google Maps, utilizando-se o pacote do R `ggmaps`.

### Cômputo das rotas

#### Base cartográfica

O OSRM adota como base cartográfica as camadas do projeto [Open Street Map - OSM](http://www.openstreetmap.org/). A base cartográfica foi obtida junto ao [Geofabrik](https://www.geofabrik.de/), em de 23 de agosto de 2016. Foi utilizado o recorte "Brasil".

#### Aquisição das rotas

As rotas entre os municípios foram consultadas através de API. Exemplo de query:

```
http://192.241.148.145:5000/route/v1/driving/-42.8179477877956,-22.9083992;-52.4089047,-28.2616137
```