library(twitteR)
library(ROAuth)
library(httr)

dir <- [enter your directory]

reqURL <- "https://api.twitter.com/oauth/request_token"
accessURL <- "https://api.twitter.com/oauth/access_token"
authURL <- "https://api.twitter.com/oauth/authorize"


options(httr_oauth_cache=T)



# Set API Keys
api_key <- XXXXX
api_secret <- XXXXX
access_token <- XXXXX
access_token_secret <- XXXXX
setup_twitter_oauth(api_key, api_secret, access_token, access_token_secret)

credentials_file <- paste0(dir, "my_oauth.Rdata")
if (file.exists(credentials_file)){
  load(credentials_file)
} else {
  cred <- OAuthFactory$new(consumerKey = api_key, consumerSecret = api_secret, requestURL = reqURL, accessURL = accessURL, authURL = authURL)
  cred$handshake(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))
  save(cred, file = credentials_file)
}
