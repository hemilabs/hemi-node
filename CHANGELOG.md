# Changelog

All notable changes to this project will be documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## Added

- Add new `scripts/gen.sh` script, which is used to set up various files for use in the Docker compose
  environments ([#2](https://github.com/hemilabs/hemi-node/pull/2)).

- Add automated linting in CI to ensure files are kept tidy and
  consistent ([#1](https://github.com/hemilabs/hemi-node/pull/1)).

## Changed

- Reorganise repository for easier setup and use. Files for each network (mainnet and testnet) are now in separate
  directories ([#2](https://github.com/hemilabs/hemi-node/pull/2)).

- Update the version of PostgreSQL used for the BFG database to
  `16.10` ([#5](https://github.com/hemilabs/hemi-node/pull/5)).

- Pin all Docker images to SHA256 digests to ensure immutability and improve
  security ([#5](https://github.com/hemilabs/hemi-node/pull/5)).

- Update the bundled Ethereum L1 nodes for the Glamsterdam network upgrade to geth `v1.17.7` and Prysm `v7.2.1`.
  Prysm now runs as a semi-supernode so it can serve blobs to `op-node`, checkpoint syncs from ChainSafe (the
  previous `beaconstate.info` endpoints no longer resolve) and no longer passes flags that Prysm v7 removed.

## Removed

- Remove unused `deploy-config.json` file ([#3](https://github.com/hemilabs/hemi-node/pull/3)).

[Unreleased]: https://github.com/hemilabs/hemi-node/compare/v0.0.0...HEAD
