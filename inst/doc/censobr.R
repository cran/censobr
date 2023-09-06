## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = identical(tolower(Sys.getenv("NOT_CRAN")), "true"),
  out.width = "100%"
)

## ---- eval = FALSE------------------------------------------------------------
#  dfh <- read_households(
#            year,          # year of reference
#            columns,       # select columns to read
#            add_labels,    # add labels to categorical variables
#            as_data_frame, # return an Arrow DataSet or a data.frame
#            showProgress,  # show download progress bar
#            cache          # cache data for faster access later
#           )

## ---- eval=TRUE, warning=FALSE------------------------------------------------
library(censobr)

# list cached files
censobr_cache(list_files = TRUE)

## ---- eval=TRUE, warning=FALSE------------------------------------------------
# delete particular file
censobr_cache(delete_file = "2010_emigration")


## ---- eval=TRUE, warning=FALSE------------------------------------------------
library(censobr)
library(arrow)
library(dplyr)
library(geobr)
library(ggplot2)

## ---- eval = TRUE, warning = FALSE--------------------------------------------
pop <- read_population(year = 2010,
                       columns = c('abbrev_state', 'V0606', 'V0010', 'V6400'),
                       add_labels = 'pt',
                       showProgress = FALSE)


## ---- eval = TRUE, warning = FALSE--------------------------------------------
df <- pop |>
      filter(abbrev_state == "RJ") |>                                                    # (a)
      collect() |>
      group_by(V0606) |>                                                                 # (b)
      summarize(higher_edu = sum(V0010[which(V6400=="Superior completo")]) / sum(V0010), # (c)
                pop = sum(V0010) ) |>
      collect()

head(df)

## ---- eval = TRUE-------------------------------------------------------------
df <- subset(df, V0606 != 'Ignorado')

ggplot() +
  geom_col(data = df, aes(x=V0606, y=higher_edu), fill = '#5c997e') +
  scale_y_continuous(name = 'Proportion with higher education',
                     labels = scales::percent) +
  labs(x = 'Cor/raça') +
  theme_classic()
  

## ---- eval = TRUE-------------------------------------------------------------
hs <- read_households(year = 2010, 
                      showProgress = FALSE)


## ---- eval = TRUE, warning = FALSE--------------------------------------------
rent <- hs |> 
        collect() |>
        group_by(code_state) |>                                            # (a)
        summarize(avgrent=weighted.mean(x=V2011, w=V0010, na.rm=TRUE)) |>  # (b)
        collect()                                                          # (c)

head(rent)

## ---- eval = TRUE, warning = FALSE--------------------------------------------
uf <- geobr::read_state(year = 2010, 
                        showProgress = FALSE)
head(uf)

## ---- eval = TRUE, warning = FALSE--------------------------------------------
uf$code_state <- as.character(uf$code_state)
rent_sf <- left_join(uf, rent, by = 'code_state')

ggplot() +
  geom_sf(data = rent_sf, aes(fill = avgrent), color=NA) +
  scale_fill_distiller(palette = "Greens", direction = 1, 
                       name='Avgerage\nRent in R$') +
  theme_void()


