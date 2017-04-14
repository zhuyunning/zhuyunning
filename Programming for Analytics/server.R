#Group 5
#Tingting Ju, Xinyi Wang, Daniel Chen, Abhinav Bhanu Pratap Singh Chandel, Yunning Zhu

library(shiny)
library(ggplot2)
function(input, output, session) {
  
thedata <-reactive({
  infile <- input$file
  if(is.null(infile))
    return(NULL)
  d <- read.csv(infile$datapath,header=TRUE)
  d
})       #This function is to read the csv file into a R dataframe
  
 observe({
   data <- thedata()
   updateSelectInput(session,'xcol','X Variable',names(data))
   updateSelectInput(session,'ycol','Y Variable',names(data))
 })    #Observe is to update the options of the coloumn selectors everytime a new csv file is updated
 
 selectedData <-reactive({
   dat <- thedata()
   dat[,c(input$xcol,input$ycol)]
 })   #Forming a new dataset of the selected columns in the Input Box
 
 output$MyPlot <- renderPlot({
   thickness <- input$slider1
   dat <-selectedData()
   x <- input$xcol
   y <- input$ycol
   g <- ggplot(data = dat, mapping = aes(dat[x], dat[y]))
   p <- g + geom_point(color = "blue", size = 4)
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
   return(q)  #Plotting the graph if and when the user selects the fit models
   })
 
}
