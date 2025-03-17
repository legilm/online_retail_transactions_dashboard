library(rio)
retail_data <- import("data/online_retail_2009-2010.csv")
retail_data <- import("data/online_retail_2010-2011.csv")
rio::import(retail_data, "data/online_retail_cleaned.csv")