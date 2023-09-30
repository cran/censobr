## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = identical(tolower(Sys.getenv("NOT_CRAN")), "true"),
  out.width = "100%"
)

## ----eval = FALSE-------------------------------------------------------------
#  # Microdata variables
#  data_dictionary(year = 2010, table = 'microdata')
#  
#  # Census tract-level variables
#  data_dictionary(year = 2010, table = 'tracts')

## ----eval = FALSE-------------------------------------------------------------
#  # 2010
#  questionnaire(year = 2010)
#  
#  # 1970
#  questionnaire(year = 1970)

## ----eval = FALSE-------------------------------------------------------------
#  # 2010
#  interview_manual(year = 2010)
#  
#  # 1970
#  interview_manual(year = 1970)

