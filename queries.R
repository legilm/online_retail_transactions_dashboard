library(DBI)
library(RSQLite)

#Sum the revenue column

conn <- DBI::dbConnect(RSQLite::SQLite(), "retail_db.sqlite")

#checking if it's well loaded
dbListTables(conn)

dbListFields(conn, "transactions")

sum <- dbGetQuery(conn, "SELECT SUM(Revenue) FROM transactions")

paste0("the total revenue was: $",sum)

best_selling <- dbGetQuery(conn, "SELECT Description, COUNT(*) AS total_sales
                           FROM transactions
                           ORDER BY total_sales DESC
                           LIMIT 1")

paste0("The best selling product is: ", best_selling$Description, ", with ", best_selling$total_sales, " Sales")

top_5_countries <-  dbGetQuery(conn,"SELECT Country, SUM(Quantity) AS total_sales
                               FROM transactions
                               GROUP BY Country
                               ORDER BY total_sales DESC
                               LIMIT 5")

paste0("The 5 top sales countries are: ", top_5_countries$Country)

top_5_customers <-  dbGetQuery(conn,"SELECT `Customer.ID`, COUNT(*) AS total_orders
                               FROM transactions
                               GROUP BY `Customer.ID`
                               ORDER BY total_orders DESC
                               LIMIT 5")

paste0("The 5 top sales countries are: ", top_5_customers$Customer.ID)


dbDisconnect(con)


