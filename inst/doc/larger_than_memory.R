## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = identical(tolower(Sys.getenv("NOT_CRAN")), "true"),
  out.width = "100%"
)


## ----warning = FALSE, message=FALSE-------------------------------------------
library(censobr)

# read 2010 mortality data
df <- censobr::read_mortality(
  year = 2010,
  add_labels = 'pt',
  showProgress = FALSE
  )

## ----warning = FALSE, message=FALSE-------------------------------------------
library(dplyr)

# Filter deaths of men in the state of Rio de Janeiro
rio <- df |>
      filter(V0704 == 'Masculino' & abbrev_state == 'RJ')

head(rio) |> 
  collect()


## ----warning = FALSE, message=FALSE-------------------------------------------
library(duckdb)
library(dplyr)
library(arrow)

# Filter deaths of men in the state of Rio de Janeiro
rio1 <- df |>
        arrow::to_duckdb() |>
        filter(sql("V0704 LIKE '%Masculino%' AND abbrev_state = 'RJ'"))

head(rio1) |> 
  collect()


## ----warning = FALSE----------------------------------------------------------
library(duckdb)
library(DBI)

# create databse connection
con <- duckdb::dbConnect(duckdb::duckdb())

# register the data in the data base
duckdb::duckdb_register_arrow(con, 'mortality_2010_tbl', df)

# Filter deaths of men in the state of Rio de Janeiro
rio2 <- DBI::dbGetQuery(con, "SELECT * FROM 'mortality_2010_tbl' WHERE V0704 LIKE '%Masculino%' AND abbrev_state = 'RJ'")

head(rio2)


