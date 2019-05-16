
#install.packages("curl")
#install.packages("digest")
#install.packages("dplyr")
#install.packages("ggplot2")
#install.packages("glue")
#install.packages("httr")
#install.packages("jsonlite")
#install.packages("munsell")
#install.packages("openssl")
#install.packages("pillar")
#install.packages("purr")
#install.packages("R6")
#install.packages("rlang")
#install.packages("scales")
#install.packages("stringi")
#install.packages("stringr")
#install.packages("tribble")
#install.packages("utf8")
#install.packages("purrr")
#install.packages("stringi")
#install.packages("glue")
#install.packages("ggmap")
#devtools::install_github("dkahle/ggmap", ref = "tidyup", force = TRUE)


library(ggmap)
api <- "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
register_google(key = api)


#Pegando o csv com o nome dos col?gios
input<- data.frame(escolas$no_entidade,escolas$fk_cod_estado)
input$sigla <-escolas$sigla
#Colocando no nome das escolas a sigla dos estados (poderia ser municipio)
input$b<-paste(input$escolas.no_entidade, input$sigla,  sep=', ')
latlon<-sapply(as.character(input$escolas.no_entidade),geocode)
latlon<-sapply(a,geocode)
  
base<-as.data.frame(latlon)
base<-sapply(base,unlist)
write.csv(base,"latlon2.csv")
#A base que ele vai dar est? transposta  
