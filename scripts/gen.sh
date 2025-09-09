#!/bin/sh
# Copyright (c) 2025 Hemi Labs, Inc.
# Use of this source code is governed by the MIT License,
# which can be found in the LICENSE file.

# Hemi Node setup helper
#
# Usage:
#   ./scripts/gen.sh <network> <sync-mode> <profile>
#
# Arguments:
#   <network>   "mainnet" or "testnet"
#   <sync-mode> "snap" or "archive"
#   <profile>   "full", "hemi", "hemi-min", or "l1"
#
# Example:
#   ./scripts/gen.sh mainnet snap hemi
#
# Requirements:
#   - git
#   - jq
#
# This script generates:
#   - secrets (jwt.hex, cookie, op-node-priv-key.txt) in the network folder
#   - .env file with environment variables
#   - entrypoint.sh used to start geth with correct flags
#
# Notes:
#   - Run inside a git checkout of the repository
#   - Safe to run multiple times (will not overwrite existing secrets)

set -eu

SCRIPT_DIR=$(dirname "$0")
ROOT_DIR=$(dirname "$SCRIPT_DIR")

log() {
	echo "gen: $*" 1>&2
}

fatal() {
	echo "fatal: $*" 1>&2
	exit 1
}

random_hex() {
	# Prefer openssl (LibreSSL on macOS, OpenBSD)
	if command -v 'openssl' >/dev/null 2>&1; then
		openssl rand -hex "$1"
		return
	fi

	# Fallback: try /dev/urandom
	if [ -r /dev/urandom ]; then
		dd if=/dev/urandom bs="$1" count=1 2>/dev/null | od -An -tx1 | tr -d ' \n'
		echo
		return
	fi

	fatal "no secure random source available"
}

read_version() {
	TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "no-tag")
	COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "no-commit")
	STATE="dirty"
	if git diff --quiet 2>/dev/null && git diff --cached --quiet 2>/dev/null; then
		STATE="clean"
	fi
}

skip_exists() {
	if [ -f "$1" ]; then
		log "warning: $1 already exists; skipping regeneration"
		return 0
	fi
	return 1
}

set_env_var() {
	VAR="$1"
	VALUE="$2"
	FILE="$3"

	if grep -q "^$VAR=" "$FILE" 2>/dev/null; then
		# Replace existing value
		tmp=$(mktemp) || fatal "cannot create temp file"
		sed "s|^$VAR=.*|$VAR=$VALUE|" "$FILE" > "$tmp" && mv "$tmp" "$FILE"
		return
	fi

	# Not present; append new variable
	echo "$VAR=$VALUE" >> "$FILE"
}

gen_secret_files() {
	JWT_HEX="$NET_DIR/jwt.hex"
	OP_NODE_PRIV_KEY="$NET_DIR/op-node-priv-key.txt"
	COOKIE="$NET_DIR/cookie"

	if ! skip_exists "$JWT_HEX"; then
		random_hex 32 > "$JWT_HEX"
		log "Generated random $JWT_HEX file"
	fi
	if ! skip_exists "$OP_NODE_PRIV_KEY"; then
		random_hex 32 > "$OP_NODE_PRIV_KEY"
		log "Generated random $OP_NODE_PRIV_KEY file"
	fi
	if ! skip_exists "$COOKIE"; then
		echo "$(random_hex 12):$(random_hex 16)" > "$COOKIE"
		log "Generated random $COOKIE file"
	fi
}

gen_env() {
	exists=""
	if [ -f "$ENV_FILE" ]; then
		exists=true
	fi

	# Sync mode
	OP_SYNC_MODE="execution-layer" # snap
	if [ "$SYNC_MODE" = "archive" ]; then
		OP_SYNC_MODE="consensus-layer"
	fi

	# Set variables
	set_env_var "NET" "$NET" "$ENV_FILE"
	set_env_var "PROFILE" "$PROFILE" "$ENV_FILE"
	set_env_var "OPSYNCMODE" "$OP_SYNC_MODE" "$ENV_FILE"

	if [ "$exists" ]; then
		log "Updated $ENV_FILE variables"
		return
	fi
	log "Generated $ENV_FILE file"
}

gen_entrypoint() {
	# Read network config
	NET_ID=$(jq -r '.id' "$NET_CONFIG")
	TBC_NET=$(jq -r '.tbc_net' "$NET_CONFIG")
	HVM_GENESIS=$(jq -r '.hvm_genesis.height' "$NET_CONFIG")
	HVM_GENESIS_HEADER=$(jq -r '.hvm_genesis.header' "$NET_CONFIG")
	OVERRIDES=$(jq -r '.overrides | to_entries | map("--override.\(.key)=\(.value)") | join (" \\\n\t")' "$NET_CONFIG")
	BOOT_NODES=$(jq -r '.boot_nodes | join(",")' "$NET_CONFIG")

	# Create entrypoint shell script
	cat >"$ENTRYPOINT_FILE" <<EOF
#!/bin/sh
# Copyright (c) 2024-2025 Hemi Labs, Inc.
# Use of this source code is governed by the MIT License,
# which can be found in the LICENSE file.

# Generated with $SCRIPT_NAME (version=$TAG commit=$COMMIT state=$STATE) on $DATE

set -xe

if [ -d "/tmp/datadir/geth" ]; then
	echo "geth data dir exists, skipping genesis."
else
	geth init --state.scheme hash --datadir /tmp/datadir/geth /tmp/genesis.json
fi

echo "Running Hemi Node version=$TAG commit=$COMMIT state=$STATE"
echo " - Network: $NET_ID (tbc: $TBC_NET)"
echo " - Sync mode: $SYNC_MODE"
geth \\
	--config=/tmp/l2-config.toml \\
	--http \\
	--http.corsdomain=* \\
	--http.vhosts=* \\
	--http.addr=0.0.0.0 \\
	--http.api=web3,eth,txpool,net \\
	--http.port=18546 \\
	--ws \\
	--ws.rpcprefix=/ \\
	--ws.addr=0.0.0.0 \\
	--ws.port=28546 \\
	--ws.origins=* \\
	--ws.api=eth,txpool,net \\
	--syncmode=$SYNC_MODE \\
	--gcmode=archive \\
	--maxpeers=100 \\
	--networkid=$NET_ID \\
	--authrpc.vhosts=* \\
	--authrpc.addr=0.0.0.0 \\
	--authrpc.port=8551 \\
	--authrpc.jwtsecret=/tmp/jwt/jwt.hex \\
	--rollup.disabletxpoolgossip=false \\
	--datadir=/tmp/datadir/geth \\
	$OVERRIDES \\
	--tbc.network=$TBC_NET \\
	--tbc.leveldbhome=/tbcdata/data \\
    --hvm.headerdatadir=/tbcdata/headers \\
    --hvm.genesisheight=$HVM_GENESIS \\
    --hvm.genesisheader=$HVM_GENESIS_HEADER \\
	--bootnodes=$BOOT_NODES
EOF
	log "Generated $ENTRYPOINT_FILE"
}

print_success() {
	echo
	log "Setup complete! ($NET, sync mode: $SYNC_MODE, profile: $PROFILE)"
	log " $SCRIPT_NAME on $DATE (version=$TAG commit=$COMMIT state=$STATE)"
	log
	log "Next steps:"
	log "1. Configure your Ethereum RPC providers:"
	log "   - Edit $NET/.env and add:"
	log "	    GETHL1ENDPOINT=<your Ethereum RPC URL>"
	log "	    PRYSMENDPOINT=<your Prysm RPC URL>"
	log
	log "2. Start your node:"
	log "	  cd $NET"
	log "	  docker compose --profile $PROFILE up --build -d"
}

run() {
	NET=$1
    SYNC_MODE=$2
    PROFILE=$3

	if [ "$NET" != "mainnet" ] && [ "$NET" != "testnet" ]; then
		fatal "Network must be 'mainnet' or 'testnet'"
	fi
	if [ "$SYNC_MODE" != "snap" ] && [ "$SYNC_MODE" != "archive" ]; then
		fatal "Sync mode must be 'snap' or 'archive'"
	fi
	if [ "$PROFILE" != "full" ] && [ "$PROFILE" != "hemi" ] && [ "$PROFILE" != "hemi-min" ] && [ "$PROFILE" != "l1" ]; then
		fatal "Profile must be one of: 'full', 'hemi', 'hemi-min', or 'l1'"
	fi

	NET_DIR="$ROOT_DIR/$NET"
	NET_CONFIG="$NET_DIR/config.json"
	ENV_FILE="$NET_DIR/.env"
	ENTRYPOINT_FILE="$NET_DIR/entrypoint.sh"

	deps="git jq"
	for dep in $deps; do
		if ! command -v "$dep" >/dev/null 2>&1; then
			fatal "Missing dependency: $dep. Please install it (e.g. sudo apt-get install -y $dep)"
		fi
	done

	SCRIPT_NAME="$0"
	DATE=$(date)
	read_version
	log "Generating files for $NET (sync mode: $SYNC_MODE, profile: $PROFILE)"

	gen_env
	gen_secret_files
	gen_entrypoint

	print_success
}

if [ $# != 3 ]; then
	echo "usage: $0 <network> <sync-mode> <profile>"
	exit 1
fi

run "$@"
