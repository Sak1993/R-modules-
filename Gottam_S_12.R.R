# ipak function: install and load multiple R packages.
# check to see if packages are installed. Install them if they are not, then load them into the R session.
ipak <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg)) 
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}

#installing required packages
packages <- c("RSQLite", "lubridate")
ipak(packages)

#to read and import BridStrikes.csv file
BirdStrikes.import <- read.csv("Bird Strikes.csv", header = T, sep = ",")

#to Connect to a DBMS going through the appropriate authorization procedure.
db <- dbConnect(SQLite(), dbname="BirdStrikes.sqlite")
#to activate forgein keys 
dbSendQuery(conn = db,  "PRAGMA foreign_keys = ON")

#to create Aircraft table with the required data
dbSendQuery(conn = db,  "CREATE TABLE Aircraft (Record_ID INTEGER PRIMARY KEY, Aircraft_Type TEXT, Aircraft_Make TEXT, Aircraft_FNumber INTEGER, Aircraft_Engines NUMBER, Aircraft_Operator TEXT)")
Aircraft = cbind.data.frame(BirdStrikes.import$Record.ID, BirdStrikes.import$Aircraft..Type, BirdStrikes.import$Aircraft..Make.Model, BirdStrikes.import$Aircraft..Flight.Number, BirdStrikes.import$Aircraft..Number.of.engines., BirdStrikes.import$Aircraft..Airline.Operator)
dbWriteTable(conn=db, name="Aircraft", Aircraft, append=T, row.names=F)

#to create Airport table with the required data
dbSendQuery(conn = db,  "CREATE TABLE Airport (Record_ID INTEGER PRIMARY KEY, Airport_Name TEXT, Airport_Origin TEXT, FOREIGN KEY(Record_ID) REFERENCES Aircraft(Record_ID))")
Airport = cbind.data.frame(BirdStrikes.import$Record.ID, BirdStrikes.import$Airport..Name, BirdStrikes.import$Origin.State)
dbWriteTable(conn=db, name="Airport", Airport, append=T, row.names=F)

#to create Datatime table with the required data
dbSendQuery(conn = db,  "CREATE TABLE Datatime (Record_ID INTEGER PRIMARY KEY, Flight_Date TEXT, Reported_Date TEXT, Time INTEGER, Time_Day TEXT, Phase TEXT, FOREIGN KEY(Record_ID) REFERENCES Aircraft(Record_ID))")
Datatime = cbind.data.frame(BirdStrikes.import$Record.ID, BirdStrikes.import$FlightDate, BirdStrikes.import$Reported..Date, BirdStrikes.import$When..Time..HHMM., BirdStrikes.import$When..Time.of.day, BirdStrikes.import$When..Phase.of.flight)
dbWriteTable(conn=db, name="Datatime", Datatime, append=T, row.names=F)

#to create Altitude table with required data
dbSendQuery(conn = db,  "CREATE TABLE Altitude (Record_ID INTEGER PRIMARY KEY, Altitude_Bin TEXT, Feet_Above_ground INTEGER, Speed INTEGER, Miles_From_Airport INTEGER, FOREIGN KEY(Record_ID) REFERENCES Aircraft(Record_ID))")
Altitude = cbind.data.frame(BirdStrikes.import$Record.ID, BirdStrikes.import$Altitude.bin, BirdStrikes.import$Feet.above.ground, BirdStrikes.import$Speed..IAS..in.knots, BirdStrikes.import$Miles.from.airport)
dbWriteTable(conn=db, name="Altitude", Altitude, append=T, row.names=F)

#to create Fatalitites table with required data 
dbSendQuery(conn = db,  "CREATE TABLE Fatalities (Record_ID INTEGER PRIMARY KEY, Number_Struck TEXT,  Pilot_Warned TEXT, Size TEXT, Species TEXT, Remains_Collected TEXT, Remains_Sent TEXT, Human_Fatalities INTEGER, People_Injured INTEGER, Remarks TEXT, FOREIGN KEY(Record_ID) REFERENCES Aircraft(Record_ID))")
Fatalities = cbind.data.frame(BirdStrikes.import$Record.ID, BirdStrikes.import$Wildlife..Number.struck, BirdStrikes.import$Pilot.warned.of.birds.or.wildlife., BirdStrikes.import$Wildlife..Size, BirdStrikes.import$Wildlife..Species, BirdStrikes.import$Remains.of.wildlife.collected., BirdStrikes.import$Remains.of.wildlife.sent.to.Smithsonian, BirdStrikes.import$Number.of.human.fatalities, BirdStrikes.import$Number.of.people.injured, BirdStrikes.import$Remarks)
dbWriteTable(conn=db, name="Fatalities", Fatalities, append=T, row.names=F)

#to create Effect table with required data 
dbSendQuery(conn = db,  "CREATE TABLE Effect (Record_ID INTEGER PRIMARY KEY, Impact_To_Flight TEXT,  Other TEXT, Indicated_Damage TEXT, FOREIGN KEY(Record_ID) REFERENCES Aircraft(Record_ID))")
Effect = cbind.data.frame(BirdStrikes.import$Record.ID, BirdStrikes.import$Effect..Impact.to.flight, BirdStrikes.import$Effect..Other, BirdStrikes.import$Effect..Indicated.Damage)
dbWriteTable(conn=db, name="Effect", Effect, append=T, row.names=F)

#to create Location table with required data 
dbSendQuery(conn = db,  "CREATE TABLE Location (Record_ID INTEGER PRIMARY KEY, Nearby TEXT,  Freefrom_En_Route TEXT, FOREIGN KEY(Record_ID) REFERENCES Aircraft(Record_ID))")
Location = cbind.data.frame(BirdStrikes.import$Record.ID, BirdStrikes.import$Location..Nearby.if.en.route, BirdStrikes.import$Location..Freeform.en.route)
dbWriteTable(conn=db, name="Location", Location, append=T, row.names=F)

#to create Conditions table with required data 
dbSendQuery(conn = db,  "CREATE TABLE Conditions (Record_ID INTEGER PRIMARY KEY, Precipitation TEXT,  Sky TEXT, FOREIGN KEY(Record_ID) REFERENCES Aircraft(Record_ID))")
Conditions = cbind.data.frame(BirdStrikes.import$Record.ID, BirdStrikes.import$Conditions..Precipitation, BirdStrikes.import$Conditions..Sky)
dbWriteTable(conn=db, name="Conditions", Conditions, append=T, row.names=F)

#to create Cost table with required data 
dbSendQuery(conn = db,  "CREATE TABLE Cost (Record_ID INTEGER PRIMARY KEY, Aircraft_time_OOS INTEGER,  Repair INTEGER, Other INTEGER,FOREIGN KEY(Record_ID) REFERENCES Aircraft(Record_ID))")
Cost = cbind.data.frame(BirdStrikes.import$Record.ID, BirdStrikes.import$Cost..Aircraft.time.out.of.service..hours., BirdStrikes.import$Cost..Repair..inflation.adj., BirdStrikes.import$Cost..Other..inflation.adj.)
dbWriteTable(conn=db, name="Cost", Cost, append=T, row.names=F)

#to get all the created tables in one data.frame
Total_data<- data.frame(Aircraft, Airport, Altitude, Conditions, Cost, Datatime, Effect, Fatalities, Location)
#function to check whether the data is correctly retrieved from all the created tables 
#Input: data_info <- function (id) with total_data
#Output: Aircraft model for specified id
data_info <- function(id){
  data_id<- Total_data[1]
  row <- which(data_id == id) 
  data <- Total_data[row,]
  aircraft_model <- data[3]
  print(aircraft_model)
}
#Aircfrat model is retrieved for the Id given in the parenthesis
data_info("204787")

#SELECT query to get the bird strikes occurred for American Airlines
Sql_query_q1<- dbGetQuery(conn = db, "SELECT count(Number_Struck) FROM Fatalities WHERE record_id in (SELECT record_id FROM Aircraft WHERE Aircraft_Operator = 'AMERICAN AIRLINES') AND Number_Struck != '0'")
# SELECT query to get number of bird strike for each airline, showing airline name including unknown and the number of strikes
Sql_query_q2<- dbGetQuery(conn = db, "SELECT Aircraft_Operator, count(*) as Number_Of_Strikes FROM Aircraft INNER JOIN Fatalities ON Aircraft.Record_ID = Fatalities.Record_ID GROUP BY Aircraft_Operator")
#SELECT query to get airline that had the most bird strikes, excluding military and unknown
Sql_query_q3<- dbGetQuery(conn = db, "SELECT Aircraft_Operator, count(*) as Number_Of_Strikes FROM Aircraft INNER JOIN Fatalities ON Aircraft.Record_ID = Fatalities.Record_ID AND Aircraft.Aircraft_Operator not in ('UNKNOWN','MILITARY') GROUP BY Aircraft_Operator ORDER BY Number_Of_Strikes DESC LIMIT 1")
#SELECT query to get bird strikes occurred for Helicopters with dates 
Sql_query_q4<- dbGetQuery(conn = db, "SELECT Aircraft_Operator, Number_Struck, Flight_Date FROM Aircraft INNER JOIN Fatalities ON Aircraft.Record_ID = Fatalities.Record_ID INNER JOIN Datatime on Aircraft.Record_ID = Datatime.Record_ID AND Aircraft.Record_ID in (SELECT Record_ID FROM Aircraft WHERE Aircraft_Operator LIKE '%HELICOPTERS%');")
#SELECT query to get airlines that had more than 10 bird strikes excluding Military and unknown
Sql_query_q5<-  dbGetQuery(conn = db, "SELECT Aircraft_Operator FROM Aircraft WHERE record_id in (SELECT record_id FROM Fatalities WHERE Number_Struck = '11 to 100') AND Aircraft_Operator not in ('UNKNOWN','MILITARY')")


#to get list of all the tables in the database
dbListTables(db)
