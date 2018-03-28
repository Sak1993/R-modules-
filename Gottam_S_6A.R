#google scraper
#to get the working directory
getwd()
#to set the working directory
setwd("C:/Users/SaiKrishnaReddy/Downloads")
#to read the csv file which has been created using Google chrome scrapper
Google.scraper<-read.csv("AL Uni List.csv", header=T, sep=",", quote =
                           "\"",dec=".", na.strings=NA)
View(Google.scraper)
#to check the file's format
str(Google.scraper)

#import.io
#to get the working directory
getwd()
#to set the working directory
setwd("C:/Users/SaiKrishnaReddy/Documents")
#to read the csv file which has been created using import.io AL Uni List import.io <-
import<-read.csv("Al Uni List import.csv ",header=T,sep=",",quote="\"", dec=".", na.strings = NA)

View(import)
#to check the file's format
str(import)

#outwithub
#to know the current working directory
getwd()
#to set the working directory
setwd("C:/Users/SaiKrishnaReddy/Downloads")
#to read the csv file from the working directory
outwithub=read.csv("AL Uni.List.csv",header = T)
#to view the out put.
View(outwithub)
#to check the file's format
str(outwithub)
