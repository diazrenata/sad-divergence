#' Percentile score
#'
#' Returns percent of values in `comparison` less than *or equal to* `x`
#'
#' @param x focal value
#' @param comparison vector of comparison values
#'
#' @return percentile score of x
#' @export
#'
percentile <- function(x, comparison) {
  
  return(mean(comparison <= x))
  
}

#' Get summary stat values from feasible set
#'
#' @param s richness
#' @param n abundance
#' @param ndraws number of draws from the  feasible set
#' @param sumstats defaults to "hill1", others not implemented
#'
#' @return vector of `hill1` values for SADs drawn from feasible set for `s` and `n`
#' @export
#'
#' @importFrom feasiblesads sample_fs
#' @importFrom dplyr mutate row_number group_by summarize
#' @importFrom tidyr pivot_longer
#' @importFrom hillR hill_taxa
fs_vals <- function(s, n, ndraws = 1000, sumstats = "hill1") {
  
  fs <- feasiblesads::sample_fs(s = s, n = n, nsamples = ndraws, storeyn = FALSE)
  
  fs_df <- fs %>%
    t() %>%
    as.data.frame() %>%
    dplyr::mutate(rank = dplyr::row_number()) %>%
    tidyr::pivot_longer(-rank, names_to ="draw", values_to = "abund")
  
  fs_summary_df <- fs_df %>%
    dplyr::group_by(draw) %>%
    dplyr::summarize(hill1 = hillR::hill_taxa(abund, q = 1)) %>%
    dplyr::ungroup()
  
  return(fs_summary_df[[sumstats]])
  
}

#' Get summary stat values from METE
#'
#' @param s richness
#' @param n abundance
#' @param ndraws number of draws from the  feasible set
#' @param sumstats defaults to "hill1", others not implemented
#'
#' @return vector of `hill1` values for SADs drawn from the METE SAD for `s` and `n`
#' @export
#' @importFrom meteR meteESF sad
#' @importFrom dplyr mutate row_number group_by summarize
#' @importFrom tidyr pivot_longer
#' @importFrom hillR hill_taxa
mete_vals <- function(s, n, ndraws = 1000, sumstats = "hill1") {
  
  mete_esf <- meteR::meteESF(S0 = s, N0 = n)
  
  mete_sad <- meteR::sad(mete_esf)
  
  mete_sad_draws <- replicate(n = ndraws, sort(mete_sad$r(s)), simplify = T) %>%
    as.data.frame() %>%
    dplyr::mutate(rank = dplyr::row_number()) %>%
    tidyr::pivot_longer(-rank, names_to = "draw", values_to = "abund")
  
  mete_summary_df <- mete_sad_draws %>%
    dplyr::group_by(draw) %>%
    dplyr::summarize(hill1 = hillR::hill_taxa(abund, q = 1)) %>%
    dplyr::ungroup()
  
  return(mete_summary_df[[sumstats]])
  
}



#' Get real summary statistic value from an SAD
#'
#' @param sad a vector of species' abundances
#' @param sumstats defaults "hill1", others not implemented
#'
#' @return sumstats value for this SAD
#' @export
#' @importFrom hillR hill_taxa
real_val <- function(sad, sumstats = "hill1") {
  
  return(hillR::hill_taxa(sad, q = 1))
  
}


#' Get species richness of an SAD
#'
#' @param sad vector of abundnaces
#'
#' @return richness
#' @export
#'
get_s <- function(sad) {
  
  return(length(sad))
  
}
#' Get total abundance of an SAD
#'
#' @param sad vector of abundnaces
#'
#' @return total abundance
#' @export
#'
get_n <- function(sad) {
  return(sum(sad))
}

full_workflow <- function(sad, ndraws = 1000, sumstat = "hill1") {
  
  s = get_s(sad)
  n = get_n(sad)
  
  real_v <- real_val(sad)
  
  fs_v <- fs_vals(s, n, ndraws = ndraws, sumstat = sumstat)
  mete_v <- mete_vals(s, n, ndraws = ndraws, sumstat = sumstat)
  
  out <- data.frame(
    s = s,
    n = n,
    real_v = real_v,
    fs_percentile = percentile(real_v, fs_v),
    mete_percentile = percentile(real_v, mete_v)
  )
  
  return(out)
}

#' Extract SAD for a site from the MACD
#'
#' @param macd_site site ID
#' @param macd_data full dataset
#'
#' @return vector of abundances for that site
#' @export
#'
extract_sad <- function(macd_site, macd_data) {
  
  sad <- macd_data[macd_data$siteID == macd_site, "abundance"]
  
  if(mode(sad) == "list") {
    
    sad <- sad[[1]]
  }
  
  if(all.equal(sad, round(sad)) == TRUE) {
    return(sad)
  }

  return()
}

