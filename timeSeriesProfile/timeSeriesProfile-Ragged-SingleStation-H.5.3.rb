#! ruby

require 'numru/netcdf'
require 'fileutils'

include NumRu

base_name = File.basename(__FILE__).gsub(".rb","")
root_path = File.dirname(__FILE__) + "/" + base_name
meta_name = root_path + "/" + base_name + ".nc"
ncml_name = root_path + "/" + base_name + ".ncml"
cdl_name = root_path + "/" + base_name + ".cdl"
FileUtils.mkdir(root_path) unless File.exists?(root_path)

file = NetCDF.create(meta_name)
file.put_att("featureType","timeSeriesProfile")
file.put_att("Conventions","CF-1.6")

p = 4
o = 10  #UNLIMITED
name = 50

profile_dim = file.def_dim("profile",p)
obs_dim = file.def_dim("obs",o)
name_dim = file.def_dim("name_strlen",name)

lat = file.def_var("lat","float",[])
lat.put_att("units","degrees_north")
lat.put_att("long_name","station latitude")
lat.put_att("standard_name","latitude")

lon = file.def_var("lon","float",[])
lon.put_att("units","degrees_east")
lon.put_att("long_name","station longitude")
lon.put_att("standard_name","longitude")

stationinfo = file.def_var("station_info","int",[])
stationinfo.put_att("long_name","station info")

stationname = file.def_var("station_name","char",[name_dim])
stationname.put_att("cf_role", "timeseries_id")
stationname.put_att("long_name", "station name")

profile = file.def_var("profile","int",[profile_dim])
profile.put_att("cf_role", "profile_id")

time = file.def_var("time","int",[profile_dim])
time.put_att("long_name","time")
time.put_att("standard_name","time")
time.put_att("units","seconds since 1990-01-01 00:00:00")

rowsize = file.def_var("row_size","int",[profile_dim])
rowsize.put_att("long_name", "number of obs in this profile")
rowsize.put_att("sample_dimension", "obs")

height = file.def_var("height","float",[obs_dim])
height.put_att("long_name","height above sea surface")
height.put_att("standard_name","height")
height.put_att("units","meters")
height.put_att("axis","Z")
height.put_att("positive","up")

temp = file.def_var("temperature","float",[obs_dim])
temp.put_att("standard_name","sea_water_temperature")
temp.put_att("long_name","Water Temperature")
temp.put_att("units","Celsius")
temp.put_att("coordinates", "time lat lon height")

# Stop the definitions, lets write some data
file.enddef

lat.put([37.5])
lon.put([-76.5])
stationinfo.put([0])
profile.put([0,1,2,3])
rowsize.put([2,2,3,3])

blank = Array.new(name)
name1 = ("Station1".split(//).map!{|d|d.ord} + blank)[0..name-1]
stationname.put([name1])

time.put( NArray.int(p).indgen!*3600)

# row_size is 2,2,3,3
heights = [0.5,1.5]  + [0.5,1.5] + [0.5,1.5,2.5] + [0.5,1.5,2.5]
temp_data = [6.7,6.9]  + [6.8,7.9] + [6.8,7.9,8.4] + [5.7,9.2,8.3]
height.put(heights)
temp.put(temp_data)


file.close
`ncdump -h #{meta_name} > #{cdl_name}`
`ncdump -x -h #{meta_name} > #{ncml_name}`
