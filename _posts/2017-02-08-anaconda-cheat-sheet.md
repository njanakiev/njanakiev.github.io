---
title: "Anaconda Cheat Sheet"
category: blog
comments: True
seo:
    date_modified: 2021-03-27
image: /assets/anaconda_cheat_sheet_files/Eunectes_murinus_10zz.jpg
imagesource: Wikimedia Commons
imageurl: https://commons.wikimedia.org/wiki/File:Eunectes_murinus_10zz.jpg
layout: post
redirect_from: /blog/anaconda-snippets/
tags: ['Anaconda', 'Python']
---
Here is a short collection of commands and solutions for [Anaconda](https://www.continuum.io/downloads) with Python that I frequently tend to use.

# Quick and Useful Commands

- `conda -v` See current version of Anaconda
- `conda install [package]` Install package to current environment
- `conda install -c [channel] [package]` Install package with a specific channel
- `conda search python` See available versions of Python
- `conda list` List all packages installed in current environment
- `conda update conda` Update Anaconda
- `conda info -e` or `conda env list` List all installed enviroments
- `conda env export > environment.yml` Export active environment
- `conda env create -f environment.yml` Create environment from specification
- `conda install --rev 1` Restore root environment to its state after installation
- `conda remove --name myenv --all` Remove an environment

# How to use Virtual Environments in Anaconda?

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

# Anaconda Base Environment

Check if Anaconda base environment is enabled:

    conda config --show | grep auto_activate_base
    
To disable the Anaconda base environment:

    conda config --set auto_activate_base False

# Reset Anaconda Root Environment

Remove root environment and `conda` command:

    conda install --revision 0
    
Restore root environment to state after first installation:

    conda install --revision 1

To list revisions, type:

    conda list --revision

Source: [How to reset anaconda root environment](https://stackoverflow.com/questions/41914139/how-to-reset-anaconda-root-environment)

# Export Anaconda Environment

Export the current Anaconda environment:

```bash
conda env export \
  --from-history \
  --no-builds > myenv.yml
```
    
The `--no-builds` flag prevents the inclusion of platform-specific build IDs. When using `--from-history` (introduced in Conda 4.7.12), Conda will only export packages and versions which you have explicitly installed using conda install.

This environment can be then installed with:

```bash
conda env create \
  --name myenv \
  --file myenv.yml
```

Here is a script to bulk export all conda environments in your system: 

```bash
#!/bin/bash
set -e

conda activate
for conda_env in $$(conda env list | cut -d" " -f1 | tail -n+4); do
  echo $$conda_env
  conda activate $$conda_env
  conda env export \
    --from-history \
    --no-builds > "$${conda_env}.yml"
done
conda activate
```

This needs to be run with `source script.sh`.

# References

- [Conda channels](https://docs.conda.io/projects/conda/en/latest/user-guide/concepts/channels.html)
- [Managing channels](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-channels.html)
- [Managing environments](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html)
- [Conda Cheat Sheet](https://kapeli.com/cheat_sheets/Conda.docset/Contents/Resources/Documents/index)
- 2018 - [Conda hacks for data science efficiency](https://ericmjl.github.io/blog/2018/12/25/conda-hacks-for-data-science-efficiency/)