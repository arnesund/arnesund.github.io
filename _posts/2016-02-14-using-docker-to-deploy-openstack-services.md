---
layout: post
title: "Docker + OpenStack = True"
date: "2016-02-14"
categories: 
  - "openstack"
tags: 
  - "consul"
  - "docker"
  - "docker-compose"
  - "docker-swarm"
  - "microservices"
  - "openstack"
---

![OpenStack and Docker](/assets/images/openstack-and-docker.png)

OpenStack has the potential to revolutionize how enterprises do virtualization, so lots of people are currently busy with setting up OpenStack private clouds. I've been part of such a project too. In this post, I'll explain why I believe Docker makes a lot of sense to use for deploying the services that together make up an OpenStack cloud. Docker features flexibility, orchestration, clustering and more.

## All about microservices

[OpenStack](http://www.openstack.org/) is commonly viewed as a platform for virtualization. However, under the hood OpenStack is nothing more than a bunch of microservices which end-users can interact with, either directly or through the Horizon UI. Most of the microservices are REST APIs for controlling different aspects of the platform (block storage, authentication, telemetry and so on). API nodes for an OpenStack cloud end up running dozens of small processes, each with their own distinct purpose. In such a setting, Dockerizing all these microservices makes a lot of sense.

## Flexibility and speed

Of several improvements Dockerizing brings, the most important is the flexibility. Running a [Docker Swarm](https://www.docker.com/products/docker-swarm) for OpenStack API services makes it possible to easily scale out by adding more swarm nodes and launching additional copies of the containers on them. Coupled with HAProxy, the new containers can join the backend pool for an API service in seconds and help alleviate high load. Sure, the same can be accomplished by adding physical API nodes, provision them with Chef/Puppet/Salt/Ansible and reconfigure HAProxy to include them in the backend pool for each service, but that takes considerably longer time than just launching more pre-built containers.

## Versioning and ease of debugging

Since Docker images are versioned and pushed to a central registry, it's trivial to ensure that all instances of a service run with identical configs, packages and libraries. Furthermore, even though a service like Nova typically consists of 4-5 different sub-services, all of them can share the same config and therefore use the same container image. The only difference is which command the container runs when started. Being able to easily check that all backend instances are identical (use the same version of the image) is important when debugging issues. Also, Docker Compose has built-in support for viewing logs from several containers sorted chronologically, no matter which physical node they run on. That also includes the option to follow logs in real-time from several containers at once.

## Orchestration and clustering

Using [Docker Compose](https://www.docker.com/products/docker-compose) to orchestrate microservices is important. Compose provides an interface to scale the number of containers for each service and supports constraints and affinities on where each container should run. For example if you run a clustered MySQL instance for the internal OpenStack databases, Compose can ensure that each database container runs on a different physical host than the others in the MySQL cluster. When creating container images for each service, an entrypoint shell script can be included and used to detect if there is an existing cluster to add itself to, or if this is the first instance of the service. Clustering the services that OpenStack APIs rely on (notably MySQL and RabbitMQ) becomes easier with this type of pattern.

## Service Discovery

A solution for Service Discovery is a requirement when operating dozens of microservices that expect to be able to find each other and talk together. In the Docker ecosystem, [Consul](https://www.consul.io/) is a great option for service discovery. Coupled with the [Registrator](https://github.com/gliderlabs/registrator) container deployed on each swarm node, all microservices that listen on a TCP/UDP port are automatically added as services in Consul. It's easy to query Consul for the IP addresses of a particular service using either the HTTP or DNS interface. With the right Consul setup, each Dockerized service can reference other services by their Consul DNS name in config files and so on. This way, no server names or IP addresses need to be hard coded in the config of each service, which is a great plus.

There are more desireable effects of Dockerizing OpenStack microservices, but the most important ones in my opinion are flexibility, ease of debugging, orchestration and service discovery. If you wonder why Docker doesn't just replace OpenStack entirely, I recommend reading [this TechRepublic article](http://www.techrepublic.com/article/openstack-is-overkill-for-docker/). There Matt Asay points out that a common enterprise pattern is to utilize OpenStack for its strong multi-tenancy model. Applications can in that case be deployed with Docker on top of VMs provisioned using OpenStack, which I think will be a very useful way of utilizing OpenStack and Docker for big enterprises with a diverse set of applications, departments and users.

~ Arne ~
