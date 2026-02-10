# DuckDuckGo MCP Server Setup Instructions

## Prerequisites
- Docker and Docker Compose installed
- External network `mcp-net` must exist

## Setup Steps

### 1. Create External Network (if not exists)
```bash
docker network create mcp-net
```

### 2. Start the MCP Server
```bash
docker-compose up -d
```

### 3. Verify the Server is Running
```bash
docker ps | grep duckduckgo-mcp-server
```

### 4. Test Connectivity
```bash
curl http://localhost:8000
```

## MCP Server Features
- **Web Search**: DuckDuckGo search without API keys
- **Content Fetching**: Retrieve and parse webpage content  
- **Built-in Rate Limiting**: 30 searches/min, 20 fetches/min
- **Port**: 8000
- **Network**: Connected to `mcp-net` external network

## Usage with Claude Desktop
Add to your Claude Desktop config:
```json
{
  "mcpServers": {
    "ddg-search": {
      "command": "docker",
      "args": ["exec", "duckduckgo-mcp-server", "python", "-m", "duckduckgo_mcp_server"]
    }
  }
}
```

## Troubleshooting
- Ensure Docker daemon is running
- Verify `mcp-net` network exists: `docker network ls`
- Check logs: `docker-compose logs duckduckgo-mcp-server`