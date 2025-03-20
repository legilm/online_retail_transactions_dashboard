library(rio)
library(dplyr)

retail_data09 <- import("data/online_retail_2009-2010.csv")
retail_data10 <- import("data/online_retail_2010-2011.csv")

retail_data <- rbind(retail_data09, retail_data10)
  
# Remove rows with missing values
retail_data <- retail_data |> 
  filter(!is.na(`Customer ID`)) |>   # Remove missing customers
  mutate(Quantity = as.integer(Quantity)) |> 
  mutate(Price = as.numeric(gsub(",", ".", Price))) |> 
  mutate(Revenue = Quantity * Price) |> 
  mutate(InvoiceDate = as.Date(InvoiceDate, "%d/%m/%Y %H:%M")) |> 
  rename(Customer.ID = `Customer ID`)

rio::export(retail_data, "data/online_retail_cleaned.csv")