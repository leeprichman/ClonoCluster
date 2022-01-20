test_that("tdt", {

  dt <- data.table::data.table(V1 = LETTERS, V2 = 1:26)

  tdtm <- dt[, 2] %>% as.matrix

  tdtm <- t(tdtm)

  colnames(tdtm) <- dt[, 1] %>% unlist

  tdtm %<>% as.data.table(keep.rownames = TRUE)

  tdt <- tdt(dt)

  testthat::expect_equal(tdtm, tdt)

})

test_that("dt2m", {

  dt <- data.table::data.table(V1 = LETTERS, V2 = 1:26, V3 = 26:1)

  m1 <- dt[, 2:3] %>% as.matrix

  rownames(m1) <- dt[,.SD, .SDcols = "V1"] %>% unlist

  m2 <- dt2m(dt)

  testthat::expect_equal(m1, m2)

})

test_that("ttheme", {

  testthat::expect_equal(class(ttheme), c("theme", "gg"))

})

test_that("colors", {

  testthat::expect_equal(c25, c("dodgerblue2", "#E31A1C", "green4", "#6A3D9A", "#FF7F00", "gold1",
  "skyblue2", "#FB9A99", "palegreen2", "#CAB2D6", "#FDBF6F", "khaki2",
  "maroon", "orchid1", "deeppink1", "blue1", "steelblue4", "darkturquoise",
  "green1", "yellow4", "yellow3", "darkorange4", "brown", "gray70",
  "black"))

  testthat::expect_equal(cw_colors, c("#c51162", "#aa00ff", "#0091ea", "#64dd17", "#ffab00", "#00b8d4",
  "#d50000", "#6200ea", "#2962ff", "#a7ffeb", "#00c853", "#ff6d00",
  "#aeea00", "#dd2c00"))

})
