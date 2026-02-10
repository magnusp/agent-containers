# 1. Get uv
FROM ghcr.io/astral-sh/uv:latest AS uv_bin

# 2. Get Node assets
FROM docker.io/library/node:23.11.0-bookworm-slim AS node_assets

# 3. Get BusyBox (glibc version)
FROM docker.io/library/busybox:1.37.0-glibc AS busybox

# 4. Final Stage
FROM cr.agentgateway.dev/agentgateway:0.12.0 AS runner

# Copy BusyBox
COPY --from=busybox /bin/busybox /bin/busybox

# Bootstrap directories and tools using BusyBox directly
RUN ["/bin/busybox", "mkdir", "-p", "/usr/bin", "/usr/local/bin", "/lib64"]
RUN ["/bin/busybox", "--install", "-s", "/bin"]

# Create the essential /usr/bin/env link (force it with -sf)
RUN ["/bin/busybox", "ln", "-sf", "/bin/env", "/usr/bin/env"]

# Copy uv binaries
COPY --from=uv_bin /uv /uvx /bin/

# Copy Node & Libraries
COPY --from=node_assets /usr/local/bin/node /usr/local/bin/node
COPY --from=node_assets /usr/local/bin/npm /usr/local/bin/npm
COPY --from=node_assets /usr/local/bin/npx /usr/local/bin/npx
COPY --from=node_assets /usr/local/lib/node_modules /usr/local/lib/node_modules

# Copy essential C++ shared libraries for Node
COPY --from=node_assets /usr/lib/x86_64-linux-gnu/libstdc++.so.6 /usr/lib/libstdc++.so.6
COPY --from=node_assets /usr/lib/x86_64-linux-gnu/libgcc_s.so.1 /usr/lib/libgcc_s.so.1

# IMPORTANT: Node often needs the ld-linux loader in /lib64
COPY --from=node_assets /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2

ENV PATH="/usr/local/bin:/usr/bin:/bin:${PATH}"

ENTRYPOINT ["/app/agentgateway"]