% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/distribution-layers.R
\name{layer_one_hot_categorical}
\alias{layer_one_hot_categorical}
\title{A \code{d}-variate OneHotCategorical Keras layer from \code{d} params.}
\usage{
layer_one_hot_categorical(object, event_size,
  convert_to_tensor_fn = tfp$distributions$Distribution$sample,
  sample_dtype = NULL, validate_args = FALSE, ...)
}
\arguments{
\item{object}{Model or layer object}

\item{event_size}{Scalar \code{integer} representing the size of single draw from this distribution.}

\item{convert_to_tensor_fn}{A callable that takes a tfd$Distribution instance and returns a
tf$Tensor-like object. Default value: \code{tfd$distributions$Distribution$sample}.}

\item{sample_dtype}{\code{dtype} of samples produced by this distribution.
Default value: \code{NULL} (i.e., previous layer's \code{dtype}).}

\item{validate_args}{Logical, default FALSE. When TRUE distribution parameters are checked
for validity despite possibly degrading runtime performance. When FALSE invalid inputs may
silently render incorrect outputs. Default value: FALSE.}

\item{...}{Additional arguments passed to \code{args} of \code{keras::create_layer}.}
}
\description{
Typical choices for \code{convert_to_tensor_fn} include:
\itemize{
\item \code{tfp$distributions$Distribution$sample}
\item \code{tfp$distributions$Distribution$mean}
\item \code{tfp$distributions$Distribution$mode}
\item \code{tfp$distributions$OneHotCategorical$logits}
}
}
\seealso{
Other distribution_layers: \code{\link{layer_categorical_mixture_of_one_hot_categorical}},
  \code{\link{layer_distribution_lambda}},
  \code{\link{layer_independent_bernoulli}},
  \code{\link{layer_independent_logistic}},
  \code{\link{layer_independent_normal}},
  \code{\link{layer_independent_poisson}},
  \code{\link{layer_kl_divergence_add_loss}},
  \code{\link{layer_kl_divergence_regularizer}},
  \code{\link{layer_mixture_logistic}},
  \code{\link{layer_mixture_normal}},
  \code{\link{layer_mixture_same_family}},
  \code{\link{layer_multivariate_normal_tri_l}}
}
\concept{distribution_layers}
