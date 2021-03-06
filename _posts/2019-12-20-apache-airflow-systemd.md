---
title: "How to Manage Apache Airflow with Systemd on Debian or Ubuntu"
category: blog
comments: True
image: /assets/apache_airflow_systemd_files/airflow.jpg
imagesource: Apache Airflow
imageurl: https://airflow.apache.org/
layout: post
tags: ['Python', 'Apache Airflow', 'Systemd', 'Server']
---
[Apache Airflow](https://airflow.apache.org/) is a powerfull workflow management system which you can use to automate and manage complex [Extract Transform Load (ETL)](https://en.wikipedia.org/wiki/Extract,_transform,_load) pipelines. In this tutorial you will see how to integrate Airflow with the [systemd](https://www.freedesktop.org/wiki/Software/systemd/) system and service manager which is available on most Linux systems to help you with monitoring and restarting Airflow on failure.

Apache Airflow goes by the principle of _configuration as code_ which lets you programmatically configure and schedule complex workflows and also monitor them. This is great if you have big data pipelines with lots of dependencies to take care. If you haven't installed Apache Airflow yet, have a look at this [installation guide](https://airflow.readthedocs.io/en/stable/installation.html) and this [tutorial](https://airflow.readthedocs.io/en/stable/tutorial.html) which should bring you up to speed.

Systemd is an [init](https://en.wikipedia.org/wiki/Init) system, which is the first process (with PID 1) that bootstraps the user space and manages user processes. It is widely used on most Linux distributions and it simplifies common sysadmin tasks like checking and configuring services, mounted devices and system states. To interact with systemd, you have a whole suite of command-line tools at your disposal, but for this tutorial you will need only need `systemctl` and `journalctl`. `systemctl` is responsible for starting, stopping, restarting and checking the status of systemd services and `journalctl` on the other hand is a tool to explore the logs generated by the systemd units.

# Apache Airflow Unit Files

In systemd, the managed resources are refered as _units_ which are configured with _unit files_ stored in the `/lib/systemd/system/` folder. The configuration of these files follow the [INI](https://en.wikipedia.org/wiki/INI_file) file format. These units can have different categories, but for the sake of this tutorial we will focus only on _service units_ whose files are suffixed with `.service`. Each unit file consists of _sections_ specified with square brackets and that are case-sensitive. Inside the sections you will find the _directives_ which are defined as `key=value` pairs. The `[Unit]` section is responsible for metadata and describing the relationship to other units. The `[Service]` section provides the main configuration for the service and finally the `[Install]` section defines what should happen when the unit is enabled. This is only scratching the surface, but you will find an extensive tutorial covering systemd units in this [article](https://www.digitalocean.com/community/tutorials/understanding-systemd-units-and-unit-files).

You can find unit files for Apache Airflow in [airflow/scripts/systemd](https://github.com/apache/airflow/tree/master/scripts/systemd), but those are specified for Red Hat Linux systems. If you are not using the distributed task queue by [Celery](http://www.celeryproject.org/) or network authentication with [Kerberos](https://web.mit.edu/kerberos/) you will only need `airflow-webserver.service` and `airflow-scheduler.service` unit files. You will need to do some changes to those files. The unit files shown in this tutorials are working for Apache Airflow installed on an [Anaconda virtual environment](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html). Here is the unit file for `airflow-webserver.service`:

```ini
[Unit]
Description=Airflow webserver daemon
After=network.target postgresql.service mysql.service redis.service rabbitmq-server.service
Wants=postgresql.service mysql.service redis.service rabbitmq-server.service

[Service]
EnvironmentFile=/home/airflow/airflow.env
User=airflow
Group=airflow
Type=simple
ExecStart=/bin/bash -c 'source /home/user/anaconda3/etc/profile.d/conda.sh; \
    conda activate ENV; \
    airflow webserver'
Restart=on-failure
RestartSec=5s
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

This unit file needs a user called `airflow`, but if you want to use it for a different user, change the directives `User=` and `Group=` to the desired user. You might notice that the `EnvironmentFile=` and `ExecStart=` directives are changed. The `EnvironmentFile=` directive specifies the path to a file with environment variables that can be used by the service. Here you can define variables like `SCHEDULER_RUNS`, `AIRFLOW_HOME` or `AIRFLOW_CONFIG`. Make sure that this file exists even if there are no variables defined. You can find in [airflow/scripts/systemd/airflow](https://github.com/apache/airflow/blob/master/scripts/systemd/airflow) a template that you can copy. The `ExecStart=` directive defines the full path (!) and arguments of the command that you want to execute. Have a look at the [documentation](https://www.freedesktop.org/software/systemd/man/systemd.service.html#Command%20lines) to know how this directive needs to formatted. In this case we want to activate the Anaconda environment before starting airflow.

Here, similar to the previous unit file, is the unit file for `airflow-scheduler.service`:

```ini
[Unit]
Description=Airflow scheduler daemon
After=network.target postgresql.service mysql.service redis.service rabbitmq-server.service
Wants=postgresql.service mysql.service redis.service rabbitmq-server.service

[Service]
EnvironmentFile=/home/airflow/airflow.env
User=airflow
Group=airflow
Type=simple
ExecStart=/bin/bash -c 'source /home/user/anaconda3/etc/profile.d/conda.sh; \
    conda activate ENV; \
    airflow initdb; \
    airflow scheduler'
Restart=always
RestartSec=5s

[Install]
WantedBy=multi-user.target
```

Note, that we have defined multiple services in `After=` and `Wants=`. These units don't have to exist, but you can install them once you need them. For example the `postgresql.service` is available once you install the [PostgreSQL](https://www.postgresql.org/) database. 

If you need the other services like `airflow-worker.service` (celery worker), `airflow-flower.service` (celery flower) or `airlfow-kerberos.service` (kerberos ticket renewer) you can copy the files from the [airflow/scripts/systemd/](https://github.com/apache/airflow/tree/master/scripts/systemd) scripts, where you need to adapt the `EnvironmentFile` and `ExecStart` directives as shown here with the webserver and scheduler.

# Starting and Managing the Apache Airflow Unit Files

This two unit files now need to be saved (or linked) to the `/lib/systemd/system/` folder. Now, to activate those you first need to reload the systemd manager configuration with:

    sudo systemctl daemon-reload
    
Next, you can start the services with:

    sudo systemctl start airflow-webserver.service
    sudo systemctl start airflow-scheduler.service
    
If you did everything right you should see an active service when you check the status with:

    sudo systemctl status airflow-webserver.service
    sudo systemctl status airflow-scheduler.service

This shows also the most recent logs for that service which is handy to see what has gone wrong. To have the service start when you restart your server/computer you need to enable the services with:

    sudo systemctl enable airflow-webserver.service
    sudo systemctl enable airflow-scheduler.service

To disable a service use `sudo systemctl disable your-service.service` and to stop a service use `sudo systemctl stop your-service.service`. Sometimes you also need to debug a service. This can be done by checking the logs with `journalctl`. For example if you want to check the last 10 log entries for a particular unit you can type:

    sudo journalctl -u your-service.service -n 10

If you want to see the 10 last log entries for both services you can type:

    sudo journalctl -u airflow-webserver.service -u airflow-scheduler.service -n 10

For more useful commands and arguments have a look at this [Systemd cheatsheet](https://janakiev.com/blog/systemd-cheatsheet/).

# Conclusion

In this tutorial you have seen how to run Apache Airflow with systemd on Debian or Ubuntu. We have also scratched the surface on the things you can do with systemd to help you with monitoring and managing services. To delve deeper into this topic, I recommend the following list of articles that were highly helpful in grasping the topics covered here.

## Resources

- [Systemd Cheatsheet](https://janakiev.com/blog/systemd-cheatsheet/)
- [How To Use Systemctl to Manage Systemd Services and Units](https://www.digitalocean.com/community/tutorials/how-to-use-systemctl-to-manage-systemd-services-and-units)
- [How To Use Journalctl to View and Manipulate Systemd Logs](https://www.digitalocean.com/community/tutorials/how-to-use-journalctl-to-view-and-manipulate-systemd-logs)
- [Understanding Systemd Units and Unit Files](https://www.digitalocean.com/community/tutorials/understanding-systemd-units-and-unit-files)
- [Using environment variables in systemd units](https://coreos.com/os/docs/latest/using-environment-variables-in-systemd-units.html)
- [systemd for Administrators, Part 1](http://0pointer.de/blog/projects/systemd-for-admins-1.html), [Part 2](http://0pointer.de/blog/projects/systemd-for-admins-2.html), [Part 3](http://0pointer.de/blog/projects/systemd-for-admins-3.html) by Lennart Poettering, the creator of systemd