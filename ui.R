library(shiny)
library(dplyr)
library(tidyr)
library(plotly)
library(shinyWidgets)
library(zoo)

shinyUI(fluidPage(
    
    # Application title
    titlePanel("Tourists Spendings"),
    
    sidebarLayout(
        sidebarPanel(
            sliderTextInput("Qtr","Time frame:" , 
                            choices = list("2018 Q1", "2018 Q2", "2018 Q3", "2018 Q4",
                                           "2019 Q1", "2019 Q2", "2019 Q3", "2019 Q4"),
                            selected = c("2019 Q1", "2019 Q3")),
            selectInput("InputReg", "Choose part of Canada", 
                        choices = list("Canada","Newfoundland and Labrador",
                                       "Prince Edward Island","Nova Scotia",
                                       "New Brunswick","Quebec",
                                       "Quebec city, Quebec","Montreal, Quebec",
                                       "Rest of Quebec","Ontario",
                                       "Greater Toronto area, Ontario","Ottawa and Countryside, Ontario",
                                       "Niagara Falls and Wine Country, Ontario","Rest of Ontario",
                                       "Manitoba","Saskatchewan",
                                       "Alberta","Canadian Rockies, Alberta",
                                       "Calgary and area, Alberta","Rest of Alberta",
                                       "British Columbia","Vancouver, Coast and Mountains, British Columbia",
                                       "Kootenay Rockies, British Columbia","Rest of British Columbia",
                                       "Yukon, Northwest Territories and Nunavut","Yukon",
                                       "Northwest Territories","Nunavut")),
            
            checkboxGroupInput("InputFrom", "Visited from", 
                               choices = list("All countries of Residence"="Total, area of residence",
                                              "United States"="United States residents", "United Kingdom",
                                              "China","France",
                                              "Mexico","India","Germany",
                                              "Australia","South Korea","Japan",
                                              "Other countries"),
                               selected = "Total, area of residence"),
            
            submitButton("Submit"),
            width = 3
        ),
        
        mainPanel(
            h4 ("Millions of tourists visit Canada every year."), 
            br(),
            h4 ("Using data from Statistics Canada web-page, 
                you can see how much they spent in different parts of Canada in just 4 simple steps:"),
            br(),
            h4("1. Select time frame, you are interested in:"),
            h4("2. Select particular part of Canada;"),
            h4("3. Select countries of residence of visitors;"),
            h4("4. Click Submit button and observe results."),
            br(),
            h4("Total amount of expenditures in selected area during selected time period for all visitors:"),
            textOutput("TotalExp"),
            br(),
            plotlyOutput("bar", width = "80%", height = "280px"),
            h4("Amount spent by visitors from selected countries:"), 
            textOutput("Resident"),
            textOutput("Total"),
            br(),
            plotlyOutput("pie"),
            width = 9
        )
    )
))
