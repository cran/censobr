## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = identical(tolower(Sys.getenv("NOT_CRAN")), "true"),
  out.width = "100%"
)


## ----eval = FALSE-------------------------------------------------------------
# read_population(
#   year,             # year of reference
#   columns,          # select columns to read
#   add_labels,       # add labels to categorical variables
#   merge_households, # bring in household-level variables
#   as_data_frame,    # return an Arrow DataSet or a data.frame
#   showProgress,     # show download progress bar
#   cache,            # cache data for faster access later
#   verbose           # whether to print informative messages
#   )

## ----warning=FALSE, message=FALSE---------------------------------------------
library(censobr)
library(arrow)
library(dplyr)
library(ggplot2)

## ----warning = FALSE, message=FALSE-------------------------------------------
pop <- read_population(
  year = 2022,
  columns = c('abbrev_state', 'P0210', 'P0110', 'P0770'),
  add_labels = 'pt',
  showProgress = FALSE
  )

class(pop)

## ----warning = FALSE, message=FALSE-------------------------------------------
dplyr::glimpse(pop)

## ----warning = FALSE, message=FALSE-------------------------------------------
df <- pop |>
      filter(abbrev_state == "RJ") |>                                                    # (a)
      compute() |>
      group_by(P0210) |>                                                                 # (b)
      summarize(higher_edu = sum(P0110[which(P0770=="Superior completo")]) / sum(P0110), # (c)
                pop = sum(P0110) ) |>
      collect()

head(df)

## ----message=FALSE------------------------------------------------------------
df <- subset(df, P0210 != 'Ignorado')

ggplot() +
  geom_col(data = df, aes(x=P0210, y=higher_edu), fill = '#5c997e') +
  scale_y_continuous(name = 'Proportion with higher education',
                     labels = scales::percent) +
  labs(x = 'Cor/raça') +
  theme_classic()
  

## ----message=FALSE------------------------------------------------------------
hs <- read_households(
  year = 2010, 
  showProgress = FALSE
  )


## ----warning = FALSE, message=FALSE-------------------------------------------
esg <- hs |> 
        compute() |>
        group_by(code_muni) |>                                             # (a)
        summarize(rede = sum(V0010[which(V0207==1)]),                      # (b)
                  total = sum(V0010)) |>                                   # (b)
        mutate(cobertura = rede / total) |>                                # (c)
        collect()                                                          # (d)

head(esg)

## ----warning = FALSE, message=FALSE-------------------------------------------
library(geobr)

muni_sf <- geobr::read_municipality(
  year = 2010,
  showProgress = FALSE
  )

head(muni_sf)

## ----warning = FALSE, message=FALSE-------------------------------------------
esg_sf <- left_join(muni_sf, esg, by = 'code_muni')

ggplot() +
  geom_sf(data = esg_sf, aes(fill = cobertura), color=NA) +
  labs(title = "Share of households connected to a sewage network") +
  scale_fill_distiller(palette = "Greens", direction = 1, 
                       name='Share of\nhouseholds', 
                       labels = scales::percent) +
  theme_void()


## ----warning = FALSE, message=FALSE-------------------------------------------
metro_muni <- geobr::read_metro_area(
  year = 2010, 
  showProgress = FALSE) |>
  subset(name_metro == "Rm São Paulo")


## ----warning = FALSE, message=FALSE-------------------------------------------
wt_areas <- geobr::read_weighting_area(
  code_weighting = "SP", 
  showProgress = FALSE,
  year = 2010
  )

wt_areas <- subset(wt_areas, code_muni %in% metro_muni$code_muni)
head(wt_areas)

## ----warning = FALSE, message=FALSE-------------------------------------------
rent <- hs |>
        filter(code_muni %in% metro_muni$code_muni) |>                     # (a)
        compute() |>
        group_by(code_weighting) |>                                        # (b)
        summarize(avgrent=weighted.mean(x=V2011, w=V0010, na.rm=TRUE)) |>  # (c)
        collect()                                                          # (d)

head(rent)

## ----warning = FALSE, message=FALSE-------------------------------------------
rent_sf <- left_join(wt_areas, rent, by = 'code_weighting')

ggplot() +
  geom_sf(data = rent_sf, aes(fill = avgrent), color=NA) +
  geom_sf(data = metro_muni, color='gray', fill=NA) +
  scale_fill_distiller(palette = "Greens", direction = 1, 
                       name='Avgerage\nRent in R$') +
  theme_void()


## ----warning=FALSE, eval=FALSE------------------------------------------------
# censobr::censobr_cache(
#   list_files = TRUE,
#   print_tree = TRUE
#   )

## ----warning=FALSE, eval=FALSE------------------------------------------------
# censobr::censobr_cache(delete_file = "2010_emigration")
# 

## ----warning=FALSE, eval=FALSE------------------------------------------------
# censobr::censobr_cache(delete_file = "all")
# 

## ----warning=FALSE, include=FALSE---------------------------------------------
# set_censobr_cache_dir() records the path in a config file that persists across
# sessions, so building this vignette must not leave the reader's cache pointing
# at a temporary directory. Remember the current setting and put it back at the end.
# These four chunks inherit the NOT_CRAN guard set at the top of this file -- do
# not add eval=TRUE to any of them, or they run during R CMD check on CRAN.
original_cache_dir <- censobr::get_censobr_cache_dir()

## ----warning=FALSE------------------------------------------------------------
tempf <- fs::path_temp(pattern = "my_temp_dir")

censobr::set_censobr_cache_dir(path = tempf)


## ----warning=FALSE, message=FALSE---------------------------------------------
# download file to our new cache dir
df_emi <- censobr::read_emigration(year = 2010)

# check files in current cache dir
censobr::censobr_cache(
  list_files = TRUE, 
  print_tree = TRUE
  )

## ----warning=FALSE, include=FALSE---------------------------------------------
# restore the cache directory the reader had before this vignette ran
censobr::set_censobr_cache_dir(path = original_cache_dir, verbose = FALSE)

