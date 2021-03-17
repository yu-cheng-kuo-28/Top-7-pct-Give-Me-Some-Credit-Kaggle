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

Alec Stephenson • (1st in this Competition) • 9 years ago • Options • Report • Reply

The big learning experience for me is how strong a team can be if the skills of its members complement each other. Rather like an ensemble in fact. None of us would have got in the top placings as individuals.

What we basically did was extract about 25-35 features from the original dataset, and applied an ensemble of five different methods; a regression random forest, a classification random forest, a feed-forward neural network with a single hidden layer, a gradient regression tree boosting algorithm, and a gradient classification tree boosting algorithm. The neural network was a pain to implement properly but improved things by a decent amount over the bagging and boosting based elements.  


