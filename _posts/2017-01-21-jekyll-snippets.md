---
title: "Jekyll Snippets"
category: blog
comments: True
image: /assets/jekyll_snippets_files/jekyll-logo.jpg
layout: post
redirect_from: /til/jekyll-snippets/
tags: ['Jekyll']
---
Some quick solutions when using [Jekyll][jekyll] to generate static sites.

## How to serve Jekyll on the local network?

In order to serve your site on the local network you can run

```bash
jekyll serve -w --host=0.0.0.0
```

In order to figure out the IP address of the site on a Windows machine, you can use the command `ipconfig` in cmd and search for the network you use currently. For example search in **Wireless LAN adapter Wi-Fi** for **Ipv4** when you want to access the site on your phone or other machine from your WiFi network.

I found the solution on [Stack Overflow][stack overflow]

## How to run multiple Jekyll sites on the local network?

By default Jekyll serves the site on port 4000. In order to run multiple sites simultaneously, each site needs to be served at a different port. This can be done by setting the port flag

```bash
jekyll serve -w --port 3000
```

The port can be also specified in the `_config.yml` file, by adding the Local Server Port with the option `port: 3000`. Further options can be found in the [Jekyll configuration][jekyll configuration].

## How to create Jekyll Blog Posts with Jupyter Notebooks

It is possible to create Jekyll blog posts with [Jupyter][jupyter] notebooks by simply converting the notebook to markdown.

```bash
jupyter nbconvert jekyll-notebook.ipynb --to markdown
```

Further resources can be found in the [article][jupyter jekyll posts] by Adam Johnson and in [Jupyter Readthedocs][jupyter readthedocs].


[jekyll]: https://jekyllrb.com/
[jekyll configuration]: http://jekyllrb.com/docs/configuration/#serve-command-options
[stack overflow]: http://stackoverflow.com/questions/16608466/connect-to-a-locally-built-jekyll-server-using-mobile-devices-in-the-lan
[jupyter]: http://jupyter.org/
[jupyter jekyll posts]: https://adamj.eu/tech/2014/09/21/using-ipython-notebook-to-write-jekyll-blog-posts/
[jupyter readthedocs]: http://jupyter-notebook.readthedocs.io/en/latest/