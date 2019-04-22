---
title: How to Execute Shell Commands with Python
category: til
comments: True
image: /til/assets/DEC_VT100_terminal.jpg
imagesource: Wikimedia Commons
imageurl: https://commons.wikimedia.org/wiki/File:DEC_VT100_terminal.jpg
layout: post
tags: ['Python', 'Command-Line', 'Server']
---

Python is a wonderful language for scripting and automating workflows and it is packed with useful tools out of the box with the [Python Standard Library](https://docs.python.org/3/library/). A common thing to do, especially for a sysadmin, is to execute shell commands. But what usually will end up in a [bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell)) or [batch](https://en.wikipedia.org/wiki/Batch_file) file, can be also done in Python. You'll learn here how to do just that with the [os](https://docs.python.org/3/library/os.html) and [subprocess](https://docs.python.org/3/library/subprocess.html) modules.

# Using the `os` Module

The first and the most straight forward approach to run a shell command is by using [os.system()](https://docs.python.org/3/library/os.html#os.system):

```python
import os
os.system('ls -l')
```
If you save this as a script and run it, you will see the output in the command line. The problem with this approach is in its inflexibility since you can't even get the resulting output as a variable. You can read more about this function in the [documentation](https://docs.python.org/3/library/os.html#os.system).

Note, that if you run this function in Jupyter notebook, you won't have an output inline. Instead you the inline output will be the return code of the executed programm (`0` for successful and `-1` for unsuccessful). You will find the output in the command line where you have started Jupyter notebook.

Next, the [os.popen()](https://docs.python.org/3/library/os.html#os.popen) command opens a pipe from or to the command line. This means that we can access the stream within Python. This is useful since you can now get the output as a variable:


```python
import os
stream = os.popen('echo Returned output')
output = stream.read()
output
```




    'Returned output\n'



When you use the `.read()` function, you will get the whole output as one string. You can also use the `.readlines()` function, which splits each line (including a trailing `\n`). Note, that you can run them only once. It is also possible to write to the stream by using the `mode='w'` argument. To delve deeper into this function, have a look at the [documentation](https://docs.python.org/3/library/os.html#os.popen).

In this example and in the following examples, you will see that you always have trailing line breaks in the output. To remove them (including blank spaces and tabs in the beginning and end) you can use the `.strip()` function like with `output.strip()`. To remove those characters only in the beginning use `.lstrip()` and for the end `.rstrip()`.

# Using the `subprocess` Module

The final approach is also the most versatile approach and the recommended module to run external commands in Python:

> The [subprocess](https://docs.python.org/3/library/subprocess.html#module-subprocess) module provides more powerful facilities for spawning new processes and retrieving their results; using that module is preferable to using this function. See the [Replacing Older Functions with the subprocess Module](https://docs.python.org/3/library/subprocess.html#subprocess-replacements) section in the [subprocess](https://docs.python.org/3/library/subprocess.html#module-subprocess) documentation for some helpful recipes. ([Source](https://docs.python.org/3/library/os.html#os.system))

The [subprocess.Popen()](https://docs.python.org/3/library/subprocess.html#subprocess.Popen) class is responsible for the creation and management of the executed process. In contrast to the previous functions, this class executes only a single command with arguments as a list. This means that you won't be able to [pipe](https://en.wikipedia.org/wiki/Pipeline_(Unix)) commands:


```python
import subprocess
process = subprocess.Popen(['echo', 'More output'],
                     stdout=subprocess.PIPE, 
                     stderr=subprocess.PIPE)
stdout, stderr = process.communicate()
stdout, stderr
```




    (b'More output\n', b'')



You'll notice that we set `stdout` and `stderr` to [subprocess.PIPE](https://docs.python.org/3/library/subprocess.html#subprocess.PIPE). This is a special value that indicates to `subprocess.Popen` that a pipe should be opened that you can then read with the `.communicate()` function. It is also possible to use a file object as with:


```python
with open('test.txt', 'w') as f:
    process = subprocess.Popen(['ls', '-l'], stdout=f)
```

Another thing that you'll notice is that the output is of type [bytes](https://docs.python.org/3/library/stdtypes.html#bytes). You can solve that by typing `stdout.decode('utf-8')` or by adding `universal_newlines=True` when calling `subprocess.Popen`.

When you run `.communicate()`, it will wait until the process is complete. However if you have a long program that you want to run and you want to continuously check the status in realtime while doing something else, you can do this like here:


```python
process = subprocess.Popen(['ping', '-c 4', 'python.org'], 
                           stdout=subprocess.PIPE,
                           universal_newlines=True)

while True:
    output = process.stdout.readline()
    print(output.strip())
    # Do something else
    return_code = process.poll()
    if return_code is not None:
        print('RETURN CODE', return_code)
        # Process has finished, read rest of the output 
        for output in process.stdout.readlines():
            print(output.strip())
        break
```

    PING python.org (45.55.99.72) 56(84) bytes of data.
    64 bytes from 45.55.99.72 (45.55.99.72): icmp_seq=1 ttl=51 time=117 ms
    64 bytes from 45.55.99.72 (45.55.99.72): icmp_seq=2 ttl=51 time=118 ms
    64 bytes from 45.55.99.72 (45.55.99.72): icmp_seq=3 ttl=51 time=117 ms
    64 bytes from 45.55.99.72 (45.55.99.72): icmp_seq=4 ttl=51 time=118 ms
    
    --- python.org ping statistics ---
    RETURN CODE 0
    4 packets transmitted, 4 received, 0% packet loss, time 3001ms
    rtt min/avg/max/mdev = 117.215/117.874/118.358/0.461 ms


You can use the `.poll()` function to check the return code of the process. It will return `None` while the process is still running. To get the output, you can use `process.stdout.readline()` to read a single line. Conversely, when you use `process.stdout.readlines()`, it reads all lines and it also waits for the process to finish if it has not finished yet. For more information on the functionionality of `subprocess.Popen`, have a look at the [documentation](https://docs.python.org/3/library/subprocess.html#subprocess.Popen). 

Also note, that you won't need quotations for arguments with spaces in between like `'\"More output\"'`. If you are unsure how to tokenize the arguments from the command, you can use the [shlex.split()](https://docs.python.org/3/library/shlex.html#shlex.split) function:


```python
import shlex
shlex.split("/bin/prog -i data.txt -o \"more data.txt\"")
```




    ['/bin/prog', '-i', 'data.txt', '-o', 'more data.txt']



You have also the [subprocess.call()](https://docs.python.org/3/library/subprocess.html#subprocess.call) function to your disposal which works like the `Popen` class, but it waits until the command completes and gives you the return code as in `return_code = subprocess.call(['echo', 'Even more output'])`. Another neat function that you can use is [subprocess.run()](https://docs.python.org/3/library/subprocess.html#subprocess.run) which works since Python 3.5. It has been added as a simplification of `subprocess.Popen`. The function will return a [subprocess.CompletedProcess](https://docs.python.org/3/library/subprocess.html#subprocess.CompletedProcess) object:


```python
process = subprocess.run(['echo', 'Even more output'], 
                         stdout=subprocess.PIPE, 
                         universal_newlines=True)
process
```




    CompletedProcess(args=['echo', 'Even more output'], returncode=0, stdout='Even more output\n')



You can now find the resulting output in this variable:


```python
process.stdout
```




    'Even more output\n'



Similar to `subprocess.call()` and the previous `.communicate()` function, it will wait untill the process is completed. Finally, here is a more advanced example on how to access a server with ssh and the `subprocess` module:


```python
import subprocess

ssh = subprocess.Popen(["ssh", "-i .ssh/id_rsa", "user@host"],
                        stdin =subprocess.PIPE,
                        stdout=subprocess.PIPE,
                        stderr=subprocess.PIPE,
                        universal_newlines=True,
                        bufsize=0)
 
# Send ssh commands to stdin
ssh.stdin.write("uname -a\n")
ssh.stdin.write("uptime\n")
ssh.stdin.close()

# Fetch output
for line in ssh.stdout:
    print(line.strip())
```

Here you can see how to write input to the process. In this case you need to set the `bufsize=0` in order to have unbuffered output. After you are finished writing to the `stdin`, you need to close the connection.

# Conclusion

You have seen now how to run external commands in Python. The most effective way is to use the `subprocess` module with all the functionality it offers. For a short and quick script you might just want to use the `os.system()` or `os.popen()` functions. If you have any questions, feel free to leave them in the comments below.

## Further Reading

- [4 Techniques for Testing Python Command-Line (CLI) Apps](https://realpython.com/python-cli-testing/)
- [Frequently Used Arguments - subprocess](https://docs.python.org/3/library/subprocess.html#frequently-used-arguments)