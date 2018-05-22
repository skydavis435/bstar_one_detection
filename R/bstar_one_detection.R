one.detection <- function(){
#Examine Single Detection Tracks Throughout BSTAR V2 Deployment
  require(data.table)
  require(bit64)
  require(parallel)
  require(ggplot2)
  require(ggthemes)
  require(stringr)
#Setup
  working.directory<-file.path(path.expand("~"),"Documents","BSTAR_One_Detection")
  radar.data<-file.path(path.expand("~"),"Documents", "Radar_Data","BSTAR_V2")
  numCores<-detectCores()
  start.date <- "2018-01-01"
  end.date<- "2018-12-31"
#Load the radar data.
  setwd(radar.data)
  filelist<-list.files(pattern="\\.csv$")
  filelist<-as.data.frame(x = filelist)  
  colnames(filelist)<-c("filename")
  filelist$filename<-as.character(filelist$filename)
#One year at a time
  filelist$date <- strptime(x = filelist$filename,format = "%Y.%m.%d")
  sub.filelist <- subset(filelist, nchar(filename)!=37)
  sub.filelist <- subset(filelist, date >= as.POSIXct(x = start.date) & date <= as.POSIXct(end.date))
  datalist <- mclapply(sub.filelist$filename,fread,mc.cores = numCores) #faster if loading multiple CSV files    
  data <- rbindlist(datalist)
#Date/Time
  data$`Start.Time_US/Central`<- as.POSIXct(x = data$`Start.Time_US/Central`, tz="US/Central")
  data$`End.time_US/Central` <- as.POSIXct(x = data$`End.time_US/Central`, tz="US/Central")  
  eco.day.night<-str_split_fixed(string = data$Ecological.Day.Night,pattern = " ",n = 2)
  data$eco.date<-eco.day.night[,1]
  data$eco.date<-as.Date(data$eco.date)
  data$eco.class<-eco.day.night[,2]
#Split out single detection
  data$division.1<-cut(x = data$Detections.qty,breaks = c(0,1,5000),labels = c("Single.Detection","Multiple.Detection"))
#Plot
  p <- ggplot(data = data, aes(x=eco.date)) + geom_bar(stat = "count",color="black",fill="grey") + facet_wrap(division.1~eco.class)
  p.1 <- p + xlab("Date") + ylab("Frequency") + ggtitle(label = "Track Counts by Date",subtitle = "BSTAR V2: Dallas Fort Worth International Airport") + theme_gdocs()
#Save
  filename<-paste0(start.date,"-",end.date,".png")
  ggsave(filename = filename,plot = p.1,path = working.directory,width = 22,height = 17,dpi = 320,units = "in")
  }