---
layout: post
category: blog
title: Batch Geocoding with Python
tags: [GIS, Python]
image: /assets/monuments.png
imageurl: https://github.com/njanakiev/austrian-monuments-visualization
imagesource: austrian-monuments-visualization
comments: true
---

You have a list of addresses, but you need to get GPS coordinates to crunch some numbers. Don't despair, there is [geocoding][geocoding] for this and Python provides some simple means to help dealing with the APIs out there.

One way to convert addresses is by using one of many geocoding APIs such as Google. This can be done by using the HTTP library [requests][requests], which can be used to access the [Google Geocoding Servide][geocoding google] as in the next snippet.


```python
import requests
url = 'https://maps.googleapis.com/maps/api/geocode/json'
params = {'sensor': 'false', 'address': 'Centre Pompidou, Paris, FR'}
r = requests.get(url, params=params)
results = r.json()['results']
location = results[0]['geometry']['location']
lat, lng = location['lat'], location['lng']
```

An important thing to note for a large batch of addresses is that there are usage limits for this API (_2500 free requests per day and 50 requests per second_). If these limits are reached, the API returns `OVER_QUERY_LIMIT` response.

Another way of retrieving latitude and longitude of addresses is by using the [Python Geocoder][geocoder] library which is consistent accross multiple geocoding providers and quite easy to use. It also provides reverse geocoding, geocoding of IP addresses and some other handy tools which can be found in the [documentation][geocoder docs]. As for our main goal, batch geocoding with the [Google provider][geocoder google] can be done in the following way.

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

Important to note is that for some providers and some addresses it sometimes helps to run multiple trials if `OVER_QUERY_LIMIT` or `ZERO_RESULTS` comes as an response for `g.status`. Another thing to note is that some addresses with city in the string might return the city centroid coordinates if the address is ambiguous. This can be easily checked if different addresses result in the same GPS coordinates. Due to the limit of the Google provider I tend to use the [ArcGIS Provider][geocoder arcgis] which uses the [ArcGIS REST API][arcgis rest api]. 

The title image comes from a visualization with the data of the austrian monuments registry ([Bundesdenkmalamt Denkmalverzeichnis][monuments registry]) where I used geocoding with ArcGIS and I visualized the data using the Python API of [Blender][blender]. The project can be seen in this [repository][monuments visualization] and the code for geocoding can be found in the same repository in [geocodeplaces.py][monuments geocodeplaces].


[geocoding]: https://en.wikipedia.org/wiki/Geocoding
[requests]: http://docs.python-requests.org/en/master/
[geocoding google]: https://developers.google.com/maps/documentation/javascript/geocodinghttps://developers.google.com/maps/documentation/javascript/geocoding
[geocoder]: https://github.com/DenisCarriere/geocoder
[geocoder docs]: http://geocoder.readthedocs.io/
[geocoder google]: http://geocoder.readthedocs.io/providers/Google.html
[geocoder arcgis]: http://geocoder.readthedocs.io/providers/ArcGIS.html
[arcgis rest api]: https://developers.arcgis.com/rest/geocode/api-reference/overview-world-geocoding-service.htm
[monuments registry]: https://bda.gv.at/de/denkmalverzeichnis/#oesterreich-gesamt
[monuments visualization]: https://github.com/njanakiev/austrian-monuments-visualization
[monuments geocodeplaces]: https://github.com/njanakiev/austrian-monuments-visualization/blob/master/geocodeplaces.py
[blender]: https://www.blender.org/
