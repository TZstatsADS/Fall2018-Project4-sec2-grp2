

uniqueletters = function(filelist){
  A=charToInt('A')
  z=charToInt('z')
  letters=intToChar( A:z )
  # Encoding(letters)="UTF-8"
  
  for(file in filelist){
    lines = readLines(file, warn=FALSE,encoding = "UTF-8")
    add=unique( unlist(str_split(lines,"")) )
    letters=unique(c(letters,add))
  }
  if(sum(letters=="")>0)  
    letters=letters[-which(letters=="")]
  
  return(sort(letters))
}

# Calculate the LD similarity
ld_sim = function(truth, ocr_vec){
  len=nchar(truth)
  return (1-stringdist(truth,ocr_vec)/len)
}

confusion = function(truthlist,ocrlist,letterset){
  ## Return a confusion probability matrix, where
  # mat[i,j]: the probability that letter[i] in OCR is letter[j] in ground_truth.
  
  
  mat=matrix(0,nrow = length(letterset), ncol = length(letterset))
  
  for (file_ind in 1:length(truthlist)){
    # read vector
    ground_truth_txt = readLines(truthlist[file_ind], 
                                         warn=FALSE,encoding = "UTF-8")
    ground_truth_vec = unlist(str_split(ground_truth_txt," "))
    
    ocr_txt = readLines(ocrlist[file_ind], 
                        warn=FALSE,encoding = "UTF-8")
    ocr_vec = unlist(str_split(ocr_txt," "))
    
    # fuzzy matching
    ground_len=length(ground_truth_vec)
    ocr_len=length(ocr_vec)
    match_list=rep(NA,ground_len)
    j=1
    for (i in 1:ground_len){
      sim=ld_sim(ground_truth_vec[i],ocr_vec[j:min(j+CANDIDATE_NUM-1,ocr_len)])
      # small trick in case that too many consecutive mismatch from both truth and ocr.
      # if(max(sim)<SIM_THRES) sim=c(sim,ld_sim(ground_truth_vec[i],ocr_vec[min(j+CANDIDATE_NUM,ocr_len):min(j+6-1,ocr_len)]))
      if(max(sim)<SIM_THRES) {
        if(sum(is.na(match_list[max((i-3),1):i]))>3)
          j=j+1
        if(j>ocr_len) break;
        next
      }
      match_list[i]=which.max(sim)+j-1
      j=match_list[i]+1
      if(j>ocr_len) break;
    }
    
    # Confusion Matrix count
    for (i in 1:ground_len){
      j=match_list[i]
      if (is.na(j)) next;
      
      nc_truth=nchar(ground_truth_vec[i])
      if (nc_truth!=nchar(ocr_vec[j])) next;
      
      truth_char=str_split( ground_truth_vec[i], "")[[1]]
      ocr_char  =str_split( ocr_vec[j], "")[[1]]
      for(k in 1:nc_truth){
        ocr_ind=which(letterset==ocr_char[k])
        truth_ind=which(letterset==truth_char[k])
        mat[ocr_ind,truth_ind]=mat[ocr_ind,truth_ind]+1
      }
    }
    # Debug line, used to tune CANDIDATE_NUM
    # if(sum(is.na(match_list))>ground_len/3) print(file_ind)
  }
  
  removed_vec=rowSums(mat)==0&colSums(mat)==0
  letters<<-letters[!removed_vec]
  mat=mat[!removed_vec,!removed_vec]
  
  # Confusion Matrix count to probability
  mat=mat/rowSums(mat) # According to the paper, we should / colSums(mat). 
  # However, I think the paper just calculate the likelihood and try to get MLE
  # I want to calculate the posterior and get MAP, which could be a more accurate estimate of the truth
  
  return(mat)
}
