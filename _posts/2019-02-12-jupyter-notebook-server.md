---
title: "Installing and Running Jupyter Notebooks on a Server"
category: blog
comments: True
featured: True
image: /assets/jupyter_notebook_server_files/Leitstand_2.jpg
imagesource: Wikimedia Commons
imageurl: https://commons.wikimedia.org/wiki/File:Leitstand_2.jpg
layout: post
tags: ['Jupyter', 'Data Science', 'Server']
---
Jupyter Notebook is a powerful tool, but how can you use it in all its glory on a server? In this tutorial you will see how to set up Jupyter notebook on a server like [Digital Ocean](https://m.do.co/c/cd7e4dd5ee1f), [AWS](https://aws.amazon.com/) or most other hosting provider available. Additionally, you will see how to use Jupyter notebooks over SSH tunneling or SSL with with [Let's Encrypt](https://letsencrypt.org/).

[Jupyter Notebook](https://jupyter.org/) is an open source web application that enables interactive computing from the browser. You can create documents that feature live code, documentation with Markdown, equations, visualization and even widgets and other interesting capabilities. Jupyter comes from the three core languages that are supported: Julia, Python, and R. Jupyter connects to a kernel with a specific language, the most common being the IPython kernel. It supports a [whole variety](https://github.com/jupyter/jupyter/wiki/Jupyter-kernels) of kernels and you should find most languages you need. This tutorial was written in [JupyterLab](https://jupyterlab.readthedocs.io/en/stable/), the next developments of Jupyter notebook:

![JupyterLab]({{ site.baseurl }}/assets/jupyter_notebook_server_files/jupyterlab.png)

In this tutorial we will be working with Ubuntu 16.04/18.04 servers, but most steps should be fairly similar for Debian 8/9 distributions. We will first go through creating SSH keys, adding a new user on the server, and installing Python and Jupyter with [Anaconda](https://www.anaconda.com/). Next, you will setup Jupyter to run on the server. Finally, you can either choose to run Jupyter notebooks over SSH tunneling or over SSL with [Let's Encrypt](https://letsencrypt.org/).

# Create SSH Keys

We are starting with a fresh server and in order to add more security when accessing your server, you should consider using SSH key pairs. These key pairs consist of a public key which is uploaded to the server and a private key that stays on your machine. Some hosting providers require you to upload the public key before creating the server instance. To create a new SSH key you can use the [ssh-keygen](https://www.ssh.com/ssh/keygen/) tool. To create the key pairs you can simply type the command:

```
ssh-keygen
```

this will prompt you to add the file path and a passphrase if you want to. There are other arguments of options you can choose from like public key algorithm or file name. You can find a very good tutorial [here](https://www.ssh.com/ssh/keygen/) on how to create a new SSH key with ssh-keygen for Linux or macOS. If you are using Windows, you can create SSH-keys with PuTTYgen as described [here](https://www.ssh.com/ssh/putty/windows/puttygen). If your hosting provider does not need a public key before creation you can copy the public key with the [ssh-copy-id](https://www.ssh.com/ssh/copy-id) tool:

```bash
ssh-copy-id -i ~/.ssh/jupyter-cloud-key user@host
```

Finally, you can connect to your server with:

```
ssh -i ~/.ssh/id_rsa root@host
```

where `~/.ssh/id_rsa` is the path to your ssh private key and `host` is the host address or IP address of you server instance.

# Adding a New User

In some servers you start off as a root user. It is considered bad practice to work directly with the root since it has a lot of privileges which can be destructive if some commands are done by accident. If you already have a user you can skip this section. Note that you can replace `cloud-user` in all the following commands with the user name you want. Start by creating a new user:

    adduser cloud-user

This command will ask you a couple of questions including a password. Next, you'll want to grant administrative privileges to this user. You can do this by typing

    usermod -aG sudo cloud-user

Now you are ready to switch to the new user with `su cloud-user` or by connecting to your server with `ssh cloud-user@host`. Optionally, you can add the SSH keys of the root user to the new user for additional security. Otherwise you can skip to the next section on how to install Anaconda. Now, if you you have existing SSH keys for the root user you can copy the public key from the root home folder to the users home folder like shown here:
    
    mkdir /home/cloud-user/.ssh
    cp /root/.ssh/authorized_keys /home/cloud-user/.ssh/
    
Next, you need to change the permissions for both the folder and the public key:
    
    cd /home/user/
    chmod 700 .ssh/
    chmod 600 .ssh/authorized_keys
    
If you are using a password for your user you need to update `/etc/ssh/sshd_config`:

    nano /etc/ssh/sshd_config

There you want to find the line `PasswordAuthentication no` and change the `no` to a `yes` to allow password authentication. Finally you want to restart the SSH service by typing `service ssh restart`. For other distributions have a look into [this](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-18-04) guide, where you will also see how to set up a firewall.

# Installing Anaconda

[Anaconda](https://www.anaconda.com/) is an open-source distribution of Python (and R) for scientific computing including package management and deployment. With it, you have most tooling that you need including Jupyter. To install Anaconda, go to the [downloads](https://www.anaconda.com/download/#linux) for linux and copy the Linux installer link for the latest Python 3.x version. Then you can download the installer with `wget`:

    wget https://repo.anaconda.com/archive/Anaconda3-5.2.0-Linux-x86_64.sh
    
Next you can install Anaconda by using `bash` as follows:

    bash Anaconda3-5.2.0-Linux-x86_64.sh
    
During installation, it is important to type `yes` when the following prompt appears during the installation:

    Do you wish the installer to prepend the Anaconda3 install location
    to PATH in your /home/user/.bashrc ? [yes|no]

After you finished installing you want to initialize the `conda` command line tool and package manager by Anaconda with: 

    source .bashrc 
    conda update conda

These two commands set up Anaconda on your server. If you have run the Anaconda bash file with sudo, you will get a `Permission denied` error. You can solve it as shown in this [question](https://stackoverflow.com/questions/49181799/conda-update-conda-permission-error) by typing `sudo chown -R $$USER:$$USER /home/user/anaconda3`. This changes the owner of this folder to the current user with the [chown](https://en.wikipedia.org/wiki/Chown) command.

# Starting Jupyter Notebook Server

Jupyter is installed with Anaconda, but we need to do some configuration in order to run it on the server. First, you'll want to create a password for Jupyter notebook. You can do this by starting the IPython shell with `ipython` and generating a password hash:

    from IPython.lib import passwd
    passwd()

Save this resulting hash for now, we will need it in a moment. Next, you want to generate a configuration file which you can create by typing.

    jupyter-notebook --generate-config

Now open the configuration file with `sudo nano ~/.jupyter/jupyter_notebook_config.py` and copy the following code into the file and replace the hash in this snippet with the one you have previously generated:
      
    c = get_config()  # get the config object
    # do not open a browser window by default when using notebooks
    c.NotebookApp.open_browser = False
    # this is the password hash that we generated earlier.
    c.NotebookApp.password = 'sha1:073bb9acaa67:b367308802ab66cb1d7654b6684eafefbd61d004'  

Now you should be set up. Next, you can decide whether you want to use SSH tunneling or you want to use SSL encryption and access your jupyter notebook over your own domain name.

# SSH Tunneling with Linux or MacOS

You can tunnel to your server by adding the `-L` argument to the `ssh` command, which is responsible for port forwarding. The first `8888` is the port you will access on your local machine (if you already use this port for another juypter instance you can use port 8889 or a different open port). You can access this then on your browser with `localhost:8888`. The second part `localhost:8888` specifies the jump server address accessed from the server. Since we want to run the notebook locally on the server, this is again localhost. This would mean that we access `localhost:8888` from the server via port forwarding to `localhost:8888` on our machine. Here is how the command would look like:

    ssh -L 8888:localhost:8888 cloud-user@host
    
If you have another Jupyter notebook running on your local machine already you can change the port to e.g. `8889` which would result in the command:

    ssh -L 8889:localhost:8888 cloud-user@host
  
Now, you can create a notebook folder for your projects on the server and run Jupyter notebook inside:
    
    mkdir notebook
    cd notebook/
    jupyter-notebook

You can also use [JupyterLab](https://jupyterlab.readthedocs.io/en/stable/) instead, which is a more powerful interface and it comes also pre-installed with Anaconda. You can start it by typing `jupyter-lab` instead of `juypter-notebook`.

# SSL Encryption with Let's Encrypt

It is also possible to use SSL encryption for your jupyter notebook. This enables you to access your Jupyter notebooks through the internet which makes it handy to share results with your colleagues. To do this you can use [Let's Encrypt](https://letsencrypt.org/), which is a free [Certificate Authority (CA)](https://en.wikipedia.org/wiki/Certificate_authority) that provides an easy way for TLS/SSL certificates. This can be done fully automated with their [certbot](https://certbot.eff.org/) tool. To find the installation guide for your system have a look at this [list](https://certbot.eff.org/all-instructions). For Ubuntu 18.04 the [installation](https://certbot.eff.org/lets-encrypt/ubuntubionic-apache.html) looks as follows:

    sudo apt-get update
    sudo apt-get install software-properties-common
    sudo add-apt-repository universe
    sudo add-apt-repository ppa:certbot/certbot
    sudo apt-get update
    sudo apt-get install certbot python-certbot-apache 

Now, you can run certbot for the domain that you have:

    sudo certbot certonly -d example.com

After going through the prompts, you should get to this output:

    IMPORTANT NOTES:
     - Congratulations! Your certificate and chain have been saved at:
       /etc/letsencrypt/live/example.com/fullchain.pem
       Your key file has been saved at:
       /etc/letsencrypt/live/example.com/privkey.pem
       Your cert will expire on 2019-05-09. To obtain a new or tweaked
       version of this certificate in the future, simply run certbot again
       with the "certonly" option. To non-interactively renew *all* of
       your certificates, run "certbot renew"
     - If you like Certbot, please consider supporting our work by:

       Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
       Donating to EFF:                    https://eff.org/donate-le

Great! You have your certificate and key file ready. Now you can use the certificate and key file in your jupyter notebook configuration file. Before you can do that, you need to change the owner of the certificate and key file with (change `user` with your own user name):
    
    sudo chown user /usr/local/etc/letsencrypt/live
    sudo chown user /usr/local/etc/letsencrypt/archive

Next, you can add the following code to the `~/.jupyter/jupyter_notebook_config.py` configuration file:

    # Path to the certificate 
    c.NotebookApp.certfile = '/etc/letsencrypt/live/example.com/fullchain.pem' 
    # Path to the certificate key we generated
    c.NotebookApp.keyfile = '/etc/letsencrypt/live/example.com/privkey.pem' 
    # Serve the notebooks for all IP addresses
    c.NotebookApp.ip = '0.0.0.0'
    
Finally, you can access Jupyter notebooks securely over `https://example.com:8888`. Just make sure to use `https://` instead of `http://`. If you made any mistakes, you can delete the certbot certificate with `sudo certbot delete` or `sudo certbot delete --cert-name example.com`. If you are using a firewall, make sure that port `8888` is open. Here is a good [guide](https://www.digitalocean.com/community/tutorials/ufw-essentials-common-firewall-rules-and-commands) on using the [Uncomplicated Firewall (UFW)](https://en.wikipedia.org/wiki/Uncomplicated_Firewall) firewall.

# Conclusion

You have learned how to set up Jupyter for a server from start to finish. This is a task that gets easier with every server set up that you do. Make sure to delve into the surrounding topics of Linux server administration since working with servers can be intimidating in the beginning. Using Jupyter you have access to a wide variety of kernels that enable you to use other languages. A list of all available kernels can be found [here](https://github.com/jupyter/jupyter/wiki/Jupyter-kernels). I hope this was helpful and if you have any further questions or remarks, feel free to share them in the comments bellow.

I covered in a [previous tutorial](https://janakiev.com/til/jupyter-virtual-envs/) how to work with virtual environments in Jupyter notebook. There is also an option to run Jupyter as a Docker container. You can use for example the [jupyter/datascience-notebook](https://hub.docker.com/r/jupyter/datascience-notebook/) container. You can read more on how to work with Jupyter and Docker in [this guide](https://jupyter-docker-stacks.readthedocs.io/en/latest/index.html). Here are further links that I have learned from and that might be useful for you too:

- [Initial Server Setup](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-18-04)
- [Running a notebook server](https://jupyter-notebook.readthedocs.io/en/stable/public_server.html)
- [How To Set Up Jupyter Notebook for Python 3](https://www.digitalocean.com/community/tutorials/how-to-set-up-jupyter-notebook-for-python-3)
- [How To Use Certbot Standalone Mode to Retrieve Let's Encrypt SSL Certificates](https://www.digitalocean.com/community/tutorials/how-to-use-certbot-standalone-mode-to-retrieve-let-s-encrypt-ssl-certificates-on-ubuntu-16-04)
- [UFW Essentials: Common Firewall Rules and Commands](https://www.digitalocean.com/community/tutorials/ufw-essentials-common-firewall-rules-and-commands)
- [Using Virtual Environments in Jupyter Notebook and Python](https://janakiev.com/til/jupyter-virtual-envs/)
- [Creating Slides with Jupyter Notebook](https://janakiev.com/til/creating-slides-with-jupyter-notebook/)

# References

- [How to use letsencrypt certificates in Jupyter and IPython](https://perrohunter.com/how-to-use-letsencrypt-certificates-in-jupyter/)
- [Adding SSL and a domain name to Jupyter Hub](https://pythonforundergradengineers.com/add-ssl-and-domain-name-to-jupyterhub.html)