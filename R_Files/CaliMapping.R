library(tidyverse)
library(ggplot2)

scatter <- ggplot(data = CaliCrowDataZF, aes(x = longitude, y = latitude))
scatter + geom_point(na.rm= TRUE, aes(color = factor(county), size = factor(observation_count)))

