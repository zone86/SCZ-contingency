setwd('C:/Users/nija/Documents/useData/patients')
library('hBayesDM')

# fit example data with the bandit2arm_delta model and run posterior predictive check
patientModel = bandit2arm_delta(data = "respTablePatient.txt", 
                           niter = 3000, 
                           nwarmup = 1000, 
                           nchain = 4,
                           ncore = 4,
                           adapt_delta = .99,
                           max_treedepth = 15,
                           inc_postpred = TRUE)

# dimension of x$parVals$y_pred
dim(x$parVals$y_pred)   # y_pred --> ... (MCMC samples) x ... (subjects) x ... (trials)

y_pred_mean = apply(x$parVals$y_pred, c(2,3), mean)  # average of 4000 MCMC samples

dim(y_pred_mean)  # y_pred_mean --> ... (subjects) x ... (trials)

numSubjs = dim(x$allIndPars)[1]  # number of subjects

subjList = unique(x$rawdata$subjID)  # list of subject IDs
maxT = max(table(x$rawdata$subjID))  # maximum number of trials
true_y = array(NA, c(numSubjs, maxT)) # true data (`true_y`)

# true data for each subject
for (i in 1:numSubjs) {
  tmpID = subjList[i]
  tmpData = subset(x$rawdata, subjID == tmpID)
  true_y[i, ] = tmpData$keyPressed  # only for data with a 'choice' column
}

# Subject #1
plot(true_y[1, ], type="l", xlab="Trial", ylab="Choice (0 or 1)", yaxt="n")
lines(y_pred_mean[1,], col="red", lty=2)
axis(side=2, at = c(0,1) )
legend("bottomleft", legend=c("True", "PPC"), col=c("black", "red"), lty=1:2)