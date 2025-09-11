# Copyright (c) 2024 Hemi Labs, Inc.
# Use of this source code is governed by the MIT License,
# which can be found in the LICENSE file.

FROM postgres:16.10-alpine3.22@sha256:1c6d2f6e4d30d49c529e09a627e8178db5011dde88d955eb08db2e135e64aa09

COPY ./*.sql /docker-entrypoint-initdb.d/
