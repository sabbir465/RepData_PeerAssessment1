###Load necessary packages
library(ggplot2)
library(dplyr)
library(lubridate)


#Loading and preprocessing the data
###1. Code for reading in the dataset and/or processing the data

rm(list=ls())
fileUrl <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip"
download.file(fileUrl, destfile = paste0(getwd(), '/zipped_data_folder.zip'))
unzip("zipped_data_folder.zip",exdir = "unziped_data_folder")
file<-list.files("unziped_data_folder", full.names = TRUE)
data<-read.csv(file)


#What is mean total number of steps taken per day?
###2. Histogram of the total number of steps taken each day
total_steps<-data %>% group_by(date) %>% summarise(total=sum(steps, na.rm = TRUE)) %>% as.data.frame()
ggplot(total_steps, aes(x = total)) +
  geom_histogram(fill = "red", binwidth = 500) +
  labs(title = "Fig 1: Daily Steps", x = "steps", y = "frequency")


###3. Mean and median number of steps taken each day
paste("daily mean   =", mean(total_steps$total, na.rm = TRUE))
paste("daily median =", median(total_steps$total, na.rm = TRUE))


#What is the average daily activity pattern?
###4. Time series plot of the average number of steps taken
total_steps<-data %>% group_by(interval) %>% summarise(total=sum(steps, na.rm = TRUE), avg=mean(steps, na.rm = TRUE)) %>% as.data.frame()

plot(total_steps$interval, total_steps$avg, type= "l", xlab="5 minutes intervals", ylab="mean steps", main = "Fig 2: Time series plot")


###5. The 5-minute interval that, on average, contains the maximum number of steps
paste("Interval that contains maximum number of steps: ", total_steps$interval[which.max(total_steps$avg)])
paste("The maximum value is: ", max(total_steps$avg))


#Imputing missing values
###6. Code to describe and show a strategy for imputing missing data
paste("Total number of missing values before imputing: ", sum(is.na(data$steps)))
missing_index<-as.numeric(which(is.na(data$steps)))
new_data<-data
for(i in missing_index){
  new_data$steps[i]<-median(new_data$steps[new_data$interval==new_data$interval[i]], na.rm = TRUE)
}
paste("Total number of missing values after imputing: ", sum(is.na(new_data$steps)))



###7. What is mean total number of steps taken per day? Histogram of the total number of steps taken each day after missing values are imputed
new_total_steps<-new_data %>% group_by(date) %>% summarise(total=sum(steps, na.rm = TRUE)) %>% as.data.frame()

ggplot(new_total_steps, aes(x = total)) +
  geom_histogram(fill = "red", binwidth = 500) +
  labs(title = "Fig 3: Daily Steps after imputing", x = "steps", y = "frequency")
paste("daily mean   (after imputing) =", mean(new_total_steps$total, na.rm = TRUE))
paste("daily median (after imputing)=", median(new_total_steps$total, na.rm = TRUE))



#Are there differences in activity patterns between weekdays and weekends?
###8. Panel plot comparing the average number of steps taken per 5-minute interval across weekdays and weekends

week_days<-c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday")
new_data$day<-as.factor(ifelse(weekdays(ymd(new_data$date)) %in% week_days, "weekday", "weekend"))

new_data_weekday <-new_data %>% filter(day=="weekday") %>% group_by(interval) %>% 
  summarise(avg=mean(steps, na.rm = TRUE)) %>% as.data.frame()%>%   mutate(day="weekday")

new_data_weekend <-new_data %>% filter(day=="weekend") %>% group_by(interval) %>%
  summarise(avg=mean(steps, na.rm = TRUE)) %>% as.data.frame()%>% mutate(day="weekend")

combined_new_data<-bind_rows(new_data_weekday, new_data_weekend)
combined_new_data$day<-as.factor(combined_new_data$day)

combined_new_data %>% ggplot(aes(interval, avg))+geom_line()+
  labs(title = "Fig 4: Daily Average Steps by weekdays", x = "interval", y = "frequency")+facet_grid(day ~.)

