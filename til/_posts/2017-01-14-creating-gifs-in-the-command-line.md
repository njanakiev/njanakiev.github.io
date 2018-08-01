---
layout: post
category: til
title: Creating GIFs in the Command Line
tags: [GIF, Command-Line, Image Processing]
image: /til/assets/webgl_02.gif
comments: true
---


Some quick tipps on creating GIFs in the command line. 

The tool I mostly use is `convert` from [ImageMagick][imagemagick]. The `-fuzz` option seems to have the largest impact on the final size, which has the effect that *Colors within this distance are considered equal*. The `-delay` option specifies the the delay of each frame in *ticks-per-second*. The `-loop` option specifies the number of loops (0 for infinite loop). The `-layers` option performs different image operation methods for image sequences, where `OptimizePlus` is improving the overall optimization. The `convert` options can be found in the [Command Line Options][imagemagick options].

```bash
convert -fuzz 6% -delay 4 -loop 0 -layers OptimizePlus frames/*.png tmp.gif
```

The file size can be further shrinked even more with [Gifsicle][gifsicle] by decreasing the colors and optimize the output. The option `-O3` is the maximum level. The different available commands can be found on the [Gifsicle Man Page][gifsicle man].

```bash
gifsicle -O3 --colors 100 tmp.gif > output.gif
```

Gifsicle can convert image sequences into GIFs by itself, but I found out that both tools perform better together. Also after installing ImageMagick on windows, the commands work there too.


[imagemagick]: https://www.imagemagick.org/script/command-line-processing.php
[imagemagick options]: https://www.imagemagick.org/script/command-line-options.php
[gifsicle]: https://www.lcdf.org/gifsicle/
[gifsicle man]: https://www.lcdf.org/gifsicle/man.html
