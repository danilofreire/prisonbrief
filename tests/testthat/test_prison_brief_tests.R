test_that("correct class", {
        xx <- prisonbrief::wpb_list()
        expect_is(xx, c("tbl_df", "tbl", "data.frame"))
})

# check right country is returned
test_that("correct country", {
        esp <- prisonbrief::wpb_series(country = "Spain")
        xy <- unique(esp$Country)
        expect_output(cat(xy), "spain")
})

# expect error
test_that("error returned from imaginary country", {
        expect_error(prisonbrief::wpb_series(country = "Weirdo Land"))
})
