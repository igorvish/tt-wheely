#
# (c) https://gist.github.com/j05h/673425
#
# Подсчет расстояния между точками на идеальной сфере.
#
module HaversineFormula

  GREAT_CIRCLE_RADIUS_KILOMETERS = 6371 # some algorithms use 6367
  POSTGRES_EARTHDISTANCE_RADUIS_KILOMETERS = 6378.168
  RAD_PER_DEG = Math::PI / 180

  module_function

    # loc1 and loc2 are arrays of [latitude, longitude]
    def distance_m(loc1, loc2)
      lat1, lon1 = loc1
      lat2, lon2 = loc2
      dLat = (lat2-lat1) * RAD_PER_DEG;
      dLon = (lon2-lon1) * RAD_PER_DEG;
      a = Math.sin(dLat/2) * Math.sin(dLat/2) +
        Math.cos(lat1 * RAD_PER_DEG) * Math.cos(lat2 * RAD_PER_DEG) *
        Math.sin(dLon/2) * Math.sin(dLon/2);
      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
      d = POSTGRES_EARTHDISTANCE_RADUIS_KILOMETERS * 1000.0 * c; # Multiply by 6371 to get Kilometers
    end

end
