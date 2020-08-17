---
title: "Creating Slides with Jupyter Notebook"
category: blog
comments: True
image: /assets/creating_slides_with_jupyter_notebook_files/Cocconi_giving_a_lecture_in_CERN's_main_auditorium_1967.jpg
imagesource: Wikimedia Commons
imageurl: https://commons.wikimedia.org/wiki/File:Cocconi_giving_a_lecture_in_CERN's_main_auditorium_1967.jpg
layout: post
redirect_from: /til/creating-slides-with-juypter-notebook/
tags: ['Jupyter']
---
[Jupyter notebook](http://jupyter.org/) is a powerful tool to interactively code in web-based notebooks with a whole plethora of programming languages. With it, it is also possible to create web-based slideshows with [reveal.js](https://github.com/hakimel/reveal.js/).

The slides functionality is already included in Jupyter Notebook, so there is no need to install plugins. Although slides do not work at the time of writing for [JupyterLab](https://jupyterlab.readthedocs.io/en/stable/). To open the slides toolbar for each cell in your Jupyter Notebook, enable it via `View > Cell Toolbar > Slideshow`:

![Jupyter Slides Toolbar]({{ site.baseurl }}/assets/creating_slides_with_jupyter_notebook_files/jupyter_slides_toolbar.png)

Now you can specify for each cell what kind of slide type you want. The available types are _Slide_ (new slide), _Sub-Slide_ (new slide below last one), _Fragment_ (fragment within previous slide), _Skip_ (skip this cell) and _Notes_ (adding speaker notes):

![Jupyter Slides Toolbar]({{ site.baseurl }}/assets/creating_slides_with_jupyter_notebook_files/jupyter_slides_type.png)

You can now convert the notebook with the [`jupyter-nbconvert`](https://nbconvert.readthedocs.io/en/latest/) command line tool and the [`--to slides`](http://nbconvert.readthedocs.io/en/latest/usage.html#convert-revealjs) option. First, you need to add/clone [reveal.js](https://github.com/hakimel/reveal.js/) into your folder with the presentation (`git clone https://github.com/hakimel/reveal.js/`) and then you can run the command:

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

This will run a server which opens the presentation in your browser ready for presentation. Another neat thing is [RISE](https://github.com/damianavila/RISE), a Jupyter slideshow extension that allows you to instantly turn your Jupyter Notebooks into a slideshow with the press of a button in your notebook:

![Jupyter Slides RISE]({{ site.baseurl }}/assets/creating_slides_with_jupyter_notebook_files/jupyter_slides_RISE.png)

Finally, if you want to create a PDF from your slides, you can do that by adding `?print-pdf` to the url of the previously hosted slides:

```
http://localhost:8000/[SLIDES TITLE].slides.html?print-pdf
```

After opening this url, you can now print the page to PDF. You can find other configuration options in the [nbconvert documentation](https://nbconvert.readthedocs.io/en/latest/config_options.html).

Happy presenting!