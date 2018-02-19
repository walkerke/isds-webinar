library(tidycensus)
library(plotly)
library(ggplot2) # devtools::install_github("tidyverse/ggplot2")
library(crosstalk)
# Set your Census API key with `census_api_key()` if not already installed

tx <- get_acs(geography = "county", 
              variables = c(pctcollege = "DP02_0067P", 
                            hhincome = "DP03_0062"), 
              state = "TX", 
              geometry = TRUE, 
              output = "wide", 
              resolution = "20m")

tx_shared <- SharedData$new(tx, key = ~NAME)

scatter <- ggplot(tx_shared, aes(x = pctcollegeE, y = hhincomeE, label = NAME)) + 
  geom_point() + 
  scale_y_continuous(labels = function(x) {paste0("$", x / 1000, "k")}) + 
  labs(x = "% with bachelor's degree", 
       y = "Median household income", 
       title = "Counties in Texas (2012-2016 ACS)")

map <- ggplot(tx_shared, aes(label = NAME)) + 
  geom_sf(fill = "grey", color = "black") + 
  coord_sf(crs = 3083) # http://spatialreference.org/ref/epsg/nad83-texas-centric-albers-equal-area/

scatterly <- ggplotly(scatter, tooltip = "NAME") %>%
  layout(dragmode = "lasso") %>%
  highlight("plotly_selected", color = "red")

maply <- ggplotly(map, tooltip = "NAME") %>%
  highlight("plotly_selected", color = "red")

w1 <- bscols(scatterly, maply)

htmltools::save_html(w1, "brushing.html")