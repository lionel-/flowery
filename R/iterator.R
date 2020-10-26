#' Iterator protocol
#'
#' @description
#'
#' An __iterator__ is a function that implements the following
#' protocol:
#'
#' - Calling the function advances the iterator. The new value is
#'   returned.
#'
#' - When the iterator is exhausted and there are no more elements to
#'   return, the symbol `quote(exhausted)` is returned. This signals
#'   exhaustion to the caller.
#'
#' - Once an iterator has signalled exhaustion, all subsequent
#'   invokations must consistently return `quote(exhausted)`.
#'
#' ```{r}
#' iterator <- as_iterator(1:3)
#'
#' # Calling the iterator advances it
#' iterator()
#' iterator()
#'
#' # This is the last value
#' iterator()
#'
#' # Subsequent invokations return the exhaustion sentinel
#' iterator()
#' ```
#'
#' Because iteration is defined by a protocol, creating iterators is
#' free of dependency. However, it is often simpler to create
#' iterators with [generators][generator], see
#' `vignette("generator")`. To iterate over an iterator, it is simpler
#' to use the [iterate()] and [collect()] helpers provided in this
#' package.
#'
#'
#' @section Properties:
#'
#' Iterators are __stateful__. Advancing the iterator creates a
#' persistent effect in the R session. Also iterators are
#' __one-way__. Once you have advanced an iterator, there is no going
#' back and once it is exhausted, it stays exhausted.
#'
#' Iterators are not necessarily finite. They can also represent
#' infinite sequences, in which case trying to exhaust them is a
#' programming error that causes an infinite loop.
#'
#' @name iterator
NULL

#' @rdname iterator
#' @export
exhausted <- function() {
  quote(exhausted)
}
#' @rdname iterator
#' @param x An object.
#' @export
is_exhausted <- function(x) {
  identical(x, quote(exhausted))
}

#' Transform a vector or list to an iterator
#'
#' @description
#'
#' `as_iterator()` takes a vector and transforms it to an [iterator
#' function][iterator].
#'
#' This is mostly useful for creating examples or to provide a bridge
#' between vectors and iterators. It is generally not efficient to use
#' the iteration protocol with vectors. Vectorised idioms are
#' generally preferred in R programming.
#'
#' @param x A vector or a function. Functions are returned as is.
#' @return An iterable function.
#' @export
as_iterator <- function(x) {
  if (is_closure(x)) {
    return(x)
  }

  # This uses `length()` and `{{` rather than `vec_size()` and
  # `vec_slice2()` for compatibility with base R because
  # `as_iterator()` is used in generators to instrument for loops
  n <- length(x)
  i <- 0L

  function() {
    if (i == n) {
      return(exhausted())
    }

    i <<- i + 1L
    x[[i]]
  }
}