select
  station_id,
  cms.station_x as station_x, 
  cms.station_y as station_y,
  cms.stadt_x as x, 
  cms.stadt_y as y,
  wohnnutzung as wohnnutzung,
  kfz_per_24h_pred * scaling as kfz_per_24h,
  traffic_intensity_kfz as traffic_intensity,
  density as building_density,
  nox_h_15 as nox_h,
  nox_v_gn15 as nox_v
from
fairq_features.coord_mapping_stadt_station cms
left join 
  fairq_features.traffic_model_scaling tms on cms.stadt_x = tms.x and cms.stadt_y = tms.y
left join 
  fairq_features.buildings bd on tms.x = bd.x and tms.y = bd.y
left join 
  fairq_features.land_use lu on bd.x = lu.x and bd.y = lu.y
left join 
  fairq_features.emissions em on bd.x = em.x and bd.y = em.y
left join 
  fairq_features.traffic_intensity ti on tms.x = ti.x and tms.y = ti.y
where station_id != '220';
