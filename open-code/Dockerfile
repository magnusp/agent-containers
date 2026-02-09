# Build stage
# hadolint ignore=DL3006 # Ignored because it is a local image built from the builder stage, not a remote image with a specific version tag.
FROM agent-base AS builder

# We act as 'node' user (inherited from base)
# Because we set NPM_CONFIG_PREFIX in base, this installs to /home/node/.npm-global
# hadolint ignore=DL3016 # The issue here is that dependabot cannot manage this version, but we can fix this later with a dummy package.json that can be copied to the container and updated by dependabot.
RUN npm install -g "opencode-ai" && \
  echo "Installed Open Code version: $(opencode --version)"

# Runtime stage
# hadolint ignore=DL3006 # Ignored because it is a local image built from the builder stage, not a remote image with a specific version tag.
FROM agent-base

# Copy the installed global modules from builder
# We must use --chown to ensure the node user owns the copied files
COPY --from=builder --chown=node:node /home/node/.npm-global /home/node/.npm-global

# Display version information
# hadolint ignore=SC2059
RUN echo "Using Open Code version: $(opencode --version)"

CMD ["opencode"]
