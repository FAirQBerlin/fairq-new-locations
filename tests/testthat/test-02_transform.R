test_that("Dropping of Gridpoints works!", {
  test_pollutant <- list(selected_vars = c("test_var"),
                         weights = c(0.42))
  
  data <- list(
    grid = data.frame(
      x = c(1, 1, 2, 2),
      y = c(1, 2, 1, 2),
      test_var = c(1, 1, 4, 4)
    ),
    stations = data.frame(
      x = c(1, 2),
      y = c(1, 2),
      test_var = c(1, 4)
    )
  ) %>%
    add_var_info(test_pollutant)
  
  expect_equal(
    drop_gridpoints_eq_to_station(data),
    list(
      grid = data.frame(
        x = c(1, 2),
        y = c(1, 2),
        test_var = c(1, 4)
      ),
      stations = data.frame(
        x = c(1, 2),
        y = c(1, 2),
        test_var = c(1, 4)
      )
      
    ) %>% add_var_info(test_pollutant)
  )
})
