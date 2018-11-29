library(dplyr)
library(tm)

r_t <- NA
r_p <- NA
p_t <- NA
p_p <- NA

measurement_correct <- function(tesseract_dir,result_dir,truth_dir){
  for(k in 1:length(correct_names)){
    ## read ground truth text
    current_ground_truth_txt <- readLines(paste0(truth_dir[k]), warn=FALSE,encoding = "UTF-8")
    ground_truth_vec <- str_split(paste(current_ground_truth_txt, collapse = " ")," ")[[1]]
    
    ## read the tesseract text
    current_tesseract_txt <- readLines(paste0(tesseract_dir[k]), warn=FALSE,encoding = "UTF-8")
    clean_tesseract_txt <- paste(current_tesseract_txt, collapse = " ")
    tesseract_vec <- str_split(clean_tesseract_txt," ")[[1]]
    
    ## read post processed text
    tesseract_delete_txt <- readLines(paste0(result_dir[k]),warn = FALSE,encoding = "UTF-8")
    tesseract_delete_error_vec <- str_split(paste(tesseract_delete_txt,collapse = " ")," ")[[1]]
    
    #Step 1. Find unique words that intersected 
    ground_truth_l <- tolower(ground_truth_vec)%>%removePunctuation()
    tesseract_l <- tolower(tesseract_vec)%>%removePunctuation()
    tesseract_delete_error_l <- tolower(tesseract_delete_error_vec)%>%removePunctuation()
    
    ground_truth_u <- which(!(ground_truth_l %in% ground_truth_l[duplicated(ground_truth_l)]))
    tesseract_u <- which(!(tesseract_l %in% tesseract_l[duplicated(tesseract_l)]))
    tesseract_no_error_u <- which(!(tesseract_delete_error_l %in% tesseract_delete_error_l[duplicated(tesseract_delete_error_l)]))
    
    gu <- ground_truth_l[ground_truth_u]
    tu <- tesseract_l[tesseract_u]
    du <- tesseract_delete_error_l[tesseract_no_error_u]
    
    intersect_u <- vecsets::vintersect(gu,tu)
    dintersect_u <- vecsets::vintersect(gu,du)
    
    
    #find the position of unique words in ground truth text and OCR text
    g1 <- which(ground_truth_l %in% intersect_u)
    t1 <- which(tesseract_l %in% intersect_u)
    d1 <- which(tesseract_delete_error_l%in%dintersect_u)
    gd1 <- which(ground_truth_l%in%dintersect_u)
    
    
    #Step2. Split the ground truth text and tesseract text into segments according to unique words as anchors
    
    #ground truth text
    transpose_list <- function(x,y){
      return(t(ground_truth_l[seq(g1[x],g1[y])]))
    }
    
    mats <- list(NA)
    
    for (i in 1:length(g1)){
      if(g1[1]>1){
        if(i==1){
          mats[[1]] <- mapply(function(x) t(ground_truth_l[seq(1,g1[x])]),1,SIMPLIFY = F)
        }else{
          mats[[i]] <- mapply(transpose_list,i-1,i,SIMPLIFY = F)
        }
      }else if (g1[1]==1){
        if (1 <= i & i <= length(g1)-1){
          mats[[i]] <- mapply(transpose_list,i,i+1,SIMPLIFY=F)
        }else{
          mats[[length(g1)]] <- mapply(function(x,y) t(ground_truth_l[seq(g1[x],g1[y])]),length(g1)-1,length(g1))
        }
      }
    }
    
    mat_g <- list(NA)
    for(i in 1:length(g1)){
      mat_g[[i]] <- mats[[i]][[1]][-1]
      mat_g[[i]] <- mat_g[[i]][-length(mat_g[[i]])]
    }
    
    #tesseract text
    t_list <- function(x,y){
      return(t(tesseract_l[seq(t1[x],t1[y])]))
    }
    
    mats2 <- list(NA)
    
    for (i in 1:length(t1)){
      if(t1[1]>1){
        if(i==1){
          mats2[[1]] <- mapply(function(x) t(tesseract_l[seq(1,t1[x])]),1,SIMPLIFY = F)
        }else{
          mats2[[i]] <- mapply(t_list,i-1,i,SIMPLIFY = F)
        }
      }else if (t1[1]==1){
        if (1 <= i & i <= length(t1)-1){
          mats2[[i]] <- mapply(t_list,i,i+1,SIMPLIFY=F)
        }else{
          mats2[[length(t1)]] <- mapply(function(x,y) t(tesseract_l[seq(t1[x],t1[y])]),length(t1)-1,length(t1))
        }
      }
    }
    
    mat_t <- list(NA)
    for(i in 1:length(t1)){
      mat_t[[i]] <- mats2[[i]][[1]][-1]
      mat_t[[i]] <- mat_t[[i]][-length(mat_t[[i]])]
    }
    
    
    #delete_error text
    d_list <- function(x,y){
      return(t(tesseract_delete_error_l[seq(d1[x],d1[y])]))
    }
    
    mats3 <- list(NA)
    
    for (i in 1:length(d1)){
      if(d1[1]>1){
        if(i==1){
          mats3[[1]] <- mapply(function(x) t(tesseract_delete_error_l[seq(1,d1[x])]),1,SIMPLIFY = F)
        }else{
          mats3[[i]] <- mapply(d_list,i-1,i,SIMPLIFY = F)
        }
      }else if (d1[1]==1){
        if (1 <= i & i <= length(d1)-1){
          mats3[[i]] <- mapply(d_list,i,i+1,SIMPLIFY=F)
        }else{
          mats3[[length(d1)]] <- mapply(function(x,y) t(tesseract_delete_error_l[seq(d1[x],d1[y])]),length(d1)-1,length(d1))
        }
      }
    }
    
    mat_d <- list(NA)
    for(i in 1:length(d1)){
      mat_d[[i]] <- mats3[[i]][[1]][-1]
      mat_d[[i]] <- mat_d[[i]][-length(mat_d[[i]])]
    }
    
    #ground truth text intersect with delete error
    gd_list <- function(x,y){
      return(t(ground_truth_l[seq(gd1[x],gd1[y])]))
    }
    
    mats4 <- list(NA)
    
    for (i in 1:length(gd1)){
      if(gd1[1]>1){
        if(i==1){
          mats4[[1]] <- mapply(function(x) t(ground_truth_l[seq(1,gd1[x])]),1,SIMPLIFY = F)
        }else{
          mats4[[i]] <- mapply(gd_list,i-1,i,SIMPLIFY = F)
        }
      }else if (gd1[1]==1){
        if (1 <= i & i <= length(gd1)-1){
          mats4[[i]] <- mapply(gd_list,i,i+1,SIMPLIFY=F)
        }else{
          mats4[[length(gd1)]] <- mapply(function(x,y) t(ground_truth_l[seq(gd1[x],gd1[y])]),length(gd1)-1,length(gd1))
        }
      }
    }
    
    mat_gd <- list(NA)
    for(i in 1:length(gd1)){
      mat_gd[[i]] <- mats4[[i]][[1]][-1]
      mat_gd[[i]] <- mat_gd[[i]][-length(mat_gd[[i]])]
    }
    
    
    #Step3. Calculate performance for precision and recall
    
    #Character wise Recall for tesseract
    inc1 <- 0
    for(i in 1:length(g1)){
      inc1 <- inc1+ sum(diag(adist(mat_g[[i]],mat_t[[i]])))
    }
    
    r_t[k] <- (sum(nchar(ground_truth_l))-inc1)/sum(nchar(ground_truth_l))
    
    
    
    #Character wise Recall for tesseract post processing
    inc2 <- 0
    for(i in 1:length(gd1)){
      inc2 <- inc2+ sum(diag(adist(mat_gd[[i]],mat_d[[i]])))
    }
    r_p[k] <- (sum(nchar(ground_truth_l))-inc2)/sum(nchar(ground_truth_l))
    
    
    #Character wise precision for tesseract
    p_t[k] <- (sum(nchar(tesseract_l))-inc1)/sum(nchar(tesseract_l))
    
    
    #Character wise precision for tesseract post processing
    p_p[k] <- (sum(nchar(tesseract_l))-inc2)/sum(nchar(tesseract_l))
    
  }
  #Construct OCR performance table 
  O_table <- data.frame("Tesseract" = rep(NA,2),
                        "Tesseract_with_postprocessing" = rep(NA,2))
  row.names(O_table) <- c("character_wise_recall","character_wise_precision")
  O_table["character_wise_recall","Tesseract"] <- round(mean(r_t),5)
  O_table["character_wise_recall","Tesseract_with_postprocessing"] <- round(mean(r_p),5)
  O_table["character_wise_precision","Tesseract"] <- round(mean(p_t),5)
  O_table["character_wise_precision","Tesseract_with_postprocessing"] <- round(mean(p_p),5)
  
  return(O_table)
  
}