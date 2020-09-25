# Details for connecting to the server:
dbms = Sys.getenv("DBMS")
user <- if (Sys.getenv("DB_USER") == "") NULL else Sys.getenv("DB_USER")
password <- if (Sys.getenv("DB_PASSWORD") == "") NULL else Sys.getenv("DB_PASSWORD")
server = Sys.getenv("DB_SERVER")
port = Sys.getenv("DB_PORT")
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = password,
                                                                port = port)

# Run the export
Achilles::exportResultsToCSV(connectionDetails,
                             resultsDatabaseSchema = "results_schema",
                             analysisIds = c(1,2,3),
                             minCellCount = 10,
                             exportFolder = file.path(getwd(), "export"))