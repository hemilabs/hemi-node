# Hemi Node Setup

This document is a guide to set up and run the Hemi stack with P2P nodes and RPC access. *This does not set up a
batcher or sequencer.*

> [!NOTE]
> This guide is only for users looking to run a node on the Hemi Network, and is not required to use a wallet (e.g.
> Rabby, Metamask, etc.) to interact with the Hemi Network, or run a PoP Miner.

**Table of Contents**
<!-- TOC -->
* [Hemi Node Setup](#hemi-node-setup)
  * [Prerequisites](#prerequisites)
    * [System Requirements](#system-requirements)
    * [ulimits](#ulimits)
  * [Installation and setup](#installation-and-setup)
<!-- TOC -->

---

## Prerequisites

This guide assumes you have the following software installed and are using Ubuntu 24.04 or newer. Running on other
systems is possible, but may not be fully supported.

- `git`
- `jq`
- `docker` and `docker-compose-plugin` (https://docs.docker.com/engine/install/ubuntu/)

### System Requirements

> [!IMPORTANT]
> NVMe disks are highly recommended to ensure performance.

| Profile                                      | CPU Cores | Memory | Disk |
|----------------------------------------------|-----------|--------|------|
| [`full`](./profiles.md#profile-full)         | 8         | 40GiB  | 6TiB |
| [`hemi`](./profiles.md#profile-hemi)         | 2         | 16GiB  | 3TiB |
| [`hemi-min`](./profiles.md#profile-hemi-min) | 2         | 12GiB  | 2TiB |
| [`l1`](./profiles.md#profile-l1)             | 6         | 24GiB  | 3TiB |

> [!WARNING]
> Over time, the amount of disk space required will grow. These values represent the current requirements (as of 2025),
> with a buffer that should be sufficient for at least another year. It is highly recommended to monitor disk usage to
> prevent the node from running out of disk space.

### ulimits

Certain components of the network require a very large number of open files. The Docker Compose file will attempt to
change the necessary ulimits automatically.

---

## Installation and setup
