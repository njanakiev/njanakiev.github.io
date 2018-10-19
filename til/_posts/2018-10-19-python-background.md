---
layout: post
category: til
title: Running a Python Script in the Background
tags: [Python, Command-Line]
comments: true
---

Quick litte snippet on how to run a Python script in background in Linux.

First, you need to add a [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)) line in the Python script which looks like the following:

    #!/usr/bin/env python3
    
This path is necessary if you have multiple versions of Python installed and `/usr/bin/env` will ensure that the first Python interpreter in your `$$PATH` environment variable is taken. You can also hardcode the path of your Python interpreter (e.g. `#!/usr/bin/python3`), but this is not flexible and not portable on other machines. Next, you'll need to set the permissions of the file to allow execution:

    chmod +x test.py
    
You can run the script with [nohup](https://en.wikipedia.org/wiki/Nohup) which ignores the hangup signal. Meaning that you can close the terminal without stoping the execution. Don't forget `&` to put it in background:

    nohup /path/to/test.py &
    
If you did not add a shebang to the file you can also run the script with this command:

    nohup python /path/to/test.py &
    
The output will be saved in the `nohup.out` file, unless you specify it like here:

    nohup /path/to/test.py > output.log &
    nohup python /path/to/test.py > output.log &

You can see the process and its process Id with this command:
    
    ps ax | grep test.py
    
If you want to stop the execution, you can kill it with the `kill` command:

    kill PID
    
## Output Buffering    
    
If you check the output file `nohup.out` during execution you might notice that outputs are not written into this file until the execution is finished. This happens because of output buffering. If you add the `-u` flag you can avoid output buffering like this:

    nohup python -u ./test.py &
    
Or by specifying a log file:

    nohup python -u ./test.py > output.log &
