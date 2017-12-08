---
layout: post
title: Command-Line Image Processing with ImageMagick
tags: [Commmand-Line, ImageMagick, Image Processing]
author: Nikolai Janakiev
image: /assets/NOS_163254866811.jpg
imageurl: http://nos.twnsnd.co/image/163254866811
imagesource: New Old Stock
comments: true
---

There are times being stuck with a load of images that need to be cropped, resized or converted, but doing this by hand in an image editor is tedious work. One tool I commonly use in these desperate situations is [ImageMagick][imagemagick], which is a powerful tool when automating raster and vector image processing. Here I'll introduce a few common commands I had to look up multiple times.

ImageMagick can do a lot of different graphics editing tasks and it even can create new images from the command-line. It can be incorporated into shell scripts, batch files or through other programs for automatic processing of images. The various command-line tools can be seen in the [documentation][command-line tools] and their usage can be seen in the [examples][usage examples].

If ImageMagick is not pre-installed on your system you can follow the [installation instructions][imagemagick download] which are pretty straight forward for the various operating systems. 


## Command-Line Image Processing

The two most common commands are [`mogrify`][mogrify] and [`convert`][convert], where `mogrify` overwrites the existing image and `convert` saves the image as a new image without modifying the original image. To convert an image from JPEG to PNG run the command


```bash
convert image.jpg image.png
```

or by the command `mogrify -format png image.jpg`

Resizing comes with many options. It can be done by using the argument [`-resize`][resize] by either directly specifying the resolution of the new image by


```bash
convert -resize 600x600 images\image.jpg resized\image.jpg
```

or it can by done by specifying by other resizing options as shown in the [Image Geometry][image geometry] section. 

Cropping can be similarly achieved by specifying the [`-crop`][crop] argument as in

```bash
convert -crop 200x200+100+10 images\image.jpg cropped\image.jpg
```

where the cropped selection is 200x200 pixel and is moved 100 pixel left and 10 pixel down. For multiple images that need to be cropped by the same rectangle, I tend to use tools like [IrfanView][irfanview] where I can read of the rectangle coordinates from the selection.

These arguments and others can be also combined into a single command as in

```bash
convert -crop 200x200+100+10 -resize 600x600 cropped_and_resized\image.jpg resized\image.jpg
```

Another useful argument is [`-quality`][quality] when specifying the image quality of JPEG, by setting a value between 0 and 100 percent.

```bash
convert -quality 70 image.png image.jpg
```

It is also possible to annotate images with text or other images with [`-annotate`][annotate] argument, which helps if you need to add information on images. The following command combines multiple settings 

```bash
convert image.jpg -gravity south -stroke black -strokewidth 1 -fill black -font Courier-New -pointsize 10 -annotate +10+10 "Annotation" annotated_image.jpg
```

where [`-gravity`][gravity] defines where the annotation is positioned. The other arguments should be self explanatory and are listed in the [command-line options][command-line tools]. In order to see which fonts are supported on the operating system, you can list the available fonts with `identify -list font`. For further examples on image annotation check out the [collection of examples][annotating images].


## Batch Image Processing

It is possible to write a script that iterates through images in a specified list of images as in the next command (for Windows) 

```bash
for %f in (*.png) do (convert %f -quality 100 %~nf.jpg)
```

This is also possible without resorting to loops by the command

```bash
mogrify -resize 600x600 -format jpg -quality 70 -path images *.png
```

which resizes all images in the current folder and converts them to JPEG with 70% quality to the folder images. The previous commands for single image processing can be translated into batch processing with additional numbering for the resulting images. The notation `%04d` translates to four digit numbering with prepending zeros.

```bash
convert -resize 600x600 images\*.jpg resized\%04d.jpg
convert -crop 200x200+100+10 images\*.jpg cropped\%04d.jpg
convert -crop 200x200+100+10 -resize 600x600 cropped_and_resized\*.jpg resized\%04d.jpg
```


## Combining multiple Images

Another useful application of ImageMagick is to append multiple images into a single image. This can be done by using the [`append`][append] argument and using [parenthesis][parenthesis] where the parenthesis define an image list in the command. Note that in Unix systems the parenthesis need to be prepended by a backslash as in `\(` and `\)`.

```
convert ( image_01.jpg image_02.jpg +append )
        ( image_01.jpg image_02.jpg +append ) -append combined.jpg
```


## Creating Optimized GIFs in the Command-Line

ImageMagick also provides the means to create GIFs from images in the command-line and by playing with the parameters you can optimize the file size. This is especially useful since many platforms like Twitter or Tumblr have file size restrictions. The optimized procedure I found for my self is combined in the following commands

```bash
convert -fuzz 6% -delay 4 -loop 0 -layers OptimizePlus frames/*.png tmp.gif
```

where the `-fuzz` option seems to have the largest impact on the final size, which has the effect that *Colors within this distance are considered equal*. The `-delay` option specifies the the delay of each frame in *ticks-per-second*. The `-loop` option specifies the number of loops (0 for infinite loop). The `-layers` option performs different image operation methods for image sequences, where `OptimizePlus` is improving the overall optimization.

The file size can be further shrinked even more with [Gifsicle][gifsicle] by decreasing the colors and optimize the output. The option `-O3` is the maximum optimization level. The available commands can be found on the [Gifsicle Man Page][gifsicle man].

```bash
gifsicle -O3 --colors 100 tmp.gif > output.gif
```

Gifsicle can convert image sequences into GIFs by itself, but I found out that both tools perform better together. 

![gif]({{ site.baseurl }}/assets/webgl_02.gif)

So there you have it, ImageMagick is a powerful tool for basic image processing tasks, but it has many more tools and options to explore. These commands should help you when you need to process or edit a load of images without spending the whole evening in some image editor.


[imagemagick]: http://www.imagemagick.org/script/index.php
[command-line tools]: http://www.imagemagick.org/script/command-line-tools.php
[usage examples]: http://www.imagemagick.org/Usage/
[imagemagick download]: http://www.imagemagick.org/script/download.php
[convert]: https://www.imagemagick.org/script/convert.php
[mogrify]: https://www.imagemagick.org/script/mogrify.php
[resize]: http://imagemagick.org/script/command-line-options.php#resize
[crop]: http://imagemagick.org/script/command-line-options.php#crop
[quality]: http://imagemagick.org/script/command-line-options.php#quality
[image geometry]: http://imagemagick.org/script/command-line-processing.php#geometry
[append]: http://imagemagick.org/script/command-line-options.php#append
[parenthesis]: http://www.imagemagick.org/Usage/basics/#parenthesis
[annotate]: http://imagemagick.org/script/command-line-options.php#annotate
[annotating images]: http://www.imagemagick.org/Usage/annotating/
[gravity]: http://imagemagick.org/script/command-line-options.php#gravity
[gifsicle]: https://www.lcdf.org/gifsicle/
[gifsicle man]: https://www.lcdf.org/gifsicle/man.html
[irfanview]: http://irfanview.tuwien.ac.at/
