## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = identical(tolower(Sys.getenv("NOT_CRAN")), "true"),
  out.width = "100%"
)


## ----dict-table, echo = FALSE, message = FALSE--------------------------------
# # ---- packages -----------------------------------------------------------
# library(knitr)
# library(kableExtra)
# 
# # ---- data ---------------------------------------------------------------
# dic_2000 <- c(
#   "Basico", "Domicilio", "Pessoa", "Responsavel", "Instrucao", "Morador"
#     )
# 
# dic_2010 <- c(
#   "Basico", "Domicilio", "Pessoa", "Responsavel", "Entorno",  "ResponsavelRenda", "DomicilioRenda", "PessoaRenda"
#   )
# 
# dic_2022 <- c(
#   "Basico", "Domicilio", "Pessoas", " ", "Entorno", "ResponsavelRenda",
#   "Indigenas", "Quilombolas", "Obitos", "Preliminares"
#   )
# 
# # pad the shorter vector with blanks so the columns have equal length
# max_len <- max(length(dic_2000), length(dic_2010), length(dic_2022))
# dic_2000 <- c(dic_2000, rep("", max_len - length(dic_2000)))
# dic_2010 <- c(dic_2010, rep("", max_len - length(dic_2010)))
# dic_2022 <- c(dic_2022, rep("", max_len - length(dic_2022)))
# 
# tab <- data.frame(`2000` = dic_2000,
#                   `2010` = dic_2010,
#                   `2022` = dic_2022,
#                   check.names = FALSE)
# 
# # ---- display ------------------------------------------------------------
# kable(tab, escape = FALSE, align = "l") |>
#   kable_styling(full_width = FALSE, position = "left")

## ----warning = FALSE----------------------------------------------------------
# library(censobr)
# 
# dom <- read_tracts(
#   year = 2022,
#   dataset = 'Domicilio',
#   showProgress = FALSE
#   )
# 
# names(dom)[c(30:33,119:121, 526:528)]

## ----warning=FALSE, message=FALSE---------------------------------------------
# data_dictionary(
#   year = 2022,
#   dataset = 'tracts'
#   )
# 

## ----warning=FALSE, message=FALSE---------------------------------------------
# library(arrow)
# library(dplyr)
# library(geobr)
# library(ggplot2)

## ----warning = FALSE----------------------------------------------------------
# muni_bh <- geobr::read_municipality(
#   code_muni = 'MG',
#   year = 2010,
#   showProgress = FALSE
#   ) |>
#   filter(name_muni == "Belo Horizonte")
# 
# tracts_sf <- geobr::read_census_tract(
#   code_tract = "MG",
#   simplified = FALSE,
#   year = 2010,
#   showProgress = FALSE
#   )
# 
# tracts_sf <- filter(tracts_sf, name_muni == "Belo Horizonte")
# 
# ggplot() +
#   geom_sf(data = tracts_sf, fill = 'gray90', color = 'gray60') +
#   theme_void()

## ----warning = FALSE----------------------------------------------------------
# # download data
# tract_entorno <- censobr::read_tracts(
#   year = 2022,
#   dataset = "Entorno",
#   showProgress = FALSE
#   )
# 
# # filter observations and calculate indicator
# df_trees <- tract_entorno |>
#   filter(code_tract %in% tracts_sf$code_tract) |>
#   group_by(code_tract) |>
#   mutate(total_households = domicilios_V05000,
#          trees = domicilios_V05031 + domicilios_V05032+ domicilios_V05033,
#          trees_prop = trees / total_households) |>
#   select(code_tract, total_households, trees, trees_prop) |>
#   collect()
# 
# head(df_trees)

## ----warning = FALSE----------------------------------------------------------
# bh_tracts <- left_join(tracts_sf, df_trees, by = 'code_tract')
# 
# ggplot() +
#   geom_sf(data = bh_tracts, aes(fill = trees_prop), color=NA) +
#   geom_sf(data = muni_bh, color='gray10', fill=NA) +
#   labs(subtitle = 'Share of households with trees in their surroundings.\nBelo Horizonte, 2010') +
#   scale_fill_distiller(palette = "Greens", direction = 1,
#                        name='Share of\nhouseholds',
#                        na.value = "gray90",
#                        labels = scales::percent) +
#   theme_void()
# 

## ----warning = FALSE----------------------------------------------------------
# # download data
# tract_basico <- censobr::read_tracts(
#   year = 2010,
#   dataset = "Basico",
#   showProgress = FALSE
#   )
# 
# tract_income <- censobr::read_tracts(
#   year = 2010,
#   dataset = "DomicilioRenda",
#   showProgress = FALSE
#   )
# 
# # select columns
# tract_basico <- tract_basico |> select('code_tract','V002')
# tract_income <- tract_income |> select('code_tract','V003')
# 
# # merge
# tracts_df <- left_join(tract_basico, tract_income) |> collect()
# 
# # calculate income per capita
# tracts_df <- tracts_df |> mutate(income_pc = V003 / V002)
# head(tracts_df)

## ----warning = FALSE----------------------------------------------------------
# bh_tracts <- left_join(tracts_sf, tracts_df, by = 'code_tract')
# 
# ggplot() +
#   geom_sf(data = bh_tracts, aes(fill = income_pc), color=NA) +
#   geom_sf(data = muni_bh, color='gray10', fill=NA) +
#   labs(subtitle = 'Avgerage income per capita.\nBelo Horizonte, 2010') +
#   scale_fill_viridis_c(name = "Income per\ncapita (R$)",
#                        labels = scales::number_format(),
#                        option = 'cividis',
#                        breaks = c(0, 500, 1e3, 5e3, 1e4, 2e4),
#                        trans = "pseudo_log", na.value = "gray90") +
#   theme_void()
# 

