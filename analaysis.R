# Load data
data <- read.csv("data.csv")

# View the first six rows
head(data)

# Calculate the mean
mean(data$score, na.rm = TRUE)
