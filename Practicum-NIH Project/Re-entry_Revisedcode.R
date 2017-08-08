## Part I: calculate Gaps

# setting working directory, read data and rename column

setwd("/Users/zhuyu/Desktop/NIH")
data08 = read.csv('NIGMS_R01_R37_93_08.csv',head=T,stringsAsFactors = FALSE)
data15 = read.csv('NIGMS_R01_R37_09_15.csv',head=T,stringsAsFactors = FALSE)
data15=data15[,!(colnames(data15)%in%c("Organization.ID..IPF."))]
dat=rbind(data08,data15)
names(dat)[names(dat) == 'Contact.PI..Person.ID'] <- 'PPID'

# subset of the original data set
dat = dat[,c('PPID','Project.Number','Type','FY','Project.Start.Date','Project.End.Date','Budget.Start.Date','Budget.End.Date','Support.Year','Organization.State','FY.Total.Cost.by.IC','Organization.Name')]
dat$pjnum = as.numeric(substr(as.character(dat$Project.Number),7,12)) 

# select competing awards
dat = dat[which(dat$Type %in% c(1,2,9)),]                                                
dat = dat[order(dat$PPID,dat$pjnum,dat$FY),]

# formating date
dat$Project.Start.Date = as.Date(dat$Project.Start.Date,format='%m/%d/%y') #reformat date in Excel to '%m/%d/%y' otherwise cannot be converted by as.Date()
dat$Project.End.Date = as.Date(dat$Project.End.Date,format='%m/%d/%y')
dat$Budget.Start.Date = as.Date(dat$Budget.Start.Date,format='%m/%d/%y') 
dat$Budget.End.Date = as.Date(dat$Budget.End.Date,format='%m/%d/%y') 
head(dat)
tail(dat)

# user defined function to calculate date distance in months. note that one nice feature of R is you can avoid the year*12+days formulation we're using here and 
# directly subtract full dates, R will calculate the distance in days, and we could divide by 30 to get (roughly) months. 
months_between = function(date2,date1) {
  #m1 = as.numeric(substr(as.character(date1),1,4))*12 + as.numeric(substr(as.character(date1),6,7))
  #m2 = as.numeric(substr(as.character(date2),1,4))*12 + as.numeric(substr(as.character(date2),6,7))
  months = (m2-m1)/30
  if (months<0) {
    months = 0
  }
  return(months)
}

# add one column named Gap.Status to judge whether a gap is open gap and calculate gap length
finaldate = as.Date('12/31/15',format='%m/%d/%y') #set a threshold of gap - 12/31/2008 
gap_status = c()
gap = c()
for (i in 1:nrow(dat)) {
  if (i %% 1000==0) print(i)
  if (i == nrow(dat)) {
    if (dat$Project.End.Date[i] < finaldate) {
      a = months_between(finaldate,dat$Project.End.Date[i])
      gap = c(gap,a)
      gap_status = c(gap_status, 'open gap')
    } else {
      gap = c(gap,0)
      gap_status = c(gap_status, '-')
    }
  } else {
    if (dat$pjnum[i+1] == dat$pjnum[i]) {
      b = months_between(dat$Budget.Start.Date[i+1],dat$Project.End.Date[i])
      gap = c(gap,b)
      gap_status = c(gap_status, '-')
    } else {
      if (dat$Project.End.Date[i] < finaldate) {
        c =  months_between(finaldate,dat$Project.End.Date[i])
        gap = c(gap,c)
        gap_status = c(gap_status, 'open gap')
      } else {
        gap = c(gap,0)
        gap_status = c(gap_status, '-')
      }
    }
  }
}
dat$Gap.Length = gap
dat$Gap.Status = gap_status
head(dat)
tail(dat)


#############################################################################################################################

# Part II:  Judge re entry or not (0/1: not re entry/ re entry)

# judge if a project has re entried or not
re_entry=c()
for (i in 1:(nrow(dat))) {
  if (i %% 1000==0) print(i)
  if (i == nrow(dat)) {
    if (! dat$Gap.Length[i] == 0) {
      if (dat$Project.End.Date[i] < finaldate) {
        re_entry=c(re_entry,0)
      } else {
        re_entry=c(re_entry,"unknown")
      }
    } else {
      re_entry=c(re_entry,0)
    }
  } else {
    if (! dat$Gap.Length[i] == 0) {
      if (! dat$pjnum[i+1] == dat$pjnum[i]) {
        if (dat$Project.End.Date[i] < finaldate) {
          re_entry=c(re_entry,0)
        } else {
          re_entry=c(re_entry,"unknown")
        } 
      } else {
        re_entry=c(re_entry,1)  
      }
    } else {
      if (dat$Project.End.Date[i] < finaldate) {
        re_entry=c(re_entry,0)
      } else {
        re_entry=c(re_entry,"unknown")
      }
    }
  }
}   

dat$Re.Entry=re_entry
head(dat)
tail(dat)


####################################################################################################################################################################

# Part III: Fix open gaps by extracting data from 2009 to 2015 to see if the open gap get closed

# read data
data_back = read.csv('NIGMS_R01_R37_09_15.csv',head=T,stringsAsFactors = FALSE)

# rename and subset the original data set
names(data_back)[names(data_back) == 'Contact.PI..Person.ID'] <- 'PPID'
data_back = data_back[,c('PPID','Project.Number','Type','FY','Project.Start.Date','Project.End.Date','Budget.Start.Date','Budget.End.Date','Support.Year')]
data_back$pjnum = as.numeric(substr(as.character(data_back$Project.Number),7,12)) 

# formating date
data_back$Budget.Start.Date = as.Date(data_back$Budget.Start.Date,format='%m/%d/%y') 

# select competing award and sort data_back
data_back = data_back[which(data_back$Type %in% c(1,2,7,9)),]                                                
data_back = data_back[order(data_back$PPID,data_back$pjnum,data_back$FY),]

# re calculate gap length and re set re_entry to 1 if any open gaps in dat get closed based on records of data_back
finaldate2 = as.Date('12/31/15',format='%m/%d/%y') #set a threshold of gap - 12/31/2015 
for (i in 1:(nrow(dat))) {
  if (i %% 1000 == 0) print (i)
  if (dat$Gap.Status[i] == 'open gap') {
    if (dat$pjnum[i] %in% data_back$pjnum) {
    #   dat$Re.Entry[i]=1
    #   dat$Gap.Length[i] = months_between(data_back$Budget.Start.Date[j], dat$Project.End.Date[i])
    # }
    for (j in 1:(nrow(data_back))){
      if (data_back$pjnum[j] == dat$pjnum[i]) {
        dat$Re.Entry[i] = 1
        dat$Gap.Length[i] = months_between(data_back$Budget.Start.Date[j], dat$Project.End.Date[i])
        break
      }
     }
    }
  if (dat$Re.Entry[i] == 0) {
    dat$Gap.Length[i] = months_between(finaldate2, dat$Project.End.Date[i])
  } 
 }
}  
  
head(dat)
tail(dat)

#######################################################################################################################

# Part IV:  add two new columns: Gap_Start_Date, Gap_End_Date from Project_End_Date and Budget_Start_Date
Gap.Start.Date = c()
Gap.End.Date = c()
for (i in 1:(nrow(dat))) {
  if (i %% 1000==0) print(i)
  if (! dat$Gap.Length[i] == 0) { 
    if (i == nrow(dat)) {
      a = format(dat$Project.End.Date[i],format = "%Y-%m-%d")
      b = format(finaldate,format = "%Y-%m-%d")
      Gap.Start.Date = c(Gap.Start.Date,a)
      Gap.End.Date = c(Gap.End.Date,b)}
    else {
      if (dat$pjnum[i+1]-dat$pjnum[i]==0) {
        a = format(dat$Project.End.Date[i],format = "%Y-%m-%d")
        b = format(dat$Budget.Start.Date[i+1],format = "%Y-%m-%d") 
        Gap.Start.Date = c(Gap.Start.Date,a)
        Gap.End.Date = c(Gap.End.Date,b) }
      else {
        a = format(dat$Project.End.Date[i],format = "%Y-%m-%d")
        b = format(finaldate,format = "%Y-%m-%d") 
        Gap.Start.Date = c(Gap.Start.Date,a)
        Gap.End.Date = c(Gap.End.Date,b) } } } 
  else { 
    a = 0
    b = 0 
    Gap.Start.Date = c(Gap.Start.Date,a)
    Gap.End.Date = c(Gap.End.Date,b) } }

dat$Gap.Start.Date = Gap.Start.Date
dat$Gap.End.Date  = Gap.End.Date
head(dat)
tail(dat)


#############################################################################################################################

# Part V: Calculate re entry probability for different gap length

# calculate the frequency and probability of gap length ( [gap length,) )
data_new=dat[which(dat$Gap.Length>0),]

gap_freq = data.frame(Gap.Length = unique(data_new$Gap.Length)[order(unique(data_new$Gap.Length))])
gap_freq$Re.Entered = gap_freq$Number = NA
for (i in 1:nrow(gap_freq)) {
  if (i %% 50 == 0) print(i)
  gap_freq$Number[i] = nrow(data_new[data_new$Gap.Length>=gap_freq$Gap.Length[i],])
  gap_freq$Re.Entered[i] = nrow(data_new[which(data_new$Gap.Length>=gap_freq$Gap.Length[i] & data_new$Re.Entry==1),])
}
gap_freq$Prob.Re.Entry = round(100*gap_freq$Re.Entered/gap_freq$Number,1)

head(gap_freq)
tail(gap_freq)

#############################################################################################################################

# Part VI: Calculate concurrent project numbers and concurrent funding per month for each gap

## calculating concurrent number of project per gap in view of month: Mave_Concurrent
## calculating concurrent funding per gap per month: Mave_Funding
PPID = dat[c('PPID')]
PPID = PPID[!duplicated(PPID),]
for (i in 1:length(PPID)) { 
  if (i %% 100==0) print(i)
  subdat = dat[which(dat$PPID == PPID[i]),]
  row_name = rownames(subdat)
  Mave_concurrent = c()
  Mave_funding = c()
  for (j in 1:(nrow(subdat))) {
    Mave_number = 0
    Mave_fnd = 0
    if (!subdat$Gap.Length[j] == 0) { 
      for (k in 1:nrow(subdat)) {
        if (!subdat$pjnum[k] == subdat$pjnum[j] ){
          wholenumber = months_between(subdat$Project.End.Date[k],subdat$Project.Start.Date[k])
          wholefunding = subdat$FY.Total.Cost.by.IC[k]
          if (subdat$Project.Start.Date[k]<=subdat$Gap.Start.Date[j] & subdat$Gap.Start.Date[j]<=subdat$Project.End.Date[k] & subdat$Project.End.Date[k]<=subdat$Gap.End.Date[j]) {
            Mave_number = Mave_number + months_between(subdat$Project.End.Date[k],subdat$Gap.Start.Date[j])
            Mfunding = wholefunding*(months_between(subdat$Project.End.Date[k],subdat$Gap.Start.Date[j]))/wholenumber
            Mave_fnd = Mave_fnd + Mfunding
          }   
          else if (subdat$Gap.Start.Date[j]<=subdat$Project.Start.Date[k] & subdat$Project.Start.Date[k]<=subdat$Gap.End.Date[j] & subdat$Gap.End.Date[j]<=subdat$Project.End.Date[k]) {
            Mave_number = Mave_number + months_between(subdat$Gap.End.Date[j],subdat$Project.Start.Date[k]) 
            Mfunding = wholefunding*(months_between(subdat$Gap.End.Date[j],subdat$Project.Start.Date[k]))/wholenumber
            Mave_fnd = Mave_fnd + Mfunding
          }
          else if (subdat$Gap.Start.Date[j]<=subdat$Project.Start.Date[k] & subdat$Project.End.Date[k]<=subdat$Gap.End.Date[j]) {
            Mave_number = Mave_number + months_between(subdat$Project.End.Date[k], subdat$Project.Start.Date[k])
            Mfunding = wholefunding*(months_between(subdat$Project.End.Date[k], subdat$Project.Start.Date[k]))/wholenumber
            Mave_fnd = Mave_fnd + Mfunding
          }
          else if (subdat$Project.Start.Date[k]<=subdat$Gap.Start.Date[j] & subdat$Gap.End.Date[j]<=subdat$Project.End.Date[k]) {
            Mave_number = Mave_number + months_between(subdat$Gap.End.Date[j], subdat$Gap.Start.Date[j])
            Mfunding = wholefunding*(months_between(subdat$Gap.End.Date[j], subdat$Gap.Start.Date[j]))/wholenumber
            Mave_fnd = Mave_fnd + Mfunding
          }
        }}}
    Mave_concurrent = c(Mave_concurrent, Mave_number / subdat$Gap.Length[j])
    Mave_funding = c(Mave_funding, Mave_fnd/ subdat$Gap.Length[j])
  }
  subdat$Mave_concurrent = Mave_concurrent
  subdat$Mave_funding = Mave_funding
  for (j in 1:(length(row_name))) { # append values based on unique row names
    dat[row_name[j],]$Mave_Concurrent = subdat[row_name[j],]$Mave_concurrent
    dat[row_name[j],]$Mave_Funding = subdat[row_name[j],]$Mave_funding
  }
}

sum(is.na(dat$Mave_Concurrent)) # Notice there is 7286 NAN in this vector, matches those records who don't have a gap.
sum(is.na(dat$Mave_Funding))
sum(dat$Gap.Length == 0)

###############################################################################################################################################

# Part VII: Calculate and Combine Avg.Total.Funding.by.PPID and Avg.Total.Funding.by.pjnum into dat

#calculate average total funding per year for each project and each PPID
dat$Avg.Total.Funding.by.PPID = 0
for (i in unique(dat$PPID)) {
  subdat = dat[which(dat$PPID == i),]
  subdat$Avg.Total.Funding.by.PPID = 0
  row_name = rownames(subdat)
  avg_funding_PPID = sum(subdat$FY.Total.Cost.by.IC) / nrow(subdat)
  for (j in 1:(length(row_name))) {
    subdat$Avg.Total.Funding.by.PPID[j] = avg_funding_PPID
    dat[row_name[j],]$Avg.Total.Funding.by.PPID = subdat[row_name[j],]$Avg.Total.Funding.by.PPID
  }}

dat$Avg.Total.Funding.by.PPID[is.nan(dat$Avg.Total.Funding.by.PPID)] = -999

head(dat)
tail(dat)

dat$Avg.Total.Funding.by.pjnum = 0
for (i in unique(dat$pjnum)) {
  subdat = dat[which(dat$pjnum == i),]
  subdat$Avg.Total.Funding.by.pjnum = 0
  row_name = rownames(subdat)
  avg_funding_pjnum = sum(subdat$FY.Total.Cost.by.IC) / nrow(subdat)
  for (j in 1:(length(row_name))) {
    subdat$Avg.Total.Funding.by.pjnum[j] = avg_funding_pjnum
    dat[row_name[j],]$Avg.Total.Funding.by.pjnum = subdat[row_name[j],]$Avg.Total.Funding.by.pjnum 
  }
}

dat$Avg.Total.Funding.by.pjnum[is.nan(dat$Avg.Total.Funding.by.pjnum)] = -999

head(dat)
tail(dat)

###########################################################################################################################

# Part VIII: add in IDeA State into dat

IDeA = c('AK','NV','ID','MT','WY','NM','ND','SD','NE','KS','OK','AR','LA','MS',
         'KY','WV','SC','HI','DE','PR','VT','NH','ME','RI')

dat['ifIDeA'] = 0
dat$ifIDeA[dat$Organization.State %in% IDeA] = 1

###########################################################################################################################

# Part VIIII: Clean a data table for model construction

# keep the records with Gap_Length > 0 of dat
subdat = dat[which(dat$Gap.Length > 0),]
subdat_2 = subdat[which(! subdat$Re.Entry == "unknown"),]

# check if there is any -999 in table
subdat_2[which(subdat_2$Avg.Total.Funding.by.pjnum == '-999'),]

# check if there is NA in Support Year
any(is.na(subdat_2))
any(is.na(subdat_2$Re.Entry))
any(is.na(subdat_2$Gap.Length))
any(is.na(subdat_2$Mave_Concurrent))
any(is.na(subdat_2$Mave_Funding))
any(is.na(subdat_2$Avg.Total.Funding.by.pjnum))
any(is.na(subdat_2$Support.Year))
any(is.na(subdat_2$ifIDeA))

# write subdat_2 into a csv for model construction
write.csv(subdat_2,'data_model.csv')

  
