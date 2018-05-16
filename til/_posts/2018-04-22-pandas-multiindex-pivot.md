---
layout: post
category: til
title: Working with MultiIndex and Pivot Tables in Pandas
tags: [Pandas, Python]
comments: true
---

Here we'll take a look at how to work with MultiIndex or also called Hierarchical Indexes in Pandas and Python on real world data. 

The data set we will be using is from the [World Bank Open Data](https://data.worldbank.org/) which we can access with the [wbdata](http://github.com/OliverSherouse/wbdata) module by Oliver Sherouse via the World Bank API. To see how to work with wbdata and how to explore the available data sets, take a look at their [documentation](http://wbdata.readthedocs.io/en/latest/). Let's say we want to take a look at the Total Population, the GDP per capita and GNI per capita for each country. We can load this data in the following way.


```python
import matplotlib.pyplot as plt
plt.style.use('ggplot')
import pandas as pd
import wbdata
%matplotlib inline

countries = ['ES', 'FR', 'DE', 'GB', 'IT']

indicators = {'SP.POP.TOTL':'Population', 
              'NY.GDP.PCAP.PP.CD':'GDP per capita',
              'NY.GNP.MKTP.PP.CD':'GNI per capita'}

df = wbdata.get_dataframe(indicators=indicators, country=countries)
df.head()
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
      <th></th>
      <th>GDP per capita</th>
      <th>GNI per capita</th>
      <th>Population</th>
    </tr>
    <tr>
      <th>country</th>
      <th>date</th>
      <th></th>
      <th></th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th rowspan="5" valign="top">Germany</th>
      <th>2017</th>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>2016</th>
      <td>48860.525292</td>
      <td>4.098523e+12</td>
      <td>82487842.0</td>
    </tr>
    <tr>
      <th>2015</th>
      <td>47810.836011</td>
      <td>3.977536e+12</td>
      <td>81686611.0</td>
    </tr>
    <tr>
      <th>2014</th>
      <td>47092.488372</td>
      <td>3.888973e+12</td>
      <td>80982500.0</td>
    </tr>
    <tr>
      <th>2013</th>
      <td>45232.197853</td>
      <td>3.730249e+12</td>
      <td>80645605.0</td>
    </tr>
  </tbody>
</table>
</div>



This already gives us a [MultiIndex](https://pandas.pydata.org/pandas-docs/stable/advanced.html) (or hierarchical index). A MultiIndex enables us to work with an arbitrary number of dimensions while using the low dimensional data structures [Series](https://pandas.pydata.org/pandas-docs/stable/generated/pandas.Series.html) and [DataFrame](https://pandas.pydata.org/pandas-docs/stable/generated/pandas.DataFrame.html) which store 1 and 2 dimensional data respectively. Before we look into how a MultiIndex works lets take a look at a plain DataFrame by resetting the index with [reset_index](https://pandas.pydata.org/pandas-docs/stable/generated/pandas.DataFrame.reset_index.html) which removes the MultiIndex. Additionally we want to convert the date column to integer values.


```python
df.reset_index(inplace=True)
df['date'] = df['date'].astype(int)
df.head()
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
      <th>country</th>
      <th>date</th>
      <th>GDP per capita</th>
      <th>GNI per capita</th>
      <th>Population</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>Germany</td>
      <td>2017</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>1</th>
      <td>Germany</td>
      <td>2016</td>
      <td>48860.525292</td>
      <td>4.098523e+12</td>
      <td>82487842.0</td>
    </tr>
    <tr>
      <th>2</th>
      <td>Germany</td>
      <td>2015</td>
      <td>47810.836011</td>
      <td>3.977536e+12</td>
      <td>81686611.0</td>
    </tr>
    <tr>
      <th>3</th>
      <td>Germany</td>
      <td>2014</td>
      <td>47092.488372</td>
      <td>3.888973e+12</td>
      <td>80982500.0</td>
    </tr>
    <tr>
      <th>4</th>
      <td>Germany</td>
      <td>2013</td>
      <td>45232.197853</td>
      <td>3.730249e+12</td>
      <td>80645605.0</td>
    </tr>
  </tbody>
</table>
</div>




```python
df.index
```




    RangeIndex(start=0, stop=340, step=1)



Here we can see that the DataFrame has by default a [RangeIndex](https://pandas.pydata.org/pandas-docs/stable/generated/pandas.RangeIndex.html). However this index is not very informative as an identification for each row, therefore we can use the [set_index](https://pandas.pydata.org/pandas-docs/stable/generated/pandas.DataFrame.set_index.html) function to choose one of the columns as an index. We can do this for the `country` index by `df.set_index('country', inplace=True)`. This would allow us to select data with the [loc](https://pandas.pydata.org/pandas-docs/stable/generated/pandas.DataFrame.loc.html) function.

How can we benefit from a MultiIndex? If we take a loot at the data set, we can see that we have for each country the same set of dates. In this case it would make sense to structure the index hierarchically, by having different dates _for each_ country. This is where the MultiIndex comes to play. Now, in order to set a MultiIndex we need to choose these two columns by by setting the index with `set_index`.


```python
df.set_index(['country', 'date'], inplace=True)
df.head()
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
      <th></th>
      <th>GDP per capita</th>
      <th>GNI per capita</th>
      <th>Population</th>
    </tr>
    <tr>
      <th>country</th>
      <th>date</th>
      <th></th>
      <th></th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th rowspan="5" valign="top">Germany</th>
      <th>2017</th>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>2016</th>
      <td>48860.525292</td>
      <td>4.098523e+12</td>
      <td>82487842.0</td>
    </tr>
    <tr>
      <th>2015</th>
      <td>47810.836011</td>
      <td>3.977536e+12</td>
      <td>81686611.0</td>
    </tr>
    <tr>
      <th>2014</th>
      <td>47092.488372</td>
      <td>3.888973e+12</td>
      <td>80982500.0</td>
    </tr>
    <tr>
      <th>2013</th>
      <td>45232.197853</td>
      <td>3.730249e+12</td>
      <td>80645605.0</td>
    </tr>
  </tbody>
</table>
</div>



That was it! Now let's take a look at the MultiIndex.


```python
df.index.summary()
```




    'MultiIndex: 340 entries, (Germany, 2017) to (Italy, 1950)'




```python
df.index.names
```




    FrozenList(['country', 'date'])



We can see that the MultiIndex contains the tuples for `country` and `date`, which are the two hierarchical levels of the MultiIndex, but we could use as many levels as there are columns available. We can take also take a look at the levels in the index.


```python
df.index.levels
```




    FrozenList([['France', 'Germany', 'Italy', 'Spain', 'United Kingdom'], [1950, 1951, 1952, 1953, 1954, 1955, 1956, 1957, 1958, 1959, 1960, 1961, 1962, 1963, 1964, 1965, 1966, 1967, 1968, 1969, 1970, 1971, 1972, 1973, 1974, 1975, 1976, 1977, 1978, 1979, 1980, 1981, 1982, 1983, 1984, 1985, 1986, 1987, 1988, 1989, 1990, 1991, 1992, 1993, 1994, 1995, 1996, 1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017]])



# Using the MultiIndex

We saw how the MultiIndex is structured and now we want to see what we can do with it. In order to access the DataFrame via the MultiIndex we can use the familiar [loc](https://pandas.pydata.org/pandas-docs/stable/generated/pandas.DataFrame.loc.html) function. (As an overview on indexing in Pandas take a look at [Indexing and Selecting Data](https://pandas.pydata.org/pandas-docs/stable/indexing.html))


```python
df.loc['Germany', 2000]
```




    GDP per capita    2.729377e+04
    GNI per capita    2.228952e+12
    Population        8.221151e+07
    Name: (Germany, 2000), dtype: float64



We can also slice the DataFrame by selecting an index in the first level by `df.loc['Germany']` which returns a DataFrame of all values for the country Germany and leaves the DataFrame with the date column as index.


```python
df_germany = df.loc['Germany']
df_germany.head()
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
      <th>GDP per capita</th>
      <th>GNI per capita</th>
      <th>Population</th>
    </tr>
    <tr>
      <th>date</th>
      <th></th>
      <th></th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>2017</th>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>2016</th>
      <td>48860.525292</td>
      <td>4.098523e+12</td>
      <td>82487842.0</td>
    </tr>
    <tr>
      <th>2015</th>
      <td>47810.836011</td>
      <td>3.977536e+12</td>
      <td>81686611.0</td>
    </tr>
    <tr>
      <th>2014</th>
      <td>47092.488372</td>
      <td>3.888973e+12</td>
      <td>80982500.0</td>
    </tr>
    <tr>
      <th>2013</th>
      <td>45232.197853</td>
      <td>3.730249e+12</td>
      <td>80645605.0</td>
    </tr>
  </tbody>
</table>
</div>



We can use this DataFrame now to visualize the GDP per capita and GNI per capita for Germany.


```python
df_germany[['GDP per capita', 'GNI per capita']].plot(figsize=(12, 12), subplots=True, layout=(2, 1));
```


![png]({{ site.baseurl }}/til/assets/pandas_multiindex_pivot_files/output_18_0.png)


# Pivot Tables

Now, let's say we want to compare the different countries along their population growth. One way to do so, is by using the [pivot](https://pandas.pydata.org/pandas-docs/stable/generated/pandas.DataFrame.pivot.html) function to reshape the DataFrame according to our needs. In this case we want to use date as the index, have the countries as columns and use population as values of the DataFrame. This works straight forward as follows.


```python
df_pivot = df.reset_index()
df_pivot = df_pivot.pivot(index='date', columns='country', values='Population')
df_pivot.head()
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
      <th>country</th>
      <th>France</th>
      <th>Germany</th>
      <th>Italy</th>
      <th>Spain</th>
      <th>United Kingdom</th>
    </tr>
    <tr>
      <th>date</th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>1950</th>
      <td>42600338.0</td>
      <td>68376002.0</td>
      <td>46366767.0</td>
      <td>28069737.0</td>
      <td>50616012.0</td>
    </tr>
    <tr>
      <th>1951</th>
      <td>42809772.0</td>
      <td>68713920.0</td>
      <td>46786118.0</td>
      <td>28236442.0</td>
      <td>50631571.0</td>
    </tr>
    <tr>
      <th>1952</th>
      <td>43123100.0</td>
      <td>69086530.0</td>
      <td>47171699.0</td>
      <td>28427994.0</td>
      <td>50706811.0</td>
    </tr>
    <tr>
      <th>1953</th>
      <td>43501503.0</td>
      <td>69483349.0</td>
      <td>47522671.0</td>
      <td>28637153.0</td>
      <td>50829901.0</td>
    </tr>
    <tr>
      <th>1954</th>
      <td>43916298.0</td>
      <td>69897556.0</td>
      <td>47841004.0</td>
      <td>28858741.0</td>
      <td>50991454.0</td>
    </tr>
  </tbody>
</table>
</div>



Important to note is that if we do not specify the values argument, the columns will be hierarchcally indexed with a MultiIndex. With this DataFrame we can now show the population of each country over time in one plot


```python
df_pivot.plot(figsize=(16, 9), title='Population');

# Show y-axis in 'plain' format instead of 'scientific'
plt.ticklabel_format(style='plain', axis='y')
```


![png]({{ site.baseurl }}/til/assets/pandas_multiindex_pivot_files/output_22_0.png)


# Conclusion

We took a look at how MultiIndex and Pivot Tables work in Pandas on a real world example.
You can also reshape the DataFrame by using [stack](https://pandas.pydata.org/pandas-docs/stable/generated/pandas.DataFrame.stack.html) and [unstack](https://pandas.pydata.org/pandas-docs/stable/generated/pandas.DataFrame.unstack.html) which are well described in [Reshaping and Pivot Tables](https://pandas.pydata.org/pandas-docs/stable/reshaping.html). For example `df.unstack(level=0)` would have done the same thing as `df.pivot(index='date', columns='country')` in the previous example. For further reading take a look at [MultiIndex / Advanced Indexing](https://pandas.pydata.org/pandas-docs/stable/advanced.html) and [Indexing and Selecting Data](https://pandas.pydata.org/pandas-docs/stable/indexing.html) which are also great resources on this topic. Another great article on this topic is [Reshaping in Pandas - Pivot, Pivot-Table, Stack and Unstack explained with Pictures](http://nikgrozev.com/2015/07/01/reshaping-in-pandas-pivot-pivot-table-stack-and-unstack-explained-with-pictures/) by Nikolay Grozev.
