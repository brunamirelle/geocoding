install.packages("httr")
install.packages("rjson")
install.packages("haven")
library(httr)
library(rjson)
library(haven)

cep <- CEP1
cep$cep<-cep$CO_CEP <- NULL
token <- "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
query <- paste("http://www.cepaberto.com/api/v3/cep?cep=",cep$cep[[1]],sep = "") #aqui a gente inicializa a base com a primeira obs

data <- GET(url=query,add_headers('Authorization' = sprintf("Token %s", token)))
result <- fromJSON(content(data,as="text"))
head(result)

cepaberto_dados <- data.frame(cep = result$cep, long = result$longitude, lat = result$latitude)

for (z in 2:10000){ #aqui a gente vai da segunda observacao ate a ultima
  
  print(z)
  
  rm(result,query, data)
  
  query <- paste("http://www.cepaberto.com/api/v3/cep?cep=",cep$cep[[z]],sep = "")
  
  data<-GET(url=query,add_headers('Authorization' = sprintf("Token %s", token)))
  
  #print(data$headers$status)
  
  if(data$headers$status == "200 OK"){
    
    result<-fromJSON(content(data,as="text"))
    
    if(is.null(result$latitude)==TRUE | is.null(result$longitude)==TRUE 
       ){
      base<-data.frame(cep = cep$cep[[z]], long = NA, lat = NA)
    }else{
      base<-data.frame(cep = result$cep, long = result$longitude, lat = result$latitude
                      )
    }
    
    
    cepaberto_dados<-rbind(cepaberto_dados,base)
    
    
    rm(base)
    
  }
  
  Sys.sleep(3)
  
}

save(cepaberto_dados, file = "cep1.RData")