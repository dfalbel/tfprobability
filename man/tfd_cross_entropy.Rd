% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/distribution-methods.R
\name{tfd_cross_entropy}
\alias{tfd_cross_entropy}
\title{Computes the (Shannon) cross entropy.}
\usage{
tfd_cross_entropy(distribution, other, name = "cross_entropy")
}
\arguments{
\item{distribution}{The distribution being used.}

\item{other}{\code{tfp$distributions$Distribution} instance.}

\item{name}{String prepended to names of ops created by this function.}
}
\value{
cross_entropy: self.dtype Tensor with shape \code{[B1, ..., Bn]} representing n different calculations of (Shannon) cross entropy.
}
\description{
Denote this distribution (self) by P and the other distribution by Q.
Assuming P, Q are absolutely continuous with respect to one another and permit densities
p(x) dr(x) and q(x) dr(x), (Shannon) cross entropy is defined as:
\code{H[P, Q] = E_p[-log q(X)] = -int_F p(x) log q(x) dr(x)}
where F denotes the support of the random variable \code{X ~ P}.
}
\seealso{
Other distribution_methods: \code{\link{tfd_cdf}},
  \code{\link{tfd_covariance}}, \code{\link{tfd_entropy}},
  \code{\link{tfd_kl_divergence}},
  \code{\link{tfd_log_cdf}}, \code{\link{tfd_log_prob}},
  \code{\link{tfd_log_survival_function}},
  \code{\link{tfd_mean}}, \code{\link{tfd_mode}},
  \code{\link{tfd_prob}}, \code{\link{tfd_quantile}},
  \code{\link{tfd_sample}}, \code{\link{tfd_stddev}},
  \code{\link{tfd_survival_function}},
  \code{\link{tfd_variance}}
}
\concept{distribution_methods}
