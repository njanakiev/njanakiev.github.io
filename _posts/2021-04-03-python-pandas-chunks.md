---
title: "Reading and Writing Pandas DataFrames in Chunks"
category: blog
comments: True
image: /assets/python_pandas_chunks_files/Washington_National_Records_Center_Stack_Area_with_Employee_Servicing_Records.jpg
imagesource: Wikimedia Commons
imageurl: https://commons.wikimedia.org/wiki/File:Washington_National_Records_Center_Stack_Area_with_Employee_Servicing_Records.tif
layout: post
tags: ['Python', 'Pandas']
---
This is a quick example how to chunk a large data set with [Pandas](https://pandas.pydata.org/) that otherwise won't fit into memory. In this short example you will see how to apply this to CSV files with [pandas.read_csv](https://pandas.pydata.org/docs/reference/api/pandas.read_csv.html).

First, create a `TextFileReader` object for iteration. This won't load the data until you start iterating over it. Here it chunks the data in DataFrames with 10000 rows each:

```python
df_iterator = pd.read_csv(
    'input_data.csv.gz', 
    chunksize=10000,
    compression='gzip')
```

Now, you can use the iterator to load the chunked DataFrames iteratively. Here you have a function `do_something(df_chunk)`, that is some operation that you need to have done on the table:

```python
for i, df_chunk in enumerate(df_iterator)

    do_something(df_chunk)
    
    # Set writing mode to append after first chunk
    mode = 'w' if i == 0 else 'a'
    
    # Add header if it is the first chunk
    header = i == 0

    df_chunk.to_csv(
        "dst_data.csv.gz",
        index=False,  # Skip index column
        header=header, 
        mode=mode,
        compression='gzip')
```

By default, Pandas infers the compression from the filename. Other supported compression formats include `bz2`, `zip`, and `xz`.

# Resources

For more information on chunking, have a look at the documentation on [chunking](https://pandas.pydata.org/pandas-docs/stable/user_guide/io.html#io-chunking). Another useful tool, when working with data that won't fit your memory, is [Dask](https://dask.org/). Dask can parallelize the workload on multiple cores or even multiple machines, although it is not a drop-in replacement for Pandas and can be rather viewed as a wrapper for Pandas.