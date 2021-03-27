---
title: "Jekyll Snippets"
category: blog
comments: True
seo:
    date_modified: 2021-03-27
image: /assets/jekyll_snippets_files/jekyll-logo.jpg
layout: post
redirect_from: /til/jekyll-snippets/
tags: ['Jekyll']
---
Some quick solutions when using [Jekyll](https://jekyllrb.com/) to generate static sites.

# How to run Jekyll with Docker

Installing Jekyll and Ruby can be difficult on certain operating systems. In those cases it is helpful to instead run Jekyll as a [Docker](https://www.docker.com/) container. Here is an example how to build and serve the project located at `/path/to/project` with the docker container:

```bash
docker run --rm -it \
  --volume="/path/to/project:/srv/jekyll" \
  --env JEKYLL_ENV=production \
  -p 4000:4000 \
  jekyll/jekyll:4 jekyll serve
```

The specific image in this case is `jekyll/jekyll:4`. The various tags and version can be found on the [jekyll/jekyll](https://hub.docker.com/r/jekyll/jekyll/) docker repository.

# How to serve Jekyll on the local network

In order to serve your site on the local network you can run

```bash
jekyll serve -w --host=0.0.0.0
```

In order to figure out the IP address of the site on a Windows machine, you can use the command `ipconfig` in cmd, or `ip a` in Linux and search for the network you use currently. For example search in **Wireless LAN adapter Wi-Fi** for **Ipv4** when you want to access the site on your phone or other machine from your WiFi network.

I found the solution on [Stack Overflow](http://stackoverflow.com/questions/16608466/connect-to-a-locally-built-jekyll-server-using-mobile-devices-in-the-lan)

# How to run multiple Jekyll sites on the local network

By default Jekyll serves the site on port 4000. In order to run multiple sites simultaneously, each site needs to be served at a different port. This can be done by setting the port flag

```bash
jekyll serve -w --port 3000
```

The port can be also specified in the `_config.yml` file, by adding the Local Server Port with the option `port: 3000`. Further options can be found in the [documentation](http://jekyllrb.com/docs/configuration/#serve-command-options).

# How to create Jekyll Blog Posts with Jupyter Notebooks

It is possible to create Jekyll blog posts with [Jupyter](http://jupyter.org/) notebooks by simply converting the notebook to markdown.

```bash
jupyter nbconvert jekyll-notebook.ipynb --to markdown
```

Further resources can be found in the [article](https://adamj.eu/tech/2014/09/21/using-ipython-notebook-to-write-jekyll-blog-posts/) by Adam Johnson and in [Jupyter Readthedocs](http://jupyter-notebook.readthedocs.io/en/latest/).