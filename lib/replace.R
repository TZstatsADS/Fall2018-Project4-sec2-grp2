# Original Replaces2():Replaces_ori
#
# Replaces1 <- function(word, range) {
#   N <- nchar(word) 
#   out <- list()
#   for (letter in letters) {
#     out[[letter]] <- rep(word, N)
#     for (i in range) {
#       substr(out[[letter]][i], i, i) <- letter
#     }
#   }
#   out <- unique(unlist(out))
#   return(out)
# }
# 
# Replaces_ori <- function(word) {
#   N <- nchar(word)
#   word.new <- Replaces1(word, 1:N)
#   out <- lapply(word.new, Replaces1,
#                 which(unlist(strsplit(word,"")) %in% unlist(strsplit(word.new,""))))
#   out <- unique(unlist(out))
#   return(out)
# }

letters_rep=rep(letters,each=length(letters))
Replaces2 <- function(word) {
  N <- nchar(word)
  if(N==1)
    return(letters)
  can_list=NULL
  for(i in 1:(N-1)) {
    for(j in (i+1):N) {
      # cat(i,j,"\n")
      can_list=c(can_list,paste(substr(word,1,i-1),letters_rep,substr(word,i+1,j-1),letters,substr(word,j+1,N),sep="")
            )
    }
  }
  return(can_list)
}

# system.time(temp<-Replaces_ori("STAFF"))
# user  system elapsed 
# 2.47    0.00    2.50 
# system.time (for(i in 1:100) {temp<-Replaces2("STAFF")} )
# user  system elapsed 
# 4.26    0.14    4.52