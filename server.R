library(shiny)
library(plotly)
library(dplyr)
library(RColorBrewer)
library(grDevices)
library(zoo)
library(tidyr)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
## Preprocess data
    x <- read.csv("./24100047.csv")
    names(x)[1]<-"Date"
    x$Date <- as.Date(paste0(x$Date, "-01"))
    x$Date <- as.yearqtr(x$Date, format = "%Y-%m-%d")

## Printing selected region of Canada
    output$Region <- renderText({
        reg <- input$InputReg
        reg
    })
    
## Calculating total expenditures in this region
    TotalExp <- reactive({
        reg <- input$InputReg
        qrt <- input$Qtr
        x<- filter(x,x$GEO == reg, x$Date >= qrt[1] & x$Date <= qrt[2], 
                   x$Area.of.residence == "Total, area of residence")
        expences <- data.frame(summarise(group_by(x, Type.of.expenditures), Total = sum(VALUE)*1000))
        expences <- filter(expences, expences$Type.of.expenditures=="Total expenditures")
        expences$Total <- prettyNum(expences$Total, big.mark = ",")
        paste(expences$Total, "CAD")
        
    })
    output$TotalExp <- renderText({
        TotalExp()
        
    })

## plotlyOutput("bar")
    output$bar <- renderPlotly({
        reg <- input$InputReg
        qrt <- input$Qtr
        x<- filter(x,x$GEO==reg, x$Date>= qrt[1] & x$Date<= qrt[2])
        x<- filter(x, x$Type.of.expenditures!="Total expenditures")
        expences <- data.frame(summarise(group_by(x, Area.of.residence), 
                                         Total = sum(VALUE)*1000))
        
        expencesHist <- filter(expences, 
                               expences$Area.of.residence!="Total, area of residence",
                               expences$Area.of.residence!="Overseas residents")
        
        bar <- plot_ly(x = ~expencesHist$Area.of.residence, y=~expencesHist$Total, type = "bar")
        bar <- bar %>% layout(title = "Total amount of spending by visitor's country of residence",
                              xaxis = list(title = "",tickangle = -45),
                              yaxis = list(title = ""))
    })    

## Printing selected countries of visitors residence
    output$Resident <- renderText({
        Resident <- input$InputFrom
        Resident
    })
    
## Calculating total expenditures for visitors from selected countries
    TotalRez <- reactive({
        reg <- input$InputReg
        qrt <- input$Qtr
        Resident <- input$InputFrom
        x<- filter(x,x$GEO==reg, x$Date>= qrt[1] & x$Date<= qrt[2], x$Area.of.residence %in% Resident)
        expences <- data.frame(summarise(group_by(x, Type.of.expenditures), Total = sum(VALUE)*1000))
        expences <- filter(expences, expences$Type.of.expenditures=="Total expenditures")
        expences$Total <- prettyNum(expences$Total, big.mark = ",")
        paste(expences$Total, "CAD")
        
    })
    output$Total <- renderText({
        TotalRez()
        
    })
    
## plotlyOutput("pie")    
    output$pie <- renderPlotly({
        reg <- input$InputReg
        qrt <- as.yearqtr(input$Qtr)
        Resident <- input$InputFrom
        x<- filter(x,x$GEO==reg, x$Date>= qrt[1] & x$Date<= qrt[2], x$Area.of.residence %in% Resident)
        expences <- data.frame(summarise(group_by(x, Type.of.expenditures), Total = sum(VALUE)/1000))
        expencesPie <- filter(expences, expences$Type.of.expenditures!="Total expenditures")
        
        # draw the diagram 
        cols <- brewer.pal(length(expencesPie$Type.of.expenditures),"Set2")
        colors <- colorRampPalette(cols)
        pie <- plot_ly(expencesPie, labels = ~Type.of.expenditures, values = ~Total, type = 'pie',
                       textposition= "auto",
                       insidetextorientation= "horizontal",
                       textinfo = "label+percent",
                       insidetextfont = list(color = '#FFFFFF'),
                       hoverinfo = "text",
                       text = ~paste(Type.of.expenditures, ":", prettyNum(Total, big.mark = ","), "M"),
                       marker = list(colors = colors(length(expencesPie$Type.of.expenditures)),
                                     line = list(color = '#FFFFFF', width = 1)),
                       #The 'pull' attribute can also be used to create space between the sectors
                       showlegend = TRUE)
        pie <- pie %>% layout(title = "Percent of spending by type for tourists from selected countries",
                              
#                              legend = list(x=-0, y=-400),
                              xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                              yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
    })
})
