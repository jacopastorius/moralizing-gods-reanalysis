
rm(list = ls())

source("../project_support.r")

# Checks Soc Complx data from exportdat.csv for error
polities <- read.csv('./input/polities.csv', header=TRUE)
polities <- polities[polities$Dupl=="n",]
Vars <- as.matrix(read.csv('./input/variables.csv', header=TRUE))
SCdat <- matrix(nrow = 0, ncol = 0)
dat <- read.table('./input/exportdat.csv', sep=",", header=TRUE, quote = "", colClasses = "character")
dat <- dat[dat$Section==Section1 | dat$Section==Section2 | dat$Section==Section3,] # Section is set in !MI.R

# create new variables combining Subsection and Variable
Vars[,1] <- paste(Vars[,2],Vars[,1]) # Creating unique variable/section combinations
dat[,5] <- paste(dat[,4],dat[,5]) # Creating unique variable/section combinations

# subset Seshat dataset to include only variables from the Vars dataset
for(i in 1:length(Vars[,1])){
   var <- Vars[i,1]
   dt <- dat[dat$Variable==var,]
   SCdat <- rbind(SCdat,dt)
}
dat <- SCdat
SCdat <- matrix(nrow = 0, ncol = 0)

# subset Seshat dataset to include only polities in the polities dataset
for(i in 1:nrow(polities)){
   dt <- dat[dat$Polity==polities$PolID[i],]
   SCdat <- rbind(SCdat,dt)
}

# extract only relevant columns
SCdat <- SCdat[,c(1,2,5,6,7,8,9,10,11,12)]
row.names(SCdat) <- NULL

# Convert categorical values to numbers. Ignore warnings: they will be taken care off in the next step -- in errors
for(i in 1:nrow(SCdat)){
   for(j in 4:5){
       if(SCdat[i,j] == "present"){SCdat[i,j] <- "1"}   
      if(SCdat[i,j] == "inferred present"){SCdat[i,j] <- "0.9"}   
      if(SCdat[i,j] == "inferred absent"){SCdat[i,j] <- "0.1"}   
      if(SCdat[i,j] == "absent"){SCdat[i,j] <- "0"}   
      if(SCdat[i,j] == "none"){SCdat[i,j] <- "0"}
      if(SCdat[i,j] == "daily"){SCdat[i,j] <- "6"}   
      if(SCdat[i,j] == "weekly"){SCdat[i,j] <- "5"}
      if(SCdat[i,j] == "monthly"){SCdat[i,j] <- "4"}  
      if(SCdat[i,j] == "seasonally"){SCdat[i,j] <- "3"}  
      if(SCdat[i,j] == "yearly"){SCdat[i,j] <- "2"}   
      if(SCdat[i,j] == "once per generation"){SCdat[i,j] <- "1"}   
      if(SCdat[i,j] == "once in a lifetime"){SCdat[i,j] <- "0"}    
      if(SCdat[i,j] == "whole polity"){SCdat[i,j] <- "3"}      
      if(SCdat[i,j] == "majority"){SCdat[i,j] <- "2"}      
      if(SCdat[i,j] == "substantial minority"){SCdat[i,j] <- "1"}      
      if(SCdat[i,j] == "elites"){SCdat[i,j] <- "0"}          
      if(SCdat[i,j] == "inactive"){SCdat[i,j] <- "1"}
      if(SCdat[i,j] == "active"){SCdat[i,j] <- "2"}          
      if(SCdat[i,j] == "moralizing"){SCdat[i,j] <- "3"}          
      if(SCdat[i,j] == "monotheistic"){SCdat[i,j] <- "1"}     
      if(SCdat[i,j] == "polytheistic"){SCdat[i,j] <- "2"}                                                     
      if(SCdat[i,j] == "not applicable"){SCdat[i,j] <- "unknown"}      
      if(SCdat[i,j] == "suspected unknown"){SCdat[i,j] <- "unknown"}      
      if(SCdat[i,j] == "unknown"){SCdat[i,j] <- NA}     
   }}
# remove missing values from Value.From
SCdat <- SCdat[is.na(SCdat[,4])==FALSE,]
dat <- SCdat
# extract errors caused by other non numeric coding of Value.From
for(i in 1:nrow(SCdat)){
   dat[i,4] <- as.numeric(SCdat[i,4])
}
# extract these rows into seperate data frame and filter
errors <- SCdat[is.na(dat[,4]),]

SCdat <- SCdat[is.na(dat[,4])==FALSE,]
# check Value.to for any values that cannot be converted to numeric
# there are none
dat <- SCdat[SCdat[,5]!="",]
datNA <- dat
for(i in 1:nrow(dat)){
   datNA[i,5] <- as.numeric(dat[i,5])
}
errors <- rbind(errors,dat[is.na(datNA[,5]),])

# Change BCE to negative years and remove CE.
# Start date
for(i in 1:nrow(SCdat)){
   if(substr(SCdat[i,6], (nchar(SCdat[i,6]) - 2) , nchar(SCdat[i,6]) ) =="BCE" )
   {a <- -as.numeric(substr(SCdat[i,6], 1, (nchar(SCdat[i,6]) - 3)))
    SCdat[i,6] <- a}
   if(substr(SCdat[i,7], (nchar(SCdat[i,7]) - 2) , nchar(SCdat[i,7]) ) =="BCE" )
   {a <- -as.numeric(substr(SCdat[i,7], 1, (nchar(SCdat[i,7]) - 3)))
    SCdat[i,7] <- a}
}
# End date
for(i in 1:nrow(SCdat)){
   if(substr(SCdat[i,6], (nchar(SCdat[i,6]) - 1) , nchar(SCdat[i,6]) ) =="CE" )
   {a <- as.numeric(substr(SCdat[i,6], 1, (nchar(SCdat[i,6]) - 2)))
    SCdat[i,6] <- a}
   if(substr(SCdat[i,7], (nchar(SCdat[i,7]) - 1) , nchar(SCdat[i,7]) ) =="CE" )
   {a <- as.numeric(substr(SCdat[i,7], 1, (nchar(SCdat[i,7]) - 2)))
    SCdat[i,7] <- a}
}

# here Date.From is checked for any values that cannot be converted to numeric
# which there are none
dat <- SCdat[SCdat[,6]!="",]
for(i in 1:nrow(dat)){
   dat[i,6] <- as.numeric(dat[i,6])
}
errors <- rbind(errors,dat[is.na(dat[,6]),])

# here Date.To is checked for any values that cannot be converted to numeric
# which there are none
dat <- SCdat[SCdat[,7]!="",]
for(i in 1:nrow(dat)){
   dat[i,7] <- as.numeric(dat[i,7])
}
errors <- rbind(errors,dat[is.na(dat[,7]),])

dir_init("./output")

# write csv of errors and filtered date
write.csv(errors, file="./output/errors.csv",  row.names=FALSE)
write.csv(SCdat, file="./output/SCdat.csv",  row.names=FALSE)

expect_equal(dim(SCdat), c(19427, 10))
expect_equal(dim(errors), c(20, 10))

print("precheck complete; SCdat.csv and errors.csv created")
