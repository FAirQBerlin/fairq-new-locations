select 
  csb.x as x, 
  csb.y as y,
  wohnnutzung as wohnnutzung,
  kfz_per_24h_pred * scaling as kfz_per_24h,
  traffic_intensity_kfz as traffic_intensity,
  density as building_density,
  nox_h_15 as nox_h,
  nox_v_gn15 as nox_v
from 
  fairq_features.coord_stadt_berlin csb
left join 
  fairq_features.traffic_model_scaling tms on csb.x = tms.x and csb.y = tms.y
left join 
  fairq_features.buildings bd on csb.x = bd.x and csb.y = bd.y
left join 
  fairq_features.land_use lu on csb.x = lu.x and csb.y = lu.y
left join 
  fairq_features.emissions em on csb.x = em.x and csb.y = em.y
left join 
  fairq_features.traffic_intensity ti on csb.x = ti.x and csb.y = ti.y;
