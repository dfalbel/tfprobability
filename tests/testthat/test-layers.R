
context("tensorflow probability keras layers")

source("utils.R")

test_succeeds("use layer_autoregressive with 1d autoregressivity", {

  skip_if_tfp_below("0.7")

  library(keras)
  n <- 2000
  x2 <- rnorm(n) %>% tf$cast(tf$float32) * 2
  x1 <- rnorm(n) %>% tf$cast(tf$float32) + (x2 * x2 / 4)
  data <- tf$stack(list(x1, x2), axis = -1L)

  made <- layer_autoregressive(params = 2, hidden_units = list(10, 10)) # output will be (n, 2, 2)
  distribution <- tfd_transformed_distribution(
    distribution = tfd_normal(loc = 0, scale = 1),
    bijector = tfb_masked_autoregressive_flow(
      function(x) tf$unstack(made(x), num = 2L, axis = -1L)), # output is list of (2000, 2) of length 2
    event_shape = list(2)) # distribution has shapes () and (2,)

  x_ <- layer_input(shape = c(2), dtype = "float32")
  log_prob_ <- distribution$log_prob(x_)
  model <- keras_model(x_, log_prob_)
  loss <- function(x, log_prob) -log_prob
  model %>% compile(optimizer = "adam", loss = loss)

  model %>% fit(x = data,
            y = rep(0, n),
            batch_size = 25,
            epochs = 1,
            steps_per_epoch = 1,
            verbose = 0)

  expect_equal((distribution %>% tfd_sample(c(3, 1)))$get_shape()$as_list(), c(3, 1, 2))
  expect_equal((distribution %>% tfd_log_prob(matrix(rep(1, 3*2), ncol = 2)))$get_shape()$as_list(), c(3))
})


# `AutoregressiveLayer` can be used as a building block to achieve different
# autoregressive structures over rank-2+ tensors.  For example, suppose we want
# to build an autoregressive distribution over images with dimension
# `[weight, height, channels]` with `channels = 3`:
# We can parameterize a "fully autoregressive" distribution, with
# cross-channel and within-pixel autoregressivity:
#   ```
# r0    g0   b0     r0    g0   b0       r0   g0    b0
# ^   ^      ^         ^   ^   ^         ^      ^   ^
# |  /  ____/           \  |  /           \____  \  |
# | /__/                 \ | /                 \__\ |
# r1    g1   b1     r1 <- g1   b1       r1   g1 <- b1
#                                        ^          |
#                                         \_________/

test_succeeds("use layer_autoregressive to model rank-3 tensors with full autoregressivity", {

  skip_if_tfp_below("0.7")

  library(keras)

  n <- 1000L
  width <- 8L
  height <- 8L
  channels <- 3L
  images <-
    runif(n * height * width * channels) %>% array(dim = c(n, height, width, channels)) %>%
    tf$cast(tf$float32)

  # Reshape images to achieve desired autoregressivity.
  event_shape <- height * width * channels
  reshaped_images <- tf$reshape(images, c(n, event_shape))

  # yields (n, 192, 2)
  made <-
    layer_autoregressive(
      params = 2,
      event_shape = event_shape,
      hidden_units = list(20, 20),
      activation = "relu"
    )

  distribution <- tfd_transformed_distribution(
    distribution = tfd_normal(loc = 0, scale = 1),
    bijector = tfb_masked_autoregressive_flow(function (x)
      tf$unstack(
        made(x), num = 2, axis = -1L # yields list (1000, 192) of length 2
      )),
    event_shape = event_shape
  )

  x_ <- layer_input(shape = event_shape, dtype = "float32")
  log_prob_ <- distribution %>% tfd_log_prob(x_)

  model <- keras_model(x_, log_prob_)
  loss <- function(x, log_prob)
    - log_prob
  model %>% compile(optimizer = "adam", loss = loss)

  model %>% fit(
    x = reshaped_images,
    y = rep(0, n),
    batch_size = 10,
    epochs = 1,
    steps_per_epoch = 1,
    verbose = 0
  )

  expect_equal((distribution %>% tfd_sample(c(3, 1)))$get_shape()$as_list(),
               c(3, 1, event_shape))
  })

test_succeeds("use layer_autoregressive to model rank-3 tensors without autoregressivity over channels", {

  skip_if_tfp_below("0.7")

  library(keras)

  n <- 1000L
  width <- 8L
  height <- 8L
  channels <- 3L
  images <-
    sample(0:1, n * height * width * channels, replace = TRUE) %>% array(dim = c(n, height, width, channels)) %>%
    tf$cast(tf$float32)

  # Reshape images to achieve desired autoregressivity.
  event_shape <- height * width
  # (n, 3, 64)
  reshaped_images <- tf$reshape(images, c(n, event_shape, channels)) %>% tf$transpose(perm = c(0L, 2L, 1L))

  # yields (n, 192, 2)
  made <-
    layer_autoregressive(
      params = 1,
      event_shape = event_shape,
      hidden_units = list(20, 20),
      activation = "relu"
    )
  # batch_shape=(), event_shape=(3, 64)
  distribution = tfd_autoregressive(
    # batch_shape=(1000,), event_shape=(3, 64)
    function(x) tfd_independent(
      # batch_shape=(1000, 3, 64), event_shape=()
      tfd_bernoulli(logits = tf$unstack(made(x), axis = -1L)[[1]], # (1000, 3, 64)
                    dtype = tf$float32),
      reinterpreted_batch_ndims = 2),
    sample0 = tf$zeros(list(channels, width * height), dtype = tf$float32))


  x_ <- layer_input(shape = c(channels, event_shape), dtype = "float32")
  log_prob_ <- distribution %>% tfd_log_prob(x_)

  model <- keras_model(x_, log_prob_)
  loss <- function(x, log_prob)
    - log_prob
  model %>% compile(optimizer = "adam", loss = loss)

  model %>% fit(
    x = reshaped_images,
    y = rep(0, n),
    batch_size = 10,
    epochs = 1,
    steps_per_epoch = 1,
    verbose = 0
  )

  expect_equal((distribution %>% tfd_sample(c(7)))$get_shape()$as_list(),
               c(7, channels, event_shape))
})


test_succeeds("layer_variable works", {

  skip_if_tfp_below("0.7")

  library(keras)

  x = tf$ones(shape = c(3, 4))
  y = tf$ones(3)

  trainable_normal <- keras_model_sequential(list(
    layer_variable(shape = 2),
    layer_distribution_lambda(
      make_distribution_fn = function (t)
        tfd_independent(
          tfd_normal(loc = t[1], scale = tf$math$softplus(t[2])),
          reinterpreted_batch_ndims = 0
        )
    )
  ))

  negloglik <- function(x, rv_x) -(rv_x %>% tfd_log_prob(x))
  trainable_normal %>% compile(optimizer = 'adam', loss = negloglik)
  trainable_normal %>% fit(x, y, steps_per_epoch = 1)

})

test_succeeds("layer_dense_variational works", {

  skip_if_tfp_below("0.7")

  library(keras)

  x = tf$ones(shape = c(150,1))
  y = tf$ones(150)

  posterior_mean_field <- function(kernel_size, bias_size = 0, dtype = NULL) {
    n <- kernel_size + bias_size
    c <- log(expm1(1))
    keras_model_sequential(list(
      layer_variable(shape = 2 * n, dtype = dtype),
      layer_distribution_lambda(make_distribution_fn = function(t) {
        tfd_independent(
          tfd_normal(loc = t[1:n], scale = 1e-5 + tf$nn$softplus(c + t[(n+1):(2*n)])),
          reinterpreted_batch_ndims = 1
        )
      })
    ))
  }

  prior_trainable <- function(kernel_size, bias_size = 0, dtype = NULL) {
    n <- kernel_size + bias_size
    keras_model_sequential() %>%
      layer_variable(n, dtype = dtype) %>%
      layer_distribution_lambda(function(t) {
        tfd_independent(
          tfd_normal(loc = t, scale = 1),
          reinterpreted_batch_ndims = 1
        )
      })
  }

  model <- keras_model_sequential(list(
    layer_dense_variational(
      units = 1,
      make_posterior_fn = posterior_mean_field,
      make_prior_fn = prior_trainable
    ),
    layer_distribution_lambda(
      make_distribution_fn = function(x)
        tfd_normal(loc = x, scale = 1)
    )
  ))

  negloglik <- function(x, rv_x) -(rv_x %>% tfd_log_prob(x))
  model %>% compile(optimizer = 'adam', loss = negloglik)
  model %>% fit(x, y, steps_per_epoch = 1)

  yhat <- model(x)
  expect_equal((yhat %>% tfd_sample())$get_shape()$as_list(), c(150,1))

})
