library(shiny)
library(bs4Dash)
library(shinyWidgets)
library(plotly)
library(highcharter)
library(leaflet)
library(DT)
library(reactable)
library(rio)
library(dplyr)

retail_data <- rio::import("data/online_retail_cleaned.csv")

ui <- dashboardPage(
  dashboardHeader(title = "Online Retail Transactions"),
  dashboardSidebar(
  ),
  dashboardBody(
    fluidRow(
      box(
        width = 12,
        title = "Revenue over time",
        status = "primary",
        solidHeader = TRUE,
        collapsible = TRUE,
        plotlyOutput("plotly")
      ),
      box(
        width = 12,
        title = "Top Products",
        status = "primary",
        solidHeader = TRUE,
        collapsible = TRUE,
        highchartOutput("highcharter")
      ),
      box(
        width = 12,
        title = "Sales by Country",
        status = "primary",
        solidHeader = TRUE,
        collapsible = TRUE,
        leafletOutput("leaflet")
      )
    ),
    fluidRow(
      box(
        width = 12,
        title = "Interactive Transaction Table",
        status = "primary",
        solidHeader = TRUE,
        collapsible = TRUE,
        DT::dataTableOutput("dt")
      )
    ),
    fluidRow(
      box(
        width = 12,
        title = "Customer Insights",
        status = "primary",
        solidHeader = TRUE,
        collapsible = TRUE,
        reactableOutput("reactible")
      )
    )
  )
) 

  server <- function(input, output, session) {
    
    # Plotly - Sales Trends
    output$plotly <- renderPlotly({
      data <- retail_data 
        arrange(InvoiceDate) |> 
        group_by(InvoiceDate) |> 
        summarize(Revenue = sum(Revenue))
        plot_ly(data,
          x = ~InvoiceDate,
          y = ~Revenue,
          type = "scatter",
          mode = "lines",
          hovertemplate = "Date: %{x}<br>Revenue: %{y:.2f}"
        ) |> 
        layout(
          title = "Revenue over Time",
          xaxis_title = "Invoice Date",
          yaxis_title = "Revenue",
          xaxis_type = "date",
          hovermode = "x unified",
          xaxis_rangeslider_visible = FALSE
        )
    })
    
    # Highcharter - Top Products
    output$highcharter <- renderHighchart({
      retail_data|> 
        group_by(Description)|> 
        summarize(Quantity = sum(Quantity))|> 
        arrange(desc(Quantity))|> 
        head(10)|> 
        hchart("bar", hcaes(x = Description, y = Quantity))
    })
    
    # Leaflet - Sales by Country
    output$leaflet <- renderLeaflet({
      country_coords <- data.frame(
        Country = c("United Kingdom", "France", "United States", "Netherlands", "Germany", "Sweden", "Italy", "Japan"),
        Latitude = c(51.5074, 48.8566, 40.7128, 52.3676, 48.1351, 55.3781, 45.4642, 35.6762),
        Longitude = c(-0.1278, 2.3522, -74.0060, 4.8945, 11.5821, 13.4383, 9.1900, 139.6503)
      )
      
      retail_data |> 
        group_by(Country) |> 
        summarize(Revenue = sum(Revenue)) |> 
        left_join(country_coords, by = "Country") |> 
        leaflet() |> 
        addTiles() |> 
        addCircleMarkers(lng = ~Longitude, lat = ~Latitude, radius = ~sqrt(Revenue/5000), popup = ~Country)
    })
    
    # DT - Interactive Transaction Table
    output$dt <- DT::renderDataTable({
      retail_data
    }, options = list(pageLength = 10, searching = TRUE, ordering = TRUE))
    
    # Reactable - Customer Insights
    output$reactible <- renderReactable({
      retail_data|>  
        group_by(Customer.ID)|> 
        summarize(TotalRevenue = sum(Revenue))|> 
        arrange(desc(TotalRevenue))|> 
        head(10)|> 
        reactable(
          columns = list(
            Customer.ID = colDef(name = "Customer ID"),
            TotalRevenue = colDef(
              name = "Total Revenue",
              style = function(value) {
                if (value > 1000) {
                  list(fontWeight = "bold", color = "green")
                } else {
                  list(color = "red")
                }
              }
            )
          )
        )
    })
  }

  

shinyApp(ui, server)