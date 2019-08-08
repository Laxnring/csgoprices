rm(list=ls())
setwd("D:/Documents/Python/bitskins")

Sys.setlocale("LC_TIME", "English")

'%!in%' <- function(x,y)!('%in%'(x,y))
pkgs <- c("odbc", "DBI", "rstudioapi", "lubridate", "ggplot2", "sqldf", "gsubfn", "dplyr", "forecast", "stats")
for (pkg in pkgs) {
  if (pkg %!in% rownames(installed.packages())) { 
    install.packages(pkg, repos = "https://cloud.r-project.org/", quiet = T) 
  }
  library(pkg, character.only = T, quietly = T)
}

options(sqldf.driver = "SQLite")
con_local = dbConnect(RSQLite::SQLite(), "steam.db")

hash_name <- "AK-47 | Emerald Pinstripe (Field-Tested)"

data <- dbGetQuery(con_local, "select * from csgo")
data$date = substr(data$date,1,nchar(data$date)-4)
data$date <- as.POSIXct(data$date, format = "%b %d %Y %H")
data <- na.omit(data)

hash_names <- unique(data$hash)

valid_names <- c()
trends = c()
prices <- c()
data_amount <- c()

abs_trends <- function(hash_names, date) {
  
  valid_names <- c()
  trends = c()
  prices <- c()
  data_amount <- c()
  
  for (hash_name in hash_names) {
    data_teste <- data[data$hash == hash_name,]
    avg_price = mean(data_teste$price)
    data_teste = data_teste[data_teste$date >= date,]
    if (nrow(data_teste) != 0) {
      trend <- lm(data_teste$price ~ data_teste$date)$coefficients[[2]]
      trends <- c(trends, trend)
      valid_names <- c(valid_names, hash_name)
      prices <- c(prices, avg_price)
      data_amount <- c(data_amount, nrow(data_teste))
      print(hash_name)
    }
  }
  data_trend <- data.frame (
    hash_name = valid_names,
    trend = trends,
    avg_price = prices,
    amount = data_amount
  )
  data_trend <- data_trend[order(-data_trend$trend),]
  
  return (data_trend)
}

data_teste <- data[data$hash == hash_name,]

perc_trends <- function(hash_names, date) {
  
  valid_names <- c()
  trends = c()
  prices_list <- c()
  data_amount <- c()
  
  for (hash_name in hash_names) {
    data_teste <- data[data$hash == hash_name,]
    prices <- ts(na.omit(data_teste$price))
    change <- as.numeric(prices/stats::lag(prices,-1) - 1)
    avg_price = mean(data_teste$price)
    
    change <- data.frame(
      nr = 1:length(change),
      change = change
    )
    
    if (nrow(data_teste) != 0) {
      trend <- lm(change ~ nr, data = change)$coefficients[[2]]
      trends <- c(trends, trend)
      
      valid_names <- c(valid_names, hash_name)
      prices_list <- c(prices_list, avg_price)
      data_amount <- c(data_amount, nrow(data_teste))
    }
    #print(sprintf("%s %f %f %f", hash_name, avg_price, trend, nrow(data_teste)))
    
  }
  data_trend <- data.frame (
    hash_name = valid_names,
    trend = trends,
    avg_price = prices_list,
    amount = data_amount
  )
  data_trend <- data_trend[order(-data_trend$trend),]
  
  return (data_trend)
}

#trends <- abs_trends(hash_names, date = "2019-07-01")

trends <- perc_trends(hash_names, date = "2019-07-01")
avg_trend = mean(trends$trend)

#filter <- data_trend[data_trend$avg_price < 1,]

data_total <- data[data$date < "2019-06-28" & data$date >= "2019-06-01",]
agregado <- aggregate(na.omit(data_total$price), by=list(data_total$date), FUN=sum)

print(agregado[1:100,])

data_plot <- data[data$hash == "Galil AR | Sandstorm (Battle-Scarred)" & data$date <= "2019-07-01" & data$price < 10,]

plot <- ggplot(data = data_plot, aes(x=data_plot$date, y = data_plot$price)) + geom_line() + ggtitle(data_plot$hash) + geom_smooth(method="lm")
print(plot)

# # UTILIZAR MÉTODO HOLT-WINTERS
# ts <- ts(na.omit(data$price), frequency=60)
# 
# holt_winters <- HoltWinters(ts)
# 
# holt_forecast <- forecast(holt_winters, h = 160)
# 
# plot(holt_forecast)
# 
# plot <- ggplot(data = data, aes(x=data$date, y = data$price)) + geom_line() + ggtitle(hash_name) + geom_smooth(method="lm")
# print(plot)
