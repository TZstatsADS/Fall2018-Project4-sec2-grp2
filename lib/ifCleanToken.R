##############################
## Garbage detection
## Ref: first three rules in the paper
##      'On Retrieving Legal Files: Shortening Documents and Weeding Out Garbage'
## Input: one word -- token
## Output: bool -- if the token is clean or not
##############################
ifCleanToken <- function(cur_token){
  now <- 1
  if_clean <- TRUE
  
  ## in order to accelerate the computation, conduct ealy stopping
  rule_list <- c("str_count(cur_token, pattern = '[A-Za-z0-9]') <= 0.5*nchar(cur_token)", 
                 # If the number of punctuation characters in a string is greater than the number of alphanumeric characters, it is garbage
                 "length(unique(strsplit(gsub('[A-Za-z0-9]','',substr(cur_token, 2, nchar(cur_token)-1)),'')[[1]]))>1", 
                 #Ignoring the first and last characters in a string, 
                 #if there are two or more different punctuation characters in the string, it is garbage
                 "nchar(cur_token)>20",#A string composed of more than 20 symbols is garbage
                "grepl(pattern='(.)\\1{2,}',cur_token)",
                #If there are three or more identical characters in a row in a string, it is garbage
                "str_count(cur_token,pattern='[A-Z]')>str_count(cur_token,pattern='[a-z]') & str_count(cur_token,pattern='[A-Z]')< str_count(cur_token,pattern='[A-Za-z0-9]')",
                #If the number of uppercase characters in a string is greater than the number of lowercase characters, and if the number of uppercase characters is less than the total number of characters in the string, it is garbage
                "grepl(pattern='^[A-Za-z]+$',cur_token) & (str_count(cur_token,pattern='[b-df-hj-np-tv-zB-DF-HJ-NP-TV-Z]') >= 8*str_count(cur_token,pattern='[aeiouAEIOU]') | str_count(cur_token,pattern='[aeiouAEIOU]') >= 8*str_count(cur_token,pattern='[b-df-hj-np-tv-zB-DF-HJ-NP-TV-Z]'))",
                # If all the characters in a string are alphabetic, and if the number of consonants in the string is greater than 8 times the number of vowels in the string, or vice-versa, it is garbage
                "grepl(pattern='[aeiouAEIOU]{3,}',cur_token) | grepl(pattern='[b-df-hj-np-tv-zB-DF-HJ-NP-TV-Z]{4,}',cur_token)",
                # If there are four or more consecutive vowels in the string or five or more consecutive consonants in the string, it is garbage
                "grepl('^[a-z].*[a-z]$',cur_token) & grepl('\\\\B[A-Z]+\\\\B',cur_token)")
                #If the first and last characters in a string are both lowercase and any other character is uppercase, it is garbage
  
  while((if_clean == TRUE)&now<=length(rule_list)){
    if(eval(parse(text = rule_list[now]))){
      if_clean <- FALSE
    }
    now <- now + 1
  }
  return(if_clean)
}
