# SCZ-contingency

Data from schizophrenia patients performing the 2-armed bandit (vending machine) contingency task.

The file 'parse_contingency_file.R' script will wrangle the data from the participants' log files to create a .txt file. 

The .txt file can then be used by the 'synthData.R' file to fit a heirarchical naive bayes model with help of the 'bandit2arm_delta' function within the 'hBayesDM' package. Posterior predictive checks are included in v.0.5.0 of the 'hBayesDM' package, and the 'synthData.R' file will also check the behaviour of the model against the raw data.

The general performance folder contains a file called 'contingency results matched.xlsx', with the most suitably matched control participants to schizophrenia patients on the basis of age, gender, and education. The file contains 2 sheets: 'general', which depicts group differences in performance in terms of responses for each of the 2 sides, and the ratings of how effective an action was to produce snacks, and 'switches', which depicts the differences in the probability that a participants will stay with a particular high/low contingency response, given they were just rewarded, as well as how likely they were to stay with a high/low contingency response across the length of the block.

Finally, the patient and control folders contain the log files for all of the participants. 
