## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = identical(tolower(Sys.getenv("NOT_CRAN")), "true"),
  out.width = "100%"
)

## ----eval = FALSE-------------------------------------------------------------
#  # Microdata variables
#  data_dictionary(year = 2010,
#                  dataset = 'microdata')
#  
#  # Census tract-level variables
#  data_dictionary(year = 2010,
#                  dataset = 'tracts')

## ----eval = FALSE-------------------------------------------------------------
#  # short questionnaire
#  questionnaire(year = 2010,
#                type = 'short')
#  
#  # long questionnaire
#  questionnaire(year = 2010,
#                type = 'long')

## ----eval = FALSE-------------------------------------------------------------
#  # 2010
#  interview_manual(year = 2010)
#  
#  # 1970
#  interview_manual(year = 1970)

