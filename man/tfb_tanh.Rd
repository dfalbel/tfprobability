% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bijectors.R
\name{tfb_tanh}
\alias{tfb_tanh}
\title{Computes \code{Y = tanh(X)}}
\usage{
tfb_tanh(validate_args = FALSE, name = "tanh")
}
\arguments{
\item{validate_args}{Logical, default FALSE. Whether to validate input with asserts. If validate_args is
FALSE, and the inputs are invalid, correct behavior is not guaranteed.}

\item{name}{name prefixed to Ops created by this class.}
}
\description{
\code{Y = tanh(X)}, therefore Y in \code{(-1, 1)}.
}
\details{
This can be achieved by an affine transform of the Sigmoid bijector, i.e., it is equivalent to

\code{tfb_chain(list(tfb_affine(shift = -1, scale = 2),
               tfb_sigmoid(),
               tfb_affine(scale = 2)))}

However, using the Tanh bijector directly is slightly faster and more numerically stable.
}
\seealso{
Other bijectors: \code{\link{tfb_absolute_value}},
  \code{\link{tfb_affine_linear_operator}},
  \code{\link{tfb_affine_scalar}},
  \code{\link{tfb_affine}},
  \code{\link{tfb_batch_normalization}},
  \code{\link{tfb_blockwise}}, \code{\link{tfb_chain}},
  \code{\link{tfb_cholesky_outer_product}},
  \code{\link{tfb_cholesky_to_inv_cholesky}},
  \code{\link{tfb_correlation_cholesky}},
  \code{\link{tfb_discrete_cosine_transform}},
  \code{\link{tfb_expm1}}, \code{\link{tfb_exp}},
  \code{\link{tfb_fill_triangular}},
  \code{\link{tfb_gumbel}}, \code{\link{tfb_identity}},
  \code{\link{tfb_inline}}, \code{\link{tfb_invert}},
  \code{\link{tfb_kumaraswamy}},
  \code{\link{tfb_masked_autoregressive_default_template}},
  \code{\link{tfb_masked_autoregressive_flow}},
  \code{\link{tfb_masked_dense}},
  \code{\link{tfb_matrix_inverse_tri_l}},
  \code{\link{tfb_matvec_lu}},
  \code{\link{tfb_normal_cdf}}, \code{\link{tfb_ordered}},
  \code{\link{tfb_permute}},
  \code{\link{tfb_power_transform}},
  \code{\link{tfb_real_nvp_default_template}},
  \code{\link{tfb_real_nvp}}, \code{\link{tfb_reciprocal}},
  \code{\link{tfb_reshape}}, \code{\link{tfb_scale_tri_l}},
  \code{\link{tfb_sigmoid}},
  \code{\link{tfb_sinh_arcsinh}},
  \code{\link{tfb_softmax_centered}},
  \code{\link{tfb_softplus}}, \code{\link{tfb_softsign}},
  \code{\link{tfb_square}},
  \code{\link{tfb_transform_diagonal}},
  \code{\link{tfb_transpose}}, \code{\link{tfb_weibull}}
}
\concept{bijectors}
