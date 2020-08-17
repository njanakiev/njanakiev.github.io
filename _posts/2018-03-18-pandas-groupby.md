---
title: "Working with Pandas Groupby in Python and the Split-Apply-Combine Strategy"
category: blog
comments: True
image: /assets/pandas_groupby_files/NOS_170539764971.jpg
imagesource: New Old Stock
imageurl: http://nos.twnsnd.co/image/170539764971
layout: post
tags: ['Pandas', 'Python']
---
In this tutorial we will cover how to use the Pandas DataFrame [groupby](https://pandas.pydata.org/pandas-docs/stable/generated/pandas.DataFrame.groupby.html) function while having an excursion to the Split-Apply-Combine Strategy for data analysis. The Split-Apply-Combine strategy is a process that can be described as a process of _splitting_ the data into groups, _applying_ a function to each group and _combining_ the result into a final data structure.

The data set we will be analysing is the [Current Employee Names, Salaries, and Position Titles](https://www.cityofchicago.org/city/en/depts/dhr/dataset/current_employeenamessalariesandpositiontitles.html) from the City of Chicago, which is listing all their employees with full names, departments, positions, and salaries. Let's get into it!


```python
%matplotlib inline

import pandas as pd
import matplotlib.pyplot as plt
plt.style.use('ggplot')

path = 'data/Current_Employee_Names_Salaries_and_Position_Titles.csv'
df = pd.read_csv(path)
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
      <th>Name</th>
      <th>Job Titles</th>
      <th>Department</th>
      <th>Full or Part-Time</th>
      <th>Salary or Hourly</th>
      <th>Typical Hours</th>
      <th>Annual Salary</th>
      <th>Hourly Rate</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>AARON,  JEFFERY M</td>
      <td>SERGEANT</td>
      <td>POLICE</td>
      <td>F</td>
      <td>Salary</td>
      <td>NaN</td>
      <td>101442.0</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>1</th>
      <td>AARON,  KARINA</td>
      <td>POLICE OFFICER (ASSIGNED AS DETECTIVE)</td>
      <td>POLICE</td>
      <td>F</td>
      <td>Salary</td>
      <td>NaN</td>
      <td>94122.0</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>2</th>
      <td>AARON,  KIMBERLEI R</td>
      <td>CHIEF CONTRACT EXPEDITER</td>
      <td>GENERAL SERVICES</td>
      <td>F</td>
      <td>Salary</td>
      <td>NaN</td>
      <td>101592.0</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>3</th>
      <td>ABAD JR,  VICENTE M</td>
      <td>CIVIL ENGINEER IV</td>
      <td>WATER MGMNT</td>
      <td>F</td>
      <td>Salary</td>
      <td>NaN</td>
      <td>110064.0</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>4</th>
      <td>ABASCAL,  REECE E</td>
      <td>TRAFFIC CONTROL AIDE-HOURLY</td>
      <td>OEMC</td>
      <td>P</td>
      <td>Hourly</td>
      <td>20.0</td>
      <td>NaN</td>
      <td>19.86</td>
    </tr>
  </tbody>
</table>
</div>



Let's take a look at what types we have in our DataFrame.


```python
df.info(memory_usage='deep')
```

    <class 'pandas.core.frame.DataFrame'>
    RangeIndex: 33183 entries, 0 to 33182
    Data columns (total 8 columns):
    Name                 33183 non-null object
    Job Titles           33183 non-null object
    Department           33183 non-null object
    Full or Part-Time    33183 non-null object
    Salary or Hourly     33183 non-null object
    Typical Hours        8022 non-null float64
    Annual Salary        25161 non-null float64
    Hourly Rate          8022 non-null float64
    dtypes: float64(3), object(5)
    memory usage: 11.6 MB


On a sidenote, `memory_usage='deep'` gives us the accurate memory usage of the DataFrame, but it can be slower to load for large DataFrames. 

Now lets see what the average _Annual Salary_ and _Hourly Rate_ is by using the [DataFrame.mean](https://pandas.pydata.org/pandas-docs/stable/generated/pandas.DataFrame.mean.html) function. (Note that _NaN_ values are ignored). And while we're at it, let's take a look at a histogram of them both with the built-in [DataFrame.hist](https://pandas.pydata.org/pandas-docs/stable/generated/pandas.DataFrame.hist.html) function.


```python
print('Average annual salary : {:8.2f} dollars'.format(df['Annual Salary'].mean()))
print('Average hourly rate   : {:8.2f} dollars'.format(df['Hourly Rate'].mean()))

df[['Annual Salary', 'Hourly Rate']].hist(figsize=(12, 6), bins=50, grid=False);
```

    Average annual salary : 86787.00 dollars
    Average hourly rate   :    32.79 dollars



![png]({{ site.baseurl }}/assets/pandas_groupby_files/output_5_1.png)


Additionally, we want to convert some of the columns into [categorical data](https://pandas.pydata.org/pandas-docs/stable/categorical.html), which will reduce the memory usage and speed up the computations in general (unless there are too many categories in a column). We can do this with [DataFrame.astype](https://pandas.pydata.org/pandas-docs/stable/generated/pandas.DataFrame.astype.html) by converting each column seperately or in one step by passing a dictionary with all columns that we want to convert.


```python
# Convert for one column
department = df['Department'].astype('category')

# Convert in one step
df = df.astype({'Department': 'category',
                'Job Titles': 'category',
                'Full or Part-Time': 'category',
                'Salary or Hourly': 'category'})
df.info(memory_usage='deep')
```

    <class 'pandas.core.frame.DataFrame'>
    RangeIndex: 33183 entries, 0 to 33182
    Data columns (total 8 columns):
    Name                 33183 non-null object
    Job Titles           33183 non-null category
    Department           33183 non-null category
    Full or Part-Time    33183 non-null category
    Salary or Hourly     33183 non-null category
    Typical Hours        8022 non-null float64
    Annual Salary        25161 non-null float64
    Hourly Rate          8022 non-null float64
    dtypes: category(4), float64(3), object(1)
    memory usage: 3.4 MB


# Introducing Group By

Let's consider you want to see what the average annual salary is for different departments. For this use case we can take advantage of the [DataFrame.groupby](https://pandas.pydata.org/pandas-docs/stable/generated/pandas.DataFrame.groupby.html) function, which is similar to the common `GROUP BY` statement in SQL.


```python
group = df.groupby('Department')
group
```




    <pandas.core.groupby.DataFrameGroupBy object at 0x7f3e633bb278>



This returns us a DataFrameGroupBy object which is our original DataFrame splitted into multiple DataFrames for each department. We can now get the DataFrame for the finance department and calculate the average annual salary there and use the same DataFrame to create another histogram.


```python
finance_df = group.get_group('FINANCE')
print('Average annual salary in finance department : {:.2f} dollars'.format(
        finance_df['Annual Salary'].mean()))

finance_df['Annual Salary'].plot(kind='hist', bins=50, figsize=(12, 6), title='Finance Department');
```

    Average annual salary in finance department : 73781.26 dollars



![png]({{ site.baseurl }}/assets/pandas_groupby_files/output_11_1.png)


Of course you could have done that by simply querying the DataFrame for the finance department with `df[df['Department'] == 'FINANCE']`, so what is the use of grouping the DataFrame then?

# Split-Apply-Combine

By using the `groupby` method, we are effectively splitting our DataFrame into multiple groups. We can then use these groups to apply various functions to each group to combine them in the end into a final data structure. 

This overall process is commonly referred as _split-apply-combine_, a method similar to [MapReduce](https://en.wikipedia.org/wiki/MapReduce), which is well described in the [pandas documentation](https://pandas.pydata.org/pandas-docs/stable/groupby.html) and in this [paper](https://www.jstatsoft.org/article/view/v040i01). We have already covered splitting and in the next step , the apply step, we have various options to consider. We can aggregate information from each group, such as group sums, means, minimum, maximum and others. We can transform each group, such as standardizing or normalizing the values within the group. And finally we can filter groups, by discarding specific groups or filtering the data within each group.

Let's continue with a simple aggregation function by calculating the mean annual salary for each department.  All we need to do is to take our previous groupby object and simply apply the `mean`function.


```python
group = df.groupby('Department')
group.mean().head()
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
      <th>Typical Hours</th>
      <th>Annual Salary</th>
      <th>Hourly Rate</th>
    </tr>
    <tr>
      <th>Department</th>
      <th></th>
      <th></th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>ADMIN HEARNG</th>
      <td>NaN</td>
      <td>78683.692308</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>ANIMAL CONTRL</th>
      <td>19.473684</td>
      <td>66197.612903</td>
      <td>24.780000</td>
    </tr>
    <tr>
      <th>AVIATION</th>
      <td>39.597967</td>
      <td>78750.549324</td>
      <td>35.633909</td>
    </tr>
    <tr>
      <th>BOARD OF ELECTION</th>
      <td>NaN</td>
      <td>53548.149533</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>BOARD OF ETHICS</th>
      <td>NaN</td>
      <td>95061.000000</td>
      <td>NaN</td>
    </tr>
  </tbody>
</table>
</div>



This returns us a DataFrame with columns as the average value within each department for all numerical columns in the DataFrame. We can combine multiple functions by the `agg` function, which gives us a column for each aggregation function and returns again a DataFrame.


```python
group.agg(['count', 'min', 'max', 'std', 'mean']).head()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead tr th {
        text-align: left;
    }

    .dataframe thead tr:last-of-type th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr>
      <th></th>
      <th colspan="5" halign="left">Typical Hours</th>
      <th colspan="5" halign="left">Annual Salary</th>
      <th colspan="5" halign="left">Hourly Rate</th>
    </tr>
    <tr>
      <th></th>
      <th>count</th>
      <th>min</th>
      <th>max</th>
      <th>std</th>
      <th>mean</th>
      <th>count</th>
      <th>min</th>
      <th>max</th>
      <th>std</th>
      <th>mean</th>
      <th>count</th>
      <th>min</th>
      <th>max</th>
      <th>std</th>
      <th>mean</th>
    </tr>
    <tr>
      <th>Department</th>
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
      <th>ADMIN HEARNG</th>
      <td>0</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>39</td>
      <td>41640.0</td>
      <td>156420.0</td>
      <td>21576.503446</td>
      <td>78683.692308</td>
      <td>0</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>ANIMAL CONTRL</th>
      <td>19</td>
      <td>10.0</td>
      <td>20.0</td>
      <td>2.294157</td>
      <td>19.473684</td>
      <td>62</td>
      <td>41832.0</td>
      <td>130008.0</td>
      <td>18803.042007</td>
      <td>66197.612903</td>
      <td>19</td>
      <td>22.88</td>
      <td>52.52</td>
      <td>6.793810</td>
      <td>24.780000</td>
    </tr>
    <tr>
      <th>AVIATION</th>
      <td>1082</td>
      <td>20.0</td>
      <td>40.0</td>
      <td>2.616414</td>
      <td>39.597967</td>
      <td>547</td>
      <td>35004.0</td>
      <td>300000.0</td>
      <td>22958.116620</td>
      <td>78750.549324</td>
      <td>1082</td>
      <td>13.00</td>
      <td>52.18</td>
      <td>8.025363</td>
      <td>35.633909</td>
    </tr>
    <tr>
      <th>BOARD OF ELECTION</th>
      <td>0</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>107</td>
      <td>27912.0</td>
      <td>133740.0</td>
      <td>25383.424530</td>
      <td>53548.149533</td>
      <td>0</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>BOARD OF ETHICS</th>
      <td>0</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>8</td>
      <td>73944.0</td>
      <td>135672.0</td>
      <td>21660.019232</td>
      <td>95061.000000</td>
      <td>0</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
  </tbody>
</table>
</div>



Let's get back to our question of getting the average annual salary for each department. In order to visualize it properly we are going to make a bar chart with decreasing average annual salary.


```python
group = df.groupby('Department')
average_salary = group['Annual Salary'].mean().sort_values(ascending=False)

# Equivalent way to get average_salary
group = df['Annual Salary'].groupby(df['Department'])
average_salary = group.mean().sort_values(ascending=False)

average_salary.plot(kind='bar', figsize=(12, 6), color='k', alpha=0.5);
```


![png]({{ site.baseurl }}/assets/pandas_groupby_files/output_17_0.png)


# Conclusion

We covered in this tutorial how to work with Pandas Group By function and how to apply the _split-apply-combine_ process to our data set by using various built-in functions. The previously mentioned [Pandas documantation](https://pandas.pydata.org/pandas-docs/stable/groupby.html) and the [Pandas Cookbook](https://pandas.pydata.org/pandas-docs/stable/cookbook.html#cookbook-grouping) on grouping covers excelent explanations and advanced examples for _split-apply-combine_ and group by to delve into. As a final bonus, sadly without using group by, here is a way to create a beautiful boxplot of the annual salary by department.


```python
import matplotlib.pyplot as plt

ax = df[['Annual Salary', 'Department']].boxplot(
                by='Department', figsize=(10, 6), rot=90);
ax.set_xlabel('');
ax.set_ylabel('Annual Salary ($$)');
ax.set_title('Annual Salary by Department');
plt.suptitle('');  # Getting rid of pandas-generated boxplot title
```


![png]({{ site.baseurl }}/assets/pandas_groupby_files/output_19_0.png)