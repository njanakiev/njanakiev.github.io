---
title: Running a Python Script in the Background
category: til
comments: True
image: /til/assets/HP_2647A_terminal.jpg
imagesource: Wikimedia Commons
imageurl: https://commons.wikimedia.org/wiki/File:HP_2647A_terminal.jpg
layout: post
tags: ['Python', 'Command-Line', 'Server']
---

This is a quick little guide on how to run a Python script in the background in Linux.

First, you need to add a [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)) line in the Python script which looks like the following:

    #!/usr/bin/env python3
    
This path is necessary if you have multiple versions of Python installed and `/usr/bin/env` will ensure that the first Python interpreter in your `$$PATH` environment variable is taken. You can also hardcode the path of your Python interpreter (e.g. `#!/usr/bin/python3`), but this is not flexible and not portable on other machines. Next, you'll need to set the permissions of the file to allow execution:

    chmod +x test.py
    
Now you can run the script with [nohup](https://en.wikipedia.org/wiki/Nohup) which ignores the hangup signal. This means that you can close the terminal without stopping the execution. Also, don't forget to add `&` so the script runs in the background:

    nohup /path/to/test.py &
    
If you did not add a shebang to the file you can instead run the script with this command:

    nohup python /path/to/test.py &
    
The output will be saved in the `nohup.out` file, unless you specify the output file like here:

    nohup /path/to/test.py > output.log &
    nohup python /path/to/test.py > output.log &

You can find the process and its process Id with this command:
    
    ps ax | grep test.py
    
If you want to stop the execution, you can kill it with the [kill](https://en.wikipedia.org/wiki/Kill_(command)) command:

    kill PID
    
It is also possible to kill the process by using [pkill](https://en.wikipedia.org/wiki/Pkill), but make sure you check if there is not a different script running with the same name:

    pkill -f test.py
    
## Output Buffering    
    
If you check the output file `nohup.out` during execution you might notice that the outputs are not written into this file until the execution is finished. This happens because of output buffering. If you add the `-u` flag you can avoid output buffering like this:

    nohup python -u ./test.py &
    
Or by specifying a log file:

    nohup python -u ./test.py > output.log &