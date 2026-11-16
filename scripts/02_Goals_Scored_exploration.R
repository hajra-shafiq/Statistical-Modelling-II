
# The Question: How do Ashford United's expected goals per match compare at home and away, and does accounting for opponent rank change that comparison.

# Load the match data using a path relative to the RStudio project
matches <- read.csv("data/raw/ashford_matches.csv")

# Count the matches played at each venue by selecting the matches$home_away which is the venue column and then using table() to count how often each label appears.
table(matches$home_away)

# Calculate observed average goals per match at each venue thus 0.87 away and 1.74 at home we are just describing these fixtures.
aggregate(goals_scored ~ home_away, data = matches, FUN = mean)

# Calculate and display the mean goals per match at each venue, tapply() splits the goal counts by venue and applies mean to each group. hence calculating the same average as aggregate() the difference is that this is saved as a named object you can use in the next calculation.
# We can now select the two averages by name ["Home"] and ["Away"]
venue_means <- tapply(matches$goals_scored, matches$home_away, mean)
print(venue_means)


# How many times as many goals did Ashford average at home? thus we can say Ashford scored on average twice as many at home then away.
venue_means["Home"] / venue_means["Away"]


# Now we are fitting the Week 2 GLM factor() tells R that venue is a category. Putting "Away" first makes it the reference category.
# therefore we have just changed how R treats the labels; it doesn't change any fixture or score.
matches$home_away <- factor(
  matches$home_away, levels = c("Away", "Home")
)


# We have now fitted the GLM and saved it as the goals_model which we can reuse this fit to get estimates, intervals and diagnostics.
# goals_scored ~ home_away means we are using goals as the response and venue as the predictor, allowing one expected count for away fixtures and another for home fixtures.
# family = poisson(link = "log") means we are using a Poisson distribution and a log link this allows us to model goal counts, with the regression equation describing the log of the expected count.
# data = matches allows us to find those columns in the matches table and fit the model using the 46 fixtures we have data for.

goals_model <- glm(
  goals_scored ~ home_away,
  family = poisson(link = "log"),
  data = matches
)

# This is Week 2's three-part framework: the distribution is Poisson, the linear predictor is intercept plus a home indicator, and the link is the logarithm. The log is applied to the expected count. with goalless matches still entered into the model as zeros.


# Summary() shows the fitted coefficients, their standard errors and tests. the intercept of -0.1398 is the log of expected away goals and the home coefficient of 0.6931 and is what R adds on the log scale for a home match
summary(goals_model)

exp(coef(goals_model)["home_awayHome"])
# ["home_awayHome"] picks the home coefficient; exp() takes it back to the scale you want; the exponential poisson coefficient gives a multiplier for expected goals 

# Calculate an approximate 95% confidence interval for the goal ratio; confint.default() takes the home coefficient and its standard error and constructs a 95% Wald interval, on the log scale.
# parm tells R which coefficient you want. exp() converts both endpoints into ratios: 1.17 to 3.42.
# The reference value is. 1 because a ratio of 1 means equal expected counts. The interval excludes 1 under the model assumptions, but it is wide. So "the model estimates twice as many" is a better explanation than "we know Ashford score twice as many at home"

home_log_ci <- confint.default(goals_model, parm = "home_awayHome")
exp(home_log_ci)

# Compare observed goals with fitted goals for the eight-goal match
# fitted() returns the expected goals for each fixture under the fitted model. we save those values beside the observed scores.
# residual(..., type = "deviance") returns a signed measure of disagreement suited to this GLM. A positive value means the observed count is above the fitted count. Squaring it gives that fixture's contribution to residual deviance

matches$fitted_goals <- fitted(goals_model)
matches$deviance_residual <- residuals(goals_model, type = "deviance")


# matches[rows, columns], the part before the comma keeps rows with exactly eight goals. The part the comma selects the four columns you want to inspect.
# Row 8 showed 8 observed versus 1.74 fitted, with residual +3.45, telling us that the venue-only model fitted that observation poorly.
matches[matches$goals_scored == 8,
        c("home_away", "goals_scored", "fitted_goals", "deviance_residual")]


# Sensitivity check: refit without match 8 for comparison only
# update() fits the same formula and model family to that temporary subset, with the original matches and goals_model being unchanged. with -8 referring to the row number, not the score
goals_without_match8 <- update(goals_model, data = matches[-8, ])

# Compare the fitted home-to-away goals ratios
# Each line extracts and exponentiates the corresponding home coefficient. unname() removes Rs original coefficient label so c() can display the two numbers with labels you chose.
# We can see the ratio fell from 2.00 to 1.67. That answers a different question from the residual: the match was unusual and it changed the size of the venue estimate, although the estimate still favored home fixtures.
# This is my Week 1 influence idea carried into a GLM. 
c(
  all_matches = exp(unname(coef(goals_model)["home_awayHome"])),
  without_match8 = exp(unname(coef(goals_without_match8)["home_awayHome"]))
)


# Check dispersion for the main model using all 46 matches (we are checking the Poisson variance assumption)
# first line measures each observed-minus-fitted difference relative to the spread expected under Poisson
# the second squares and sums those differences, then divides by the residual degrees of freedom: 44 for 46 fixture and two estimated coefficients
# The last line displays the ratio, 1.28
# we are using an essential week 2 idea: a distribution specifies variation as well as a mean. Poisson assumes that the variance equals the mean given the predictors.
# A dispersion ratio around 1 is the benchmark. 1.28 suggest some extra variation, but it is a diagnostic clue, not a pass/fail rule.
pearson_residuals <- residuals(goals_model, type = "pearson")
dispersion_ratio <- sum(pearson_residuals^2) / df.residual(goals_model)
dispersion_ratio

# Compare home and away goals while accounting for opponent rank
# We keep the same matches, response, distribution and link. The only change is the formula. + opponent_rank lets expected goals vary with rank, while assuming one common home-to-away ratio at every rank.
goals_rank_model <- glm(
  goals_scored ~ home_away + opponent_rank,
  family = poisson(link = "log"),
  data = matches
)


# summary() give us two comparisons:
# Venue: e^0.69315 = 2.00. comparing home and away at the same opponent rank.
# Rank: e^0.0545 = 1.056. At the same venue, one place lower in the table-- say rank 20 rather than 19 is associated with about 5.6% higher expected goasl. Using rank as a number assumes the same multiplicative change per place throughout the table.

summary(goals_rank_model)

# Compare the home-to-away goal ratios from the two models : this block prints 2.00 unadjusted and 2.00 adjusted. The number stayed the same, but the interpretation changed: the first compares the two venues overall; the second compares them at a given rank.
c(
  unadjusted = exp(unname(coef(goals_model)["home_awayHome"])),
  adjusted_for_rank = exp(unname(coef(goals_rank_model)["home_awayHome"]))
)

# Check whether each opponent rank appears at both venues
with(matches, table(opponent_rank, home_away))
# with(matches,...) lets you refer to the columns without writing matches$ each time. The two-variable table() shows one home and one away fixture at each observed rank. This balance explains why, in this additive Poisson model, including rank leaves the home-to-away ratio unchanged, it doesn't mean rank is irrelevant to goals.



# Repeat the Pearson dispersion check for the adjusted model
rank_pearson <- residuals(goals_rank_model, type = "pearson")
rank_dispersion <- sum(rank_pearson^2) / df.residual(goals_rank_model)
rank_dispersion
# The ratio fell to 0.99, so this check shows no obvious overdispersion after adding rank. it does not test whether fixtures agaisnt the same opponent are independent.



# Test whether opponent rank improves fit after accounting for venue
anova(goals_model, goals_rank_model, test = "Chisq")

# The first model has venue only; the second adds rank. They are nested because setting the rank coefficient to zero recovers the first model. The test asks whether allowing a rank coefficient improves fit after accounting for venue.
# The deviance fell by 8.26 for one extra coefficient (good thing fits the observed matches better), giving approximate p = 0.004. This is the same nested-model reasoning you learned in Week 1 , but here you use a likelihood-ratio test.
# 0.004046 is the p-value. if rank had no association with expected goals after accounting for venue, a drop this large or larger would occur abot out 0.4% of the time, under the model assumptions and the chi-squared approximation.
# Since 0.004 < 0.05, we reject the null hypothesis that the rank coefficient is zero.

# Thus we can conclude that adding opponent rank improved the fit to the observed matches compared with the venue-only model(likelihood-ratio test: 8.26, 1df, p = 0.004)




# I used a Poisson GLM with a log link to model Ashford United’s goals per match. 
# Adding opponent rank to the venue-only model improved fit (likelihood-ratio statistic 8.26, 1 df, \(p=0.004\)). At the same venue, an opponent ranked one place lower was associated with about 5.6% higher expected goals. 
# The fitted home-to-away ratio remained 2.00 because the same opponents were played once at each venue. 
# Pearson dispersion fell from 1.28 to 0.99, so the adjusted model showed no obvious over dispersion by this check. The test assumes independent matches, which may be questionable for fixtures against the same opponent.



# 95% Wald confidence interval for the home-to-away goal ratio,
# adjusting for opponent rank
exp(confint.default(goals_rank_model, parm = "home_awayHome"))

# confint.default() uses the home coefficient and its standard error
# to calculate an approximate 95% Wald interval on the log scale.
# exp() converts both endpoints to the home-to-away goal ratio scale.
#
# At the same opponent rank, Ashford's expected goals per match
# were estimated to be 2.00 times as high at home as away
# (95% Wald confidence interval: 1.17 to 3.42).
#
# A ratio of 1 means equal expected goals at both venues.
# The interval excludes 1, giving evidence of higher expected goals
# at home under the model assumptions. The interval is wide, so
# the size of the home-away difference is uncertain.


# Conclusion
# Including opponent rank improved fit to Ashford's 46 observed
# fixtures compared with the venue-only Poisson model
# (likelihood-ratio statistic = 8.26, 1 df, p = 0.004).
# At the same venue, facing an opponent one place lower in the
# final table was associated with 5.6% higher expected goals.
# At the same opponent rank, expected goals were 2.00 times as
# high at home as away (approximate 95% Wald CI: 1.17 to 3.42).
# The adjusted model showed no obvious overdispersion
# (Pearson ratio = 0.99), but fixtures against the same
# opponent may be related. Prediction on new matches was not tested.

















