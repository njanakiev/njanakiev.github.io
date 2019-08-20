---
title: Command-Line Image Processing with ImageMagick
category: blog
comments: True
image: /assets/NOS_163254866811.jpg
imagesource: New Old Stock
imageurl: http://nos.twnsnd.co/image/163254866811
layout: post
tags: ['Command-Line', 'ImageMagick', 'Image Processing']
featured: True
---

There are times being stuck with a load of images that need to be cropped, resized or converted, but doing this by hand in an image editor is tedious work. One tool I commonly use in these desperate situations is [ImageMagick](http://www.imagemagick.org/script/index.php), which is a powerful tool when automating raster and vector image processing. Here I'll introduce a few common commands I had to look up multiple times.

ImageMagick can do a lot of different graphics editing tasks and it even can create new images from the command-line. It can be incorporated into shell scripts, batch files or through other programs for automatic processing of images. The various command-line tools can be seen in the [documentation](http://www.imagemagick.org/script/command-line-tools.php) and their usage can be seen in the [examples](http://www.imagemagick.org/Usage/).

If ImageMagick is not pre-installed on your system you can follow the [installation instructions](http://www.imagemagick.org/script/download.php) which are pretty straight forward for the various operating systems.

# Image Conversions

The two most common commands are [`mogrify`](https://www.imagemagick.org/script/mogrify.php) and [`convert`](https://www.imagemagick.org/script/convert.php), where `mogrify` overwrites the existing image and `convert` saves the image as a new image without modifying the original image. To convert an image from JPEG to PNG run the command:

```bash
convert image.jpg image.png
```

or by the command `mogrify -format png image.jpg`

Another useful argument is [`-quality`](http://imagemagick.org/script/command-line-options.php#quality) when specifying the image quality of JPEG, by setting a value between 0 and 100 percent:

```bash
convert -quality 70 image.png image.jpg
```

When you convert an image with transparency like PNG to JPEG, the transparent part will become black. If you want to have a different background color you can do that with:

```bash
convert image.png -background white -flatten image.jpg
```

Here, you first select the background color with [`-background`](https://imagemagick.org/script/command-line-options.php#background). To see what colors you can use, have a look at [this documentation](https://imagemagick.org/script/color.php). Finally, the additional [`-flatten`](https://imagemagick.org/script/command-line-options.php#flatten) argument flattens the layers (the background layer and image layer) to a single layer. Note, that if you only use `-flatten`, the background will be white since the default background color is white. But keep in mind, that if you convert without `-flatten` the background will become black.

# Resizing and Cropping Images

Resizing comes with many options. It can be done by using the argument [`-resize`](http://imagemagick.org/script/command-line-options.php#resize) by either directly specifying the resolution of the new image by:

```bash
convert -resize 600x600 image.jpg resized_image.jpg
```

It can by also done by specifying by other resizing options as shown in the [Image Geometry](http://imagemagick.org/script/command-line-processing.php#geometry) section. 

Cropping can be similarly achieved by specifying the [`-crop`](http://imagemagick.org/script/command-line-options.php#crop) argument as in:

```bash
convert -crop 200x200+100+10 image.jpg cropped_image.jpg
```

where the cropped selection is 200x200 pixel and is moved 100 pixel left and 10 pixel down. For multiple images that need to be cropped by the same rectangle, I tend to use tools like [Gimp](https://www.gimp.org/) or [IrfanView](http://irfanview.tuwien.ac.at/) where I can read of the rectangle coordinates from the selection.

These arguments and others can be also combined into a single command as in:

```bash
convert -crop 200x200+100+10 \
  -resize 600x600 \
  image.jpg cropped_and_resized.jpg
```

# Annotating Images

It is also possible to annotate images with text or other images with [`-annotate`](http://imagemagick.org/script/command-line-options.php#annotate) argument, which helps if you need to add information on images. The following command combines multiple settings:

```bash
convert -gravity south \
  -stroke black \
  -strokewidth 1 \
  -fill black \
  -font Courier-New \
  -pointsize 10 \
  -annotate +10+10 "Annotation" \
  image.jpg annotated_image.jpg
```

where [`-gravity`](http://imagemagick.org/script/command-line-options.php#gravity) defines where the annotation is positioned. The other arguments should be self explanatory and are listed in the [command-line options](http://www.imagemagick.org/script/command-line-tools.php). In order to see which fonts are supported on the operating system, you can list the available fonts with `identify -list font`. For further examples on image annotation check out the [collection of examples](http://www.imagemagick.org/Usage/annotating/).

# Batch Image Processing

It is possible to write a script that iterates through images in a specified list of images as in the next command (for Windows):

```bash
for %f in (*.png) do (convert %f -quality 100 %~nf.jpg)
```

This is also possible without resorting to loops by the command:

```bash
mogrify -resize 600x600 -format jpg -quality 70 -path images *.png
```

which resizes all images in the current folder and converts them to JPEG with 70% quality to the folder images. The previous commands for single image processing can be translated into batch processing with additional numbering for the resulting images. The notation `%04d` translates to four digit numbering with prepending zeros:

```bash
convert -resize 600x600 images\*.jpg resized\%04d.jpg
convert -crop 200x200+100+10 images\*.jpg cropped\%04d.jpg
convert -crop 200x200+100+10 -resize 600x600 cropped_and_resized\*.jpg resized\%04d.jpg
```

# Combining multiple Images

Another useful application of ImageMagick is to append multiple images into a single image. This can be done by using the [`append`](http://imagemagick.org/script/command-line-options.php#append) argument and using [parenthesis](http://www.imagemagick.org/Usage/basics/#parenthesis) where the parenthesis define an image list in the command. Note that in Unix systems the parenthesis need to be prepended by a backslash as in `\(` and `\)`:

```
convert ( image_01.jpg image_02.jpg +append )
        ( image_01.jpg image_02.jpg +append ) -append combined.jpg
```

In order to join top-to-bottom you need to add `-append` after the images and if you want to join the images left-to-right use `+append` instead. 

# Creating Optimized GIFs in the Command-Line

ImageMagick also provides the means to create GIFs from images in the command-line and by playing with the parameters you can optimize the file size. This is especially useful since many platforms like Twitter or Tumblr have file size restrictions. The optimized procedure I found for my self is combined in the following commands:

```bash
convert -fuzz 6% -delay 4 -loop 0 -layers OptimizePlus frames/*.png tmp.gif
```

where the `-fuzz` option seems to have the largest impact on the final size, which has the effect that *Colors within this distance are considered equal*. The `-delay` option specifies the the delay of each frame in *ticks-per-second*. The `-loop` option specifies the number of loops (0 for infinite loop). The `-layers` option performs different image operation methods for image sequences, where `OptimizePlus` is improving the overall optimization.

The file size can be further shrinked down with [Gifsicle](https://www.lcdf.org/gifsicle/) by decreasing the colors and optimizing the output:

```bash
gifsicle -O3 --colors 100 tmp.gif > output.gif
```

The option `-O3` is the maximum optimization level. The available commands can be found on the [Gifsicle Man Page](https://www.lcdf.org/gifsicle/man.html). Gifsicle can convert image sequences into GIFs by itself, but I found out that both tools perform better together. 

![gif]({{ site.baseurl }}/assets/imagemagick_image_processing_files/webgl_02.gif)

# Conclusion

So there you have it, ImageMagick is a powerful tool for basic image processing tasks, but it has many more tools and options to explore. These commands should help you when you need to process or edit a load of images without spending the whole evening in some image editor.