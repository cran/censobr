context("censobr_cache")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()
testthat::skip_if_not_installed("arrow")


# Reading the data -----------------------

test_that("censobr_cache", {

  # simply list files
  testthat::expect_message( censobr_cache() )

  ## delete existing

  # download
  censobr::read_emigration(year = 2010, showProgress = FALSE, cache = TRUE)

  # cache dir
  pkgv <- paste0('censobr/data_release_', censobr_env$data_release)
  cache_dir <- tools::R_user_dir(pkgv, which = 'cache')

  # list cached files
  files <- list.files(cache_dir, full.names = TRUE)
  fname <- paste0('2010_emigration_',censobr_env$data_release, '.parquet')
  fname_full <- files[grepl(fname, files)]

  testthat::expect_true( file.exists(fname_full) )
  testthat::expect_message( censobr_cache(delete_file = fname) )
  testthat::expect_false( file.exists(fname_full) )

  ## delete ALL
  censobr::read_emigration(year = 2010, showProgress = FALSE, cache = TRUE)
  files <- list.files(cache_dir, full.names = TRUE)
  fname <- paste0('2010_emigration_',censobr_env$data_release, '.parquet')
  fname_full <- files[grepl(fname, files)]
  testthat::expect_true( file.exists(fname_full) )
  testthat::expect_message( censobr_cache(delete_file = 'all') )
  censobr_cache(delete_file = 'all')
#  testthat::expect_true( length(list.files(cache_dir)) == 0 )

  # if file does not exist, simply print message
  testthat::expect_message( censobr_cache(delete_file ='aaa') )

 })


# ERRORS and messages  -----------------------
test_that("censobr_cache", {

  # Wrong date 4 digits
  testthat::expect_error(censobr_cache(list_files= 999))
  testthat::expect_error(censobr_cache(delete_file = 999))
  })


# clean cache
censobr_cache(delete_file = 'all')
