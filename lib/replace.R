
Replaces1 <- function(word, range) {
  N <- nchar(word) 
  out <- list()
  for (letter in letters) {
    out[[letter]] <- rep(word, N)
    for (i in range) {
      substr(out[[letter]][i], i, i) <- letter
    }
  }
  out <- unique(unlist(out))
  return(out)
}

Replaces2 <- function(word) {
  N <- nchar(word)
  word.new <- Replaces1(word, 1:N)
  out <- lapply(word.new, Replaces1,
                which(unlist(strsplit(word,"")) %in% unlist(strsplit(word.new,""))))
  out <- unique(unlist(out))
  return(out)
}







