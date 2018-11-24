---
layout: post
category: til
title: Object Serialization with Pickle and JSON in Python
tags: [Python]
comments: true
---

This is a quick little overview on how to use [pickle](https://docs.python.org/3/library/pickle.html) and [JSON](https://docs.python.org/3/library/json.html) for object serialization in Python with the [Python standard library](https://docs.python.org/3/library/).

## Object Serialization with Pickle

Pickle is used for serializing and de-serializing Python objects. This is a great way to store intermediate results while computing things. Pickling and unpickling can be done with the two functions `dump()` and `load()` respectively. The only thing you have to take care is that you open the file in binary mode. This is how you pickle your file:

```python
import pickle

with open('data.pkl', 'wb') as f:
    pickle.dump(data, f)
```
And this is how you unpickle your file:

```python
with open('data.pkl', 'rb') as f:
    data = pickle.load(f)
```

It is also possible to pickle an object to a [bytes](https://docs.python.org/3/library/stdtypes.html#bytes) sequence with the `dumps()` function:

```python
bytes_sequence = pickle.dumps(data)
```

You can get the object back with the `loads()` function:

```python
data = pickle.loads(bytes_sequence)
```

## Object Serialization with JSON

Pickle is a wonderful tool, but you won't be able to use it in other languages. This is where JSON comes in handy. Python offers out of the box a [JSON](https://docs.python.org/3/library/json.html) encoder and decoder. To store and load JSON you can use the `dump()` and `load()` functions respectively. Since they are called the same as in pickling, this makes it easy to remember them.

```python
import json

# Writing a JSON file
with open('data.json', 'w') as f:
    json.dump(data, f)

# Reading a JSON file
with open('data.json', 'r') as f:
    data = json.load(f)
```

You can additionally encode and decode JSON to a string which is done with the `dumps()` and `loads()` functions respectively. Encoding can be done like here:

```python
json_string = json.dumps(data)
```

And to decode JSON you can type:

```python
data = json.loads(json_string)
```

This comes handy when you work witk REST APIs where many APIs deal with JSON files as input and/or outputs.

# Conclusion

You have seen two common and easy ways to serialize data in Python. The Python standard library offers also many other modules to serialize data which you can explore in the [data persistence](https://docs.python.org/3/library/persistence.html) documentation. There is also a great tutorial on JSON serialization in this [article](https://realpython.com/python-json/), which covers handling JSON in further detail. Here is another great [article](https://www.datacamp.com/community/tutorials/pickle-python-tutorial) that describes pickling in more detail.
