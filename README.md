# Statistical Modelling II — Group Project

Shared workspace for the MTH6134 group project using the fictional
2023/24 Midland Premier League data.

## Current status

We have organised the original datasets and created an RStudio Project.

We are preparing to investigate how expected BMI is associated with
age and playing position, using Week 1 normal linear regression.

No analysis results or fitted models are being presented yet.
The full assessment tasks have not yet been provided, so the analysis
plan and this README will develop as the project progresses.

## What has been set up?

- The original CSV datasets are stored in `data/raw/`.
- Their contents have been preserved unchanged.
- An `.Rproj` file lets everyone open the same project structure in RStudio.
- A `.gitignore` file excludes personal RStudio settings and Mac metadata.
- The `notes` folder contains the initial BMI investigation plan.
- A `scripts` folder has been created for the R code we will write.

Our aim is to produce work that every group member can understand,
explain and reproduce.

## Repository structure

```text
Statistical-Modelling-II/
├── README.md
├── Statistical-Modelling-II.Rproj
├── .gitignore
├── data/
│   └── raw/
│       ├── league_players.csv
│       └── ashford_matches.csv
├── notes/
│   └── bmi-investigation.md
└── scripts/
```

Git does not track empty folders. The `scripts` folder will appear
on GitHub once we save a file inside it.

## The datasets

### Players: `league_players.csv`

Contains 620 players across 24 clubs, with one row per player.

| Variable | Description |
|---|---|
| team | Club name |
| position | GK, DEF, MID or FWD |
| age | Age in years |
| minutes_played | Total minutes played during the season |
| training_load | Weekly training intensity score, from 1 to 5 |
| prev_injuries | Number of injuries in the previous three seasons |
| bmi | Body mass index |
| injured | Injury during the season: 1 = yes, 0 = no |

### Matches: `ashford_matches.csv`

Contains Ashford United's 46 league fixtures, with one row per match.

| Variable | Description |
|---|---|
| home_away | Home or Away |
| goals_scored | Goals scored by Ashford United |
| goals_conceded | Goals conceded by Ashford United |
| opponent_rank | Opponent's final league rank |

All data are simulated. Players and matches are different units of
observation; the files should not simply be combined row by row.

## Software needed

Install these if they are not already available:

- [R](https://cran.r-project.org/): performs the calculations.
- [RStudio Desktop](https://posit.co/download/rstudio-desktop/):
  provides an interface for writing and running R code.
- [GitHub Desktop](https://desktop.github.com/):
  helps download and share repository changes.

You also need a GitHub account. Ask the repository owner for
collaborator access if you need to upload changes.

## First-time setup: clone the repository

Cloning downloads a local copy that remains linked to GitHub.
You only need to clone it once.

1. Open GitHub Desktop and sign in to GitHub.com.
2. Choose **File → Clone Repository**.
3. Select the **URL** tab.
4. Enter:
   `https://github.com/hajra-shafiq/Statistical-Modelling-II.git`
5. Choose where to store the repository on your computer.
6. Click **Clone**.

Each member can store their copy in a different local location.

## Open the project in RStudio

1. In GitHub Desktop, select this repository.
2. Choose **Repository → Show in Finder** on Mac,
   or **Show in Explorer** on Windows.
3. Double-click `Statistical-Modelling-II.Rproj`.
4. Check that the project name appears at the top right of RStudio.

Use this existing `.Rproj` file whenever you work on the project.
You do not need to create a new RStudio Project.

The project starts R in the repository folder, allowing us to use
the same relative file paths on different computers.

For example:

```r
players <- read.csv("data/raw/league_players.csv")
```

This tells R to look inside `data`, then `raw`, for the CSV.
Do not replace it with a personal Desktop or Downloads path.

## Before each work session: get the latest changes

1. Open GitHub Desktop.
2. Check that **Current Repository** is `Statistical-Modelling-II`.
3. Check that **Current Branch** is `main` for the shared starting version.
4. Click **Fetch origin**.
5. If **Pull origin** appears, click it.

**Fetch** checks for updates. **Pull** brings those changes into
your local copy.

If Git reports a conflict or prevents the pull, ask the group for
help before proceeding. Do not discard work to bypass the problem.

## Where to put your work

### `data/raw/`

Original supplied data. Do not manually edit or overwrite these files.
Any cleaning or transformation should be recorded in R code.

### `scripts/`

R scripts containing the commands needed to reproduce our work.
Use descriptive filenames and comments explaining important decisions.

### `notes/`

Research questions, plans, interpretations, limitations and decisions.

The initial BMI plan is in `notes/bmi-investigation.md`.

Files ending in `.md` use Markdown: plain text with simple formatting
that GitHub displays as headings, lists and tables.

## Running R code

Once scripts have been added:

1. Open the RStudio Project.
2. Open the relevant `.R` file from the `scripts` folder.
3. Read the comments and run commands in order.
4. Run a line or selected lines using:
   - **Mac:** Command + Enter
   - **Windows:** Ctrl + Enter

The script editor stores instructions.
The Console executes them and displays results.

Saving a script does not run it. Running code does not automatically
save the script.

If an error occurs, investigate it before continuing.

To check reproducibility, save your files, choose
**Session → Restart R**, then run the required scripts from the beginning.
Restarting R clears objects from memory; it does not delete saved files.

We will document script order and package requirements as work develops.

## Sharing changes through GitHub Desktop

There are three separate steps:

- **Save:** writes edits to files on your computer.
- **Commit:** records selected changes in local Git history.
- **Push:** uploads commits to GitHub for the group to access.

To share work:

1. Save your files.
2. Open **GitHub Desktop → Changes**.
3. Review each changed file.
4. Tick only the changes belonging to the work being recorded.
5. Enter a descriptive commit summary.
6. Click **Commit to main**, if working on `main`.
7. Click **Push origin**.
8. Check GitHub online to confirm the update arrived.

Example commit messages:

- `Organise original datasets into data/raw`
- `Add BMI exploration by age and position`
- `Document interpretation of BMI diagnostic plots`

Agree with the group before editing the same files.
We will agree a branch and review workflow as the project develops.

## Files we do not share

The `.gitignore` currently excludes:

- `.Rproj.user`: personal RStudio project settings.
- `.Rhistory`: local command history.
- `.RData` and `.Ruserdata`: saved R session data.
- `.DS_Store`: macOS Finder settings.

These files can remain on your computer without being committed.
The shared `.Rproj` file is included in the repository.

Never commit passwords, access tokens or other sensitive information.

## Initial investigation: BMI

**Question:** How is expected BMI associated with age and playing position?

**Unit of observation:** One player.

**Response:** BMI.

**Proposed predictors:** Age and playing position.

Planned stages:

1. Inspect variable types, missing values and plausible ranges.
2. Explore BMI, its relationship with age and differences across positions.
3. Assess an additive normal linear model.
4. Check residual patterns, variance, normality and influential observations.
5. Consider whether an age–position interaction is justified.
6. Interpret estimates and confidence intervals.
7. Distinguish predictions of a mean from predictions for an individual.
8. Record conclusions and limitations.

This is an exploratory application of Week 1 methods.
We have not established that the proposed model is suitable.

Players are grouped within clubs, which may matter for independence.
We will interpret associations without claiming causal effects.

## Working and learning together

For each analysis, record:

- What question we are asking.
- Why the chosen method is appropriate.
- What code was run.
- What the results mean.
- What checks were performed.
- Why decisions were made.
- What limitations remain.

Before each seminar, pull the latest changes and read the relevant notes.
During the session, discuss findings, questions and next steps.

Keep a brief individual contribution log alongside the shared work.
Git history records file changes, but does not capture all discussion,
reviewing, interpretation or planning.

The final report structure and selected analyses will be agreed once
the full assessment brief is available.