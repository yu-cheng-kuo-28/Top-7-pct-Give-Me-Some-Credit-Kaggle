# Top-7-pct_Give-Me-Some-Credit_Kaggle
***6.82% (63/924) on private leaderboard in a closed competition in 2011***

- I did this project in 2020/06 as the final project of the *graduate level* course **"R Computing for Business Data Analytics"** of *department of MIS* in NCCU. In addition, I got ***97 (A+)*** in this course.
- Chinese reader may refer to the file **"(Chinese)Give_Me_Credit_Morton_Kuo.pdf"**, which is the orignial Chinese report, for more detialed analysis.


## (1) Introduction

- It's a [closed cometition on Kaggle in 2011](https://www.kaggle.com/c/GiveMeSomeCredit/overview). Competitors were required to predict credit deault based on an unbalanced dataset with target having (0, 1) = (93.32% , 6.68%). Therefore, the model evaluation metric was AUC.
- No.1 ~ No.3 won prizes. No.4 ~ No.11 won gold medals. No.12 ~ No.50 won silver medals. No.51 ~ No.100 won bronze medals. 
- I did this project in 2020/06 as the final project of the *graduate level* course **"R Computing for Business Data Analytics"** of *department of MIS* in NCCU. In addition, I got ***97 (A+)*** in this course.
- After thorough feature engineering, I leveraged LR, RF & XGBoost, then did a double-layer stacking. Finally, I got ***14.83% (17/924) on public leaderboard*** and ***6.82% (63/924) on private leaderboard***, which equivalent to getting a ***bronze medal*** in this long closed competition. 


## (2) Literature Review

Before we get started, let's take a close look at [recommendations from those top-tier competitors](https://www.kaggle.com/c/GiveMeSomeCredit/discussion/1166#7269).

### 2-1 Alec Stephenson • (1st in this Competition) • 9 years ago • Options • Report • Reply

The big learning experience for me is how strong a team can be if the skills of its members complement each other. Rather like an ensemble in fact. None of us would have got in the top placings as individuals.

What we basically did was extract about 25-35 features from the original dataset, and applied an ensemble of five different methods; a regression random forest, a classification random forest, a feed-forward neural network with a single hidden layer, a gradient regression tree boosting algorithm, and a gradient classification tree boosting algorithm. The neural network was a pain to implement properly but improved things by a decent amount over the bagging and boosting based elements.  

### 2-2 Xavier Conort • (2nd in this Competition) • 9 years ago • Options • Report • Reply

My big learning experience in this contest is not to trust fully the public leaderboard scores to rank models. I spent the last 16 days without any improvement in the public leaderboard while my submissions accuracy was improving against my cross validation set (and the private test set!).

I used an ensemble of 15 models including GBMs, weighted GBMs, Random Forest, balanced Random Forest, GAM, weighted GAM (all with bernoulli/binomial error), SVM and bagged ensemble of SVMs.

I haven't try to fine tune each models individually but looked for diversity of fits.  

My best score (0.89345, not in the private leaderboard as I haven't selected it in my final set) was an ensemble of 11 models which excluded the SVMs fits.

### 2-3 Shea Parkes • (5th in this Competition) • 9 years ago • Options • Report • Reply

Alright, so people were posting about best single algorithm. I won't say that these are "non-ensemble" since most of these methods are by definition ensembles themselves (randomForest, gbms, etc.)

These are obviously sensitive to our choice of data scrubbing. I don't think we did as well as occupy on that mark.

Our best randomForest was some ~8k trees large. We didn't "balance" it so we had to run a bunch to make up for that. It landed around 0.8578.

The best Neural Net landed around 0.8677

The best gbm around 0.8674

Hell, an elastic net'd glm got 0.8644

So yea, we really needed to work better on "balancing" our random forests.

This was the first contest we actually got to what's commonly called "ensembling"; i.e. combining the above algorithms. That's definitely where we hit some hiccups and spun our wheels for awhile. We pulled it out okay, but I must say finishing just out of the money is quite annoying. We can claim to be very consistent in ranking though. We didn't over or underfit much at all. Mostly that's just because we didn't put huge trust in the leaderboard (we didn't use it to tune any parameters at least.) It did steer us away from our best ensembling approach though. We still threw it in though because we'd spent so much time on it. And that helped us stick 5th place.

We've got plenty of ideas to refine for the next contest. Too bad the next pure-ish classification contest is ending in a couple weeks. I just don't want to put in that much time over the holidays.


## (3) Imbalanced Classification

![01](01_imbalanced_response.png)


## (4) Missing Value Imputation

## (5) EDA

## (6) Feature Engineering

## (7) Model Building & Feature Selection


## (8) Conclusion 



## (9) Reference

1. Zumel, N., Mount, J. (2014) Practical Data Science with R.
2. Zheng, A., Casari A. (2018). Feature Engineering for Machine Learning.
3. Ozdemir, S., Susarla, D. (2018). Feature Engineering Made Easy.
4. Online forum of the dataset “GiveMeSomeCredit”(2012). Retrieved from
https://www.kaggle.com/c/GiveMeSomeCredit/discussion
