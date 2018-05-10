---
layout: post
category: til
title: Calculate Distance Between GPS Points in Python
tags: [GIS, Python]
image: /til/assets/NOS_162360396834.jpg
imageurl: http://nos.twnsnd.co/image/162360396834
imagesource: New Old Stock
comments: true
---

When working with [GPS](https://en.wikipedia.org/wiki/Global_Positioning_System), it is sometimes helpful to calculate distances between points. But simple [Euclidean distance](https://en.wikipedia.org/wiki/Euclidean_distance) doesn't cut it since we have to deal with a sphere, or an oblate [spheroid](https://en.wikipedia.org/wiki/Spheroid) to be exact. So we have to take a look at [geodesic](https://en.wikipedia.org/wiki/Geodesic) distances. 

There are various ways to handle this calculation problem. For example there is the [Great-circle distance](https://en.wikipedia.org/wiki/Great-circle_distance), which is the shortest distance between two points on the surface of a sphere. Another similar way to measure distances is by using the [Haversine formula](https://en.wikipedia.org/wiki/Haversine_formula), which takes the equation

\begin{equation}
    a = hav(\Delta\varphi) + cos(\varphi_1) \cdot cos(\varphi_2) \cdot hav(\Delta\lambda)
\end{equation}

with haversine function

\begin{equation}
    hav(\theta) = sin^{2}(\frac{\theta}{2})
\end{equation}

and takes this to calculate the geodesic distance

\begin{equation}
    \text{distance} = 2 \cdot R \cdot arctan(\sqrt{a}, \sqrt{1-a})
\end{equation}

where the latitude is $$ \varphi $$, the longitude is denoted as $$ \lambda $$ and $$ R $$ corresponds to [Earths mean radius](https://www.wikidata.org/wiki/Q1155470) in kilometers (`6371`). We can take this formula now and translate it into Python


```python
import math

def haversine(coord1, coord2):
    R = 6372800  # Earth radius in meters
    lat1, lon1 = coord1
    lat2, lon2 = coord2
    
    phi1, phi2 = math.radians(lat1), math.radians(lat2) 
    dphi       = math.radians(lat2 - lat1)
    dlambda    = math.radians(lon2 - lon1)
    
    a = math.sin(dphi/2)**2 + \
        math.cos(phi1)*math.cos(phi2)*math.sin(dlambda/2)**2
    
    return 2*R*math.atan2(math.sqrt(a), math.sqrt(1 - a))
```

Important to note is that we have to take the radians of the longitude and latitude values. We can take this function now and apply distances to different cities. Lets say we want to calculate the distances from London to some other cities.


```python
london_coord = 51.5073219,  -0.1276474
cities = {
    'berlin': (52.5170365,  13.3888599),
    'vienna': (48.2083537,  16.3725042),
    'sydney': (-33.8548157, 151.2164539),
    'madrid': (40.4167047,  -3.7035825) 
}

for city, coord in cities.items():
    distance = haversine(london_coord, coord)
    print(city, distance)
```

    madrid 1263769.8859593808
    vienna 1235650.1412429416
    sydney 16997984.55171465
    berlin 930723.2019867426
    

This already gives us some seemingly accurate result, but let's compare it to another method.

You can also use [geopy](https://github.com/geopy/geopy) to measure distances. This package has many different methods for calculating distances, but it uses the [Vincenty's formulae](https://en.wikipedia.org/wiki/Vincenty's_formulae) as default, which is a more exact way to calculate distances on earth since it takes into account that the earth is, as previously mentioned, an oblate spheroid. The Vincenty's formulae is well described in this [article](https://nathanrooy.github.io/posts/2016-12-18/vincenty-formula-with-python/).


```python
from geopy.distance import distance

for city, coord in cities.items():
    d = distance(london_coord, coord).m
    print(city, d)
```

    madrid 1263101.9239132649
    vienna 1238804.7757636765
    sydney 16988546.466847803
    berlin 933410.764122098
    

As you can see, there is a difference between the values, especially since we work with very large distances, which enhances the distortion of our spheroid-shaped Earth.

There is also the [pyproj](https://jswhit.github.io/pyproj/) Python package, which offers Python interfaces to [PROJ.4](http://proj4.org/). It is a great package to work with [map projections](https://en.wikipedia.org/wiki/Map_projection), but in there you have also the [Geod](https://jswhit.github.io/pyproj/pyproj.Geod-class.html) class which offers various geodesic computations. To calculate the distance between two points we use the [inv](https://jswhit.github.io/pyproj/pyproj.Geod-class.html#inv) function, which calculates an inverse transformation and returns forward and back azimuths and distance. 


```python
import pyproj

geod = pyproj.Geod(ellps='WGS84')

for city, coord in cities.items():
    lat0, lon0 = london_coord
    lat1, lon1 = coord
    
    azimuth1, azimuth2, distance = geod.inv(lon0, lat0, lon1, lat1)
    print(city, distance)
    print('    azimuth', azimuth1, azimuth2)
```

    madrid 1263101.92391795
        azimuth -166.0130675331932 11.403752336198153
    vienna 1238804.77576733
        azimuth 100.74306171242293 -66.60186399055117
    sydney 16988546.466908153
        azimuth 60.33221400668488 -40.68498881273351
    berlin 933410.764123629
        azimuth 77.79312482066598 -91.53477000281634
    

On a geographic sidenote, the forward azimuth is the direction which is defined as a horizontal angle measured clockwise from a north base line and a back azimuth is the opposite direction of the forward azimuth. You could use this information for example to sail the ocean if this is what you intend.
