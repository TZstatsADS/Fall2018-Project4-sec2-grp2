 
library(tidyverse)

candidate <- function(wc){
  #a1<- letters
  #a2<- letters
  grid <- expand.grid(one = letters, two = letters)
  word_c <- rep(wc,dim(grid)[1])
  candidate_list <- c()
  for (i in 1:nchar(wc)){
    for (j in (i+1):(nchar(wc)+1)){
      c <- word_c
      substr(c,i,i) <- as.character(grid$one)
      substr(c,j,j) <- as.character(grid$two)
      candidate_list <- c(candidate_list,c)
    }
  }
  candidate_list = unique(candidate_list)
  return(candidate_list)
}