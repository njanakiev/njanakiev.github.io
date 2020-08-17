---
title: "Videos and GIFs with Three.js"
category: blog
comments: True
image: /assets/videos_and_gifs_with_threejs_files/webgl_01.gif
layout: post
redirect_from: /til/videos-and-gifs-with-threejs/
tags: ['GIF', 'FFmpeg', 'Three.js', 'JavaScript']
---
[Three.js][threejs] is a powerful JavaScript library to create 3D computer graphics on the browser using [WebGL][webgl]. Here we'll see how to create animations and videos from Three.js demos.

For this task we will utilize [CCapture.js][ccapture], which is a handy library to capture frames from the canvas. It supports [WebM][webm], gifs or images in jpg or png collected in a tar file. Here we will focus on the image output of all frames because we want more control over the video and gif format.

Add the [ccapture.js library][ccapture-min] in your project folder and add it to your html file

```html
<script src="CCapture.all.min.js"></script>
```

To control the width and size of the frames simply set the size of the renderer.

```js
const width  = 600;
const height = 600;
const renderer = new THREE.WebGLRenderer({canvas: canvas, antialias: true});
renderer.setSize( width, height );
```

To start the capture in your JavaScript code just add the following code for png export

```js
const capturer = new CCapture( { format: 'png' } );
capturer.start();
```

and to capture a frame, pass the canvas that you want to capture to the `capturer` during the render loop

```js
function render(){
	requestAnimationFrame(render);
	// render your scene
	capturer.capture( canvas );
}
render();
```

After you have enough frames (e.g. specified number of frames) you can stop the capture and save the frames with

```js
capturer.stop();
capturer.save();
```

In our case we get a tar file which we need to extract (with e.g. [7zip][7zip] and the command `7z x frames.tar`). Now we can create an mp4 video from the frames with [ffmpeg][ffmpeg] by running the command

```bash
ffmpeg -i %07d.png video.mp4
```

There are further settings you can add to the command which can be found in the [ffmpeg documentation][ffmpeg doc]. In order to create animated gifs from your frames you can use [ImageMagick][imagemagick] and [Gifsicle][gifsicle]. With ImageMagick you can create a gif animation by running the following command in the folder with the frames

```bash
convert -delay 4 -loop 0 *.png animation.gif
```

where the `-delay` flag specifies the delay of each frame in *ticks-per-second* and the `-loop` flag specifies the number of loops, which is with `0` an endless loop. Creating more efficient gifs is covered in this [post]({{ site.baseurl }}{% link _posts/2017-01-14-creating-gifs-in-the-command-line.md %}) and creating videos for Instagram is covered in this [post]({{ site.baseurl }}{% link _posts/2017-02-26-instagram-videos-from-images.md %}).


[threejs]: https://threejs.org/
[webgl]: https://en.wikipedia.org/wiki/WebGL
[webm]: https://en.wikipedia.org/wiki/WebM
[7zip]: https://www.7-zip.org/
[imagemagick]: http://www.imagemagick.org/
[gifsicle]: https://www.lcdf.org/gifsicle/
[ccapture]: https://github.com/spite/ccapture.js/
[ccapture-min]: https://github.com/spite/ccapture.js/blob/master/build/CCapture.all.min.js
[ffmpeg]: https://ffmpeg.org/
[ffmpeg doc]: https://ffmpeg.org/ffmpeg.html