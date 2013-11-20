#! ruby

require 'numru/netcdf'
require_relative '../utils'

include NumRu

readme = \
"
http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#idp8320208

When the intention of a data variable is to contain only a single time series, the preferred
encoding is a special case of the multidimensional array representation.
"

nc = CFNetCDF.new(__FILE__, readme)
file = nc.netcdf_file
file.put_att("featureType","timeSeries")

t = 0  #UNLIMITED
name = 50

time_dim = file.def_dim("time",t)
name_dim = file.def_dim("name_strlen",name)

lat = file.def_var("lat","sfloat",[])
lat.put_att("units","degrees_north")
lat.put_att("long_name","station latitude")
lat.put_att("standard_name","latitude")

lon = file.def_var("lon","sfloat",[])
lon.put_att("units","degrees_east")
lon.put_att("long_name","station longitude")
lon.put_att("standard_name","longitude")

stationname = file.def_var("station_name","char",[name_dim])
stationname.put_att("cf_role", "timeseries_id")
stationname.put_att("long_name", "station name")

alt = file.def_var("alt","sfloat",[])
alt.put_att("long_name","vertical disance above the surface")
alt.put_att("standard_name","height")
alt.put_att("units","m")
alt.put_att("positive","up")
alt.put_att("axis","Z")

time = file.def_var("time","int",[time_dim])
time.put_att("long_name","time of measurement")
time.put_att("standard_name","time")
time.put_att("units","seconds since 1990-01-01 00:00:00")
time.put_att("missing_value",-999,"int")

temp = file.def_var("temperature","sfloat",[time_dim])
temp.put_att("long_name","Air Temperature")
temp.put_att("standard_name","air_temperature")
temp.put_att("units","Celsius")
temp.put_att("coordinates", "lat lon alt")
temp.put_att("missing_value",-999.9,"sfloat")

humi = file.def_var("humidity","sfloat",[time_dim])
humi.put_att("long_name","Humidity")
humi.put_att("standard_name","specific_humidity")
humi.put_att("units","Percent")
humi.put_att("coordinates", "lat lon alt")
humi.put_att("missing_value",-999.9,"sfloat")

# Stop the definitions, lets write some data
file.enddef

lat.put(NArray.int(1).random!(180))
lon.put(NArray.int(1).random!(180))
alt.put(NArray.int(1).random!(10))

blank = Array.new(name)

stats = ("Station-0".split(//).map!{|d|d.ord} + blank)[0..name-1]
stationname.put(stats)

time.put(NArray.int(100).indgen!*3600, "start" => [0], "end" => [99])
temp.put(NArray.float(100).random!(40))
humi.put(NArray.float(100).random!(90))

file.close
nc.create_output
