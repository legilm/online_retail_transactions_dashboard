library(shiny)
library(bslib)
library(plotly)
library(highcharter)
library(leaflet)
library(DT)
library(reactable)
library(rio)

source("R/data_cleaning.R")


ui <- fluidPage(
  titlePanel("Online Retail Transactions"),
  sidebarLayout(
    sidebarPanel(
      selectInput("my_theme", "Choose a theme:", 
                  choices = c("default", "cosmo", "cerulean")),
      actionButton("update", "Update")
    ),
    mainPanel(
      # card(
      #   title = "Plot - Sales trend",
      #   width = 12,
      #   uiOutput("plotly"),
        card(
          title = "Top products",
          width = 12,
          uiOutput("highcharter")
        ),
        card(
          title = "Map",
          width = 6,
          uiOutput("leaflet")
        ),
        card(
          title = "Transaction table",
          width = 12,
          uiOutput("dt")
        ),
        card(
          title = "Customer insights",
          width = 12,
          uiOutput("reactable")
      )
    )
  )
)


server <- function(input, output) {
  

  # 
  # output$plotly <- renderUI({
  # 
  #   # Create the line chart
  #   plot_ly(retail_data, x = ~InvoiceDate, y = ~Revenue, type = 'scatter', mode = 'lines+markers',
  #           text = ~paste("Date:", InvoiceDate, "<br>Total Revenue:", Revenue),
  #           hoverinfo = 'text')
  #   plotlyOutput("plot")
  # })
  # 
  output$highcharter <- renderHighchart({
    hchart(
      retail_data, 
      "column", 
      hcaes(x = StockCode, y = Quantity, group = Country)) |> 
      hc_plotOptions(column = list(stacking = "normal"))  |> 
      hc_title(text = "Top products highcharter") |>
      hc_xAxis(title = list(text = "Stock Code")) |>
      hc_yAxis(title = list(text = "Quantity"))
  })
}

shinyApp(ui, server)