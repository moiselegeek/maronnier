install.packages("RGoogleAnalytics")

library(RGoogleAnalytics)

install.packages("devtools")
devtools::install_github("hrbrmstr/AnomalyDetection")

library(AnomalyDetection)
library(hrbrthemes)
library(tidyverse)


### Google Analytics

client.id <- 'xxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com'
client.secret <- 'xxxxxxxxxxxxxxx'
view.id <- "ga:xxxxxx"

if (!file.exists("./token")) { 
  token <- Auth(client.id,client.secret)
  token <- save(token,file="./token")
} else {
  load("./token")
}

ValidateToken(token)

start.date <- "2019-01-01"
end.date <- "2019-12-31"
url <- "YOUR_URL"


query.list <- Init(start.date = start.date,
                   end.date = end.date,
                   dimensions = "ga:date",
                   metrics = "ga:sessions",
                   filters = paste("ga:landingPagePath=~", url,sep=""),
                   table.id = view.id
                   )



ga.query <- QueryBuilder(query.list)
ga.data <- GetReportData(ga.query, token)


colnames(ga.data) <- c('Date', 'Sessions')

### anomali detection

data <- ga.data[,1:2]



data$Date <- as.Date(data[["Date"]], "%Y%m%d")
colnames(data) <- c("timestamp","count")

a_result <- AnomalyDetectionTs(data,direction = 'both', max_anoms = 0.02, plot = TRUE)
a_result$anoms$timestamp <- as.POSIXlt(a_result$anoms$timestamp)


print(a_result)


ggplot(a_result, aes(timestamp, count)) + 
  geom_line(data=a_result, aes(timestamp, count), color='blue') + 
  geom_point(data=a_result$anoms, aes(timestamp, anoms), color='red')




