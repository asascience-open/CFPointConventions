#! ruby

require 'numru/netcdf'
require 'fileutils'

include NumRu

base_name = File.basename(__FILE__).gsub(".rb","")
meta_name = base_name + "/" + base_name + ".nc"
ncml_name = base_name + "/" + base_name + ".ncml"
cdl_name = base_name + "/" + base_name + ".cdl"
FileUtils.mkdir(base_name) unless File.exists?(base_name)

file = NetCDF.create(meta_name)
file.put_att("featureType","point")

o = 100
obs_dim = file.def_dim("obs",o)

lat = file.def_var("lat","float",[obs_dim])
lat.put_att("units","degrees_north")
lat.put_att("long_name","latitude of the observation")
lat.put_att("standard_name","latitude")

lon = file.def_var("lon","float",[obs_dim])
lon.put_att("units","degrees_east")
lon.put_att("long_name","longitude of the observation")
lon.put_att("standard_name","longitude")

alt = file.def_var("alt","float",[obs_dim])
alt.put_att("units","m")
alt.put_att("positive","up")
alt.put_att("axis","Z")
alt.put_att("standard_name","height")

time = file.def_var("time","int",[obs_dim])
time.put_att("long_name","time")
time.put_att("standard_name","time")
time.put_att("units","seconds since 1990-01-01 00:00:00")

temp = file.def_var("temperature","float",[obs_dim])
temp.put_att("long_name","Water Temperature")
temp.put_att("standard_name","sea_water_temperature")
temp.put_att("units","Celsius")
temp.put_att("coordinates", "time lat lon alt")

humi = file.def_var("humidity","float",[obs_dim])
humi.put_att("long_name","Humidity")
humi.put_att("standard_name","specific_humidity")
humi.put_att("units","Percent")
humi.put_att("coordinates", "time lat lon alt")

# Stop the definitions, lets write some data
file.enddef

# lat/lon/time/alt do not have to be increasing, 
# since each observation is not related to any other
lat.put(NArray.int(o).random!(180))
lon.put(NArray.int(o).random!(180))
time.put(NArray.int(o).random!(3600))
alt.put(NArray.float(o).random!(10))
temp.put(NArray.float(o).random!(40))
humi.put(NArray.float(o).random!(90))


file.close
`ncdump -h #{meta_name} > #{cdl_name}`
`ncdump -x -h #{meta_name} > #{ncml_name}`

