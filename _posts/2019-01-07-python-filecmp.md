---
layout: post
category: blog
title: File and Directory Comparisons with Python
tags: [Python, File-System]
comments: true
image: /assets/Unix_Server_Attic_Hideaway.jpg
imageurl: https://commons.wikimedia.org/wiki/File:Unix_Server_Attic_Hideaway.jpeg
imagesource: Wikimedia Commons
redirect_from: '/til/python-filecmp/'
---

The Python standard library offers a powerful set of tools out of the box including file system handling. In this quick little article you'll see a couple of useful recipes to compare files and directories with the [filecmp](https://docs.python.org/3/library/filecmp.html) module.

When you have a painful mess of files and folders (like [here](https://xkcd.com/1360/), or [here](https://xkcd.com/1459/)), which are difficult to plow through, Python is your friend to automate the search and comparison. This can then be combined with automatic processing, modification or deletion of files and directories instead of manually going through each file. 

__A fair warning:__ _Always check and test the code properly when modifying the file system with any operation like deleting, renaming, copying, among others. And also keep multiple copies of your important files ["Two is One and One is None"](https://www.forbes.com/sites/work-in-progress/2011/06/21/two-is-one-and-one-is-none/)._

In the `filecmp` module you'll find the `cmp()` function which can compare two files. By default the comparision is shallow (`shallow=True`) which means that only the [os.stat()](https://docs.python.org/3/library/os.html#os.stat) signatures (like size, date modified, ...) of both files are compared. By setting `shallow=False` the comparison is done by comparing the contents of the files, which takes more time. Here is a snippet you can use to find all duplicates in a folder:

```python
import os
import itertools
import filecmp

files = os.listdir('path/to/directory')

for f1, f2 in itertools.combinations(files, 2):
    if filecmp.cmp(f1, f2):
        print(f1, f2)
```

Here you can see the use of another highly useful module from the Python standard librar, the [itertools](https://docs.python.org/3/library/itertools.html) module, which can help you with various iterators and looping functions. In this case you can see the [combinations()](https://docs.python.org/3/library/itertools.html#itertools.combinations) function which returns all permutations of length 2 of the list of files. This makes sure that each file is compared with each other file in the list. To search recursively over all files in a folder, replace `files = os.listdir('...')` in the previous code with: 

```python
files = []
for (dirpath, dirnames, filenames) in os.walk('.'):
    for f in filenames:
        files.append(os.path.join(dirpath, f))
```

You can also compare directories with the [dircmp](https://docs.python.org/3/library/filecmp.html#the-dircmp-class) class. The following snippet goes through two folders recursively and displays all files that have the same name, but are different and it lists all files that exist either on the left or right filepath:

```python
import filecmp
c = filecmp.dircmp(filepath1, filepath2)

def report_recursive(dcmp):
    for name in dcmp.diff_files:
        print("DIFF file %s found in %s and %s" % (name, 
            dcmp.left, dcmp.right))
    for name in dcmp.left_only:
        print("ONLY LEFT file %s found in %s" % (name, dcmp.left))
    for name in dcmp.right_only:
        print("ONLY RIGHT file %s found in %s" % (name, dcmp.right))
    for sub_dcmp in dcmp.subdirs.values():
        print_diff_files(sub_dcmp)

report_recursive(c)
```

This is a great way if you have multiple folders with the same name but you have no idea if they have the same contents (like different versions of a backup folder). Keep in mind that this does only a shallow comparision like you saw in the file comparison before.

I hope this helps! If anything is unclear or you have other useful tipps and tricks, you can share those in the comments or feel free to reach out.
