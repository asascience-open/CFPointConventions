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
file.put_att("featureType","profile")
file.put_att("Conventions","CF-1.6")

z = 42

z_dim = file.def_dim("z",z)

lat = file.def_var("lat","sfloat",[])
lat.put_att("units","degrees_north")
lat.put_att("long_name","station latitude")
lat.put_att("standard_name","latitude")

lon = file.def_var("lon","sfloat",[])
lon.put_att("units","degrees_east")
lon.put_att("long_name","station longitude")
lon.put_att("standard_name","longitude")

profile = file.def_var("profile","int",[])
profile.put_att("cf_role", "profile_id")

time = file.def_var("time","int",[])
time.put_att("long_name","time")
time.put_att("standard_name","time")
time.put_att("units","seconds since 1990-01-01 00:00:00")

alt = file.def_var("z","sfloat",[z_dim])
alt.put_att("units","m")
alt.put_att("standard_name","altitude")
alt.put_att("long_name","height above mean sea level")
alt.put_att("positive","up")
alt.put_att("axis","Z")
	
temp = file.def_var("temperature","sfloat",[z_dim])
temp.put_att("long_name","Water Temperature")
temp.put_att("units","Celsius")
temp.put_att("coordinates", "time lat lon z")

humi = file.def_var("humidity","sfloat",[z_dim])
humi.put_att("long_name","Humidity")
humi.put_att("standard_name","specific_humidity")
humi.put_att("units","Percent")
humi.put_att("coordinates", "time lat lon z")

# Stop the definitions, lets write some data
file.enddef

# Uniquely identifiying value for this profile.
profile.put(0)

lat.put([37.5])
lon.put([-76.5])
time.put(NArray.int(1).indgen!*3600)

alt.put(NArray.float(z).random!(10))
temp.put(NArray.float(z).random!(40))
humi.put(NArray.float(z).random!(90))

file.close
`ncdump -h #{meta_name} > #{cdl_name}`
`ncdump -x -h #{meta_name} > #{ncml_name}`
