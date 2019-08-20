---
layout: post
category: blog
title: Anaconda Snippets
tags: [Anaconda, Python]
image: /assets/Eunectes_murinus_10zz.jpg
imagesource: Wikimedia Commons
imageurl: https://commons.wikimedia.org/wiki/File:Eunectes_murinus_10zz.jpg
comments: true
redirect_from: /til/anaconda-snippets
---

Here is a short collection of commands and solutions for [Anaconda](https://www.continuum.io/downloads) with Python that I frequently tend to use.

# Quick and Useful Commands

| Command | Description |
| --- | --- |
|`conda -v`| See current version of Anaconda |
|`conda install [package]`| Install package to the root Python installation |
|`conda search python`| See available versions of Python |
|`conda list`| List all packages installed in Anaconda |
|`conda update conda`| Update Anaconda |
|`conda info -e`| List all installed enviroments |
|`conda env export > environment.yml`| Export active environment |
|`conda env create -f environment.yml`| Create environment from specification |
|`conda install --rev 1`| Restore root environment to its state after installation|

# How to use virtual environments in Anaconda?

In Anaconda it is possible to run different environments and versions of Python which helps when working with conflicting packages or packages that are for example not updated and available for newer Python versions. In order to install a new environment with the name `py35` in Anaconda simply use

```bash
conda create -n py35 python=3.5 anaconda
```

This creates a new environment installed in the `/envs/py35` directory inside the Anaconda directory. If you need to install further packages to the created virtual environment you can install it by

```bash
conda install -n py35 [package]
```

This virtual enviroment can be now activated with

```bash
source activate py35
```

or on windows with `activate py35`. You can then deactivate the environment with

```bash
source deactivate py35
```

or on windows with `deactivate py35`. And finally if you do not need the environment anymore, it can be deleted with

```bash
conda remove -n py35 -all
```

Here is more information on how to [manage python](https://conda.io/docs/py2or3.html) and on how to [manage packages](https://conda.io/docs/using/pkgs.html) in Anaconda.