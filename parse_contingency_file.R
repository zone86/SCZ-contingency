## import data
#setwd('useData')
path = "~/useData/patients"
outFile = NULL
files = dir(path, pattern = '.log')

for (i in 1:length(files)) {

  mydata = read.table(files[i], sep = "\t", stringsAsFactors = FALSE)
  
  time = mydata$V1
  event = mydata$V3
  timeTable = cbind(as.numeric(time, event))
  subj = substr(files[i], 1, 3)
  
  ## get rows of events of interest
  # find the row index of every left button press
  tableLeft = which(event == "Keypress: t", arr.ind = TRUE) 
  
  ## find the row index of every left button reward
  idxEarnLeft = which(event =='earn t', arr.ind = TRUE)
  
  ## find the row index of every right button press
  tableRight = which(event == 'Keypress: v', arr.ind = TRUE)
  
  ## find the row index of every right button reward
  idxEarnRight = which(event == 'earn v', arr.ind = TRUE) 
  
  ## Get index of the the beginning of the first trial 
  startTrial = which(event == 'Keypress: space', arr.ind = TRUE)
  
  ## get the row index of the block start and the block end:
  beginrow = which(event == 'end rating R', arr.ind = TRUE)
  endrow = which(event == 'start rating L', arr.ind = TRUE)
  
  ## identify rewarded trials
  idxRewRight = data.frame(rep(-1, length(tableRight)))
  
  for (i in 1:length(idxEarnRight)) {
    startrow = idxEarnRight[i]
    idx = max(which(tableRight < startrow))
    idxRewRight$rep..1..length.tableRight..[idx] = 1
  }
  
  idxRewLeft = data.frame(rep(-1, length(tableLeft)))
  
  for (i in 1:length(idxEarnLeft)) {
    startrow = idxEarnLeft[i]
    idx = max(which(tableLeft < startrow))
    idxRewLeft$rep..1..length.tableLeft..[idx] = 1
  }
  
  ## bind reward and time column to tableLeft and tableRight
  tableLeft = cbind(timeTable[tableLeft], tableLeft, idxRewLeft$rep..1..length.tableLeft..)
  tableRight = cbind(timeTable[tableRight], tableRight, idxRewRight$rep..1..length.tableRight..)
  
  ## bind response column to tableLeft and tableRight
  tableLeft = cbind(tableLeft, rep(1, nrow(tableLeft))) 
  tableRight = cbind(tableRight, rep(2, nrow(tableRight))) 
  
  ## combine left and right responses and order according with time 
  respTable = as.data.frame(rbind(as.matrix(tableLeft), as.matrix(tableRight)))
  respTable = respTable[order(respTable$V1), ]
  names(respTable) = c('time', 'row', 'rewloss', 'choice')
  
  # remove responses occurring 1 second after rewards
  rewards = subset(respTable, respTable$rewloss == 1)
  rewardStartTimes = rewards$time
  rewardEndTimes = rewards$time + 1
  removeRewards = sapply(as.matrix(respTable$time), function(x){
    idxRewardEvents = which(rewardStartTimes < x & x < rewardEndTimes)})
  idxRewRem = which(removeRewards > 0)
  
  if (length(idxRewRem >= 1)){
    respTable = respTable[-idxRewRem,]
  } else {
      respTable
    } 

  # remove responses occurring between blocks
  betweenBlocks = sapply(as.matrix(respTable$row), function(x){
    idxBlocks = which(endrow < x & x < beginrow)})
  idxBlocks = which(betweenBlocks > 0)
  respTable = respTable[-idxBlocks,]
  
  # remove responses occuring before trial start
  idxStart = which(respTable$row < startTrial)
  
  if (length(idxStart >= 1)){
    respTable = respTable[-idxStart,]
  } else {
    respTable
  }
  
  # create table for bandit2arm
  # add column for trial response count
  respTable$trial = 1:nrow(respTable)
  
  # add column for subject number
  respTable$subjID = rep(subj, nrow(respTable)) 
  
  newTable = data.frame(cbind(respTable$subjID, as.numeric(respTable$trial), as.numeric(respTable$choice), as.numeric(respTable$rewloss)))
  names(newTable) = c('subjID', 'trial', 'choice', 'outcome' )
  outFile = rbind(outFile, newTable)
}

write.table(data.frame(outFile), file = 'respTablePatient.txt', row.names = FALSE, sep = "\t")
