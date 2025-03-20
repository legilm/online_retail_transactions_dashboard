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
library(waiter)

retail_data <- rio::import("data/online_retail_cleaned.csv")

ui <- dashboardPage(
  autoWaiter(),
  dashboardHeader(title = "Online Retail Transactions"),
  dashboardSidebar(
    sidebarMenu(
      selectInput("country_filter", "Select Country", 
                  choices = c("All", unique(retail_data$Country)), 
                  selected = "All"),
      actionButton("filter_button", "Filter")
    )
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
    
    observeEvent(input$show, {
      w$show()
      Sys.sleep(3)
      w$hide()
    })
    
    # Filter data based on selected country
    filtered_data <- eventReactive(input$filter_button, {
      if (input$country_filter == "All") {
        return(retail_data)
      } else {
        return(retail_data[retail_data$Country == input$country_filter, ])
      }
    })
    
    # Plotly - Sales Trends
    output$plotly <- renderPlotly({
      data <- filtered_data() %>%
        arrange(InvoiceDate) %>%
        group_by(InvoiceDate) %>%
        summarize(Revenue = sum(Revenue))
      plot_ly(
        data,
        x = ~InvoiceDate,
        y = ~Revenue,
        type = "scatter",
        mode = "lines",
        hovertemplate = "Date: %{x}<br>Revenue: %{y:.2f}"
      ) %>%
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
      filtered_data() %>%
        group_by(Description) %>%
        summarize(Quantity = sum(Quantity)) %>%
        arrange(desc(Quantity)) %>%
        head(10) %>%
        hchart("bar", hcaes(x = Description, y = Quantity))
    })
    
    # Leaflet - Sales by Country
    output$leaflet <- renderLeaflet({
      country_coords <- data.frame(
        Country = c("United Kingdom", "France", "USA", "Belgium", "Australia", "EIRE", "Germany", "Portugal", "Japan", "Denmark", "Netherlands", "Poland", "Spain", "Channel Islands", "Italy", "Cyprus", "Greece", "Norway", "Austria", "Sweden", "United Arab Emirates", "Finland", "Switzerland", "Unspecified", "Nigeria", "Malta", "RSA", "Singapore", "Bahrain", "Thailand", "Israel", "Lithuania", "West Indies", "Korea", "Brazil", "Canada", "Iceland", "Lebanon", "Saudi Arabia", "Czech Republic", "European Community"),
        Latitude = c(51.5074, 48.8566, 37.0902, 50.8503, -25.2744, 53.4129, 51.1657, 39.3999, 35.6762, 55.6761, 52.3676, 52.2297, 40.4637, 49.3723, 41.8719, 35.1264, 39.0742, 60.4720, 47.5162, 59.3293, 23.4241, 61.9241, 46.2044, NA, 9.0820, 35.8800, -25.7479, 1.3521, 25.9304, 13.7563, 32.7918, 54.6872, 55.1660, 37.5665, 3.2028, 37.0902, 49.2827, 33.8547, 50.0755, 49.8175, 48.2082, 47.1625),
        Longitude = c(-0.1278, 2.3522, -95.7129, 4.4699, 133.7751, -7.6921, 10.4515, -8.2245, 139.6503, 12.5679, 4.8945, 19.1451, -3.7038, -2.5854, 12.5113, 33.4299, 21.8243, 10.4479, 14.5501, 18.0645, 53.8478, 25.7489, 8.2275, NA, 8.6753, 14.4775, 28.2293, 103.8516, 50.6333, 100.5018, 35.2137, 6.2600, 127.7669, -43.5504, -79.4543, -19.0000, 35.8833, 45.0792, 24.4539, 4.4350, 15.2578, 14.4378, 14.4378)
      )
      
      filtered_data() |> 
        group_by(Country) |> 
        summarize(Revenue = sum(Revenue)) |> 
        left_join(country_coords, by = "Country") |> 
        leaflet() |> 
        addTiles() |> 
        addCircleMarkers(lng = ~Longitude, lat = ~Latitude, radius = ~sqrt(Revenue/5000), popup = ~Country)
    })
    
    # DT - Interactive Transaction Table
    output$dt <- DT::renderDataTable({
      filtered_data()
    }, options = list(pageLength = 10, searching = TRUE, ordering = TRUE))
    
    # Reactable - Customer Insights
    output$reactible <- renderReactable({
      filtered_data() |>  
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