---
title: "Manage Jupyter Notebook and JupyterLab with Systemd"
category: blog
comments: True
image: /assets/jupyter_systemd_files/Activiteit_in_de_controle_kamer_in_de_Tap-Line_olie_terminal_nabij_Saida,_Bestanddeelnr_255-6308.jpg
imagesource: Wikimedia Commons
imageurl: https://commons.wikimedia.org/wiki/File:Activiteit_in_de_controle_kamer_in_de_Tap-Line_olie_terminal_nabij_Saida,_Bestanddeelnr_255-6308.jpg
layout: post
tags: ['Jupyter', 'Systemd', 'Server']
---
In this article you will see how to easily manage [Jupyter](https://jupyter.org/) Notebook and [JupyterLab](https://jupyterlab.readthedocs.io/en/stable/) by using the [Systemd](systemd.io) tooling. This is useful when you want to have an instance running local or on your server that you can manage and monitor.

What is Systemd and why do we need it? Systemd is an [init](https://en.wikipedia.org/wiki/Init) system in Linux used for system intialization and service management. This allows services configured for Systemd to manage and monitor them. This way, you can check if the service is still running, you can set it to automatically restart, you monitor the outputs of the service, and much more. To add Jupyter as a service we have to create a unit file. Let's have a look how that works.

# Create a Jupyter Unit File
    
Systemd uses unit files as its primary way to manage and configure system resources. These files are in the [INI](https://en.wikipedia.org/wiki/INI_file) file format and are stored in `/etc/systemd/system`. 

But before we start, we have to configure a password for Jupyter. Typically when running Jupyter, it would open a window in your browser with a generated token. In this case it will run in the background as a service and you would need to use a password. This can be done by generating hashed password and salt for use in notebook configuration with:

```bash
python -c "from IPython.lib.security import passwd; print(passwd('PASS'))"
```

Which should give you a hash like this one:

    sha1:137775e93d29:ba64d3b78e089f0f779167242ddb080a05c42a84

For more information on security, have a read on [Security in the Jupyter notebook server](https://jupyter-notebook.readthedocs.io/en/stable/security.html). Great, now let's continue to create a file with the name `jupyter.service` with the following contents:

```ini
[Unit]
Description=Jupyter Notebook

[Service]
Type=simple
PIDFile=/run/jupyter.pid
ExecStart=/home/user/anaconda3/bin/python -m jupyter-lab --notebook-dir=/home/user/notebooks --no-browser --NotebookApp.password='sha1:137775e93d29:ba64d3b78e089f0f779167242ddb080a05c42a84'
User=user
Group=user
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Each file has a few sections and each section like `[Unit]`, `[Service]`, and `[Install]` have various [directives](https://www.freedesktop.org/software/systemd/man/systemd.directives.html) that are used to configure a service. Most of them should already give a hint on what they are used for, but we will quickly go through some of them. To read more into detail how this works have a look at the tutorial [Understanding Systemd Units and Unit Files](https://www.digitalocean.com/community/tutorials/understanding-systemd-units-and-unit-files).

The most important one here is the `ExecStart=` directive, which specifies the command to be run. It is important to note, that only absolute paths should be used and that the `ExecStart=` directive has to be written in one line. In this case the unit files uses JupyterLab that is installed in the Anaconda base environment. If you use virtualenv instead, change the directive for `ExecStart=` to:

```bash
ExecStart=/bin/bash -f "source /home/user/notebooks/bin/activate; jupyter-lab --notebook-dir=/home/user/notebooks"
```

The `PIDFile=` directive specifies where the process identification number is stored. Make sure to have your user and group in the `User=` and `Group=` directives. The `Restart=` directive specifies if the service should be restarted when the service exits, is killed or a timeout is reached. `RestartSec=` specifies how long it should wait until the service will be then restarted.  You can read more about the directives in the [documentation](https://www.freedesktop.org/software/systemd/man/systemd.directives.html).

If you use more configuration and want to have it in a bash script instead, you can create a script like the following:

```bash
#!/bin/bash
/home/nikolai/anaconda3/bin/jupyter-lab \
  --notebook-dir=/home/user/notebooks \
  --ip='*' \
  --port=8888 \
  --NotebookApp.token='' \
  --NotebookApp.password='sha1:137...' \
  --no-browser
```

Then, replace the previous `ExecStart` with `ExecStart=/path/to/script.sh` in the unit file. Also, make sure to make it executable with `chmod +x /path/to/script.sh`. 

Finally, instead of using the argument `--notebook-dir`, you can specify the working directory by using the `WorkingDirectory=` directive.

# Enable and Start the Jupyter Service 

First, move the unit file to `/etc/systemd/system/` with:

```bash
sudo mv jupyter.service /etc/systemd/system/
```

Then, reload the systemd manager configuration with:

```bash
sudo systemctl daemon-reload
```

Next, enable the service to start at boot with:

```bash
sudo systemctl enable jupyter
```

To start the Jupyter service, you need to type:

```bash
sudo systemctl start jupyter
```

To check its status, you can type:

```bash
sudo systemctl status jupyter
```
    
Finally, you can monitor the outputs of the service with `sudo journalctl -u jupyter -f`. To show the log messages since the last boot (`-b`) and without additional fields like timestamp and hostname (`-o cat`), type:

```bash
sudo journalctl -u jupyter -b -o cat -f
```

This should show you a similar output to the following output:

```
Started Jupyter Notebook.
[I 18:54:36.878 LabApp] JupyterLab extension loaded from /home/user/anaconda3/lib/python3.7/site-packages/jupyterlab
[I 18:54:36.879 LabApp] JupyterLab application directory is /home/user/anaconda3/share/jupyter/lab
[I 18:54:36.880 LabApp] Serving notebooks from local directory: /home/user/notebooks
[I 18:54:36.880 LabApp] The Jupyter Notebook is running at:
[I 18:54:36.880 LabApp] http://0.0.0.0:8888/
```

This really useful if you need to have a look at what Jupyter logs out since some errors and logs are not visible within the notebooks. For more useful commands and arguments have a look at this [Systemd cheatsheet](https://janakiev.com/blog/systemd-cheatsheet/).

# Conclusion

Now, you should be able to manage and monitor your Jupyter service with Systemd. To learn how to install and configure Jupyter on a server including SSL/TLS, have a look at my previous guide on [Installing and Running Jupyter Notebooks on a Server](https://janakiev.com/blog/jupyter-notebook-server/)  Here are a few further resources when working with systemd:

- [Systemd Cheatsheet](https://janakiev.com/blog/systemd-cheatsheet/)
- [Understanding Systemd Units and Unit Files](https://www.digitalocean.com/community/tutorials/understanding-systemd-units-and-unit-files)
- [How To Use Systemctl to Manage Systemd Services and Units](https://www.digitalocean.com/community/tutorials/how-to-use-systemctl-to-manage-systemd-services-and-units)
- [How To Use Journalctl to View and Manipulate Systemd Logs](https://www.digitalocean.com/community/tutorials/how-to-use-journalctl-to-view-and-manipulate-systemd-logs)