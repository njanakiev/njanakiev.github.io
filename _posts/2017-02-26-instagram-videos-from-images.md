---
title: "Creating Instagram Videos from Images"
category: blog
comments: True
image: /assets/instagram_videos_from_images_files/NOS_134533666968.jpg
imagesource: New Old Stock
imageurl: http://nos.twnsnd.co/image/134533666968
layout: post
redirect_from: /til/instagram-videos-from-images/
tags: ['Instagram', 'FFmpeg', 'Command-Line', 'Image Processing']
---
Uploading Videos in Instagram is tricky, not every format is supported and the format needs to fulfil some video specifications. Here we get into the recipe for creating a proper video for instagram from a sequence of images.

In order to create a [mp4][mp4] slideshow or video from a sequence of frames you can use [ffmpeg][ffmpeg], which is a common multimedia framework and command-line tool for decoding, encoding, converting and other functions usefull for working with various media formats. The command for creating a slideshow from a set of frames is

```bash
ffmpeg -i frame_%04d.png output.mp4
```

which creates a mp4 from images enumerated as (frame_0000, frame_0001, ...), where `%04d` or `%4d` specifies enumerations prepended with zeros. Enumerations without zeros are specified by `%d`. This output video cannot be used for instagram, so we need to add further specifications to our command in order to be able to upload it on instagram. The resulting command is

```bash
ffmpeg -r 30 -i frame_%04d.png -c:v libx264 -c:a aac -ar 44100 -pix_fmt yuv420p output.mp4
```

In this command we specify the video codec with `-c:v libx246` the [H.264][H.264] codec. The audio codec is denoted with `-c:a aac -ar 44100` which applies the [AAC][AAC] codec with 44100 Hz audio sampling frequency. The framerate can be specified with the `-framerate` or `-r` and is by default 25 fps. The `-pix_fmt` flag specifies the pixel format where we need the `yuv420p` format which is specifies a color sampling in [YUV][YUV]. A list of requirements can be found in the [Instagram Video Requirements][instagram video].


[mp4]: https://en.wikipedia.org/wiki/MPEG-4_Part_14
[H.264]: https://en.wikipedia.org/wiki/H.264/MPEG-4_AVC
[AAC]: https://en.wikipedia.org/wiki/Advanced_Audio_Coding
[YUV]: https://en.wikipedia.org/wiki/YUV
[ffmpeg]: https://ffmpeg.org/
[ffmpeg slideshow]: http://trac.ffmpeg.org/wiki/Slideshow
[instagram video]: https://www.facebook.com/business/ads-guide/video-views/instagram-video-views