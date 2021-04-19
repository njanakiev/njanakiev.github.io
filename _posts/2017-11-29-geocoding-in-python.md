---
title: "Batch Geocoding with Python"
category: blog
comments: True
seo:
    date_modified: 2021-03-31
image: /assets/geocoding_in_python_files/monuments.png
imagesource: austrian-monuments-visualization
imageurl: https://github.com/njanakiev/austrian-monuments-visualization
layout: post
tags: ['GIS', 'Python']
---
You have a list of addresses, but you need to get GPS coordinates to crunch some numbers. Don't despair, there is [geocoding](https://en.wikipedia.org/wiki/Geocoding) for this and Python provides some simple means to help to deal with the APIs out there.

The title image comes from a visualization with the data of the Austrian monuments registry ([Bundesdenkmalamt Denkmalverzeichnis](https://bda.gv.at/de/denkmalverzeichnis/#oesterreich-gesamt)) where I used geocoding with ArcGIS and I visualized the data using the Python API of [Blender](https://www.blender.org/). The project can be seen in this [repository](https://github.com/njanakiev/austrian-monuments-visualization) and the code for geocoding can be found in the same repository in [geocodeplaces.py](https://github.com/njanakiev/austrian-monuments-visualization/blob/master/geocodeplaces.py).

# Google Geocoding API

One way to convert addresses is by using one of many geocoding APIs such as Google. This can be done by using the HTTP library [requests](http://docs.python-requests.org/en/master/), which can be used to access the [Google Geocoding Service](https://developers.google.com/maps/documentation/javascript/geocodinghttps://developers.google.com/maps/documentation/javascript/geocoding) as in the following snippet:


```python
import requests

url = 'https://maps.googleapis.com/maps/api/geocode/json'
r = requests.get(url, params={
    'sensor': 'false', 
    'address': 'Centre Pompidou, Paris, FR'
})

results = r.json()['results']
location = results[0]['geometry']['location']
lat, lng = location['lat'], location['lng']
```

An important thing to note for a large batch of addresses is that there are usage limits for this API (_2500 free requests per day and 50 requests per second_). If these limits are reached, the API returns `OVER_QUERY_LIMIT` response.

# Geocoder

Another way of retrieving latitude and longitude of addresses is by using the [Geocoder](https://github.com/DenisCarriere/geocoder) library which is consistent across multiple geocoding providers and quite easy to use. It also provides reverse geocoding, geocoding of IP addresses and some other handy tools which can be found in the [documentation](http://geocoder.readthedocs.io/). As for our main goal, batch geocoding with for example the [Google provider](http://geocoder.readthedocs.io/providers/Google.html) can be done in the following way:

```python
import geocoder
import time

addresses = ['Centre Pompidou, Paris, FR', 'Times Square, NY', ...]
# Use a dictionary to collect all the geocoded addresses
coords = {}

for address in addresses:
    print(address)

    # Apply some sleep to ensure to be below 50 requests per second
    time.sleep(1)

    g = geocoder.google(address)
    if coords not in address:
        if g.status == 'OK':
            coords[address] = g.latlng
        else:
            print('status: {}'.format(g.status))
```

Important to note is that for some providers and some addresses it sometimes helps to run multiple trials if `OVER_QUERY_LIMIT` or `ZERO_RESULTS` comes as a response for `g.status`. Another thing to note is that some addresses with "city" in the string might return the city centroid coordinates if the address is ambiguous. This can be easily checked if different addresses result in the same GPS coordinates. Due to the limit of the Google provider, I tend to use the [ArcGIS Provider](http://geocoder.readthedocs.io/providers/ArcGIS.html) which uses the [ArcGIS REST API](https://developers.arcgis.com/rest/geocode/api-reference/overview-world-geocoding-service.htm).

# Nominatim

Finally, it is also possible to run geocoding with OpenStreetMap data using [Nominatim](https://nominatim.org/). Here you can see how you could create a function which you can directly use to create a [GeoPandas](https://geopandas.org/) `GeoDataFrame`:

```python
import json
import time
import requests
import pandas as pd
import geopandas as gpd
import shapely.geometry

def geocode_place(place, country):
    time.sleep(1)  # keep the requests limited to 1 second
    url = 'https://nominatim.openstreetmap.org/search/{}'.format(
        place + ', ' + country)
    data = requests.get(url, params={'format': 'json'}).json()
    if data:
        # Create shapely Point geometry from lon, lat coordinates
        lon = float(data[0]['lon'])
        lat = float(data[0]['lat'])
        return shapely.geometry.Point(lon, lat)
    else:
        return None

# Read an existing table that has to contain place and country columns
df = pd.read_csv('data/places.csv')
df['geometry'] = df.apply(
    lambda row: geocode_place(row['place'], row['country']),
    axis=1)
gdf = gpd.GeoDataFrame(df, geometry='geometry', crs="EPSG:4326")
```

Since Nominatim is mainly used to power the search bar in [openstreetmap.org](https://openstreetmap.org/) it has some usage limits. Bulk geocoding of larger amounts is not permitted and should be kept under 1 request per second. For more requirements and information have a look at their [usage policy](https://operations.osmfoundation.org/policies/nominatim/). There are also some helpful resources on Nominatim in the [OpenStreetMap Wiki](https://wiki.openstreetmap.org/wiki/Nominatim).