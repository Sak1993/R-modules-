#gzfile to load the zip file
movies.zip <-("movies.list.gz")
#readLines to unzip the file in R
movies <- readLines(movies.zip)


#function to capture names only with text and numbers
fun.movies <- function(film) {
  grep('^(([0-9])|([A-Z])|([a-z]))+',film, perl = T)
}

#These are the movie rows. movies.list is the dataset with movies list
#calling function name to lapply to get movie names
movies1.list <- movies[which(lapply(movies,fun.movies) == 1)]

#removing unwanted header information
movies1.list <- movies1.list[7:length(movies1.list)]
head(movies1.list)



#function to parse and split movie name and year
#saving only one column of year by removing duplicates
movie.name.year <- function(movie) {
  val <- sub('\\(([0-9]+)\\)','',movie)
  val <- strsplit(val,'(\\t)+',perl = T)
  val <- as.data.frame(val[[1]])
}

#calling the function movie.name.year to lapply
movie1.split <- lapply(movies1.list,movie.name.year)
movie1.split <- data.frame(movie1.split)

#Transporsing the data frame
movie1.split <- t(movie1.split)

#Giving names for the two columns
colnames(movie1.split) <- c('Name', 'Year')

#Number of rows
rownames(movie1.split) <- 1:nrow(movie1.split)

#Omitting NAs in the dataframe
movie1.split <- na.omit(movie1.split)

#Convert year to numeric type
movie1.split[,2] <- as.numeric(movie1.split[,2])


#Printing the first 10 rows
head(movie1.split,10)

