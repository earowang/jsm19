## ---- load-flights
library(lubridate)
library(tidyverse)
library(tsibble)
library(forcats)

(flights <- read_rds("~/Research/paper-tsibble/data/flights.rds"))

## ---- try-tsibble
flights_ts <- flights %>% 
  as_tsibble(key = flight_num, index = sched_dep_datetime, regular = FALSE)

## ---- find-duplicate
flights %>% 
  duplicates(key = flight_num, index = sched_dep_datetime)

## ---- find-duplicate-lgl
dup_lgl <- are_duplicated(flights, key = flight_num, 
  index = sched_dep_datetime, from_last = TRUE)

## ---- tsibble
flights_ts <- flights %>% 
  filter(!dup_lgl) %>% 
  as_tsibble(key = flight_num, index = sched_dep_datetime, regular = FALSE)

## ---- aggregate-week
carrier_delay <- flights_ts %>% 
  group_by(carrier) %>% 
  index_by(week = ~ yearweek(.)) %>% 
  summarise_at(vars(contains("delay")), list(~ mean(.)))

## ---- select1
carrier_delay %>% 
  select(carrier, dep_delay)

## ---- select2
carrier_delay %>% 
  select_at(vars(contains("delay")))

## ---- forecast
library(fable)
library(feasts)
carrier_delay %>% 
  ggplot(aes(x = week, y = dep_delay)) +
  geom_line() +
  facet_grid(carrier ~ .)

carrier_week %>% 
  model(ets = ETS(dep_delay)) %>% 
  forecast(h = weeks(4)) %>% 
  autoplot(data = filter_index(carrier_week, "2017 Dec" ~ .), level = NULL)
