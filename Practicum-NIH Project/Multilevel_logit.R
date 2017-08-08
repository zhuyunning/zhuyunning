setwd("/Users/zhuyu/Desktop/NIH")
database = read.csv('gapdat.csv',head=T,stringsAsFactors = FALSE)
library(lme4)

fit0<-glmer(Gap.Status~(1|pjnum),dat=database,family=binomial("logit"))
summary(fit0)

fit<-glmer(Gap.Status~Gap.Length+(1|pjnum),dat=database,family=binomial("logit"))
summary(fit)

fit2<-glmer(Gap.Status~Gap.Length+SY+(1|pjnum),dat=database,family=binomial("logit"))
summary(fit2)

fit3<-glmer(Gap.Status~Gap.Length*SY+(1|pjnum),dat=database,family=binomial("logit"))
summary(fit3)

u0 <- ranef(fit0, postVar = TRUE)
u0se <- sqrt(attr(u0[[1]], "postVar")[1, , ])
commid <- as.numeric(rownames(u0[[1]]))
u0tab <- cbind("commid" = commid, "u0" = u0[[1]], "u0se" = u0se)
colnames(u0tab)[2] <- "u0"
u0tab <- u0tab[order(u0tab$u0), ]
u0tab <- cbind(u0tab, c(1:dim(u0tab)[1]))
u0tab <- u0tab[order(u0tab$commid), ]
colnames(u0tab)[4] <- "u0rank"
plot(u0tab$u0rank, u0tab$u0, type = "n", xlab = "u_rank", ylab = "conditional
       + modes of r.e. for comm_id:_cons", ylim = c(-4, 4))
segments(u0tab$u0rank, u0tab$u0 - 1.96*u0tab$u0se, u0tab$u0rank, u0tab$u0 + 1.96*u0tab$u0se)
points(u0tab$u0rank, u0tab$u0, col = "blue")
abline(h = 0, col = "red")
