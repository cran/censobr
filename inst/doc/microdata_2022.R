## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = identical(tolower(Sys.getenv("NOT_CRAN")), "true"),
  out.width = "100%"
)

## ----eval = FALSE-------------------------------------------------------------
# library(censobr)
# 
# # path to the zip file with the raw data
# fake_zip <- system.file(
#   "extdata/microdata_2022_controlado_fake.zip",
#   package = "censobr"
#   )
# 
# censobr::import_microdata22(zip_path = fake_zip)
# 

## ----eval = FALSE-------------------------------------------------------------
# pop <- censobr::read_population(year = 2022)
# 
# fam <- censobr::read_families(year = 2022)
# 
# hou <- censobr::read_households(year = 2022)
# 
# mor <- censobr::read_mortality(year = 2022)
# 

