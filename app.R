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
library(shinyFeedback)
library(shinycssloaders)
library(usethis)
library(shinymanager)
library(httr)
library(jsonlite)

retail_data <- rio::import("data/online_retail_cleaned.csv")

api_key <- Sys.getenv("api_key")

ui <- dashboardPage(
  dashboardHeader(title = "Online Retail Transactions"),
  dashboardSidebar(
    width = 300,
    waiterPreloader(),
    sidebarMenu(
      collapsed = TRUE,
      dateRangeInput("dates", 
                     label = h3("Date range"), 
                     min = min(retail_data$InvoiceDate),
                     max = max(retail_data$InvoiceDate),
      hr(),
      verbatimTextOutput("date_range_selected")
      ),
      selectInput("country_filter", 
                  "Select Country",
                  choices = c("All", unique(retail_data$Country)),
                  multiple = FALSE,
                  selected = "All",
      ),
      loadingButton(
        "filter_button",
        "Filter",
        class = "btn btn-primary",
        style = "width: 150px;",
        loadingLabel = "Loading...",
        loadingSpinner = "spinner",
      ),
      p("Choose a country to download the sales file."),
      selectInput("country_to_download", "Country to Download", 
                  c("United Kingdom", "France", "USA", "Belgium", "Australia", "EIRE", "Germany", "Portugal", "Japan", "Denmark", "Netherlands", "Poland", "Spain", "Channel Islands", "Italy", "Cyprus", "Greece", "Norway", "Austria", "Sweden", "United Arab Emirates", "Finland", "Switzerland", "Unspecified", "Nigeria", "Malta", "RSA", "Singapore", "Bahrain", "Thailand", "Israel", "Lithuania", "West Indies", "Korea", "Brazil", "Canada", "Iceland", "Lebanon", "Saudi Arabia", "Czech Republic", "European Community")
                  ),
      downloadButton("download_btn",
                     "Download")),
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
  
  weather <- eventReactive(input$filter_button, {
    if (input$country_filter == "All") {
      return(retail_data)
    } else {
      return(retail_data |> 
               filter(Country == input$country_filter))
    }
  })
  


    # https://api.openweathermap.org/data/3.0/onecall?lat={lat}&lon={lon}&exclude={current}&appid={626eba3ab8885e11d774a6c0c7109729}
  
  # Filter data based on selected country
  filtered_data <- eventReactive(input$filter_button, {
    if (input$country_filter == "All") {
      return(retail_data)
    } else {
          return(retail_data |> 
                 filter(Country == input$country_filter))
      }
  })
  
  # You can access the values of the widget (as a vector of Dates)
  # with input$dates, e.g.
  output$date_range_selected <- renderPrint({ input$dates })

  observeEvent(input$filter_button, {

  #  data <- filtered_data()

    resetLoadingButton("filter_button")
  })

  output$download_btn <- downloadHandler(
    filename = function() {
      paste0(input$country_to_download, " - ", Sys.Date(), " - Sales data", ".csv")  # File name based on selection
    },
    content = function(file) {
      
      # Filter data based on user selection
      data_to_download <- retail_data |> 
        filter(Country == input$country_to_download)
      
      # Save the filtered data in the output file
      rio::export(data_to_download, file, "csv")
    }
  )

  # Plotly - Sales Trends
  output$plotly <- renderPlotly({
    data <- retail_data |>
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
        title = list(text = "Revenue over Time"),
        xaxis = list(title = "Invoice Date", type = "date", rangeslider = list(visible = FALSE)),
        yaxis = list(title = "Revenue"),
        hovermode = "x unified"
      )
  })

  # Highcharter - Top Products
  output$highcharter <- renderHighchart({
    filtered_data() |>
      group_by(Description) |>
      summarize(Quantity = sum(Quantity)) |>
      arrange(desc(Quantity)) |>
      head(10) |>
      hchart("bar", hcaes(x = Description, y = Quantity))
  })

  # Leaflet - Sales by Country
  output$leaflet <- renderLeaflet({
    country_coords <- data.frame(
      Country = c("United Kingdom", "France", "USA", "Belgium", "Australia", "EIRE", "Germany", "Portugal", "Japan", "Denmark", "Netherlands", "Poland", "Spain", "Channel Islands", "Italy", "Cyprus", "Greece", "Norway", "Austria", "Sweden", "United Arab Emirates", "Finland", "Switzerland", "Unspecified", "Nigeria", "Malta", "RSA", "Singapore", "Bahrain", "Thailand", "Israel", "Lithuania", "West Indies", "Korea", "Brazil", "Canada", "Iceland", "Lebanon", "Saudi Arabia", "Czech Republic", "European Community"),
      Latitude = c(51.5074, 48.8566, 37.0902, 50.8503, -25.2744, 53.4129, 51.1657, 39.3999, 35.6762, 55.6761, 52.3676, 52.2297, 40.4637, 49.3723, 41.8719, 35.1264, 39.0742, 60.4720, 47.5162, 59.3293, 23.4241, 61.9241, 46.2044, 0, 9.0820, 35.8800, -25.7479, 1.3521, 25.9304, 13.7563, 32.7918, 54.6872, 55.1660, 37.5665, 3.2028, 37.0902, 49.2827, 33.8547, 50.0755, 49.8175, 48.2082),
      Longitude = c(-0.1278, 2.3522, -95.7129, 4.4699, 133.7751, -7.6921, 10.4515, -8.2245, 139.6503, 12.5679, 4.8945, 19.1451, -3.7038, -2.5854, 12.5113, 33.4299, 21.8243, 10.4479, 14.5501, 18.0645, 53.8478, 25.7489, 8.2275, 0, 8.6753, 14.4775, 28.2293, 103.8516, 50.6333, 100.5018, 35.2137, 6.2600, 127.7669, -43.5504, -79.4543, -19.0000, 35.8833, 45.0792, 24.4539, 4.4350, 15.2578)
    )
    filtered_data() |>
      group_by(Country) |>
      summarize(Revenue = sum(Revenue)) |>
      left_join(country_coords, by = "Country") |>
      leaflet() |>
      addTiles() |>
      addCircleMarkers(lng = ~Longitude, lat = ~Latitude, radius = ~ sqrt(Revenue / 5000), popup = ~Country)
  })

  # DT - Interactive Transaction Table
  output$dt <- DT::renderDataTable(
    {
      filtered_data()
    },
    options = list(pageLength = 10, searching = TRUE, ordering = TRUE)
  )

  # Reactable - Customer Insights
  output$reactible <- renderReactable({
    filtered_data() |>
      group_by(Customer.ID) |>
      summarize(TotalRevenue = sum(Revenue)) |>
      arrange(desc(TotalRevenue)) |>
      head(10) |>
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
