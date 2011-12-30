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

p = 6
o = 0  #UNLIMITED

obs_dim = file.def_dim("obs",o)
profile_dim = file.def_dim("profile",p)

lat = file.def_var("lat","sfloat",[profile_dim])
lat.put_att("units","degrees_north")
lat.put_att("long_name","station latitude")
lat.put_att("standard_name","latitude")

lon = file.def_var("lon","sfloat",[profile_dim])
lon.put_att("units","degrees_east")
lon.put_att("long_name","station longitude")
lon.put_att("standard_name","longitude")

profile = file.def_var("profile","int",[profile_dim])
profile.put_att("cf_role", "profile_id")

parent = file.def_var("parentIndex","int",[obs_dim])
parent.put_att("long_name", "index of profile")
parent.put_att("instance_dimension", "profile")

time = file.def_var("time","int",[profile_dim])
time.put_att("long_name","time of measurement")
time.put_att("standard_name","time")
time.put_att("units","seconds since 1990-01-01 00:00:00")

alt = file.def_var("z","sfloat",[obs_dim])
alt.put_att("long_name","height above mean sea level")
alt.put_att("standard_name","altitude")
alt.put_att("units","m")
alt.put_att("positive","up")
alt.put_att("axis","Z")

temp = file.def_var("temperature","sfloat",[obs_dim])
temp.put_att("long_name","Air Temperature")
temp.put_att("standard_name","air_temperature")
temp.put_att("units","Celsius")
temp.put_att("coordinates", "time lat lon z")

humi = file.def_var("humidity","sfloat",[obs_dim])
humi.put_att("long_name","Humidity")
humi.put_att("standard_name","specific_humidity")
humi.put_att("units","Percent")
humi.put_att("coordinates", "time lat lon z")

# Stop the definitions, lets write some data
file.enddef

lat.put(NArray.int(p).random!(180))
lon.put(NArray.int(p).random!(180))

#time.put(NArray.int(100).random!(3600), "start" => [0], "end" => [99])
time.put(NArray.int(p).indgen!*3600)

# We define the parent indexes here.  Six profiles, and a total of with 100 observations.
# This maps the observations to the profile (which has a lat/lon/time)
#     1:  10 obs
#     2:   6 obs
#     3:   2 obs
#     4:  40 obs
#     5:  30 obs
#     6:  12 obs
# total: 100 obs
first =  NArray.int(10).fill!(1).to_a
second = NArray.int(6).fill!(2).to_a
third =  NArray.int(2).fill!(3).to_a
fourth = NArray.int(40).fill!(4).to_a
fifth =  NArray.int(30).fill!(5).to_a
sixth =  NArray.int(12).fill!(6).to_a

parent.put(first + second + third + fourth + fifth + sixth, "start" => [0], "end" => [99])

# could do it this way, but be more verbose so it is more easily understood what is happening.
#alt.put(NArray.float(100).random!(40))
alt.put(NArray.float(10).random!(10).sort, "start" => [0], "end" => [9])
alt.put(NArray.float(6).random!(10).sort, "start" => [10], "end" => [15])
alt.put(NArray.float(2).random!(10).sort, "start" => [16], "end" => [17])
alt.put(NArray.float(40).random!(10).sort, "start" => [18], "end" => [57])
alt.put(NArray.float(30).random!(10).sort, "start" => [58], "end" => [87])
alt.put(NArray.float(12).random!(10).sort, "start" => [88], "end" => [99])

temp.put(NArray.float(100).random!(40))
humi.put(NArray.float(100).random!(90))


file.close
`ncdump -h #{meta_name} > #{cdl_name}`
`ncdump -x -h #{meta_name} > #{ncml_name}`
