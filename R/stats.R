
#' Estimate means and variances of many populations from samples of each
#'
#' Implements the general case of the non-parametric linear empirical Bayes
#' estimator of many means and many variances as described in the same named
#' publication by Herbert Robbins (1985) <doi:10.1073/pnas.82.6.1571>.
#'
#' @param x_ij list of numeric vectors, corresponding to independent random samples each from a different population
#'
#' @return data.frame with one row for each element of \code{x_ij} and columns corresponding to statistics of \code{x_ij} including the proposed estimator for the means, \code{t_i}, and for the variances, \code{w_i}.
#'
#' @examples
#' estimate(x_ij = split(iris$Sepal.Length, f = iris$Species))
#'
#' @export
estimate <- function(x_ij) {
  # statistics needed for estimator t_i
  x_i <- sapply(x_ij, mean)
  x <- mean(x_i)
  s2_i <- sapply(x_ij, var)
  s2 <- mean(s2_i)
  u2 <- var(x_i)
  n_i <- sapply(x_ij, length)
  n <- length(n_i)
  nu = mean(1/n_i)

  # estimator of θ_i
  tmp <- pmax(u2-nu*s2,0)
  t_i <- x + tmp / (tmp + 1/n_i * s2) * (x_i-x)

  # statistics needed for estimator w_i
  nu4 <- var(s2_i)
  nu_prime <- mean((n_i-3)/(n_i*(n_i-1)))
  s4_i <- s2_i^2
  A_i <- (n_i^2-2*n_i+3) / ((n_i-1)*(n_i-2)*(n_i-3)) * mapply(function(x_ij, x_i) sum((x_ij-x_i)^4), x_ij, x_i) - (3*(2*n_i-3)*(n_i-1)) / (n_i*(n_i-2)*(n_i-3)) * s4_i
  B_i <- n_i*(n_i-1) / (n_i^2 - 2*n_i + 3) * (s4_i - A_i/n_i)
  A = mean(A_i)
  B = mean(B_i)

  # estimator of Var(θ_i) (= σ^2_i)
  tmp <- pmax(nu4-nu*A + nu_prime * B, 0)
  w_i <- s2 + tmp / (tmp + 1/n_i * (A - (n_i-3) / (n_i-1) * B) )  * (s2_i - s2)

  data.frame(row.names = names(x_ij), x_i, x, s2_i, s2, u2, n_i, nu, n,  t_i, B_i, B, A_i, A, w_i)
}
