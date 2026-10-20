# Week 1: BMI investigation
## Question: How is expected BMI associated with age and position?

players <- read.csv("data/raw/league_players.csv")
head(players)

## Checking how R has stored each variable

str(players)

## we need to treat playing position as categorical variable and we do this below

players$position <- factor(players$position)

## Now we check the categories and their sample sizes 

table(players$position)

## Lets now use the summary function to show whether there are any missing values in the variable we are going to use in our BMI investigation

summary(players[c("bmi","age","position")])

## From this we can see there is no NA in any of the variables we will use allowing us to continue on with this analysis


## Fitting a simple linear regression model analyzing BMI against AGE e.g E(BMI|age) = B0 + B1age

simple_model <- lm(bmi~age, data = players)

## Lets now inspect the coefficient estimates and their uncertainty

summary(simple_model)

## Therefore we can see our fitted equation for the simple model is E(BMI | age) = 23.721245 - 0.00764 * age

# Using the output from this summary we can make the following conclusions:

## Standard error: 0.01568 which is the uncertainty in that estimated slope
## t: -0.487 which is the estimate divided by its standard error 
## p: 0.626 which is the result of testing H0:B1 = 0
## Residual standard error: 1.509 which is the estimated error standard deviation, in BMI units
## Residual degrees of freedom: 618 which makes sense as its 620 players minus the 2 estimated coefficients

# Therefore our interpretation using solely the summary function for the simple model would be:

## for one year increase in age our model suggest we would expect a -0.00764 in expected BMI for a player.
## We can also say that with a p-value of 0.626 we would fail to reject H0:B1 = 0 at a 5% significance level.
## and we can also calculate a 95% confidence interval for B1 (age) as follows.

confint(simple_model,"age",0.95)

## which we can also see includes 0 within it supporting what we said earlier about being unable to reject H0


# The two qualifications that matter here are as follows:
## This does not prove that age is unrelated to BMI. We have assessed a linear association in an age only model.

## Next lets plot BMI against age and add the fitted line

plot(bmi~age,data = players, xlab = "Age (years)", ylab = "BMI", main = "BMI against age")

# Now add the fitted line using our simple model we created earlier

abline(simple_model, col = "blue", lwd = 2)

## What we can conclude from this visually:

# Mean relationship: no strong upward or downward trend, and no obvious clear curve.
# Spread: no obvious widening funnel. There are fewer players at the youngest and oldest ages, so their apparent spread is harder to judge
# Unusual observations: some players lie far above or below the line. That warrants investigation later; it does not automatically make them errors.

# Visually we can see it is consistent with the small estimated slope and large p-value.
# We can also use the R^2  we found early being 0.0003838 to state that the age only model explains approximately 0.038% of the observed variation in BMI.


# From the analysis above we can see that our age only model is not very good.

# As a result next we will investigate playing position as our age only model ignores position.

# Before we add position lets first explore whether BMI distribution appears different across the four positions.
# we shall compare the observed BMI distributions across playing positions

boxplot(
  bmi~position,
  data = players,
  xlab = "Playing position",
  ylab = "BMI",
  main = "BMI by playing position"
)

# From this boxplot forwards appear to have the highest median BMI

# We can also draw three other useful observation:
# - The median differences look relatively small
# - The boxes overlap considerable, so position does not neatly seperate individual players BMIs.
# - The spreads look broadly similar, although we'll assess variance more carefully using model diagnostics.



# Our next step is going to be to fit the additive model that includes position too. Using GK as the reference category:
# E(BMI|age, position) = B0 + B1*age + B2*Idef + B3*Ifwd + B4*Imid
# Each indicator equals 1 when the player has that position and 0 otherwise
# This model assumes one common age slope across all position and position differences that are constant across ages

# First we will set up the reference category explicitly using GK as the reference category

players$position <-relevel(players$position, ref = "GK")

# The use of relevel() changes which category R uses for comparisons. It does not change the observations or the model's possible fitted values.
# We can check the order of the categories using levels()
levels(players$position)



# Now lets fit and inspect the additive model
# Allow position differences while assuming a common age slope, in the formula we use + which allows us to include age and position without an interaction.
additive_model <- lm(bmi~age + position, data = players)

summary(additive_model)

# now we have a simple model and an additive model our next stpe should to answer the question below
# Does position contribute to modelling expected BMI after accounting for age?

# In order to do this we must compare the reduced simple model and the full additive model

# Our null hypothesis is:
# H0: Bdef = Bfwd = Bmid = 0 
# H1: at least one is non zero

# to do this we must jointly assess position after accounting for age

anova(simple_model, additive_model)

# This table shows us:

# Res.Df: residual degrees of freedom.
# RSS: residual sum of squares for each model.
# Df: the three additional coefficients.
# Sum of Sq: the reduction in RSS from adding position
# F and Pr(>F): the joint test statistic and p-value

# This differs from the F-test at the bottom of summary(additive_model): that compared age and position together against an intercept-only model.

# Our interpretation is since our P-value is 0.3646 > 0.05 (testing at 5% sig level):
# There is insufficient evidence that adding position improves the model for expected BMI after accounting for age.


# IMPORTANT:
# A lower RSS alone does not justify adding predictors:
# extra predictors can improve the fit to random variation.
# This test does not prove that position differences are zero.
# We still need to check model assumptions before trusting the test.


# Key distinction is the additive model fits these observations slightly more closely, but the improvement is not large enough relative. to the remaining variation to provide evidence for the three extra position coefficients.

# Our next step is to check whether the model assumptions make this comparison trustworthy

# Inspect residuals for problems with the mean structure or variance

plot(additive_model, which = 1)


# How to read what we see:
# The residuals-versus-fitted plot shows a roughly flat smooth
# line near zero, with no obvious curvature or funnel pattern.
# There is no clear visual evidence here of a misspecified mean
# relationship or nonconstant variance.
# Some large residuals warrant further investigation.



# Next lets check normality:
# Assess whether the residual distributions are approximately normal ( By producing a normal QQ plot)

plot(additive_model, which = 2)

# Residuals follow the normal Q-Q reference line closely,
# with minor departures in the tails.
# The plot supports the approximate normality assumption.


# Next lets investigate influence
# we can see that rows 3, 474 and 184 have appeared because of their large residuals. But a large residual does not necessarily mean an observation strongly changes the fitted model.
# cooks distance assesses how much the fitted values would change if an observation were removed

# Identifying observations that may strongly affect the fitted model

plot(additive_model, which = 4)

# From this we can see rows 220, 59 and 571 have the largest Cooks distances. These are the observations whose removal would have the greatest effect on this fitted model, according to this diagnostic.
# Horizontal axis: Player row number
# Vertical axis: Cooks distance
# Taller spikes: greater influence on the fitted model.

# We should notice how these differ from the rows labelled on the residual plots. INFLUENCE DEPENDS ON BOTH THE RESIDUAL AND LEVERAGE.


# Applying the guidelines provides in week 1

# Our lecture notes suggest investigating Cook's distances above 8/n-2p
# Here, n = 620 and p = 5, incl intercept 

8/(620-10)

# we can see that several observations appear above that level. This is an INVESTIGATION GUIDELINE NOT A DELETION RULE.

# Calculate Cook's distances and the Week 1 investigation threshold
cook <- cooks.distance(additive_model)

n <- nobs(additive_model)
p <- additive_model$rank
cutoff <- 8 / (n - 2 * p)

# Add the threshold to the existing Cook's distance plot
abline(h = cutoff, col = "red", lty = 2)

# Identify observations above the threshold
flagged <- which(cook > cutoff)
flagged

# Here which() returns the row numbers meeting the condition


# Now lets inspected the flagged players
# Indexing means before the comma ( select the rows in flagged), After the comma (select the four named columns)

players[flagged, c("team","position", "age", "bmi")]

# We know Cook's distance combines residual size and leverage. That explain why a player can influential without having the largest residual overall
# Lets examine both these ingredients together (Influential & Residual)

# Examine residual size, leverage and influence for flagged players
data.frame(
  row = flagged,
  position = players$position[flagged],
  age = players$age[flagged],
  bmi = players$bmi[flagged],
  studentised_residual = rstudent(additive_model)[flagged],
  leverage = hatvalues(additive_model)[flagged],
  cooks_distance = cook[flagged]
)

# Studentised residual: how unusual the response is relative to its fitted mean, allowing for it estimated variability
# Leverage: how unusual the predictor combination is within this model
# Cook's distance: their combined effect the fit 

# Our week 1 leverage guideline is 2p/n

(2*5)/620


# Next we will run a SENSITIVITY CHECK to determine how much do these ten observations collectively affect our estimated associations?

# we do this by temporarily fitting the same model without the ten flagged players, then compare it with the full-data model

# Sensitivity analysis only: temporarily omit flagged observations
sensitivity_model <- lm(
  bmi ~ age + position,
  data = players[-flagged, ]
)

# Compare coefficient estimates
cbind(
  full_data = coef(additive_model),
  sensitivity = coef(sensitivity_model)
)

# SENSITIVITY CHECK: WHAT HAVE WE LEARNED?
#
# We temporarily omitted the 10 players flagged by Cook's distance
# and fitted the same additive model again.
# This did not change the original dataset.

# The age coefficient changed very little:
# from -0.00843 to -0.00892 BMI units per year.
# The estimated age association remains small and negative.

# The position differences relative to goalkeepers increased:
# DEF: from 0.198 to 0.297 BMI units.
# FWD: from 0.368 to 0.444 BMI units.
# MID: from 0.132 to 0.245 BMI units.
# Their directions stayed the same.

# Six omitted players were goalkeepers. Changes to the estimated
# goalkeeper mean can affect all three position comparisons.

# CONCLUSION:
# The estimated age slope is relatively insensitive to jointly
# omitting these players. The position estimates show some sensitivity.
# We have not yet checked whether confidence intervals or
# hypothesis-test conclusions change.

# We retain all players in the main analysis because these
# diagnostic flags alone do not justify deleting observations.


# Next is to finish the sensitivity check:
# We know how the coefficient estimates changed. Now we'll check their uncertainty and whther the joint conclusion about position changes.


# Compare uncertainty about the age coefficient
confint(additive_model, "age")
confint(sensitivity_model, "age")

# Fit an age-only model on the same sensitivity sample
sensitivity_age <- lm(
  bmi ~ age,
  data = players[-flagged, ]
)

# Test position jointly within that sensitivity sample
anova(sensitivity_age, sensitivity_model)

# SENSITIVITY CHECK: DOES POSITION CONTRIBUTE AFTER ACCOUNTING FOR AGE?
anova(sensitivity_age, sensitivity_model)

# Both models use the same 610 players, temporarily excluding
# the 10 observations flagged by Cook's distance.
#
# Model 1 contains age only.
# Model 2 contains age and position.
#
# Adding position introduces 3 coefficients and reduces RSS
# from 1289.3 to 1281.1.
#
# H0: all three position coefficients are zero.
# H1: at least one position coefficient is nonzero.
#
# The joint F-test gives F = 1.2982 and p = 0.2741.
# Since p > 0.05, we do not reject H0 at the 5% level.
#
# There is insufficient evidence that position improves the
# age-only model in this sensitivity sample.
#
# The full-data test gave p = 0.3646. Although the p-value changed,
# the conclusion at the 5% level did not.
# Therefore, this particular conclusion is unchanged by jointly
# omitting the 10 flagged players.
#
# This does not prove that position differences are absent.
# We retain all players in the main analysis: an influence flag
# alone is not a reason to delete an observation.


























































































