---
layout: post
category: til
title: Using Anaconda in Blender
tags: [Blender, Anaconda, Python]
image: /til/assets/NOS_93315690552.jpg
imageurl: http://nos.twnsnd.co/image/93315690552
imagesource: New Old Stock
comments: true
---

Sometimes you need other packages when scripting in Blender. Blender already includes [Numpy][numpy] in its newer versions out of the box which is quite handy. However I often have the need to install new packages to use for my own scripts and add-ons. There is also a way to use an already installed version of [Anaconda][anaconda] which I'll show in this post. It worked for me for Blender 2.77 and 2.79 on Windows.

Anaconda is a package manager and Python distribution which simplifies installing new packages for Python and has many useful packages pre-installed, which is especially useful when working with Windows where some packages are sometimes troublesome to install.

1. First step is to install Anaconda and Blender. I use Anaconda3 x64 and Blender 2.79 x64.
2. Then create a Python 3.5 environment with Anaconda by using the command `conda create -n py35 python=3.5 anaconda`. I compiled some tipps on virtual environments in Anaconda in this [post][anaconda snippets].
4. Rename the folder of the Blender Python environment `C:\Program Files\Blender Foundation\Blender\2.79\python` to something different like `_python`.
5. Finally you can either copy the contents of the folder `C:\Anaconda3\envs\py3` to `C:\Program Files\Blender Foundation\Blender\2.79\python` or alternatively you can use a link to the Anaconda folder. To create a link make sure to run the console as administrator and then create a [hard link to a directory][symlink] by running

```
mklink /j python C:\Anaconda3\envs\py3
```

After these steps try to import the packages included in the Anaconda packages (e.g. `import pandas`, `import scipy`) and the Blender packages (e.g. `import bpy`, `import bmesh`) inside the Python console in Blender or the text editor. If this works, you should be able to use every python module available through the Anaconda environment and also install new packages when needed.

[stackoverflow question]: https://blender.stackexchange.com/questions/51067/using-anaconda-python-3-in-blender-winx64
[numpy]: http://www.numpy.org/
[anaconda]: https://docs.anaconda.com/anaconda/
[symlink]: https://www.howtogeek.com/howto/16226/complete-guide-to-symbolic-links-symlinks-on-windows-or-linux/
[anaconda snippets]: {{ site.baseurl }}{% link til/_posts/2017-09-16-using-anaconda-in-blender.md %}
