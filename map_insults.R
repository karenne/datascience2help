#directorio que utilizamos 
dir <- [enter your directory]

# parsear json
library(jsonlite)

Usersfile <-paste0(dir , "tweets_bcn_all.json")

json_bcn <- readLines(Usersfile, warn=FALSE)

Usersfile_2 <-paste0(dir , "tweets_bcn_all_2.json")

json_bcn_2 <- readLines(Usersfile_2, warn=FALSE)

Usersfile_3 <-paste0(dir , "tweets_bcn_all_5.json")

json_bcn_3 <- readLines(Usersfile_3, warn=FALSE)

Usersfile_4 <-paste0(dir , "tweets_bcn_all_4.json")

json_bcn_4 <- readLines(Usersfile_4, warn=FALSE)

json_bcn_all <- append(json_bcn, json_bcn_2)
json_bcn_all <- append(json_bcn_all, json_bcn_3)
json_bcn_all <- append(json_bcn_all, json_bcn_4)

# Inicializar la primera línea
first_line <- fromJSON(json_bcn[1])

# Leer coordenadas, las líneas comentadas son para cuando me da un error.
#Si no funciona una opción probar la otra.

coords <- array(0,dim=c(0,2))
k = 0
for (line in json_bcn_all) {
  k = k + 1
  if (line != '') {
    line <- paste(line, collapse="")
    if (is.null(fromJSON(line)$place) == FALSE) { 
    coords_box <- fromJSON(line)$place$bounding_box$coordinates
#    coords_box <- as.data.frame(coords_box)
#    coords <- rbind(coords, c(mean(unlist(coords_box[1,])), mean(unlist(coords_box[2,]))))
    coords <- rbind(coords, c(mean(unlist(coords_box[1,,1])), mean(unlist(coords_box[1,,2]))))
      }
    }
}

colnames(coords) <- c('lon', 'lat')

coords <- as.data.frame(coords)
require(plyr)

freq_coords <- count(coords)
  
library(rworldmap)
newmap <- getMap(resolution = "low")
plot(newmap, xlim = c(1, 3), ylim = c(40, 43), asp = 1)
points(coords[,1], coords[,2], col='red', cex=.6)

library(ggmap)
map <- get_map(location = 'Barcelona', zoom = 8)
mapPoints <- ggmap(map) +
  geom_point(aes(x = lon, y = lat, size=freq) , data = freq_coords, alpha = .5,
             col='red')


mapPoints

#lista con los insultos más habituales según el artículo: 
#https://www.elconfidencial.com/alma-corazon-vida/2015-11-23/cinco-insultos-mas-utilizados-revelan-vision-del-mundo-caracter-espanol_1100793/

insultos <- c('tont(o|a)', 'idiota', 'ilipollas', 'hij(o|a) puta', 'j(a|o)puta', 'cabron',
              'estupid(o|a)', 'imbecil', 'cretin(o|a)', 'gusano', ' burr(o|a)', 'subnormal')

#Now, choosing those with an insult

coords_2 <- array(0,dim=c(0,2))
txt_ins <- array(0,dim=c(0,1))
other_txt <- array(0,dim=c(0,1))
for (line in json_bcn_all) {
  if (line != '') {
    text <- fromJSON(line)$text
    text <- iconv(text, to='ASCII//TRANSLIT')
    text <- tolower(text)
    test <- gsub(' de ', '', text)
    if (any(unlist(lapply(insultos,
                          function (x) {
                            grepl(x,text)})))==TRUE) {
      if (is.null(fromJSON(line)$place) == FALSE) { 
        coords_box <- fromJSON(line)$place$bounding_box$coordinates
#        coords_box <- as.data.frame(coords_box)
#        coords_2 <- rbind(coords_2, c(mean(unlist(coords_box[1,])), mean(unlist(coords_box[2,]))))
        coords_2 <- rbind(coords_2, c(mean(unlist(coords_box[1,,1])), mean(unlist(coords_box[1,,2]))))
        txt_ins <- rbind(txt_ins, text)
      }
    }
    else {
      other_txt <- rbind(other_txt, text)
    }
  }
}

colnames(coords_2) <- c('lon', 'lat')

coords_2 <- as.data.frame(coords_2)
require(plyr)

freq_coords_2 <- count(coords_2)

plot(newmap, xlim = c(1, 3), ylim = c(40, 43), asp = 1)
points(coords_2[,1], coords_2[,2], col='red', cex=.6)

mapPoints <- ggmap(map) +
  geom_point(aes(x = lon, y = lat, size=freq) , data = freq_coords_2, alpha = .5,
             col='red')

mapPoints

freq_merge <- merge(freq_coords, freq_coords_2, by=c('lon', 'lat'))
freq_merge$prop <- freq_merge$freq.y / freq_merge$freq.x * 100


map <- get_map(location = 'Barcelona', zoom = 10)


require(RColorBrewer)  # for brewer.pal(...)

#Heatmap 
mapPoints <- ggmap(map) +
  stat_density2d(data=freq_merge, aes(fill = prop), alpha=0.3, geom="polygon")+
  geom_point(aes(x = lon, y = lat, size=prop) , data = freq_merge, alpha = .5,
             col='orange') +
  scale_fill_gradientn(colours=(brewer.pal(7,"Spectral")))

mapPoints
