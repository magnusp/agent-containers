# Build stage
FROM agent-base AS builder

# Install OpenAI Codex in the builder stage
RUN npm install -g @openai/codex && \
  echo "Installed Codex version: $(codex --version)"

# Runtime stage
FROM agent-base

# Copy the installed Codex from builder
# We must use --chown to ensure the node user owns the copied files
COPY --from=builder --chown=node:node /home/node/.npm-global /home/node/.npm-global

# Display version information
RUN echo "" && \
  echo "\e[34m=================================================================\e[0m" && \
  echo "\e[34m                   OPENAI CODEX VERSION                          \e[0m" && \
  echo "\e[34m=================================================================\e[0m" && \
  echo "\e[34m" && codex --version && \
  echo "\e[0m" && \
  echo ""

CMD ["codex", "--approval-mode", "auto-edit"]
