# Athena OS Docker Image

![athena-banner](https://user-images.githubusercontent.com/83867734/221656804-51b13a4f-876b-4ca8-856e-288d2209a949.png)


Athena OS container brings you to live a funny hacking experience in a containerized environment:

* Select your favourite **InfoSec role** between Black Hat, Red Teamer, OSINT Specialist and much more
* Play **Hack The Box** machines for improving your skills
* Explore more than **2800+ hacking tools** retrievable by Arch Linux and BlackArch repositories
* Make your **Capture The Flag** or **ethical hacking** activity efficient

Find us at:

* [Discord](https://discord.gg/DNjvQkb5Ad) - realtime support / chat with the community and the team.
* [GitHub](https://github.com/Athena-OS) - view the source for all of our repositories.


## Usage

Athena OS container has been developed in order to be run by podman instead of docker. The choice to use podman comes from its advantages over docker, one of most important: security.

Install `podman` and `podman-compose` packages for your Linux environment.

Athena OS container allows you to learn and play on Hack The Box platform. It is possible to access to Hack The Box by using your App Token. Retrieve your App Token from the Hack The Box website in your Profile Settings.

Store your App Token in a file called `htb-api-file`, save and close it, and then run:

```
podman secret create htb-api htb-api-file
```
In this manner, podman will store securely your API key. Now, you can delete the `htb-api-file` by `rm -rf htb-api-file`.

You can run Athena OS container in two ways: by podman-compose or podman cli.

### podman-compose (recommended)

```yaml
version: '3.4'

services:
  athena:
    image: athenaos/coreathena
    cap_add:
      - net_admin
      - net_raw
    devices:
      - /dev/net/tun
    secrets:
       - htb-api
    tmpfs:
      - /run
      - /tmp
    restart: unless-stopped
```

### podman cli

```bash
podman run -d \
  --name=athena \
  --secret htb-api \
  --cap-add=NET_RAW \
  --cap-add NET_ADMIN \
  --device /dev/net/tun \
  --restart unless-stopped \
  docker.io/athenaos/core:latest
```

## Parameters

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| ---- | --- |
| `--secret htb-api` | usage of App Token on the container |
| `--cap-add=NET_RAW ` | needed for running ping command |
| `--cap-add NET_ADMIN` | needed for running OpenVPN |
| `--device /dev/net/tun` | needed for creating tun interface used by OpenVPN |

## Updating Info

Below are the instructions for updating containers:

### Via Podman Compose

* Update all images: `podman-compose pull`
  * or update a single image: `podman-compose pull athena`
* Let compose update all containers as necessary: `podman-compose up -d`
  * or update a single container: `podman-compose up -d athena`
* You can also remove the old dangling images: `podman image prune`

### Via Podman Run

* Update the image: `podman pull docker.io/athenaos/core:latest`
* Stop the running container: `podman stop athena`
* Delete the container: `podman rm athena`
* Recreate a new container with the same podman run parameters as instructed above (if mapped correctly to a host folder, your `/config` folder and settings will be preserved)
* You can also remove the old dangling images: `podman image prune`

## Building locally

If you want to make local modifications to these images for development purposes or just to customize the logic:

```bash
git clone https://github.com/Athena-OS/athena-core-docker.git
cd athena-core-docker
podman build \
  --no-cache \
  --pull \
  -t docker.io/athenaos/core:latest .
```

The ARM variants can be built on x86_64 hardware using `multiarch/qemu-user-static`

```bash
podman run --rm --privileged multiarch/qemu-user-static:register --reset
```

Once registered you can define the dockerfile to use with `-f Dockerfile.aarch64`. This method has not been tested yet.
