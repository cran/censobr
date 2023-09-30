## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = identical(tolower(Sys.getenv("NOT_CRAN")), "true"),
  out.width = "100%"
)

use_suggested_pkgs <- c((requireNamespace("scales")), 
                        (requireNamespace("ggplot2")), 
                        (requireNamespace("geobr")))

use_suggested_pkgs <- all(use_suggested_pkgs)

## ----eval = TRUE, warning = FALSE---------------------------------------------
library(censobr)

dom <- read_tracts(year = 2010, 
                   dataset = 'Domicilio', 
                   showProgress = FALSE)

names(dom)[c(1:20,301:320)]

## ----eval=FALSE, warning=FALSE, message=FALSE---------------------------------
#  data_dictionary(year = 2010, dataset = 'tracts')
#  

## ----eval = use_suggested_pkgs, warning=FALSE, message=FALSE------------------
library(arrow)
library(dplyr)
library(geobr)
library(ggplot2)

## ----eval = use_suggested_pkgs, warning = FALSE-------------------------------
muni_bh <- geobr::read_municipality(code_muni = 'MG', 
                                    year = 2010, 
                                    showProgress = FALSE) |>
           filter(name_muni == "Belo Horizonte")

tracts_sf <- geobr::read_census_tract(code_tract = "MG",
                                      simplified = FALSE,
                                      year = 2010,
                                      showProgress = FALSE)

tracts_sf <- filter(tracts_sf, name_muni == "Belo Horizonte")

ggplot() + 
  geom_sf(data=tracts_sf, fill = 'gray90', color='gray60') + 
  theme_void()

## ----eval = use_suggested_pkgs, warning = FALSE-------------------------------
# download data
tract_basico <- read_tracts(year = 2010,
                            dataset = "Basico", 
                            showProgress = FALSE)

tract_income <- read_tracts(year = 2010,
                            dataset = "DomicilioRenda", 
                            showProgress = FALSE)

# select columns
tract_basico <- tract_basico |> select('code_tract','V002')
tract_income <- tract_income |> select('code_tract','V003')

# merge
tracts_df <- left_join(tract_basico, tract_income) |> collect()

# calculate income per capita
tracts_df <- tracts_df |> mutate(income_pc = V003 / V002)
head(tracts_df)

## ----eval = use_suggested_pkgs, warning = FALSE-------------------------------
bh_tracts <- left_join(tracts_sf, tracts_df, by = 'code_tract')

ggplot() +
  geom_sf(data = bh_tracts, aes(fill = income_pc), color=NA) +
  geom_sf(data = muni_bh, color='gray10', fill=NA) +
  labs(subtitle = 'Avgerage income per capita.\nBelo Horizonte, 2010') +
  scale_fill_viridis_c(name = "Income per\ncapita (R$)",
                       labels = scales::number_format(),
                       option = 'cividis',
                       breaks = c(0, 500, 1e3, 5e3, 1e4, 2e4),
                       trans = "pseudo_log", na.value = "gray90") +
  theme_void()


## ----eval = use_suggested_pkgs, warning = FALSE-------------------------------
# download data
tract_entorno <- read_tracts(year = 2010,
                             dataset = "Entorno", 
                             showProgress = FALSE)

# filter observations and calculate indicator
df_trees <- tract_entorno |>
                  filter(code_tract %in% tracts_sf$code_tract) |>
                  mutate(total_households = entorno01_V001,
                         trees = entorno01_V044 + entorno01_V046 + entorno01_V048,
                         trees_prop = trees / total_households) |>
                  select(code_tract, total_households, trees, trees_prop) |>
                  collect()

head(df_trees)

## ----eval = use_suggested_pkgs, warning = FALSE-------------------------------
bh_tracts <- left_join(tracts_sf, df_trees, by = 'code_tract')

ggplot() +
  geom_sf(data = bh_tracts, aes(fill = trees_prop), color=NA) +
  geom_sf(data = muni_bh, color='gray10', fill=NA) +
  labs(subtitle = 'Share of households with trees in their surroundings.\nBelo Horizonte, 2010') +
  scale_fill_distiller(palette = "Greens", direction = 1, 
                       name='Share of\nhouseholds', 
                       na.value = "gray90",
                       labels = scales::percent) +
  theme_void()


