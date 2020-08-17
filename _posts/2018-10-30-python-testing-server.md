---
title: "Local Testing Server with Python"
category: blog
comments: True
image: /assets/python_testing_server_files/QWERTY_keyboard.jpg
imagesource: Wikimedia Commons
imageurl: https://commons.wikimedia.org/wiki/File:QWERTY_keyboard.jpg
layout: post
redirect_from: /til/python-testing-server/
tags: ['Python', 'Command-Line']
---
This quick little tutorial shows how to setup a simple local testing server with Python.

You can run run local files in the browser, but some times they won't work or will give you some headache with things like [Cross-Origin Resource Sharing (CORS)](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS). The main problems include:

> - __They feature asynchronous requests.__ Some browsers (including Chrome) will not run async requests (see [Fetching data from the server](https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Client-side_web_APIs/Fetching_data)) if you just run the example from a local file. This is because of security restrictions (for more on web security, read [Website security](https://developer.mozilla.org/en-US/docs/Learn/Server-side/First_steps/Website_security)). 
> - __They feature a server-side language.__ Server-side languages (such as PHP or Python) require a special server to interpret the code and deliver the results. ([Source](https://developer.mozilla.org/en-US/docs/Learn/Common_questions/set_up_a_local_testing_server))
    
You can start a server in Python 3 with:

    python3 -m http.server

If you are still using Python 2 you can start the server with:

    python -m SimpleHTTPServer
    
The server will run the contents of the directory on `localhost` and port `8000`. If you need another port, you can add the port at the end of the command (`python3 -m http.server 7800` or `python -m SimpleHTTPServer 7800` for Python 3 and 2 respectively).

If you need to run server-side languages you will have to resort to the respective web frameworks for testing like [Django (Python)](https://www.djangoproject.com/), [PHP](http://www.php.net/), [Node.js (JavaScript)](https://nodejs.org/en/), [Ruby on Rails](https://rubyonrails.org/) or any other you need to run.