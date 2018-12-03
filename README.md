# Project: OCR Output Enhancement

![image](figs/intro.png)

### [Full Project Description](doc/project4_desc.md)

Term: Fall 2018

+ Sec2 Group 2
+ Team members
	+ Cai, Yang yc3404@columbia.edu
	+ Cui, Jiayi jc4884@columbia.edu
	+ Wang, Nannan nw2387@columbia.edu
	+ Yang, Yang yy2819@columbia.edu
	+ Yu, Wenting wy2294@columbia.edu

+ Project summary: In this project, we created an OCR post-processing procedure to enhance Tesseract OCR output based on Latent Dirichlet Allocation topic model.

+ Error Detection: We implemented the 8 rules by Scott Kulp and April Kontostathis, *On Retrieving Legal Files: Shortening Documents and Weeding Out Garbage*.
 
 	+ If a string is more than 20 characters in length, it is garbage. This rule was taken from rmgarbage, but shortened from 40 to 20 characters.
	+ If the number of punctuation characters in a string is greater than the number of alphanumeric characters, it is garbage. This rule was taken from rmgarbage.
	+ Ignoring the first and last characters in a string, if there are two or more different punctuation characters in the string, it is garbage. This rule was taken from rmgarbage.
	+ If there are three or more identical characters in a row in a string, it is garbage. This rule was taken from rmgarbage, but shortened from four or more characters to three.
	+ If the number of uppercase characters in a string is greater than the number of lowercase characters, and if the number of uppercase characters is less than the total number of characters in the string, it is garbage. This is a new rule we developed when we saw that OCR errors often created excessive numbers of uppercase characters, but normally, in English, there is usually no more than one uppercase character in a term. However, some- times real English words appeared in all uppercase characters, which is acceptable, so words that contain only uppercase characters are not considered garbage.
	+ If all the characters in a string are alphabetic, and if the number of consonants in the string is greater than 8 times the number of vowels in the string, or vice-versa, it is garbage. This rule was taken from rmgarbage, but the threshold was shortened from 10 to 8.
	+ If there are four or more consecutive vowels in the string or five or more consecutive consonants in the string, it is garbage. This is a new rule we developed when we noticed that real English words with these traits are rare, but this property appeared often in OCR errors.
	+ If the first and last characters in a string are both lowercase and any other character is uppercase, it is garbage. This rule was taken from rmgarbage.
	
+ Error Correction: We implemented the word candidate score computing method by Michael L. Wick, Michael G. Ross and Erik G. Learned-Miller, *Context-Sensitive Error Correction: Using Topic Models to Improve OCR*.

	+ Topic Model: in this project, we used the Latent Dirichlet Allocation by David Blei to generate the topic-document and topic-term probabilities. We split the data into test set and training set, and used the ground truth to train the topic model. The doc-topic matrix returns the probabilities of each of the 30 topics in each documents, and the term-topic matrix returns the probabilities of each word appearing under each of the 30 topics.
	+ Confusion Characters: the probabilities of mistaking one character from another character is also used in calculating the score of word candidate. For example, i and j may have higher probability to be mistaken than other character pairs. Our confusion matrix included not only alphabet pairs but also numeric&symbol pairs and the dimension is 110*110.
	+ Candidate Score: Words that have the same length and no more then 2 different characters to a word to are the candidates of this word. The score of a candidate is the probability of this word in this document (doc-topic * topic-term), plus the summation of the probabilities of confusing character pairs. To avoid prob = 0, a small bias(1+e5) is added to probabilities calculated by topic model.
	
+ Performance Measurement
	+ Step 1:find unique words in two texts separately. The unique words have to be intersected(only the ones that appear in both texts are used).
	+ Step 2: Use unique words as anchors to split each segment into smaller ones
	+ Step 3: Delete unique words from all segments (delete the first and the last word in every segments)
	+ Step 4: use Lenshtein distance to calculate the number of incorrect characters in every segments
	+ Step 5: calculate precision and recall 

	
**Contribution statement**: 
+ Error Detection
	+ Cai, Yang (Implemented error detection method with rule based technique)
	+ Yu, Wenting (Implemented error detection method with rule based technique)
+ Error Correction
	+ Cui, Jiayi (Built term-doc frequency matrix and LDA model, generated topic-document-word probilities and reproduced final documents)
	+ Yang, Yang (Complete confusion probability matrix with fuzzy matching preprocessing, Design score architecture, Speed up fetching with new [pythondict-like Data Structure](https://github.com/jokerkeny/Dict-for-R) by 200 times, Speed up candidate generator 50 times, also Prune the candidate)
	+ Wang, Nannan (Generate all word candidates,Computing word candidate scores and substituting/Presenter)
+ Performance Measurement
	+ Cai, Yang (Implemented RETAS Algorithm to measure the performance of detection method)
	+ Cui, Jiayi (Computed error correction performance)

**References**:
+ Kulp, Scott, and April Kontostathis. On Retrieving Legal Files: Shortening Documents and Weeding Out Garbage        webpages.ursinus.edu/akontostathis/KulpKontostathisFinal.pdf
+ Yalniz, Ismet & Manmatha, R. (2011). A Fast Alignment Scheme for Automatic OCR Evaluation of Books. Proceedings of the International Conference on Document Analysis and Recognition, ICDAR. 754 - 758. 10.1109/ICDAR.2011.157. 

Following [suggestions](http://nicercode.github.io/blog/2013-04-05-projects/) by [RICH FITZJOHN](http://nicercode.github.io/about/#Team) (@richfitz). This folder is orgarnized as follows.

```
proj/
├── lib/
├── data/
├── doc/
├── figs/
└── output/
```

Please see each subfolder for a README file.
