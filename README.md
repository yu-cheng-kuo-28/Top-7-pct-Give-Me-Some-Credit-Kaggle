# Top-7-pct_Give-Me-Some-Credit_Kaggle


Skip to content
Search or jump to…

Pull requests
Issues
Marketplace
Explore
 
@mortonkuo 
mortonkuo
/
Top-4-pct_Titanic_Kaggle
1
0
0
Code
Issues
Pull requests
Discussions
Actions
Projects
Wiki
Security
Insights
Settings
Top-4-pct_Titanic_Kaggle
/
README.md
in
main
 

Spaces

2

Soft wrap
1
# Top-4-pct_Titanic_Kaggle
2
Top 4 % (833/22219) in **[Titanic: Machine Learning from Disaster](https://www.kaggle.com/c/titanic)**, an iconic entry-level competition on Kaggle, in 2020/05. This analysis was ***conducted with R***.
3
​
4
## Outline
5
1. Ranking 
6
2. Dataset
7
3. Steps
8
4. Reproducing Outcome on Training Data Given by Kaggle
9
5. The Public Leaderboard Ranking and Score on Kaggle
10
6. Details \
11
6-1 Introduction to Features \
12
6-2 Missing Value Imputation \
13
6-3 Features Transformation \
14
6-4 Feature Extraction \
15
6-5 Model Selection 
16
​
17
## 1. Ranking 
18
​
19
![titanicLeaderBoard01](Top_4_pct_Titanic_01.png)
20
![titanicLeaderBoard02](Top_4_pct_Titanic_02.png)
21
​
22
## 2. Dataset
23
​
24
The Titanic dataset here is retrieved from Kaggle in 2020/05. Notice that **the Titanic dataset has changed now**, so my top 4% ranking in Titanic disappeared. Kaggle ***deleted the feature "Name"***, probably for ***preventing cheating***, and resampled to get the new data. 
25
​
26
## 3. Steps
27
​
28
1. Performing **10-fold** cross-validation under **3-way** split to select the best prediction model. (Doing k-fold CV in training data given by Kaggle.)
29
2. Reporting the average accuracy of cross-validation (training, validation, test in *n*-fold cross-validation).
30
3. Applying the selected model on the test data.
31
​
32
## 4. Reproducing Outcome on Training Data Given by Kaggle
33
​
34
I got a 0.89 accuracy on test data using **Random Forest** with 10-fold under 3-way split.
35
​
36
![outcome](Top_4_pct_Titanic_03.png) \
37
Run the following snippet in "Terminal" of *RStudio* to get the outcome.
38
```R
39
Rscript Titanic_Kaggle_Morton_Kuo.R --fold 5 --train Titanic_Data/train.csv --test Titanic_Data/test.csv --report performance1.csv --predict predict.csv
40
...
41
Rscript Titanic_Kaggle_Morton_Kuo.R --fold 10 --train Titanic_Data/train.csv --test Titanic_Data/test.csv --report performance6.csv --predict predict.csv
42
```
43
​
No file chosen
Attach files by dragging & dropping, selecting or pasting them.
@mortonkuo
Commit changes
Commit summary
Create README.md
Optional extended description
Add an optional extended description…

morton.kuo.28@gmail.com
Choose which email address to associate with this commit

 Commit directly to the main branch.
 Create a new branch for this commit and start a pull request. Learn more about pull requests.
 
© 2021 GitHub, Inc.
Terms
Privacy
Security
Status
Docs
Contact GitHub
Pricing
API
Training
Blog
About
