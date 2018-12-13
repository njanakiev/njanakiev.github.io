---
layout: post
category: til
title: Creating Slides with Jupyter Notebook
tags: [Jupyter]
comments: true
---


[Jupyter notebook](http://jupyter.org/) is a powerful tool to interactively code in web-based notebooks with a whole plethora of programming languages. With it, it is also possible to create web-based slideshows with [reveal.js](https://github.com/hakimel/reveal.js/).

To open the slides toolbar for each cell in your Jupyter Notebook, enable it via `View > Cell Toolbar > Slideshow`. Now you can specify for each cell what kind of slide type you want. The available types are _Slide_ (new slide), _Sub-Slide_ (new slide below last one), _Fragment_ (fragment within previous slide), _Skip_ (skip this cell) and _Notes_ (adding speaker notes).

You can now convert the slides with the [`jupyter-nbconvert`](https://nbconvert.readthedocs.io/en/latest/) command line tool and the [`--to slides`](http://nbconvert.readthedocs.io/en/latest/usage.html#convert-revealjs) option. First, you need to add/clone [reveal.js](https://github.com/hakimel/reveal.js/) into your folder with the presentation (`git clone https://github.com/hakimel/reveal.js/`) and then you can run the command:

```bash
jupyter-nbconvert --to slides presentation.ipynb --reveal-prefix=reveal.js
```

If you want to enable scrolling you can add the following to the jupyter nbconvert command (thanks to [Hannah Augustin](http://hannahaugustin.at/) for the hint):

```bash
--SlidesExporter.reveal_scroll=True
```

It is also possible [serve slides with an https server](http://nbconvert.readthedocs.io/en/latest/usage.html#servepostprocessorexample) by using the `--post serve` option as in the command:

```bash
jupyter-nbconvert --to slides presentation.ipynb --post serve
```

This will run a server which opens the presentation in your browser ready for presentation. Another neat thing is [RISE](https://github.com/damianavila/RISE), a Jupyter slideshow extension that allows you to instantly turn your Jupyter Notebooks into a slideshow with the press of a button in your notebook. 

You can find other configuration options in the [nbconvert documentation](https://nbconvert.readthedocs.io/en/latest/config_options.html).

Happy presenting!
