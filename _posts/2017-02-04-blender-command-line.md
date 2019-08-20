---
layout: post
category: blog
title: Running Blender from the Command Line
tags: [Python, Blender, Command-Line]
image: /assets/MET_265559.jpg
imageurl: http://www.metmuseum.org/art/collection/search/265559
imagesource: Metropolitan Museum of Art
comments: true
redirect_from: /til/blender-command-line
---


[Blender][blender] is a very powerful professional open source 3D modelling software for 3D graphics and animation among many other tools. Many things in Blender can be automated with [Python][python] and I often use Blender directly from the command line with Python scripts. Here are some quick commands and snippets that I frequently use.

First thing you need is a Python script which creates or works with a scene in Blender. In this [Blender Scripts Cookbook][cookbook] are a few examples to get you started. In order to run a Python script in Blender you can simply execute the following command

```bash
blender -b -P myscript.py
```

This runs Blender in the background and executes `myscript.py`. Blender creates the basic scene preset with the cube, the lamp and the camera when you run the command. If you want to use an existing Blender scene, you can run the following command

```bash
blender myscene.blend -b -P myscript.py
```

In order to use arguments in the script which should be ignored by Blender, you can append `--` to your command and append the arguments for the script. You just need to clean the arguments in Python of all the previous arguments before `--` like in the next code snippet.

```python
import sys

if "--" not in sys.argv:
	argv = []  # as if no args are passed
else:
	argv = sys.argv[sys.argv.index("--") + 1:]  # get all args after "--"
```

Sometimes it is handy to access other Python scripts or packages with relative paths from the folder of the script. This can be done by appending the absolute path to the `sys.path` variable as follows

```python
import bpy

# Check if script is opened in Blender program
if(bpy.context.space_data == None):
	cwd = os.path.dirname(os.path.abspath(__file__))
else:
	cwd = os.path.dirname(bpy.context.space_data.text.filepath)
		
sys.path.append(cwd)
```

where the `bpy` package is the access to the [Blender/Python API][blender api]. In order to acces files with relative paths from the script folder you need to append their path to `cwd` like `filepath = os.path.join(cwd, RELATIVE_PATH_TO_FILE)`.

Here are further [Resources][resources] for running Blender in the command line terminal. And in the [Blender Scripts Cookbook][cookbook] are many good examples for Python scripting in Blender.

 
[blender]: https://www.blender.org/
[python]: https://www.python.org/
[blender api]: https://docs.blender.org/api/blender_python_api_2_78a_release/info_quickstart.html
[resources]: https://docs.blender.org/api/blender_python_api_2_59_2/info_tips_and_tricks.html
[cookbook]: https://wiki.blender.org/index.php/Dev:Py/Scripts/Cookbook
