---
layout: post
category: til
title: Using the Blender Interactive Console from the Command-Line
tags: [Blender, Python, Command-Line]
image: /til/assets/Control_Panel_for_UNIVAC_1232_Computer.jpg
imageurl: https://commons.wikimedia.org/wiki/File:Control_Panel_for_UNIVAC_1232_Computer.jpg
imagesource: Wikimedia Commons (Steven Fine)
comments: true
---


[Blender][blender] is a wonderful and free 3D modelling tool, but sometimes you need to work with it without the GUI. Luckily Blender supports that and you can work there and do your thing very easily with Python.

All you need to run Blender in the background is the following command, which gets you to the Blender interactive console.

```bash
blender -b --python-console
```

In Windows you need to add Blender to your `PATH` variable to be able to run it from everywhere. There you can start typing and executing commands as you would in the interactive console when running the Blender the usual way. This is a great way to test a few commands in your command line. Here is a quick example listing all objects in the scene.

```python
>>> import bpy
>>> for obj in bpy.data.objects:
...     print(obj.name, obj.type)
...     
Camera CAMERA
Cube MESH
Lamp LAMP
```

On a practical sidenote, using the [`dir()` function][python dir], you can see all the names (functions, methods, modules, ...) of the object you pass it. This is a great way to explore the objects within the console. Another useful command is the [`help()` function][python help] which gives you the available help of the passed object.

This is of course most useful when you want to edit or do something in an existing scene without opening Blender (e.g. running on a server). To do this simply add the Blender scene you want to open to the previous command.

```bash
blender myscene.blend -b --python-console
```

There you can even render your scene by typing

```python
>>> bpy.context.scene.render.filepath
'/tmp/'

>>> bpy.context.scene.render.resolution_x = 800
>>> bpy.context.scene.render.resolution_y = 800
>>> bpy.context.scene.render.resolution_percentage = 100
>>> bpy.ops.render.render(write_still=True)
{'FINISHED'}
```

This renders you the available scene to the `/tmp/` folder. It is also possible to run other settings and commands which you can see in the [Render Operators][render operators]. Only note that the `bpy.ops.render.opengl()` function does not work without the Blender GUI.

# Conclusion

I hope this was a quick and useful tutorial. I also wrote an article covering how to use [Anaconda in Blender][blender anaconda] and how to use [Blender from the command-line][blender command line]. For further resources on the Blender API take a look at the [documentation][blender api documentation].


[blender]: https://www.blender.org/
[blender anaconda]: {{ site.baseurl }}{% link til/_posts/2017-09-16-using-anaconda-in-blender.md %}
[blender command line]: {{ site.baseurl }}{% link til/_posts/2017-02-04-blender-command-line.md %}
[python dir]: https://docs.python.org/3/library/functions.html#dir
[python help]: https://docs.python.org/3/library/functions.html#help
[render operators]: https://docs.blender.org/api/current/bpy.ops.render.html
[blender api documentation]: https://docs.blender.org/api/current/contents.html
