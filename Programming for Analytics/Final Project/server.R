#Group 5
#Tingting Ju, Xinyi Wang, Daniel Chen, Abhinav Bhanu Pratap Singh Chandel, Yunning Zhu

library(shiny)
library(ggplot2)
library(DT)
function(input, output, session) {
  
thedata <-reactive({
  infile <- input$file
  if(is.null(infile))
    return(NULL)
  d <- read.csv(infile$datapath,header=TRUE)
})       #This function is to read the csv file into a R dataframe

 output$table <- DT::renderDataTable(DT::datatable({thedata()}, options = list(pageLength = 25)))
 
 observe({
   data <- thedata()
   updateSelectInput(session,'xcol','X Variable',names(data))
   updateSelectInput(session,'ycol','Y Variable',names(data))
 })    #Observe is to update the options of the coloumn selectors everytime a new csv file is updated
 
 selectedData <-reactive({
   dat <- thedata()
   dat[,c(input$xcol,input$ycol)]
 })   #Forming a new dataset of the selected columns in the Input Box
 
 output$MyPlot1 <- renderPlot({
   thickness <- input$slider1
   dat <-selectedData()
   x <- input$xcol
   y <- input$ycol
   g <- ggplot(data = dat, mapping = aes(dat[x], dat[y]))
   p <- g + geom_point(alpha=0.3, stroke=0, color = "blue", size = 4) + labs(title="Simple Linear Regression Plot for Top 100 Movies")
   plot(p)    #Plotting a basic graph when there is no fit model selected by the user
   if(input$fit)   #If the linear checkbox is ticked
   {
     q <- p + geom_smooth(method="lm", formula = y~x, color = "pink", size = thickness,se=FALSE)
   }
   if(input$fit2) #If the Quadratic Checkbox is ticked
   {
     q <- p + geom_smooth(method="lm", formula = y ~ poly(x,2), color = "orange", size = thickness,se=FALSE)
   }
   if(input$fit && input$fit2) #If bothe quadratic and linear is ticked
   {
     q <- p + geom_smooth(method="lm", formula = y~x, color = "pink", size = thickness,se=FALSE) + geom_smooth(method="lm", formula = y ~ poly(x,2), color = "orange", size = thickness,se=FALSE)
   }
   if(input$fit3)
   {
     q<-p+stat_density2d(aes(fill=..level..),geom="polygon",color="#e74c3c",size=0.2)+scale_fill_gradient(low="#eeeeee",high="#e74c3c")
   }
   if(input$fit && input$fit2 && input$fit3)
   {
     q <- p + geom_smooth(method="lm", formula = y~x, color = "pink", size = thickness,se=FALSE) + geom_smooth(method="lm", formula = y ~ poly(x,2), color = "orange", size = thickness,se=FALSE) + 
       stat_density2d(aes(fill=..level..),geom="polygon",color="#e74c3c",size=0.2)+scale_fill_gradient(low="#eeeeee",high="#e74c3c")
   }  
   return(q)  #Plotting the graph if and when the user selects the fit models
   })
 output$MyPlot2 <- renderPlot({
   thickness <- input$slider1
   data<-read.csv("~/top100.csv",header=TRUE)
   g <- ggplot(data) + geom_jitter(aes(Twitter_Sentiment,Worldwide_Rev,color="Twitter_Sentiment")) + geom_smooth(aes(Twitter_Sentiment,Worldwide_Rev),method=lm,se=FALSE,color="blue") + 
     geom_jitter(aes(IMDB,Worldwide_Rev,color="IMDB")) + geom_smooth(aes(IMDB,Worldwide_Rev),method=lm,se=FALSE,color="red") + 
     geom_jitter(aes(RT,Worldwide_Rev,color="RT")) + geom_smooth(aes(RT,Worldwide_Rev),method=lm,se=FALSE,color="black") +
     geom_jitter(aes(MetaScore,Worldwide_Rev,color="MetaScore")) + geom_smooth(aes(MetaScore,Worldwide_Rev),method=lm,se=FALSE,color="pink") + 
     geom_jitter(aes(Budget,Worldwide_Rev,color="Budget")) + geom_smooth(aes(Budget,Worldwide_Rev),method=lm,se=FALSE,color="Orange") +
     scale_colour_manual("", breaks = c("Twitter_Sentiment", "IMDB", "RT","MetaScore","Budget"),
                         values = c("Twitter_Sentiment"="blue", "IMDB"="red", "RT"="black","MetaScore"="pink","Budget"="Orange")) +
     theme(legend.text=element_text(size=13)) + 
     labs(x = "Reviews", y = "Worldwide revenue", title="Multiple Regression Plot for Top 100 Movies")
   return(g) 
 })
}
