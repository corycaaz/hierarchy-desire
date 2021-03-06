# Dependencies
library(tidyverse)

# Import data
forced <- read_csv("data/forced_response.csv")
free <- read_csv("data/free_response.csv")

# SPLIT IMAGE NAMES: FORCED RESPONSE --------------------------------------

# Select only forced responses related to images
forced1 <- forced %>%
  select("id", starts_with("fc_"))

# Transform to long format
forced_long <- gather(forced1, key = "fc_question", value = "fc_selection", -id)

# Split variables and keep long format
forced_long2 <- str_split_fixed(string = forced_long$fc_selection,
                                pattern = "-",
                                n = 3) %>%
  as.data.frame() %>%
  bind_cols(forced_long) %>%
  as_tibble() %>%
  select("id", "fc_question", "fc_selection",
         "ethnicity" = "V1", "masculinity" = "V2")

# Prepare for export 
forced_long3 <- forced_long2 %>%
  # Create continuous dependent variable
  count(id, ethnicity, masculinity) %>%
  # Make levels even
  spread(key = ethnicity, value = n) %>%
  gather(key = ethnicity, value = n, -c(id, masculinity)) %>%
  spread(key = masculinity, value = n) %>%
  gather(key = masculinity, value = n, -c(id, ethnicity)) %>%
  # Are the variables even?
  arrange(id, ethnicity) %>%
  mutate(
    # Replace missing values with zero
    n = replace(n, is.na(n), 0),
    # Create factors
    ethnicity = factor(ethnicity),
    masculinity = factor(masculinity),
    # Name the response type
    response = rep("forced", n = nrow(forced_long2))
  )

# Save long format for forced responses
write_csv(forced_long3, path = "data/forced_long.csv")

# SPLIT IMAGE NAMES: FREE RESPONSE ----------------------------------------

# Select only free responses related to images, transform to long format
free_long <- free %>%
  select("id", contains("-")) %>%
  gather(key = "option", value = "choice", -id) %>%
  filter(choice != "none") %>%
  select("id", "choice")

# Split variables and keep long format
free_long2 <- str_split_fixed(string = free_long$choice,
                              pattern = "-",
                              n = 3) %>%
  as.data.frame() %>%
  bind_cols(free_long) %>%
  as_tibble() %>%
  select("id", "choice",
         "ethnicity" = "V1", "masculinity" = "V2")

# Prepare for export
free_long3 <- free_long2 %>%
  # Create continuous dependent variable
  count(id, ethnicity, masculinity) %>%
  # Make levels even
  spread(key = ethnicity, value = n) %>%
  gather(key = ethnicity, value = n, -c(id, masculinity)) %>%
  spread(key = masculinity, value = n) %>%
  gather(key = masculinity, value = n, -c(id, ethnicity)) %>%
  # Are the variables even?
  arrange(id, ethnicity) %>%
  mutate(
    # Replace missing values with zero
    n = replace(n, is.na(n), 0),
    # Create factors
    ethnicity = factor(ethnicity),
    masculinity = factor(masculinity),
    # Name the response type
    response = rep("free", n = nrow(free_long2))
  )

# Save long format for free responses
write_csv(free_long3, path = "data/free_long.csv")

