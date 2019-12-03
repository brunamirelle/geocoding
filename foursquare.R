# #capturar e transformar java para R
# install.packages("httr")
# install.packages("rjson")
# #ler csv
# install.packages("haven")
# #função unique
# install.packages("tidyverse")

library(httr)
library(rjson)
library(haven)
library(foreign)
library(tidyverse)


###Definindo pasta de trabalho onde o arquivo do foursquare se localiza
path = '~/pasta/'
setwd(path)

#Lendo arquivo enviado pelo foursquare já organizado em id e nome
base = read.csv2("checkins.csv",sep=',', stringsAsFactors = FALSE, header=FALSE)

#mudanças necessárias para minha base em particular, adaptar para cada necessidade
#Manter id e nome
base = base[c("V5","V6")]
base = unique(base)
#retirar linhas com nomes repetidos
base = base[!nchar(base$V5)<20,]
base = base[!nchar(base$V6)==0,]
base = base[!base$V6=="user",]
base = base[!base$V6=="with[0].id",]
base = base[!base$V6=="venue.url",]



#V1 = código da localização no foursquare

#Dados retirados da conta do foursquare
client_id = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
client_secret = "YYYYYYYYYYYYYYYYYYYYYYYYYYYYYY"
data = "20191108"  #ano/mes/dia

# link para capturar a localização com a API 
query = paste("https://api.foursquare.com/v2/venues/",base$V5[[1]],"?client_id=",client_id,"&","client_secret=",client_secret,"&v=",data,sep = "")

# capturando os dados 
data <- GET(url=query)

# passando os dados de java para lista do R
result <- fromJSON(content(data,as="text"))

#######capturando informações do meu interesse
#endereço
endereco = result[["response"]][["venue"]][["location"]][["formattedAddress"]]
# escrevendo endereço completo
endereco = paste(endereco[1],endereco[2],endereco[3],endereco[4], sep = " ")

#categorias
categoria1 = data.frame(categoria1_id =result[["response"]][["venue"]][["categories"]][[1]][["id"]], categoria1_name =result[["response"]][["venue"]][["categories"]][[1]][["name"]], categoria1_pluralName =result[["response"]][["venue"]][["categories"]][[1]][["pluralName"]], categoria1_shortName =result[["response"]][["venue"]][["categories"]][[1]][["shortName"]])
categoria2 = data.frame(categoria2_id =result[["response"]][["venue"]][["categories"]][[2]][["id"]], categoria2_name =result[["response"]][["venue"]][["categories"]][[2]][["name"]], categoria2_pluralName =result[["response"]][["venue"]][["categories"]][[2]][["pluralName"]], categoria2_shortName =result[["response"]][["venue"]][["categories"]][[2]][["shortName"]])
length(categoria2)

#data frame para a primeira entrada (nesse caso categoria2 não é NA)
dados_finais <- data.frame(requestId=result$meta$requestId , venueid=result$response$venue$id, nome = result$response$venue$name, long = result$response$venue$location$lng, lat = result$response$venue$location$lat, address = result$response$venue$location$address,address_complete=endereco, categoria1, categoria2)


for (z in 2:472){ #aqui a gente vai da segunda observacao ate a ultima
  
  print(z)
  
  rm(result,query, data)
  
  query <- paste("https://api.foursquare.com/v2/venues/",base$V5[[z]],"?client_id=",client_id,"&","client_secret=",client_secret,"&v=",data,sep = "")
  data <- GET(url=query)
  result <- fromJSON(content(data,as="text"))
  endereco = result[["response"]][["venue"]][["location"]][["formattedAddress"]]
  endereco = paste(endereco[1],endereco[2],endereco[3],endereco[4], sep = " ")
  categoria1 = data.frame(categoria1_id =result[["response"]][["venue"]][["categories"]][[1]][["id"]], categoria1_name =result[["response"]][["venue"]][["categories"]][[1]][["name"]], categoria1_pluralName =result[["response"]][["venue"]][["categories"]][[1]][["pluralName"]], categoria1_shortName =result[["response"]][["venue"]][["categories"]][[1]][["shortName"]])
  
  #resolvendo caso categoria2 seja NA (pode ser adaptado a outras colunas)
  if(length(result[["response"]][["venue"]][["categories"]])==2){
    
    categoria2 = data.frame(categoria2_id =result[["response"]][["venue"]][["categories"]][[2]][["id"]], categoria2_name =result[["response"]][["venue"]][["categories"]][[2]][["name"]], categoria2_pluralName =result[["response"]][["venue"]][["categories"]][[2]][["pluralName"]], categoria2_shortName =result[["response"]][["venue"]][["categories"]][[2]][["shortName"]])
  }else{
    categoria2 = data.frame(categoria2_id =NA, categoria2_name =NA, categoria2_pluralName =NA, categoria2_shortName =NA)
  }
  
  base_temp <- data.frame(requestId=result$meta$requestId , venueid=result$response$venue$id, nome = result$response$venue$name, long = result$response$venue$location$lng, lat = result$response$venue$location$lat, address = result$response$venue$location$address,address_complete=endereco, categoria1, categoria2)
  
  dados_finais <-rbind(dados_finais,base_temp)
  
  
  rm(base_temp)
  
}

#Formas de Armazenar
save(dados_finais,file="dados_finais.RData" )
save.image(".RData")
write.csv(dados_finais,"dados_site.csv")