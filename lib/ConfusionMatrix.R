

uniqueletters = function(filelist){
  A=charToInt('A')
  z=charToInt('z')
  letters=intToChar( A:z )
  Encoding(letters)="UTF-8"
  
  for(file in filelist){
    lines = readLines(file, warn=FALSE,encoding = "UTF-8")
    add=unique( unlist(str_split(lines,"")) )
    letters=unique(c(letters,add))
  }
  return(sort(letters))
}

# Calculate the 
ld_sim = function(truth, ocr_vec){
  len=nchar(truth)
  return (1-stringdist(truth,ocr_vec)/len)
}

confusion = function(truthlist,ocrlist,letterset){
  ## Return a confusion probability matrix, where
  # mat[i,j]: the probability that letter[i] in OCR is letter[j] in ground_truth.
  
  
  mat=matrix(0,nrow = length(letterset), ncol = length(letterset))
  
  for (file_ind in length(truthlist)){
    # read vector
    current_ground_truth_txt = readLines(truthlist[file_ind], 
                                         warn=FALSE,encoding = "UTF-8")
    ground_truth_vec = unlist(str_split(current_ground_truth_txt," "))
    
    ocr_vec = readLines(ocrlist[file_ind], 
                        warn=FALSE,encoding = "UTF-8")
    
    # fuzzy matching
    ground_len=length(ground_truth_vec)
    ocr_len=length(ocr_vec)
    match_list=rep(NA,ground_len)
    j=1
    for (i in 1:ground_len){
      sim=ld_sim(ground_truth_vec[i],ocr_vec[j:min(j+CANDIDATE_NUM-1,ocr_len)])
      if(max(sim)<SIM_THRES) next;
      match_list[i]=which.max(sim)+j-1
      j=match_list[i]+1
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
  }
  
  # Confusion Matrix count to probability
  mat=mat/rowSums(mat)
  return(mat)
}
