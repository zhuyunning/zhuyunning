# Read in the Consolidated Input File
movies<-read.csv("~/Prog_Final/Deliverables/Consolidated.csv")

# Use Min Max Normalization Methodology to Transform Input into 0-to-1 Range
normalize <- function(x){
  return((x-min(x,na.rm=TRUE))/(max(x,na.rm=TRUE)-min(x,na.rm=TRUE)))
}

movies_norm<-lapply(movies[2:8],normalize)
head(movies_norm)

# Output Normalized Data to CSV
write.csv(movies_norm, file = "Consolidated_Norm.csv")

# 1st MR:  WorldWide Revenue vs Twitter Sentiment & IMDB & RT & MetaScore
# Result: Global P-Value = 0.03; R^2 = 0.11; Adj R^2 = 0.07
# Result: Individual P-Values:  Sentiment Scores: 0.55
# Result: Individual P-Values:  IMDB: 0.31
# Result: Individual P-Values:  RT:  0.78
# Result: Individual P-Values:  MetaScore:  0.18
# Result: Beta Coefficients:  Sentiment Scores: -0.07
# Result: Beta Coefficients:  IMDB: 0.13
# Result: Beta Coefficients:  RT:  0.03
# Result: Beta Coefficients:  MetaScore:  0.10
mr_AllRatings<-lm(Worldwide_Rev~Twitter_Sentiment+IMDB+RT+MetaScore,data=movies_norm)
summary(mr_AllRatings)

# 2nd MR:  WorldWide Revenue vs Twitter Sentiment & IMDB & RT & MetaScore & Budget
# Result: Global P-Value = 0.00; R^2 = 0.60; Adj R^2 = 0.58
# Result: Individual P-Values:  Sentiment Scores: 0.74
# Result: Individual P-Values:  IMDB: 0.60
# Result: Individual P-Values:  RT:  0.04*
# Result: Individual P-Values:  MetaScore:  0.42
# Result: Individual P-Values:  Budget:  0.00*
# Result: Beta Coefficients:  Sentiment Scores: -0.03
# Result: Beta Coefficients:  IMDB: -0.04
# Result: Beta Coefficients:  RT:  0.14
# Result: Beta Coefficients:  MetaScore:  -0.04
# Result: Beta Coefficients:  Budget:  0.62
mr_All<-lm(Worldwide_Rev~Twitter_Sentiment+IMDB+RT+MetaScore+Budget,data=movies_norm)
summary(mr_All)

# CPDs:
# Result: Sentiment Scores: 0.00
# Result: IMDB: 0.00
# Result: RT:  0.02
# Result: MetaScore:  0.00
# Result: Budget:  0.54
library('heplots')
etasq(mr_All,anova=TRUE,partial=FALSE)

# 3rd MR:  WorldWide Revenue vs RT + Budget
# Result: Global P-Value = 0.00; R^2 = 0.60; Adj R^2 = 0.59
# Result: Individual P-Values:  RT: 0.02
# Result: Individual P-Values:  Budget: 0.00
mr_RT_Budget<-lm(Worldwide_Rev~RT+Budget,data=movies_norm)
summary(mr_RT_Budget)

# SLR:  WorldWide Revenue vs Rotten Tomato
# Result: Global P-Value = 0.00; R^2 = 0.07; Adj R^2 = 0.06
# Result: Coefficient = 0.16
slr_RT<-lm(Worldwide_Rev~RT,data=movies_norm)
summary(slr_RT)

# SLR:  WorldWide Revenue vs Budget
# Result: Global P-Value = 0.00; R^2 = 0.58; Adj R^2 = 0.57
slr_budget<-lm(Worldwide_Rev~Budget,data=movies_norm)
summary(slr_budget)

# SLR:  WorldWide Revenue vs Twitter Sentiment
# Result: Global P-Value = 0.50; R^2 = 0.00; Adj R^2 = -0.00
slr_twitter<-lm(Worldwide_Rev~Twitter_Sentiment,data=movies_norm)
summary(slr_twitter)

# SLR:  WorldWide Revenue vs IMDB
# Result: Global P-Value = 0.00; R^2 = 0.08; Adj R^2 = 0.07
slr_IMDB<-lm(Worldwide_Rev~IMDB,data=movies_norm)
summary(slr_IMDB)

# SLR:  WorldWide Revenue vs MetaScore
# Result: Global P-Value = 0.00; R^2 = 0.07; Adj R^2 = 0.06
slr_Meta<-lm(Worldwide_Rev~MetaScore,data=movies_norm)
summary(slr_Meta)

# MR:  WorldWide Revenue vs Twitter + IMDB
mr_Twitter_IMDB<-lm(Worldwide_Rev~Twitter_Sentiment+IMDB,data=movies_norm)
summary(mr_Twitter_IMDB)

# MR:  WorldWide Revenue vs Twitter + RT
mr_Twitter_RT<-lm(Worldwide_Rev~Twitter_Sentiment+RT,data=movies_norm)
summary(mr_Twitter_RT)

# MR:  WorldWide Revenue vs Twitter + MetaScore
mr_Twitter_Meta<-lm(Worldwide_Rev~Twitter_Sentiment+MetaScore,data=movies_norm)
summary(mr_Twitter_Meta)

# MR:  WorldWide Revenue vs IMDB + RT
mr_IMDB_RT<-lm(Worldwide_Rev~IMDB+RT,data=movies_norm)
summary(mr_IMDB_RT)

# MR:  WorldWide Revenue vs IMDB + MetaScore
mr_IMDB_Meta<-lm(Worldwide_Rev~IMDB+MetaScore,data=movies_norm)
summary(mr_IMDB_Meta)

# MR:  WorldWide Revenue vs RT + MetaScore
mr_RT_Meta<-lm(Worldwide_Rev~RT+MetaScore,data=movies_norm)
summary(mr_RT_Meta)

# Display Correlation Matrix
#library(agricolae)
#analysis<-correlation(movies_norm[2:8],method="pearson")

# MR:  DOMESTIC Revenue vs Twitter Sentiment & IMDB
#mr_twitter_IMDB<-lm(Domestic_Rev~Twitter_Sentiment+IMDB,data=movies_norm)
#summary(mr_twitter_IMDB)

# SLR:  Domestic Revenue vs IMDB
#slr_IMDB<-lm(Domestic_Rev~IMDB,data=movies_norm)
#summary(slr_IMDB)

# Experiment:  Plot
#Worldwide_Rev=movies_norm[,2]
#IMDB=movies_norm[,5]
#plot(IMDB, Worldwide_Rev, pch=16, xlab = "IMDB Score", ylab = "Worldwide Revenue", cex.lab = 1.2, col = "blue")

# Experiment:  Quadratic Fit
#IMDBSquare<-IMDB^2
#quadratic_IMDB<-lm(Worldwide_Rev~IMDB+IMDBSquare)
#summary(quadratic_IMDB)
