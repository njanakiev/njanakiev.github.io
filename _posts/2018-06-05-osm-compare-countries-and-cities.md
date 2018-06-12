---
layout: post
category: blog
title: Compare Countries and Cities with OpenStreetMap and t-SNE
tags: [OpenStreetMap, Overpass API, GIS, Python]
image: /assets/NOS_135192661848.jpg
imageurl: http://nos.twnsnd.co/image/135192661848
imagesource: New Old Stock
comments: true
---

There are many ways to compare countries and cities and many measurements to choose from. We can see how they perform economically, or how their demographics differ, but what if we take a look at data available in [OpenStreetMap](https://www.openstreetmap.org/)? In this article we explore just that with the help of a procedure called t-SNE.

In the previous article [How to Predict Economic Indicators with OpenStreetMap]({{ site.baseurl }}{% link _posts/2018-05-15-osm-predict-economic-indicators.md
 %}) we explored how to use the amenities found in [OpenStreetmap](https://www.openstreetmap.org/) (OSM) for different countries to predict economic indicators. In this article we will continue and take a closer look at how to use the amenity distributions to compare and cluster countries and cities. All the code used for this and the previous article can be found in this [repository](https://github.com/njanakiev/osm-predict-economic-measurements).

# Understanding the Data

The data we are looking at, consists of the number of various amenities for countries in the european union (EU) and member states of the european free trade association (EFTA). 

OSM is structured in nodes, ways and relations, which describe the geometry. These [elements](https://wiki.openstreetmap.org/wiki/Elements) of OSM can have tags giving us additional information about the geometry, which are stored as key-value pairs. We are interested in tags with the [amenity](https://wiki.openstreetmap.org/wiki/Key:amenity) key which tags different community facilities such as _university_, _school_, _restaurant_, _atm_ and various others. We have selected the top 50 amenities listed in [taginfo](https://taginfo.openstreetmap.org/keys/amenity#values), and we have then collected the counts for these amenities within the country border for our selected countries.


```python
import pandas as pd
import matplotlib.pyplot as plt

plt.style.use('ggplot')
%matplotlib inline


# Get population
df_population = pd.read_csv('data/economic_measurements.csv', index_col='country')
df_population = df_population[['Population']]

# Get amenity counts
df_amenity = pd.read_csv('data/country_amenity_counts.csv')
df_amenity.set_index('country', inplace=True)
df_amenity.drop(columns='country_code', inplace=True)

# Replace 0 values with 0.1 (important for logarithmic representation)
df_amenity = df_amenity.applymap(lambda x: 0.1 if x == 0 else float(x))

# Normalize amenities of each country by their population
df_amenity_normalized = df_amenity.apply(
    lambda row: row / df_population['Population'].loc[row.name], axis=1)

df_amenity.head()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>parking</th>
      <th>place_of_worship</th>
      <th>school</th>
      <th>bench</th>
      <th>restaurant</th>
      <th>fuel</th>
      <th>cafe</th>
      <th>fast_food</th>
      <th>bank</th>
      <th>waste_basket</th>
      <th>...</th>
      <th>waste_disposal</th>
      <th>marketplace</th>
      <th>bus_station</th>
      <th>university</th>
      <th>college</th>
      <th>parking_entrance</th>
      <th>swimming_pool</th>
      <th>theatre</th>
      <th>taxi</th>
      <th>veterinary</th>
    </tr>
    <tr>
      <th>country</th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>Belgium</th>
      <td>33209.0</td>
      <td>6644.0</td>
      <td>5936.0</td>
      <td>15257.0</td>
      <td>7549.0</td>
      <td>2414.0</td>
      <td>2496.0</td>
      <td>3441.0</td>
      <td>2529.0</td>
      <td>9439.0</td>
      <td>...</td>
      <td>80.0</td>
      <td>124.0</td>
      <td>79.0</td>
      <td>520.0</td>
      <td>248.0</td>
      <td>430.0</td>
      <td>408.0</td>
      <td>333.0</td>
      <td>79.0</td>
      <td>370.0</td>
    </tr>
    <tr>
      <th>Bulgaria</th>
      <td>4978.0</td>
      <td>1964.0</td>
      <td>1686.0</td>
      <td>372.0</td>
      <td>2828.0</td>
      <td>1437.0</td>
      <td>1353.0</td>
      <td>710.0</td>
      <td>925.0</td>
      <td>72.0</td>
      <td>...</td>
      <td>68.0</td>
      <td>182.0</td>
      <td>222.0</td>
      <td>162.0</td>
      <td>51.0</td>
      <td>56.0</td>
      <td>84.0</td>
      <td>121.0</td>
      <td>193.0</td>
      <td>81.0</td>
    </tr>
    <tr>
      <th>Czech Republic</th>
      <td>29815.0</td>
      <td>8010.0</td>
      <td>3768.0</td>
      <td>14759.0</td>
      <td>10271.0</td>
      <td>2580.0</td>
      <td>2057.0</td>
      <td>2069.0</td>
      <td>1291.0</td>
      <td>2424.0</td>
      <td>...</td>
      <td>335.0</td>
      <td>98.0</td>
      <td>444.0</td>
      <td>280.0</td>
      <td>487.0</td>
      <td>352.0</td>
      <td>118.0</td>
      <td>374.0</td>
      <td>65.0</td>
      <td>290.0</td>
    </tr>
    <tr>
      <th>Denmark</th>
      <td>32094.0</td>
      <td>2620.0</td>
      <td>2249.0</td>
      <td>4168.0</td>
      <td>2840.0</td>
      <td>1810.0</td>
      <td>3067.0</td>
      <td>6780.0</td>
      <td>682.0</td>
      <td>1122.0</td>
      <td>...</td>
      <td>100.0</td>
      <td>49.0</td>
      <td>219.0</td>
      <td>181.0</td>
      <td>126.0</td>
      <td>263.0</td>
      <td>18.0</td>
      <td>178.0</td>
      <td>131.0</td>
      <td>65.0</td>
    </tr>
    <tr>
      <th>Germany</th>
      <td>403687.0</td>
      <td>62159.0</td>
      <td>38465.0</td>
      <td>333044.0</td>
      <td>94386.0</td>
      <td>17898.0</td>
      <td>28377.0</td>
      <td>31867.0</td>
      <td>25452.0</td>
      <td>61599.0</td>
      <td>...</td>
      <td>2054.0</td>
      <td>1494.0</td>
      <td>1842.0</td>
      <td>2624.0</td>
      <td>1188.0</td>
      <td>8359.0</td>
      <td>120.0</td>
      <td>2596.0</td>
      <td>4054.0</td>
      <td>3417.0</td>
    </tr>
  </tbody>
</table>
<p>5 rows × 50 columns</p>
</div>



This is an excerpt of our data set. In the next parallel coordinates plot we can see all of the amenties for all of the countries.


```python
from pandas.plotting import parallel_coordinates

plt.figure(figsize=(16, 9))
plt.xticks(rotation=90, fontsize=12)
plt.yticks(fontsize=12)
plt.grid(False)
ax = parallel_coordinates(df_amenity_normalized.reset_index(), 'country', colormap='summer')
ax.set_yscale('log')
plt.legend(fontsize=10);
```


![png]({{ site.baseurl }}/assets/osm_compare_countries_and_cities_files/output_4_0.png)


We can't quite make ourself an image from this, but it gives us a rough overview how the data is distributed. Let's now have a look how we can reduce the dimensionality to explore the relationship between the countries.

## Principal Component Analysis

One important and extremely valuable procedure for dimensionality reduction is the [Principal Component Analysis](https://en.wikipedia.org/wiki/Principal_component_analysis) (PCA). The aim is to reduce dimensionality while retaining as much of the variance as possible. This is done by finding the list of principal axes in the data by using [Sngular Value Decomposition](https://en.wikipedia.org/wiki/Singular_value_decomposition) (SVD) to project the data to a lower dimensional space. The first principal component describes most of the variance in the data, and the following principal components are sorted by largest variance in descending order. The dimensionality reductions works by setting the smallest principal components to zero which results in a lower dimensional projection while preserving maximal variance in the data.

If you want to continue to explore the PCA, the excerpt [In Depth: Principal Component Analysis](https://jakevdp.github.io/PythonDataScienceHandbook/05.09-principal-component-analysis.html) by Jake VanderPlas is a great applied tutorial on PCA and Victor Powell made a great [interactive guide](http://setosa.io/ev/principal-component-analysis/) to get an visual intuition for PCA.


```python
from sklearn.decomposition import PCA

X = df_amenity_normalized.values
pca = PCA(n_components=2)
X_pca = pca.fit_transform(X)

fig, ax = plt.subplots(figsize=(16, 12))
ax.plot(X_pca[:, 0], X_pca[:, 1], 'o', color='C1')
for i, country in enumerate(df_amenity_normalized.index):
    ax.annotate(country, (X_pca[i, 0] + 0.00005, X_pca[i, 1] + 0.00005), fontsize=14, alpha=0.7)
    
ax.margins(0.08)
```


![png]({{ site.baseurl }}/assets/osm_compare_countries_and_cities_files/output_6_0.png)


We can already see some possible relationships by proximity of the countries like some of the Scandinavian countries or some of the German-speaking countries. We can also see some countries that are seemingly unrelated like Iceland.

It is important to note that PCA relies on the assumption that there are linear correlations in the data set. This makes it difficult when the data is not linearly correlated (e.g. as a donut shape, spiral shape). This leads us to a different set of procedures, namely manifold learning.

## Manifold Learning

Manifold learning, also considered non-linear dimensionality reduction is an approach to reduce the dimensions of a data set which then can be used for example to visualize the data in two or three dimensions. This is done by searching for a low dimensional embedding within the high dimensional space. This can help with data compression, reverse or deal with the curse of dimensionality, de-noising, visualization and even for a reasonable distance metric within a high dimensional geometry.

## t-distributed Stochastic Neighbor Embedding

A popular approach from manifold learning is the t-distributed Stochasitc Neighbor Embedding (t-SNE) introduced by van der Maaten and Hinton in their paper [Visualizing Data using t-SNE](https://lvdmaaten.github.io/publications/papers/JMLR_2008.pdf) from 2008. It is used for embedding high-dimensional data into a low-dimensional space such as two or three dimensions. It aims to iteratively reduce the distance between similar points and increase the distance between dissimilar points.

It is important to consider and test the hyperparameters when using t-SNE. One such hyperparameter is the perplexity which balances local and global relationships in the data, and is related to the number of nearest neighbors that are used. Typical values that can be explored are between 5 and 50. The other hyperparameters are the learning rate and the number of steps, which control the convergence of the algorithm.

To delve deeper into t-SNE, there is a wonderful article on [How to use t-SNE effectively](https://distill.pub/2016/misread-tsne/) by Wattenberg, et al. which gives an intuitive explanation of the use of t-SNE. It is also important to note that t-SNE has been shown to be unreliable for clustering, as it does not preserve distance. 


```python
from sklearn.manifold import TSNE

X = df_amenity_normalized.values

tsne = TSNE(n_components=2, learning_rate=400, perplexity=5)
X_embedded = tsne.fit_transform(X)

fig, ax = plt.subplots(figsize=(16, 12))
ax.plot(X_embedded[:, 0], X_embedded[:, 1], 'o', color='C1')
for i, country in enumerate(df_amenity_normalized.index):
    ax.annotate(country, (X_embedded[i, 0] + 15, X_embedded[i, 1] + 15), fontsize=14, alpha=0.7)

ax.margins(0.1)
ax.tick_params(left=False, bottom=False, labelleft=False, labelbottom=False)
```


![png]({{ site.baseurl }}/assets/osm_compare_countries_and_cities_files/output_8_0.png)


We can see again that Scandinavian countries like to be close to each other, as well as German-speaking countries. Another cluster of similar countries is formed by the Netherlands, Belgium, France and the Czech Republic. Poland, Estonia, Lithuania, Latvia and Portugal seem to be also similar in their distribution of amenities.

There are many other nonlinear dimensionality reduction techniques, many of which are covered by scikit-learn. They also have a great introduction for the various techniques in their [manifold learning](http://scikit-learn.org/stable/modules/manifold.html) section.

# Comparing Cities

After comparing countries, let's take a look if cities from two countries differ in their composition of amenities. For this we collected the number of amenities in the same way as before on the countries, but this time we counted the amenities within each city polygon. The two countries we aim to compare are Germany and France.


```python
df = pd.read_csv('data/city_amenities_counts.csv')

df_pop = df['population']

mask = (df['country'] == 'Germany') | (df['country'] == 'France')
df_subset = df[mask]
df_pop_subset = df_pop[mask]

# Select subset with amenities
X = df_subset.loc[:, 'parking':'veterinary']
# Replace every 0 value with 0.1
X = X.applymap(lambda x: float(0.1 if x == 0 else x))
# Normalize values with population
X_normalized = X.apply(lambda row: row / df_pop_subset[row.name], axis=1)

y = df_subset['country'].map({'Germany':0, 'France':1})
X.head()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>parking</th>
      <th>place_of_worship</th>
      <th>school</th>
      <th>bench</th>
      <th>restaurant</th>
      <th>fuel</th>
      <th>cafe</th>
      <th>fast_food</th>
      <th>bank</th>
      <th>waste_basket</th>
      <th>...</th>
      <th>waste_disposal</th>
      <th>marketplace</th>
      <th>bus_station</th>
      <th>university</th>
      <th>college</th>
      <th>parking_entrance</th>
      <th>swimming_pool</th>
      <th>theatre</th>
      <th>taxi</th>
      <th>veterinary</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>12</th>
      <td>7188.0</td>
      <td>693.0</td>
      <td>1163.0</td>
      <td>8836.0</td>
      <td>4062.0</td>
      <td>328.0</td>
      <td>2145.0</td>
      <td>2098.0</td>
      <td>443.0</td>
      <td>2655.0</td>
      <td>...</td>
      <td>84.0</td>
      <td>65.0</td>
      <td>7.0</td>
      <td>97.0</td>
      <td>81.0</td>
      <td>218.0</td>
      <td>1.0</td>
      <td>178.0</td>
      <td>379.0</td>
      <td>96.0</td>
    </tr>
    <tr>
      <th>13</th>
      <td>6380.0</td>
      <td>426.0</td>
      <td>626.0</td>
      <td>3635.0</td>
      <td>1839.0</td>
      <td>235.0</td>
      <td>810.0</td>
      <td>860.0</td>
      <td>357.0</td>
      <td>584.0</td>
      <td>...</td>
      <td>67.0</td>
      <td>40.0</td>
      <td>13.0</td>
      <td>86.0</td>
      <td>12.0</td>
      <td>319.0</td>
      <td>0.1</td>
      <td>79.0</td>
      <td>146.0</td>
      <td>69.0</td>
    </tr>
    <tr>
      <th>14</th>
      <td>3928.0</td>
      <td>368.0</td>
      <td>441.0</td>
      <td>4906.0</td>
      <td>1850.0</td>
      <td>143.0</td>
      <td>715.0</td>
      <td>685.0</td>
      <td>320.0</td>
      <td>1660.0</td>
      <td>...</td>
      <td>31.0</td>
      <td>33.0</td>
      <td>4.0</td>
      <td>95.0</td>
      <td>19.0</td>
      <td>737.0</td>
      <td>29.0</td>
      <td>59.0</td>
      <td>189.0</td>
      <td>59.0</td>
    </tr>
    <tr>
      <th>15</th>
      <td>2875.0</td>
      <td>447.0</td>
      <td>407.0</td>
      <td>2024.0</td>
      <td>1125.0</td>
      <td>146.0</td>
      <td>456.0</td>
      <td>496.0</td>
      <td>219.0</td>
      <td>1107.0</td>
      <td>...</td>
      <td>14.0</td>
      <td>23.0</td>
      <td>3.0</td>
      <td>85.0</td>
      <td>23.0</td>
      <td>235.0</td>
      <td>0.1</td>
      <td>48.0</td>
      <td>103.0</td>
      <td>27.0</td>
    </tr>
    <tr>
      <th>16</th>
      <td>1385.0</td>
      <td>259.0</td>
      <td>228.0</td>
      <td>977.0</td>
      <td>1128.0</td>
      <td>79.0</td>
      <td>348.0</td>
      <td>332.0</td>
      <td>167.0</td>
      <td>263.0</td>
      <td>...</td>
      <td>28.0</td>
      <td>10.0</td>
      <td>3.0</td>
      <td>65.0</td>
      <td>6.0</td>
      <td>141.0</td>
      <td>0.1</td>
      <td>36.0</td>
      <td>56.0</td>
      <td>11.0</td>
    </tr>
  </tbody>
</table>
<p>5 rows × 50 columns</p>
</div>



Let's take a look again at the parallel coordinates plot to get a sense of the data.


```python
from pandas.plotting import parallel_coordinates

df_plot = pd.concat([X_normalized, df_subset['country']], axis=1)

plt.figure(figsize=(16, 9))
plt.xticks(rotation=90, fontsize=12)
plt.yticks(fontsize=12)
plt.grid(False)
ax = parallel_coordinates(df_plot, 'country', colormap='summer', alpha=0.8)
ax.set_yscale('log')
plt.legend(fontsize=10);
```


![png]({{ site.baseurl }}/assets/osm_compare_countries_and_cities_files/output_12_0.png)


We can already see differences between German and French cities for amenities like _hunting stand_, _vending machine_, _telephone_, _bench_ and a few others. Now we will apply again dimensionality reduction to our data set to see whether any relationships are visible.

## PCA Dimensionality Reduction


```python
pca = PCA(n_components=2)
X_pca = pca.fit_transform(X_normalized.values)

plt.figure(figsize=(16, 12))
plt.plot(X_pca[y == 0][:, 0], X_pca[y == 0][:, 1], 'r.', label='Germany')
plt.plot(X_pca[y == 1][:, 0], X_pca[y == 1][:, 1], 'b.', label='France')
plt.legend(fontsize=10, loc='upper left');
plt.title('PCA of Amenity Distribution')
plt.xlabel('First Principal Component')
plt.ylabel('Second Principal Component')

for i, country_idx in enumerate(df_subset.index):
    country = df.iloc[country_idx]['city']
    color = 'r' if y.iloc[i] == 0 else 'b'
    plt.annotate(country, (X_pca[i, 0] + 0.00002, X_pca[i, 1] + 0.00002), fontsize=10, alpha=0.4, color=color)
    
plt.margins(0.07)
```


![png]({{ site.baseurl }}/assets/osm_compare_countries_and_cities_files/output_14_0.png)


Here we already can see that German and French cities seem to exhibit differences based on their amenity distribution.

## T-SNE Dimensionality Reduction


```python
tsne = TSNE(n_components=2, learning_rate=1000, perplexity=10)
X_embedded = tsne.fit_transform(X_normalized.values)

plt.figure(figsize=(16, 12))
plt.plot(X_embedded[y == 0][:, 0], X_embedded[y == 0][:, 1], 'r.', label='Germany')
plt.plot(X_embedded[y == 1][:, 0], X_embedded[y == 1][:, 1], 'b.', label='France')
plt.title('T-SNE of Amenity Distribution')
plt.legend(fontsize=10, loc='upper left');

for i, country_idx in enumerate(df_subset.index):
    country = df.iloc[country_idx]['city']
    color = 'r' if y.iloc[i] == 0 else 'b'
    plt.annotate(country, (X_embedded[i, 0] + 0.00002, X_embedded[i, 1] + 0.00002), fontsize=10, alpha=0.4, color=color)

plt.margins(0.1)
plt.tick_params(left=False, bottom=False, labelleft=False, labelbottom=False)
```


![png]({{ site.baseurl }}/assets/osm_compare_countries_and_cities_files/output_17_0.png)


We can see that cities of the same country are close to each other, but not exclusively. This could mean that some cities share certain similiarities, while others are more distinctively German or French in their amenity distribution.

# Conclusion

We saw in this article how to compare countries and cities by using their amenities derived from OpenStreetMap. There are many paths to continue exploring. It might be worth exploring other algorithms from [manifold learning](http://scikit-learn.org/stable/modules/manifold.html). It might be interesting to extend this analysis to other countries (Keep in mind that OSM is not equally well annotated on the globe). By using the cities it might be possible to find some sort of centroid for a country which describes the country in the most distinctive way. Further, the amenity distributions might be used as feature vectors for classification of countries or cities.

All the code used for this and the previous article can be found in this [repository](https://github.com/njanakiev/osm-predict-economic-measurements). The previous article [How to Predict Economic Indicators with OpenStreetMap]({{ site.baseurl }}{% link _posts/2018-05-15-osm-predict-economic-indicators.md
 %}) covers more details on how the data was collected and other comparisons in the data. In the notebook on [graphical structure](https://github.com/njanakiev/osm-predict-economic-measurements/blob/master/graphical-structure-amenities.ipynb), the amenities are additionally compared by correlation and graphical structure by using the Graphical Lasso algorithm.
