# Hemi Node Quick Start

This document is a quick-start guide to set up and run the Hemi stack with P2P nodesÒ and RPC access. *This does not set
up a batcher or sequencer.*

> [!NOTE]
> This guide is only for users looking to run a node on the Hemi Network, and is not required to use a wallet (e.g.
> Rabby, Metamask, etc.) to interact with the Hemi Network, or run a PoP Miner.

> [!IMPORTANT]
> **This is the quick-start guide, and glosses over the details of running a node.**
> For more information, please see our [full setup guide](setup.md).

**Table of Contents**

* [Prerequisites](#prerequisites)
  * [System Requirements](#system-requirements)
  * [ulimits](#ulimits)
* [Setup](#setup)
  * [Mainnet (snap sync)](#mainnet-snap-sync)
  * [Testnet (snap sync)](#testnet-snap-sync)

---

## Prerequisites

This guide assumes you have the following software installed and are using Ubuntu 24.04 or newer. Running on other
systems is possible, but may not be fully supported.

- `git`
- `jq`
- `docker` and `docker-compose` (https://docs.docker.com/engine/install/ubuntu/)

### System Requirements

> [!IMPORTANT]
> NVMe disks are highly recommended to ensure performance.

| Profile    | CPU Cores | Memory | Disk |
|------------|-----------|--------|------|
| `hemi-min` | 2         | 12GiB  | 2TiB |

> [!WARNING]
> Over time, the amount of disk space required will grow. These values represent the current requirements (as of 2025),
> with a buffer that should be sufficient for at least another year. It is highly recommended to monitor disk usage to
> prevent the node from running out of disk space.

### ulimits

Certain components of the network require a very large number of open files. The Docker Compose file will attempt to
change the necessary ulimits automatically.

---

## Setup

> [!IMPORTANT]
> This guide sets up snap-sync nodes, using the `hemi-min` Docker compose profile. The following components will run:
>
>  - `bssd` (Bitcoin Secure Sequencer)
>  - `op-geth-l2` (Hemi L2 geth node)
>  - `op-node` (Hemi L2 op-node)

### Mainnet (snap sync)

1. Clone the repository:
    ```sh
    git clone https://github.com/hemilabs/hemi-node.git
    cd hemi-node 
    ```

2. Prepare the configuration files (**mainnet** with snap sync, hemi-min profile):
    ```sh
    ./scripts/gen.sh mainnet snap hemi-min
    # gen: Generating files for mainnet (sync mode: snap, profile: hemi-min)
    # gen: Generated ./mainnet/.env file
    # gen: Generated random ./mainnet/jwt.hex file
    # gen: Generated random ./mainnet/op-node-priv-key.txt file
    # gen: Generated random ./mainnet/cookie file
    # gen: Generated ./mainnet/entrypoint.sh
    #
    # gen: Setup complete! (mainnet, sync mode: snap, profile: hemi-min)
    # gen:  ./scripts/gen.sh on Tue Oct 14 19:17:41 AEDT 2025 (version=v0.0.0 commit=d929f26 state=clean)
    # gen:
    # gen: Next steps:
    # gen: 1. Configure your Ethereum RPC providers:
    # gen:    - Edit mainnet/.env and add:
    # gen:        GETHL1ENDPOINT=<your Ethereum RPC URL>
    # gen:        PRYSMENDPOINT=<your Prysm RPC URL>
    # gen:
    # gen: 2. Start your node:
    # gen:      cd mainnet
    # gen:      docker compose --profile hemi-min up --build -d
    # gen:
    # gen: 3. Monitor your node:
    # gen:      ./heminode.sh
    ```

3. Configure your Ethereum RPC providers:
    - Edit `mainnet/.env` and add:
      ```
      GETHL1ENDPOINT=<YOUR_ETHEREUM_RPC_URL>
      PRYSMENDPOINT=<YOUR_PRYSM_RPC_URL>
      ```

4. Start the node:
    ```sh
    cd mainnet
    docker compose --profile hemi-min up --build -d
    ```

### Testnet (snap sync)

1. Clone the repository:
    ```sh
    git clone https://github.com/hemilabs/hemi-node.git
    cd hemi-node
    ```

2. Prepare the configuration files (**testnet** with snap sync, hemi-min profile):
    ```sh
    ./scripts/gen.sh testnet snap hemi-min
    # gen: Generating files for testnet (sync mode: snap, profile: hemi-min)
    # gen: Generated ./testnet/.env file
    # gen: Generated random ./testnet/jwt.hex file
    # gen: Generated random ./testnet/op-node-priv-key.txt file
    # gen: Generated random ./testnet/cookie file
    # gen: Generated ./testnet/entrypoint.sh
    #
    # gen: Setup complete! (testnet, sync mode: snap, profile: hemi-min)
    # gen:  ./scripts/gen.sh on Tue Oct 14 19:17:41 AEDT 2025 (version=v0.0.0 commit=d929f26 state=clean)
    # gen:
    # gen: Next steps:
    # gen: 1. Configure your Ethereum RPC providers:
    # gen:    - Edit testnet/.env and add:
    # gen:        GETHL1ENDPOINT=<your Ethereum RPC URL>
    # gen:        PRYSMENDPOINT=<your Prysm RPC URL>
    # gen:
    # gen: 2. Start your node:
    # gen:      cd testnet
    # gen:      docker compose --profile hemi-min up --build -d
    # gen:
    # gen: 3. Monitor your node:
    # gen:      ./heminode.sh
    ```

3. Configure your Ethereum RPC providers:
    - Edit `testnet/.env` and add:
      ```
      GETHL1ENDPOINT=<YOUR_ETHEREUM_RPC_URL>
      PRYSMENDPOINT=<YOUR_PRYSM_RPC_URL>
      ```

4. Start the node:
    ```sh
    cd testnet
    docker compose --profile hemi-min up --build -d
    ```
