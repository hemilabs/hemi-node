# Hemi Node Profiles

The Docker compose files support running multiple different profiles, depending on your use case and requirements.

> [!TIP]
> For most use cases, the [`hemi-min` profile](#profile-hemi-min) is recommended.

Each profile runs a different set of components, and has a different use case.

- [**`full` profile** - Runs every required component](#profile-full)
  - Includes all Hemi L2 components
  - Includes BFG (used for PoP Mining) and the required `electrs` indexer
  - Includes Ethereum L1 nodes
  - Includes Bitcoind node (used by `electrs`)

- [**`hemi` profile** - Runs the Hemi components, using external RPC endpoints](#profile-hemi)
  - Includes all Hemi L2 components
  - Includes BFG (used for PoP mining) and the required `electrs` indexer
  - External RPC endpoints are required for:
    - Ethereum L1 nodes (geth and prysm)
    - Bitcoind (used by BFG through `electrs`)

- [**`hemi-min` profile - Lightweight profile**](#profile-hemi-min)
  - Includes all Hemi L2 components
  - Does not include BFG (and its required `electrs` indexer)
  - External RPC endpoints are required for:
    - Ethereum L1 nodes (geth and prysm)

- [**`l1` profile - Ethereum and Bitcoin L1 components only**](#profile-l1)
  - Ethereum L1 nodes (geth and prysm)
  - Bitcoind node

| Profile            | `full` | `hemi`       | `hemi-min`   | `l1` |
|--------------------|--------|--------------|--------------|------|
| Hemi `op-geth`     | ✅      | ✅            | ✅            |      |
| Hemi `op-node`     | ✅      | ✅            | ✅            |      |
| Hemi `bssd`        | ✅      | ✅            | ✅            |      |
| Hemi `bfgd`        | ✅      | ✅            |              |      |
| Ethereum `prysm`   | ✅      | RPC required | RPC required | ✅    |
| Ethereum `geth`    | ✅      | RPC required | RPC required | ✅    |
| Bitcoin `bitcoind` | ✅      | RPC required |              | ✅    |
| Bitcoin `electrs`  | ✅      | ✅            |              |      |

> [!IMPORTANT]
> Each profile has entirely different system requirements. Please
> see [System Requirements](setup.md#system-requirements) for up-to-date requirements for each profile.

## Profile `full`

Runs a Hemi L2 node (`op-geth` and `op-node`), Hemi Bitcoin Finality Governor (used by PoP Miners) and Ethereum L1
components.

> [!WARNING]
> This profile runs Ethereum L1 components, in addition to the Hemi L2 components. This profile requires significantly
> more disk capacity in order to store L1 data.
>
> In most cases, it is preferable to use the `hemi` or `hemi-min` profile and provide RPC endpoints for external
> Ethereum L1 nodes.

**Services**

| Service         | Description                                         |
|-----------------|-----------------------------------------------------|
| `bfgd`          | Hemi Bitcoin Finality Governor (used by PoP Miners) |
| `bfgd-postgres` | PostgreSQL database for `bfgd`                      |
| `bitcoind`      | Bitcoin full node (used by `electrs`)               |
| `electrs`       | Bitcoin indexer (used by `bfgd`)                    |
| `bssd`          | Hemi Bitcoin Secure Sequencer                       |
| `op-geth-l2`    | Hemi L2 op-geth node                                |
| `op-node`       | Hemi L2 op-node                                     |
| `geth-l1`       | Ethereum L1 geth node                               |
| `prysm`         | Prysm (L1)                                          |

**Init containers**

| Service               | Description                                                   |
|-----------------------|---------------------------------------------------------------|
| `op-geth-l2-init`     | Fixes directory ownership for `op-geth-l2` data directory     |
| `op-geth-l2-init-tbc` | Fixes directory ownership for `op-geth-l2` TBC data directory |

## Profile `hemi`

Runs a Hemi L2 node (`op-geth` and `op-node`) and a Hemi Bitcoin Finality Governor (used by PoP Miners).

> [!TIP]
> This profile runs the services necessary for use with a `popmd` (PoP Miner) daemon:
>   - Bitcoin Finality Governor (RPC used by `popmd`)
>   - Electrs (used by `bfgd`)

**Requires**

- Ethereum L1 RPC URL (must be set as `GETHL1ENDPOINT` environment variable)
- Ethereum Prysm RPC URL (must be set as `PRYSMENDPOINT` environment variable)
- Bitcoind RPC URL (must be set as `BITCOINENDPOINT` environment variable)

**Services**

| Service         | Description                                         |
|-----------------|-----------------------------------------------------|
| `bfgd`          | Hemi Bitcoin Finality Governor (used by PoP Miners) |
| `bfgd-postgres` | PostgreSQL database for `bfgd`                      |
| `electrs`       | Bitcoin indexer (used by `bfgd`)                    |
| `bssd`          | Hemi Bitcoin Secure Sequencer                       |
| `op-geth-l2`    | Hemi L2 op-geth node                                |
| `op-node`       | Hemi L2 op-node                                     |

**Init containers**

| Service               | Description                                                   |
|-----------------------|---------------------------------------------------------------|
| `op-geth-l2-init`     | Fixes directory ownership for `op-geth-l2` data directory     |
| `op-geth-l2-init-tbc` | Fixes directory ownership for `op-geth-l2` TBC data directory |

## Profile `hemi-min`

Runs a Hemi L2 node (`op-geth` and `op-node`).

> [!TIP]
> This profile is recommended for most use cases, and is the most lightweight profile.
>
> This profile does not run the components necessary to run `popmd` (PoP Miner). See the [`hemi` profile](#profile-hemi)
> if you require the Bitcoin Finality Governor to run a PoP Miner.

**Requires**

- Ethereum L1 RPC URL (must be set as `GETHL1ENDPOINT` environment variable)
- Ethereum Prysm RPC URL (must be set as `PRYSMENDPOINT` environment variable)

**Services**

| Service      | Description                   |
|--------------|-------------------------------|
| `bssd`       | Hemi Bitcoin Secure Sequencer |
| `op-geth-l2` | Hemi L2 op-geth node          |
| `op-node`    | Hemi L2 op-node               |

**Init containers**

| Service               | Description                                                   |
|-----------------------|---------------------------------------------------------------|
| `op-geth-l2-init`     | Fixes directory ownership for `op-geth-l2` data directory     |
| `op-geth-l2-init-tbc` | Fixes directory ownership for `op-geth-l2` TBC data directory |

## Profile `l1`

Runs only Ethereum L1 and Bitcoin components. **This does not run any Hemi services.**

**Services**

| Service    | Description           |
|------------|-----------------------|
| `bitcoind` | Bitcoin full node     |
| `geth-l1`  | Ethereum L1 geth node |
| `prysm`    | Prysm (L1)            |
