# Custom mcp-proxy Dockerfile with uvx support
FROM ghcr.io/sparfenyuk/mcp-proxy:latest

# Install uv for package management
RUN python3 -m ensurepip && \
    pip install --no-cache-dir uv

# Set environment variables for uv
ENV PATH="/usr/local/bin:$PATH" \
    UV_PYTHON_PREFERENCE=only-system \
    UV_CACHE_DIR=/tmp/uv-cache

# Keep the original entrypoint
ENTRYPOINT ["catatonit", "--", "mcp-proxy"]