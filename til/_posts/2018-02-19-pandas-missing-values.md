---
layout: post
category: til
title: Working with Missing Values in Pandas
tags: [Pandas, Python]
comments: true
---

Here we'll see how to work with missing values in a Pandas DataFrame on a data set from the [World Bank Open Data](https://data.worldbank.org/) of the [Global Economic Monitor](https://datacatalog.worldbank.org/dataset/global-economic-monitor).


```python
import pandas as pd

path = 'data/GemDataEXTR/Emerging Market Bond Index (JPM Total Return Index).xlsx'
df = pd.read_excel(path, sheetname='annual')

# Drop first row
df = df.iloc[1:]

# Convert index column to integer
df.index = df.index.map(int)
df.head(12)
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Argentina</th>
      <th>Bulgaria</th>
      <th>Belarus</th>
      <th>Belize</th>
      <th>Brazil</th>
      <th>Chile</th>
      <th>China</th>
      <th>Cote d'Ivoire</th>
      <th>Colombia</th>
      <th>Developing Countries</th>
      <th>...</th>
      <th>El Salvador</th>
      <th>Serbia</th>
      <th>Trinidad and Tobago</th>
      <th>Tunisia</th>
      <th>Turkey</th>
      <th>Ukraine</th>
      <th>Uruguay</th>
      <th>Venezuela, RB</th>
      <th>Vietnam</th>
      <th>South Africa</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>1990</th>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>...</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>1991</th>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>...</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>1992</th>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>...</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>1993</th>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>...</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>1994</th>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>...</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>1995</th>
      <td>82.61642</td>
      <td>120.3042</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>90.6030</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>79.44512</td>
      <td>NaN</td>
      <td>...</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>80.24534</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>1996</th>
      <td>111.72060</td>
      <td>156.6395</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>126.5848</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>95.76585</td>
      <td>NaN</td>
      <td>...</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>126.69840</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>1997</th>
      <td>140.11080</td>
      <td>249.7464</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>158.6840</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>111.81540</td>
      <td>NaN</td>
      <td>...</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>172.71890</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>1998</th>
      <td>147.66550</td>
      <td>281.3943</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>155.3104</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>133.09940</td>
      <td>NaN</td>
      <td>...</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>161.67040</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>1999</th>
      <td>154.43290</td>
      <td>305.8159</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>158.3479</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>164.19570</td>
      <td>NaN</td>
      <td>...</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>138.8067</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>173.32320</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>2000</th>
      <td>174.57410</td>
      <td>370.4026</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>202.6921</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>188.40200</td>
      <td>NaN</td>
      <td>...</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>152.3002</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>211.69040</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>2001</th>
      <td>152.42480</td>
      <td>410.3846</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>218.9289</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>213.20560</td>
      <td>NaN</td>
      <td>...</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>149.6182</td>
      <td>180.0858</td>
      <td>NaN</td>
      <td>242.96080</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
  </tbody>
</table>
<p>12 rows × 49 columns</p>
</div>



As you can see the data set is filled with quite a few `NaN` values. In order for us to work properly with the data set we will drop all rows where all values missing by using the [pandas.DataFrame.dropna](https://pandas.pydata.org/pandas-docs/stable/generated/pandas.DataFrame.dropna.html) function.


```python
df.dropna(axis=0, how='all', inplace=True)
```

We can check with Pandas how many values are still null by summing over result of the [pandas.isnull](https://pandas.pydata.org/pandas-docs/stable/generated/pandas.isnull.html) function. For the summing we use [pandas.DataFrame.sum](https://pandas.pydata.org/pandas-docs/stable/generated/pandas.DataFrame.sum.html) function to sum over an axis (by default axis 0) which returns us a [pandas.Series](http://pandas.pydata.org/pandas-docs/stable/generated/pandas.Series.html). Note that in the sum all `True` values are viewed as `1` and all `False` values as `0`. Now we can see the first 10 countries with their number of missing values.


```python
df.isnull().sum()[:10]
```




    Argentina                0
    Bulgaria                 4
    Belarus                 19
    Belize                  18
    Brazil                   0
    Chile                   18
    China                   18
    Cote d'Ivoire           18
    Colombia                 0
    Developing Countries    18
    dtype: int64



This function is also a great way to get a quick overview in which columns are missing values hidden.

Say, we want to get all the countries that have no missing values. We get those by first getting the Series with the number of each of the missing values from before and then applying a condition with the [pandas.Series.where](https://pandas.pydata.org/pandas-docs/stable/generated/pandas.Series.where.html) function followerd by dropping all the resulting countries which are `NaN`. Another way is to filter the Series is by using boolean variables `s == 0` which evaluates the whole Series if each value is equals to zero by a boolean value. This boolean Series can be then in turn used to filter the Series by applying `s[s == 0]` which does the same thing as the previous example.


```python
s = df.isnull().sum()
countries = s.where(s == 0).dropna(how='any') # eqivalent
countries = s[s == 0]                         # eqivalent
```

Finally we will plot part of the data set with the [pandas.DataFrame.plot](https://pandas.pydata.org/pandas-docs/stable/generated/pandas.DataFrame.plot.html) function and we will compare the _Emerging Market Bond Index (JPM Total Return Index)_  for all countries that have no missing values in the data set. We do that by filtering this time the DataFrame by the columns with the country names that we extracted perviously.


```python
%matplotlib inline
import matplotlib

# Specify figure size
matplotlib.rcParams['figure.figsize'] = (16, 9)

ax = df[countries.index].plot(title='Emerging Market Bond Index (JPM Total Return Index)');
ax.set_xlabel('Year');
ax.set_ylabel('JPM Total Return Index');

# Force integer labels for x-axis
ax.xaxis.set_major_locator(matplotlib.ticker.MaxNLocator(integer=True));
```


![png]({{ site.baseurl }}/til/assets/pandas_missing_values_files/output_10_0.png)

