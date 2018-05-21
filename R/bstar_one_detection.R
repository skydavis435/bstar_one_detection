#Examine Single Detection Tracks Throughout BSTAR V2 Deployment
  require(data.table)
  require(bit64)
  require(parallel)
  require(ggplot2)
  require(ggthemes)
#Setup
  working.directory<-file.path(path.expand("~"),"Documents","BSTAR_one_detection")
  radar.data<-file.path(path.expand("~"),"Documents", "Radar_Data","BSTAR_V2")
  numCores<-detectCores()
#Load the radar data.
  setwd(radar.data)
  filelist<-list.files(pattern="\\.csv$")
  datalist<-mclapply(filelist,fread,mc.cores = numCores) #faster if loading multiple CSV files    
  