#directorio que utilizamos 
dir <- [enter your directory]

# script donde se declaran las credenciales
source(paste0(dir, "access_twit_api.R"))

# Con la librería streamR podemos scrapear con geolocalización
# y filtrar por timeout o por número de tweets:

library(streamR)
filterStream(paste0(dir,"tweets_bcn_all.json"), 
             track = insultos, locations=c(1,40,3,43), 
             lang='es', timeout = 1000, oauth = cred);
filterStream(paste0(dir,"tweets_bcn_all_2.json"), locations=c(1,40,3,43), 
             lang='es', tweets=1500, oauth = cred);
