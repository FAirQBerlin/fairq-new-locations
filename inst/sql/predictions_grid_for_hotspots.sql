with latest_forecasts as (
-- Select latest forecast for each combination of x, y, and target date_time
select
	date_time,
	x,
	y,
	value
from
	model_predictions_grid_nov2021_oct2022
  where model_id = {{model_id}}
  and x in ({{x_coords}})
  -- Keep latest predictions for each combination of coordinates and date_time:
  order by date_time_forecast desc
  limit 1
  by x, y, date_time
),

day_means as (
select
	toDate(date_time) date,
	x,
	y,
	avg(value) value -- to find mean of value of that day
from
	latest_forecasts
group by
	toDate(date_time),
	x,
	y
)

select
	x,
	y,
	avg(value) avg, -- mean over all days
	max(value) max, -- max over all days
	quantile(0.9)(value) quantile_90 -- quantile over all days
from
	day_means
group by
	x,
	y
order by
	x,
	y
;
