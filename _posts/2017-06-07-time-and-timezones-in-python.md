---
layout: post
title: Working with Time and Time Zones in Python
tags: [Python]
image: /assets/MET_2094.jpg
imageurl: http://www.metmuseum.org/art/collection/search/2094
imagesource: Metropolitan Museum of Art
comments: true
---


Time conversions can be tedious, but Python offers some relief for the frustration. Here are some quick recipes which are quite useful when juggling with time.


## Parse Timestamps to UTC

Imagine you get logged timestamps in a certain format like `2017-05-30T23:51:03Z` which is commonly referred as [ISO 8601][iso_8601]. You know that the time zone is Europe/Paris or [Central European Time][cet] (UTC+01:00) and you want to normalize the timestamp to [UTC][utc]. This can be done by using the pyhton [datetime][datetime] object as follows

```python
import datetime
import pytz

timestring = "2017-05-30T23:51:03Z"

# Create datetime object
d = datetime.datetime.strptime(timestring, "%Y-%m-%dT%H:%M:%SZ")
print(d.tzinfo) # Return time zone info
print(d.strftime("%d.%m.%y %H:%M:%S"))

# Set the time zone to 'Europe/Paris'
d = pytz.timezone('Europe/Paris').localize(d)
print(d.tzinfo) # Return time zone info
# Transform the time to UTC
d = d.astimezone(pytz.utc)
print(d.tzinfo) # Return time zone info
print(d.strftime("%d.%m.%y %H:%M:%S"))
```

with the result

```
None
30.05.17 23:51:03
Europe/Paris
UTC
30.05.17 21:51:03
```

where `strptime()` translates the formated time string to a datetime object by using [format codes][strftime] and where `strftime()` translates the datetime object back to a String represented by a format string consisting of the same format codes. The [pytz][pytz] module is helpful for working with time zones. What is also important to mention is that due to [Daylight Saving Time][dst], the time zone Europe/Paris for this timestamp is [Central European Summer Time][cest] (UTC+02:00), which can be seen in the time difference in the result. This [Computerphile video][computerphile] illustrates how painful time zones can get.


## Working with Unix Timestamps

Another convenient way to save timestamps is to use [Unix timestamps][unixtime], which are commonly in the UTC time zone. They measure the passed seconds since 1 January 1970, which will overflow for the 32-bit representation on the 19 January 2038. But we shouldn't worry now about that [problem][year2038problem].

```python
import datetime

timestamp = "1496181063"

# Gives you the date and time in local time
d = datetime.datetime.fromtimestamp(int(timestamp))
print(d.strftime("%d.%m.%y %H:%M:%S"))

# Gives you the date and time in UTC
d = datetime.datetime.utcfromtimestamp(int(timestamp))
print(d.strftime("%d.%m.%y %H:%M:%S"))
```

with the result

```
30.05.17 23:51:03
30.05.17 21:51:03
```

where the first timestamp is the local time (CEST) at that time transformed from UTC and the second timestamp is in UTC. I prefer to work directly in UTC to avoid confusion. In order to get the current timestamp you can use the [time][time] module as follows

```python
import time
import datetime

# Returns unix timestamp for current time
timestamp = time.time()
# Get datetime object in local time
d = datetime.datetime.fromtimestamp(timestamp)
# Return unix timestamp from datetime object
timestamp = d.timestamp()
```


## Getting Timestamps from Files

This is farely straight forward. Sometimes you need to get the time information of a certain file. In python you can access this information with the [os.path][os.path] module, where the following functions all return a unix timestamp.

```python
import os
import datetime

filepath = "path/to/file"

# Return the system’s ctime. 
# In Windows creation time and in Unix systems last metadata change
timestamp = os.path.getctime(filepath)
# Return the time of last modification of path
timestamp = os.path.getmtime(filepath)
# Return the time of last access of path
timestamp = os.path.getatime(filepath)

d = datetime.datetime.fromtimestamp(timestamp)
```


## Working with Time Differences

In order to perform arithmetic operations with time you can simply substract two datetime objects, which will return a `datetime.timedelta` object.

```python
import datetime

timestring = "2017-05-30T23:51:03Z"

# Create datetime objects
d0 = datetime.datetime.strptime(timestring, "%Y-%m-%dT%H:%M:%SZ")
d1 = datetime.datetime.now() # Current time

# Calculate timedelta
dt = d1 - d0

passed_days = dt.days
passed_seconds = dt.days # remaining seconds
passed_microseconds = dt.microseconds # remaining microseconds
total_seconds = dt.total_seconds()
```

where `dt` can be used as a offset for another datetime object, by using one of the various [timedelta operations][timedelta].


[utc]: https://en.wikipedia.org/wiki/Coordinated_Universal_Time
[dst]: https://en.wikipedia.org/wiki/Daylight_saving_time
[cet]: https://en.wikipedia.org/wiki/Central_European_Time
[cest]: https://en.wikipedia.org/wiki/Central_European_Summer_Time
[iso_8601]: https://en.wikipedia.org/wiki/ISO_8601
[unixtime]: https://en.wikipedia.org/wiki/Unix_time
[datetime]: https://docs.python.org/3/library/datetime.html
[calender]: https://docs.python.org/3/library/calendar.html
[timedelta]: https://docs.python.org/3/library/datetime.html#timedelta-objects
[time]: https://docs.python.org/3/library/time.html
[pytz]: http://pytz.sourceforge.net/
[strftime]: https://docs.python.org/2/library/datetime.html#strftime-strptime-behavior
[year2038problem]: https://en.wikipedia.org/wiki/Year_2038_problem
[computerphile]: https://www.youtube.com/watch?v=-5wpm-gesOY
[os.path]: https://docs.python.org/2/library/os.path.html
