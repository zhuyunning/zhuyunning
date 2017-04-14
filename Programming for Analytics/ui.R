#Group 5
#Tingting Ju, Xinyi Wang, Daniel Chen, Abhinav Bhanu Pratap Singh Chandel, Yunning Zhu

fluidPage(
  
  
  fileInput('file', 'Choose CSV file',
            accept=c('text/csv', 'text/comma-separated-values,text/plain')),
     #Uploading a CSV file with accept conditions defined
  hr(),
  
  headerPanel('Plot'),
  sidebarPanel(
    selectInput('xcol', 'X Variable', ""),  #Input bar with empty selections which will be updated post the csv file is uploaded
    selectInput('ycol', 'Y Variable', ""),  #Input bar with empty selections which will be updated post the csv file is uploaded
   
    checkboxInput("fit", "Linear", FALSE),    #For Linear fit
    checkboxInput("fit2", "Quadratic", FALSE),  #For Quaudratic Fit
    
    sliderInput("slider1", label = h3("line thickness"), min = 1, 
                max = 5, value = 3)    #SLider for thickness
    ),
  mainPanel(
    plotOutput("MyPlot")
  )
)

