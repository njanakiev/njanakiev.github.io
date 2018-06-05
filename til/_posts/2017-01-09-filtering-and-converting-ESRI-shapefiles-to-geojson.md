---
layout: post
category: til
title: Filtering and Converting ESRI Shapefiles to GeoJSON
tags: [GIS, ESRI Shapefile, GDAL, OGR, GeoJSON]
comments: true
---


In this example I used the data from [Natural Earth][natural earth] and I wanted to extract specific countries from the "Admin 1 – States, Provinces" data set and convert the ESRI shapefile to GeoJSON.

## How to extract specific regions or elements with certain attributes from an ESRI shapefile?

Sometimes its helpful to browse the data in some GIS editor and to look through the attributes. The attributes for the shapefile can be found in [QGIS][qgis] when loading the shapefile and by opening *Layer/Open Atribute Table*.

The shapefile can be directly filtered in [QGIS][qgis] by opening *Layer/Filter...* and by providing a filter expression. In my case I was interested in the `iso_a2` attribute in order to select a single country. The filter expression in this data set for Great Britain would be `"iso_a2" = 'GB'`.

This expression can be also used with `ogr2ogr` to extract Great Britain into another shapefile with the command

```bash
ogr2ogr -where "iso_a2 = 'GB'" gb.shp input.shp
```

## How to convert an ESRI shapefile to GeoJSON?

In order to convert a shapefile to GeoJSON you can simply use `ogr2ogr`

```bash
ogr2ogr -f "GeoJSON" output.json input.shp
```

## All in one command

Now apply the filtering and the conversion into a single step

```bash
ogr2ogr -f GeoJSON -where "iso_a2 = 'GB'" gb.json input.shp
```
Here is what the selection looks like (rendered with pycairo):

![Great Britain State and Provinces]({{ site.baseurl }}/til/assets/gb.svg)

Some other handy commands can be found in this [GDAL Cheatsheet][gdal cheatsheet].


[natural earth]: http://www.naturalearthdata.com/downloads/10m-cultural-vectors/
[qgis]: http://www.qgis.org/
[gdal cheatsheet]: https://github.com/dwtkns/gdal-cheat-sheet
