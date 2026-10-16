
# ============================================================
# Statistical Modelling II
# Data import, exploration and visualisation
# ============================================================

# 1. Clear the current R environment
rm(list = ls())

# 2. Load the CSV datasets
matches <- read.csv("ashford_matches.csv")
players <- read.csv("league_players.csv")

# 3. Display the datasets
cat("\n===== MATCH DATA =====\n")
print(head(matches))

cat("\n===== PLAYER DATA =====\n")
print(head(players))

# 4. View the datasets in RStudio
View(matches)
View(players)

# 5. Check dataset dimensions
cat("\n===== DATASET DIMENSIONS =====\n")
cat("Matches: ", nrow(matches), "rows and",
    ncol(matches), "columns\n")
cat("Players: ", nrow(players), "rows and",
    ncol(players), "columns\n")

# 6. List all variable names
cat("\n===== MATCH VARIABLES =====\n")
print(names(matches))

cat("\n===== PLAYER VARIABLES =====\n")
print(names(players))

# 7. Summarise all variables
cat("\n===== SUMMARY OF MATCH DATA =====\n")
print(summary(matches))

cat("\n===== SUMMARY OF PLAYER DATA =====\n")
print(summary(players))

# 8. Check for missing values
cat("\n===== MISSING VALUES =====\n")
cat("Missing values in matches:\n")
print(colSums(is.na(matches)))

cat("Missing values in players:\n")
print(colSums(is.na(players)))

# 9. Count duplicate rows
cat("\n===== DUPLICATE ROWS =====\n")
cat("Duplicate match rows:", sum(duplicated(matches)), "\n")
cat("Duplicate player rows:", sum(duplicated(players)), "\n")

# 10. Calculate means of numeric variables
cat("\n===== MATCH NUMERIC MEANS =====\n")
match_numeric <- matches[
  , sapply(matches, is.numeric), drop = FALSE
]

if (ncol(match_numeric) > 0) {
  print(sapply(match_numeric, mean, na.rm = TRUE))
} else {
  cat("No numeric variables found in match data.\n")
}

cat("\n===== PLAYER NUMERIC MEANS =====\n")
player_numeric <- players[
  , sapply(players, is.numeric), drop = FALSE
]

if (ncol(player_numeric) > 0) {
  print(sapply(player_numeric, mean, na.rm = TRUE))
} else {
  cat("No numeric variables found in player data.\n")
}

# 11. Plot histograms for numeric variables
if (ncol(match_numeric) > 0) {
  for (variable in names(match_numeric)) {
    values <- match_numeric[[variable]]
    values <- values[is.finite(values)]
    
    if (length(values) > 0 &&
        length(unique(values)) > 1) {
      hist(
        values,
        main = paste("Distribution of", variable, "(matches)"),
        xlab = variable,
        col = "lightblue",
        border = "white"
      )
    }
  }
}

if (ncol(player_numeric) > 0) {
  for (variable in names(player_numeric)) {
    values <- player_numeric[[variable]]
    values <- values[is.finite(values)]
    
    if (length(values) > 0 &&
        length(unique(values)) > 1) {
      hist(
        values,
        main = paste("Distribution of", variable, "(players)"),
        xlab = variable,
        col = "lightgreen",
        border = "white"
      )
    }
  }
}

# 12. Save summary tables as CSV files
write.csv(
  as.data.frame(summary(matches)),
  "match_summary.csv"
)

write.csv(
  as.data.frame(summary(players)),
  "player_summary.csv"
)

cat("\n===== ANALYSIS COMPLETE =====\n")

