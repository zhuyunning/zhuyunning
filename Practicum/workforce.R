pt0 = TRUE  # functions and paramters
pt1 = FALSE # read, merge, and save dat; else load dat
pt2 = FALSE # create and save gapdat with basic variables (fixed vars, gap length, gap status); else load gapdat
pt3 = FALSE # calculate concurrent project count and funding and save gapdat.full; else load gapdat.full
pt4 = TRUE  # logistic modeling 
pt5 = FALSE  # projecting re-entry month over month

if (pt0) {
  library(MASS)
  days.per.month = 365/12
  
  #Defined <after> model m3 gets run; shown here for reference
  #m3prob = function(Gap.Length,SY,Num.Concurrent,Funding.Concurrent) {
  #  return(1/(1+exp(-1*(m3['(Intercept)']+m3['Gap.Length']*Gap.Length+m3['SY']*SY+m3['SY2']*SY*SY
  #                      +m3['Num.Concurrent']*Num.Concurrent+m3['Funding.Concurrent']*Funding.Concurrent))))
  #}
  
  months_between = function(date1,date2) {
    months= as.numeric(round((date2-date1)/days.per.month))
    return(max(0,months))
  }
  
  active.grants = function(PPID,pjnum,date) {
    og = dat[dat$PPID==PPID & ! dat$pjnum==pjnum,]
    return(     c(sum(date>=og$Budget.Start.Date & date<og$Project.End.Date),sum(og$FY.Total.Cost.by.IC[date>=og$Budget.Start.Date & date<og$Project.End.Date]))         )
  }
}


if (pt1) {
  dat08 = read.csv('/Users/lijingning/Desktop/A/PRACTICUM/NIH/new/NIGMS_R01_R37_93_08.csv',head=T,stringsAsFactors = FALSE)
  dat08$Project.Start.Date = as.Date(dat08$Project.Start.Date,format='%d-%b-%y')
  dat08$Project.End.Date   = as.Date(dat08$Project.End.Date,format='%d-%b-%y')
  dat08$Budget.Start.Date  = as.Date(dat08$Budget.Start.Date,format='%d-%b-%y')
  dat08$Budget.End.Date    = as.Date(dat08$Budget.End.Date,format='%d-%b-%y')
  
  dat15 = read.csv('/Users/lijingning/Desktop/A/PRACTICUM/NIH/new/NIGMS_R01_R37_09_15.csv',head=T,stringsAsFactors = FALSE)
  dat15$Project.Start.Date = as.Date(dat15$Project.Start.Date,format='%m/%d/%y')
  dat15$Project.End.Date   = as.Date(dat15$Project.End.Date,format='%m/%d/%y')
  dat15$Budget.Start.Date  = as.Date(dat15$Budget.Start.Date,format='%m/%d/%y')
  dat15$Budget.End.Date    = as.Date(dat15$Budget.End.Date,format='%m/%d/%y')
  
  dat15 = dat15[,-31]
  names(dat08)[names(dat08) == 'Contact.PI..Person.ID'] <- 'PPID'
  names(dat15)[names(dat15) == 'Contact.PI..Person.ID'] <- 'PPID'
  dat = rbind(dat08,dat15)
  dat = dat[which(dat$Type %in% c(1,2,9)),]   ### JAKE TOLD THEM TO USE TYPE 7 TOO BUT HE WAS WRONG                                     
  dat = dat[,c('PPID','Project.Number','Type','FY','Project.Start.Date','Project.End.Date','Budget.Start.Date',
               'Budget.End.Date','Support.Year','Organization.State','FY.Total.Cost.by.IC','Organization.Name')]
  dat$pjnum = as.numeric(substr(as.character(dat$Project.Number),7,12)) 
  #dat$SY = substr(dat$Project.Number,14,15)
  dat = dat[order(dat$PPID,dat$pjnum,dat$FY),]
  
  carndat = read.csv('/Users/lijingning/Desktop/A/PRACTICUM/NIH/new/NIGMS_R01_R37_93_08_carn.csv',head=T)
  carndat$pjnum = substr(as.character(carndat$Project.Number),7,12)
  dat$Carn = carndat$Carnegie_Classification[match(dat$pjnum,carndat$pjnum)]
  save(dat,file='/Users/lijingning/Desktop/A/PRACTICUM/NIH/new/analysis.data.RData')
} else {
  load('/Users/lijingning/Desktop/A/PRACTICUM/NIH/new/analysis.data.RData')
}

if (pt2) {
  finaldate  = as.Date('2015-12-31',format='%Y-%m-%d')
  gapdat1 = data.frame(PPID=NA,pjnum = NA, SY=NA, State=NA,Gap.Start = as.Date('01-01-1901',format='%m-%d-%Y'), Gap.Length = NA, Gap.Status = NA)
  gapdat1 = gapdat1[0,]
  gapdat10 = gapdat9 = gapdat8 = gapdat7 = gapdat6 = gapdat5 = gapdat4 = gapdat3 = gapdat2 = gapdat1
  gapdat_partials = list(gapdat1,gapdat2,gapdat3,gapdat4,gapdat5,gapdat6,gapdat7,gapdat8,gapdat9,gapdat10)
  chunk.size=2000
  num.chunks = ceiling(nrow(dat)/chunk.size)
  
  for(k in 1:num.chunks) {
    for (i in (chunk.size*(k-1)+1):min((chunk.size*k),nrow(dat)-1)) {
      if (i %% 50 ==0 ) print(sprintf('chunk %d, going from dat row %d to dat row %d, on dat row %d',k,(chunk.size*(k-1)+1),chunk.size*k,i))
      if (dat$Project.End.Date[i]<=as.Date('2008-12-31',format='%Y-%m-%d')) {
        if (dat$pjnum[i+1] == dat$pjnum[i]) {
          gaplength = months_between(dat$Project.End.Date[i],dat$Budget.Start.Date[i+1])
          if (gaplength>0) {
            out = data.frame(PPID=dat$PPID[i],pjnum=dat$pjnum[i],SY=dat$Support.Year[i],State=dat$Organization.State[i],
                             Gap.Start=dat$Project.End.Date[i],Gap.Length=(1:(gaplength+1)),Gap.Status=   c(rep(0,gaplength),1)    )
            gapdat_partials[[k]] = rbind(gapdat_partials[[k]],out)
          }
        } else {
          gaplength = months_between(dat$Project.End.Date[i],finaldate)
          out = data.frame(PPID=dat$PPID[i],pjnum=dat$pjnum[i],SY=dat$Support.Year[i],State=dat$Organization.State[i],
                           Gap.Start=dat$Project.End.Date[i],Gap.Length=(1:(gaplength+1)),Gap.Status=  c(rep(0,gaplength),0)    )
          gapdat_partials[[k]] = rbind(gapdat_partials[[k]],out)
        }
      }
    }
  }
  i=nrow(dat)
  if (dat$Project.End.Date[i]<=as.Date('2008-12-31',format='%Y-%m-%d')){
    gaplength = months_between(dat$Project.End.Date[i],finaldate)
    out = data.frame(PPID=dat$PPID[i],pjnum=dat$pjnum[i],SY=dat$Support.Year[i],State=dat$Organization.State[i],
                     Gap.Start=dat$Project.End.Date[i],Gap.Length=(1:(gaplength+1)),Gap.Status=  c(rep(0,gaplength),0)    )
    gapdat_partials[[k]] = rbind(gapdat_partials[[k]],out)
  }
  
  gapdat = rbind(gapdat_partials[[1]],gapdat_partials[[2]],gapdat_partials[[3]],gapdat_partials[[4]],gapdat_partials[[5]],
                 gapdat_partials[[6]],gapdat_partials[[7]],gapdat_partials[[8]],gapdat_partials[[9]],gapdat_partials[[10]])
  save(gapdat,file='/Users/lijingning/Desktop/A/PRACTICUM/NIH/new/gapdat.RData')
} else {
  load('/Users/lijingning/Desktop/A/PRACTICUM/NIH/new/gapdat.RData')
}

if (pt3) {
  gapdat$Funding.Concurrent = gapdat$Num.Concurrent = NA
  for (i in 1:nrow(gapdat)) {
    if (i %% 250 == 0) print(i)
    gapdat[i,c('Num.Concurrent','Funding.Concurrent')] = active.grants(gapdat$PPID[i],gapdat$pjnum[i],gapdat$Gap.Start[i] + days.per.month*gapdat$Gap.Length[i])
  }
  gapdat$Funding.Concurrent = gapdat$Funding.Concurrent/1000
  save(gapdat,file='/Users/lijingning/Desktop/A/PRACTICUM/NIH/new/gapdat.full.RData')
} else {
  load('/Users/lijingning/Desktop/A/PRACTICUM/NIH/new/gapdat.full.RData')
}

if (pt4) {
  gapdat$SY2 = (gapdat$SY)^2
  idea_states = c('AK','AR','DE','HI','ID','MT','WY','NV','NM','ND','SD','NE','KS','OK','LA','MS','KY','WV','SC','PR','ME','VT','NH','RI')
  gapdat$idea = ifelse(gapdat$State %in% idea_states,1,0)
  gapdat$FY = as.numeric(substr(as.character(gapdat$Gap.Start),1,4))
  carndat$pjnum = as.numeric(carndat$pjnum)
  gapdat$Carn = carndat$Carnegie_Classification[match(gapdat$pjnum,carndat$pjnum)]
  
  t1=summary(glm(Gap.Status~Gap.Length,data=gapdat,family='binomial'))
  #Coefficients:
  #               Estimate Std. Error z value Pr(>|z|)    
  #  (Intercept) -3.431002   0.024008 -142.91   <2e-16 ***
  #  Gap.Length  -0.054222   0.001029  -52.69   <2e-16 ***
  t2=summary(glm(Gap.Status~Gap.Length + SY,data=gapdat,family='binomial'))
  #Coefficients:
  #               Estimate Std. Error z value Pr(>|z|)    
  #  (Intercept) -3.583531   0.028892 -124.03   <2e-16 ***
  #  Gap.Length  -0.054017   0.001028  -52.54   <2e-16 ***
  #  SY           0.021066   0.002040   10.33   <2e-16 ***
  
  

  
  t3=summary(glm(Gap.Status~Gap.Length + SY + SY2 + Num.Concurrent + Funding.Concurrent,data=gapdat,family='binomial'))
  #Coefficients:
  #                      Estimate Std. Error  z value Pr(>|z|)    
  #  (Intercept)        -3.8132924  0.0360432 -105.798  < 2e-16 ***
  #  Gap.Length         -0.0535029  0.0010279  -52.049  < 2e-16 ***
  #  SY                  0.0802262  0.0062722   12.791  < 2e-16 ***
  #  SY2                -0.0022850  0.0002443   -9.354  < 2e-16 ***
  #  Num.Concurrent      0.3762052  0.0939028    4.006 6.17e-05 ***
  #  Funding.Concurrent -0.0007703  0.0002975   -2.590  0.00961 ** 
  syx=1:45
  syy=exp(syx*0.0802262)*exp(syx*syx*-0.0022850)
  plot(syx,syy,pch=19,col='red')
  
  t4=summary(glm(Gap.Status~Gap.Length + SY + SY2 + Funding.Concurrent,data=gapdat,family='binomial'))
  #Coefficients:
  #                      Estimate Std. Error  z value Pr(>|z|)    
  #  (Intercept)        -3.794e+00  3.563e-02 -106.460  < 2e-16 ***
  #  Gap.Length         -5.375e-02  1.027e-03  -52.335  < 2e-16 ***
  #  SY                  8.048e-02  6.277e-03   12.822  < 2e-16 ***
  #  SY2                -2.310e-03  2.446e-04   -9.441  < 2e-16 ***
  #  Funding.Concurrent  3.085e-04  8.813e-05    3.501 0.000464 ***
  
  t5=summary(glm(Gap.Status~Gap.Length + SY + SY2 + Num.Concurrent,data=gapdat,family='binomial'))
  #Coefficients:
  #                  Estimate Std. Error  z value Pr(>|z|)    
  #  (Intercept)    -3.8091646  0.0359840 -105.857  < 2e-16 ***
  #  Gap.Length     -0.0536668  0.0010269  -52.263  < 2e-16 ***
  #  SY              0.0800881  0.0062759   12.761  < 2e-16 ***
  #  SY2            -0.0022890  0.0002446   -9.358  < 2e-16 ***
  #  Num.Concurrent  0.1418844  0.0296318    4.788 1.68e-06 ***
  
  
  t6=summary(glm(Gap.Status~Gap.Length + SY + SY2 + Num.Concurrent + Funding.Concurrent + Num.Concurrent*Funding.Concurrent,data=gapdat,family='binomial'))
  #Coefficients:
  #                                     Estimate Std. Error  z value Pr(>|z|)    
  #  (Intercept)                       -3.831e+00  3.638e-02 -105.288  < 2e-16 ***
  #  Gap.Length                        -5.339e-02  1.028e-03  -51.930  < 2e-16 ***
  #  SY                                 7.983e-02  6.281e-03   12.710  < 2e-16 ***
  #  SY2                               -2.276e-03  2.448e-04   -9.298  < 2e-16 ***
  #  Num.Concurrent                     4.352e-01  9.662e-02    4.504 6.67e-06 ***
  #  Funding.Concurrent                -4.618e-05  3.478e-04   -0.133    0.894    
  #  Num.Concurrent:Funding.Concurrent -5.709e-04  1.447e-04   -3.945 7.97e-05 ***
  
  
  
  t7mod = glm(Gap.Status~Gap.Length + SY + SY2 + Num.Concurrent + Funding.Concurrent + Num.Concurrent*Funding.Concurrent + idea + FY,data=gapdat,family='binomial')
  t7=summary(t7mod)
  step7 = stepAIC(t7mod,direction='both')
  t8=summary(glm(Gap.Status~Gap.Length + SY + SY2 + Num.Concurrent + Funding.Concurrent + Num.Concurrent*Funding.Concurrent + idea + FY 
                 + idea*Gap.Length + idea*SY + idea*SY2 + idea*Num.Concurrent,data=gapdat,family='binomial'))
  t9=summary(glm(Gap.Status~Gap.Length + SY + SY2 + Num.Concurrent + Funding.Concurrent + Num.Concurrent*Funding.Concurrent + idea + FY 
                 + idea*Gap.Length + idea*SY + idea*Num.Concurrent,data=gapdat,family='binomial'))
  t10=summary(glm(Gap.Status~Gap.Length + SY + SY2 + Num.Concurrent + Funding.Concurrent + Num.Concurrent*Funding.Concurrent + idea 
                 + idea*Gap.Length + idea*SY + idea*Num.Concurrent,data=gapdat,family='binomial'))
  t11=summary(glm(Gap.Status~Gap.Length + SY + SY2 + Num.Concurrent + Funding.Concurrent + Num.Concurrent*Funding.Concurrent + idea 
                  + idea*Gap.Length + idea*SY,data=gapdat,family='binomial'))
  t12=summary(glm(Gap.Status~Gap.Length + SY + SY2 + Num.Concurrent + Funding.Concurrent + Num.Concurrent*Funding.Concurrent + idea 
                  + idea*Gap.Length,data=gapdat,family='binomial'))
  t13=summary(glm(Gap.Status~Gap.Length + SY + SY2 + Num.Concurrent + Funding.Concurrent + Num.Concurrent*Funding.Concurrent + idea,data=gapdat,family='binomial'))

  full = glm(Gap.Status~Gap.Length + SY + SY2 + Num.Concurrent + Funding.Concurrent + idea +  Gap.Length*SY + Gap.Length*SY2 + Gap.Length*Num.Concurrent + Gap.Length*Funding.Concurrent 
             + Gap.Length*idea + SY*SY2 + SY*Num.Concurrent + SY*Funding.Concurrent + SY*idea + SY2*Num.Concurrent + SY2*Funding.Concurrent + SY2*idea + Num.Concurrent*Funding.Concurrent
             + Num.Concurrent*idea + Funding.Concurrent*idea,dat=gapdat,family='binomial')  
  full2 = glm(Gap.Status~(Gap.Length + SY + SY2 + Num.Concurrent + Funding.Concurrent + idea + FY + Carn)^2,dat=gapdat,family='binomial')
  stepfull = stepAIC(full,direction='both')
  stepfull2 = stepAIC(full2,direction='both')
  save(stepfull2,file='/Users/lijingning/Desktop/A/PRACTICUM/NIH/new/stepfull2.RData')
  
  finalmod = glm(Gap.Status~Gap.Length + SY + SY2 + Num.Concurrent + Funding.Concurrent + idea + Gap.Length*SY + Gap.Length*SY2 + Gap.Length*idea + SY*SY2 + 
                   SY2*Num.Concurrent + SY2*Funding.Concurrent + Num.Concurrent*Funding.Concurrent,dat=gapdat,family='binomial')
  finalcoefs = finalmod$coefficients
  syx=1:45
  syy=exp(syx*8.010838e-02)*exp(syx*syx*-4.378781e-03)*exp(syx*syx*syx*6.192228e-05)
  plot(syx,syy,pch=19,col='red')
}

if (pt5) {
  m3 = t3$coefficients[,'Estimate']
  
  m3prob = function(Gap.Length,SY,Num.Concurrent,Funding.Concurrent) {
    return(1/(1+exp(-1*(m3['(Intercept)']+m3['Gap.Length']*Gap.Length+m3['SY']*SY+m3['SY2']*SY*SY
                        +m3['Num.Concurrent']*Num.Concurrent+m3['Funding.Concurrent']*Funding.Concurrent))))
  }
  
  ## REDO THIS; takes ~ 30-40 min
  #for (i in 1:nrow(gapdat)) {
  #  gapdat$m3[i] = m3prob(gapdat$Gap.Length[i],gapdat$SY[i],gapdat$Num.Concurrent[i],gapdat$Funding.Concurrent[i])
  #  if (i %% 250==0) print(i)
  #}
  
  # if (FALSE) {
    #terminal gaps: the last entry for each project
    closedpjs = unique(gapdat$pjnum[gapdat$Gap.Status==1])
    termgaps = data.frame(pjnum=unique(gapdat$pjnum[gapdat$Gap.Status==0]),Gap.Start = as.Date(NA),Gap.Length=NA,SY=NA,Num.Concurrent=NA,
                          Funding.Concurrent=NA,m3=NA)
    #termgaps = termgaps[!termgaps$pjnum %in% closedpjs,] 
    
    for (i in 1:nrow(termgaps)) {
      termgaps$Gap.Start[i] = max(gapdat$Gap.Start[gapdat$pjnum==termgaps$pjnum[i]])
      termgaps$Gap.Length[i] = max(gapdat$Gap.Length[gapdat$pjnum==termgaps$pjnum[i] & gapdat$Gap.Start==termgaps$Gap.Start[i]])
      datrow = which(gapdat$pjnum==termgaps$pjnum[i] & gapdat$Gap.Start==termgaps$Gap.Start[i] & gapdat$Gap.Length==termgaps$Gap.Length[i])
      termgaps$SY[i] = gapdat$SY[datrow]
      termgaps$Num.Concurrent[i] = gapdat$Num.Concurrent[datrow]
      termgaps$Funding.Concurrent[i] = gapdat$Funding.Concurrent[datrow]
      termgaps$m3[i] = m3prob(termgaps$Gap.Length[i],termgaps$SY[i],termgaps$Num.Concurrent[i],termgaps$Funding.Concurrent[i])
      if (i %% 100==0) print(i)
    }
    
    
    termgaps$m3.12 = termgaps$m3.11 = termgaps$m3.10 = termgaps$m3.9 = termgaps$m3.8 = termgaps$m3.7 = 
      termgaps$m3.6 = termgaps$m3.5 = termgaps$m3.4 = termgaps$m3.3 = termgaps$m3.2 = NA
    for (i in 1:nrow(termgaps)) {
      termgaps$m3.2[i] = termgaps$m3[i]+(1-termgaps$m3[i])*m3prob(termgaps$Gap.Length[i]+1,SY=termgaps$SY[i],Num.Concurrent=termgaps$Num.Concurrent[i],Funding.Concurrent=termgaps$Funding.Concurrent[i])
      termgaps$m3.3[i] = termgaps$m3.2[i]+(1-termgaps$m3.2[i])*m3prob(termgaps$Gap.Length[i]+2,SY=termgaps$SY[i],Num.Concurrent=termgaps$Num.Concurrent[i],Funding.Concurrent=termgaps$Funding.Concurrent[i])
      termgaps$m3.4[i] = termgaps$m3.3[i]+(1-termgaps$m3.3[i])*m3prob(termgaps$Gap.Length[i]+3,SY=termgaps$SY[i],Num.Concurrent=termgaps$Num.Concurrent[i],Funding.Concurrent=termgaps$Funding.Concurrent[i])
      termgaps$m3.5[i] = termgaps$m3.4[i]+(1-termgaps$m3.4[i])*m3prob(termgaps$Gap.Length[i]+4,SY=termgaps$SY[i],Num.Concurrent=termgaps$Num.Concurrent[i],Funding.Concurrent=termgaps$Funding.Concurrent[i])
      termgaps$m3.6[i] = termgaps$m3.5[i]+(1-termgaps$m3.5[i])*m3prob(termgaps$Gap.Length[i]+5,SY=termgaps$SY[i],Num.Concurrent=termgaps$Num.Concurrent[i],Funding.Concurrent=termgaps$Funding.Concurrent[i])
      termgaps$m3.7[i] = termgaps$m3.6[i]+(1-termgaps$m3.6[i])*m3prob(termgaps$Gap.Length[i]+5,SY=termgaps$SY[i],Num.Concurrent=termgaps$Num.Concurrent[i],Funding.Concurrent=termgaps$Funding.Concurrent[i])
      termgaps$m3.8[i] = termgaps$m3.7[i]+(1-termgaps$m3.7[i])*m3prob(termgaps$Gap.Length[i]+5,SY=termgaps$SY[i],Num.Concurrent=termgaps$Num.Concurrent[i],Funding.Concurrent=termgaps$Funding.Concurrent[i])
      termgaps$m3.9[i] = termgaps$m3.8[i]+(1-termggapaps$m3.8[i])*m3prob(termgaps$Gap.Length[i]+5,SY=termgaps$SY[i],Num.Concurrent=termgaps$Num.Concurrent[i],Funding.Concurrent=termgaps$Funding.Concurrent[i])
      termgaps$m3.10[i] = termgaps$m3.9[i]+(1-termgaps$m3.9[i])*m3prob(termgaps$Gap.Length[i]+5,SY=termgaps$SY[i],Num.Concurrent=termgaps$Num.Concurrent[i],Funding.Concurrent=termgaps$Funding.Concurrent[i])
      termgaps$m3.11[i] = termgaps$m3.10[i]+(1-termgaps$m3.10[i])*m3prob(termgaps$Gap.Length[i]+5,SY=termgaps$SY[i],Num.Concurrent=termgaps$Num.Concurrent[i],Funding.Concurrent=termgaps$Funding.Concurrent[i])
      termgaps$m3.12[i] = termgaps$m3.11[i]+(1-termgaps$m3.11[i])*m3prob(termgaps$Gap.Length[i]+5,SY=termgaps$SY[i],Num.Concurrent=termgaps$Num.Concurrent[i],Funding.Concurrent=termgaps$Funding.Concurrent[i])
    }
    
    save(termgaps,file='/Users/lijingning/Desktop/A/PRACTICUM/NIH/new/terminalgaps.RData')
  # } else {
  #   load('/Users/lijingning/Desktop/A/PRACTICUM/NIH/new/terminalgaps.RData')
  # }
}
  
z=termgaps[order(termgaps$m3,decreasing=T),]
z[1:10,]
  
#write.csv(theItemOfInterestFromYourDRadataFileAsThereMayBeMoreThanOneThingInthere,file="yourCSV.csv")
