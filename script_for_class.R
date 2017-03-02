# Set working directory
setwd("/Users/Daniel/CTL/manuscripts/ROOTS/data")

# Load packages
library(tidyverse)
library(haven)
library(stringr)

# List files to load
chkptfiles <- list.files(pattern = "Checkpoints") 

# Load data
chkpt <- map(chkptfiles, ~read_spss(.))

# Name list elements
names(chkpt) <- paste0("c", 1:4)

# Select columns
chkpt <- chkpt %>% 
	map(~select(., 1, 2, starts_with("CP")) %>% 
		 filter(!is.na(ROOTS_ID)))

# Check that columns are the same across datasets
map_dbl(chkpt, ncol)

# What's different?
map(chkpt, names)

# Fix issue for first cohort
chkpt$c1 <- chkpt$c1[ ,-c(47:ncol(chkpt$c1))]

# Check that issue is fixed
map_dbl(chkpt, ncol)

# Tidy each data frame
tidy_chkpt <- chkpt %>% 
		map(~gather(., var, score, -1:-2) %>% 
				separate(var, c("checkpoint", "measure")) %>% 
				mutate(tot_poss = parse_number(measure),
				   	   checkpoint = parse_number(checkpoint),
				   	   measure = str_extract(measure, "[a-zA-Z]+"),
				   	   full_cred = ifelse(score == tot_poss, 1, 0)))

# Create cohort variable, row bind to a single data set
d <-  map2(tidy_chkpt, seq_along(tidy_chkpt), ~mutate(.x, cohort = .y)) %>% 
	map_df(rbind)

# Make variable names all lower case
names(d) <- tolower(names(d))

# Filter for only total scores ("T"), select only columns to keep, spread by
# checkpoint, and remove any rows with missing data
s_d <- d %>% 
	filter(measure == "T") %>% 
	select(1:2, 8, 3, 7) %>% 
	spread(checkpoint, full_cred) %>% 
	na.omit()

# Create pattern variable using good-ol' apply
s_d$pattern <- apply(s_d[ ,-c(1:3)], 1, paste, collapse = "-")

# Create pattern variable with tidyverse (can't get quite what I want)
# tmp <- s_d %>% 
# 	select(-1:-3) %>% 
# 	by_row(., paste, collapse = "-", 
# 		.collate = "rows", 
# 		.to = "pattern") %>%  


# Write out files for Lina
write.csv(as.data.frame(table(s_d$pattern)), "total_pats_all_cohs_v3.csv", row.names = FALSE)
write.csv(s_d, "patterns_with_ids_v2.csv", row.names = FALSE)

# Read files back in, after her columns being added
class <- read_csv("total_pats_all_cohs_v3da.csv")

# Change name of first variable so they can be merged
names(class)[1] <- "pattern"

# Merge back in with original data, remove cases with unknown patterns, select
# for relevant variables, and recode fall_off to a factor with no missing data.
td <- left_join(s_d, class, by = "pattern") %>% 
		filter(category != "U") %>% 
	   	select(1:3, 12, 14:15) %>% 
		mutate(fall_off = as.factor(ifelse(is.na(fall_off), 0, fall_off)),
			   category = as.factor(category))

# Load achievement data for all cohorts
allcoh <- read_spss("allcoh/C1C2C3C4MasterDataFile_DEIDENTIFIED.sav")

# Put column names lower case
names(allcoh) <- tolower(names(allcoh))

# Select for only achievement data, rename roots id so it can be merged
allcoh <- allcoh %>% 
	select(rts_stid, condition, student_gender, race_eth01, 
			race_eth02, esl, lep, sped, t1nsb.tot, t2nsb.tot, t1asp.cmp,
			t2asp.cmp, t1tema, t2tema, sesat_tot, stm.rs) %>% 
	rename(roots_id = rts_stid)

# Merge data
d <- left_join(td, allcoh, by = "roots_id")

# re-tidy the data
d <- d %>% 
	gather(test, score, t1nsb.tot:stm.rs) 

# code test as a factor and provide new labels for easier splitting 
# (base syntax)
d$test <- factor(d$test, 
			levels = c("t1nsb.tot", "t2nsb.tot", "t1asp.cmp", "t2asp.cmp", 
						"t1tema", "t2tema", "sesat_tot", "stm.rs"),
			labels = c("nsb_pre", "nsb_post", "asp_pre", "asp_post", 
						"tema_pre", "tema_post", "sesat", "stm"))

# Set theme globally for plots
theme_set(theme_bw())

# Create violin plots
ggplot(d, aes(category, score)) + 
	geom_violin() +
	facet_wrap(~test, 
				ncol = 4) +
	stat_summary(fun.y = "mean", 
				 color = "blue", 
				 geom = "point")

# Can't really see it. Scale variables.
d <- d %>% 
	group_by(test) %>% 
	mutate(scaled_score = scale(score))

# Check that scaling worked
d %>% 
	group_by(test) %>% 
	summarize(mean = mean(scaled_score, na.rm = TRUE),
			  stdev = sd(scaled_score, na.rm = TRUE))

# Try again: Much better, and are more comparable between measures now.
ggplot(d, aes(category, scaled_score)) + 
	geom_violin() +
	facet_wrap(~test, 
				ncol = 4) +
	stat_summary(fun.y = "mean", 
				 color = "blue", 
				 geom = "point")

# Save plot in folder one level up
ggsave("../violin_plots_allcoh.pdf")

#--------------------------- Fit preliminary models ---------------------------

# Change on-track students to the reference group
d$category <- relevel(d$category, ref = "OT")

# Fix funkiness with scaled score
str(d$scaled_score)
d$scaled_score <- as.numeric(d$scaled_score)

# Nest the data, and fit a model for each test with the category predicting
# the scaled score
by_test <- d %>% 
	group_by(test) %>% 
	nest() %>% 
	mutate(model = map(data, ~lm(scaled_score ~ category, data = .)))

# Extract coefficients
coefs <- by_test %>%
		transmute(coefs = map(model, broom::tidy, conf.int = TRUE)) %>% 
		flatten() %>% 
		map_df(rbind) %>% 
		mutate(model = rep(by_test$test, each = 5),
			   term = gsub("category", "", term)) %>% 
		filter(term != "(Intercept)")

## Plot coefficients

# Make points not overlap
pd <- position_dodge(.4)

# plot coefs
ggplot(coefs, aes(model, estimate, color = term)) + 
	geom_point(position = pd) +
	geom_errorbar(aes(ymin = conf.low, ymax = conf.high, width = .2), 
		position = pd) +
	geom_hline(yintercept = 0) +
	coord_flip()

# Save plot 
ggsave("../class_pred_out_allcoh.pdf")

# ---- Residual gain-score model ----

d2 <- d %>% 
	filter(test != "sesat" & test != "stm") %>% 
	separate(test, c("test", "occassion")) %>% 
	select(roots_id, test, category, occassion, scaled_score, fall_off) %>% 
	spread(occassion, scaled_score)

# Exploratory plot
ggplot(d2, aes(pre, post, color = category)) +
	geom_point() +
	geom_smooth(se = FALSE, method = "lm", lwd = 1.5) +
	facet_wrap(~test) +
	scale_color_brewer(palette = "Set1")

# Save plot
ggsave("../pre_post.pdf")

# Fit (multiple) models
by_test2 <- d2 %>% 
	group_by(test) %>% 
	nest() %>% 
	mutate(main_effects = map(data, 
				~lm(post ~ pre + category, data = .)),
		   interaction = map(data, 
		   		~lm(post ~ pre*category, data = .)),
		   compare = map2(main_effects, interaction, anova),
		   compare_p = map_dbl(compare, function(x) x$"Pr(>F)"[2]))

# Extract coefficients from main effects model (slightly more compact code)
coefs2 <- map(by_test2$main_effects, broom::tidy, conf.int = TRUE) %>% 
		map_df(rbind) %>% 
		mutate(model = rep(by_test2$test, each = 6),
			   term = gsub("category", "", term)) %>% 
		filter(term != "(Intercept)")

# Plot coefficients
ggplot(coefs2, aes(model, estimate, color = term)) + 
	geom_point(position = pd) +
	geom_errorbar(aes(ymin = conf.low, ymax = conf.high, width = .2), 
		position = pd) +
	geom_hline(yintercept = 0) +
	coord_flip() 

# Save plot
ggsave("../resid_gains.pdf")

# Investigate conditional means
library(visreg)

pdf("cond_res_gains.pdf")
	par(mfrow = c(3, 1), mar = c(2, 3, 1, 1), bty = "n", oma = c(2, 0, 0, 0))
	for(i in 1:3) {
		visreg(by_test2$main_effects[[i]], "category", 
				xaxt = "n", 
				ylim = c(-1, 3))
		title(main = by_test2$test[i], line = -2, cex.main = 1.5)
	}
	axis(1, 
		at = seq(-.1, 1.1, .2), 
		labels = c("", "OT", "F", "I", "R", "S", ""),
		line = 1)
dev.off()
