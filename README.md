# Local Gameserver Cluster using Minikube
## Prerequisites

What you will need to make this work (I recommend using [Chocolatey](https://chocolatey.org/) for all your installation needs):

- OS: Windows 10 Professional (needed for Hyper-V below)
- Install [Docker Desktop](https://www.docker.com/products/docker-desktop) (`choco install docker-desktop`)
    - Strictly speaking you only need something that will allow you to run `docker` commands from the powershell CLI 
- Install [Minikube](https://minikube.sigs.k8s.io/docs/start/) (`choco install minikube`)
- Install [Kubernetes CLI](https://kubernetes.io/releases/download/) (`choco install kubernetes-cli`)
- Install [Terraform](https://www.terraform.io/downloads) (`choco install terraform`)
- Enable  [Virtualisation](https://www.google.com/search?q=how+to+enable+virtualization+BIOS) in your BIOS and [HyperV](https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v) on Windows
- Administrator privileges - in order to run under Hyper-V the scripts will need to be run from a shell with administrator privileges.

## Manual Changes

I would love for everything to be automatic, but it is not quite there yet, and the number of barriers in terms of getting everything to talk to each other for this config means that I need to not look at this for a while before tackling it. 

There is a line of config that needs to be manually changed so that it will work on whatever network you run this on. It is the piece of YAML below in the `main.tf` file of the `tf-agones` folder specifying ranges that metallb can use. I can think of a couple of different approaches to auto-detect this, or at least guess at it, and insert it in dynamically, but for now it is something you have to change manually yourself. The placeholder values are documentation IP addresses and will not work as-is

```YAML
addresses:
  - 192.0.2.225-192.0.2.250
```
## Purpose

This config starts a local [kubernetes](https://kubernetes.io/) cluster using [minikube](https://minikube.sigs.k8s.io/) and including [Agones](https://agones.dev/site/). It also starts a local docker registry to push images to so that they can be used to run the images locally. The intent is to run a fleet of UE4/Agones gameservers in a local kubernetes environment that mimics a live environment more closely. It is intended to run on Windows as natively as possible but with a few tweaks it could be made to run under Linux/WSL also. Nonetheless, the containers are still Linux based under the hood, so when compiling on Windows, the gameserver binary will need to be Linux based. 

### Using Xonotic

In order to provide a fully working example, this config pulls down a gameserver image for [Xonotic](https://xonotic.org/), the open source FPS shooter. It then re-tags the image and uploads it to the local registry to demonstrate that aspect working. It is intended to be very easy to substitute your own Agones compatible binary into the config and run that instead.

## Using the Cluster

Before we start, the first thing to make sure of is that your CLI is an Administrator shell, otherwise this will not work.

### Create the Cluster

Terraform is used to start the cluster, but to ensure creation in the right order, it needs to be explicitly done in several stages, hence we have a couple of helper powershell scripts. The first one validates/applies the configs in the needed order:

```shell
# just run in powershell from the root of this repo
./deploy.ps1 apply
```
**Note:** any other value other than `apply` as an argument just validates the config and makes no actual changes

### Destroy the cluster

Similar to creation, once you are finished with the cluster, terraform will take care of tearing everything down, but needs a little help to get the order right:

```shell
./destroy.ps1
```

### Check to see if your gameserver is running

```shell
minikube -p gs-cluster kubectl -- -n gameservers get gameservers
minikube -p gs-cluster kubectl -- -n gameservers get pods -o wide
etc.
```

## Playing a Game on your Cluster

The ultimate test is, of course, playing an actual game on your shiny new gameserver. To do this, just [download Xonotic](https://xonotic.org/download/), enter the IP:PORT of your gameserver into the multiplayer config screen, hit Join, and hopefully blast away at the bots!

## Pushing a gameserver image to the local registry

First you need to build a Linux gameserver image. If you are using Unreal Engine, you can still build a binary for Linux on Windows by [cross compiling](https://docs.unrealengine.com/4.27/en-US/SharingAndReleasing/Linux/GettingStarted/)

## Build your docker image with a tag using the sample Dockerfile

**Note:** the `gs-folder` referenced in the Dockerfile must be local to the folder, you cannot use absolute paths to grab the files from elsewhere (this is a feature of docker). The assumption is that this folder will contain the "LinuxServer" folder produced by your gameserver build. Similarly, the shell files referenced will start your gameserver as you see fit, and I have included an example of adding Agones configuration options to an Unreal Engine game for reference.

```sh
cd docker
docker build . -t xonotic-gameserver:latest
```

2. Tag your local image with the local registry

```sh
docker tag xonotic-gameserver:latest localhost:5001/xonotic-gameserver:latest
```

3. Push your image to the local registry

```sh
docker push localhost:5001/xonotic-gameserver:latest
```
## Scaling up the Fleet

Now that have a functioning single gameserver, how do we create more? Easy, just scale up the fleet:

```shell
minikube -p gs-cluster kubectl -- -n gameservers scale fleet local-fleet --replicas=1
```