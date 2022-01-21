test_that("ROCR_wrap", {

  set.seed(10)

  rt <- ROCR_wrap(rnorm(1000), rnorm(1000, mean = 1), return_curve = TRUE)

  testthat::expect_equal(rt$auc %>% unique %>% signif(digits = 4),
  75.68)

  rt[, dist := sqrt(((1 - tpr)^2) + ((fpr)^2))]

  rt <- rt[dist == min(dist)]

  testthat::expect_equal(rt$thresh %>% signif(digits = 4),
  0.5957)

  rtdigest <- digest::digest(rt, algo = "md5")

  testthat::expect_equal(rtdigest,
    "fe620e1c8cdb9b9852d5bd66eec0dd70")

})
