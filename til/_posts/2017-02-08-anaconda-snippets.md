---
layout: post
category: til
title: Anaconda Snippets
tags: [Anaconda, Python, Command-Line]
comments: true
---

Here are some useful or frequently used commands and solutions for [Anaconda][anaconda] and [Python][python].

## Quick and Useful Commands

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

## How to use virtual environments in Anaconda?

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

Here is more information on how to [manage python][managing python] and on how to [manage packages][managing pkgs] in Anaconda.



[anaconda]: https://www.continuum.io/downloads
[managing python]: https://conda.io/docs/py2or3.html
[managing pkgs]: https://conda.io/docs/using/pkgs.html
[python]: https://www.python.org/
[pip]: https://pip.pypa.io/en/stable/