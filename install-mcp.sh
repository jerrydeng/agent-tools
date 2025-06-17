#!/bin/bash
# Manus MCP Integration - One-Command Installer
# Usage: curl -sSL https://your-url/install-mcp.sh | bash
# Or: wget -qO- https://your-url/install-mcp.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="$HOME/manus_mcp"
GITHUB_RAW_BASE="https://raw.githubusercontent.com/your-repo/manus-mcp-integration/main"
# For demo purposes, we'll use local files

echo -e "${BLUE}🚀 Manus MCP Integration Installer${NC}"
echo -e "${BLUE}====================================${NC}"
echo ""

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is required but not installed"
        exit 1
    fi
    
    PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2 | cut -d'.' -f1,2)
    if ! python3 -c "import sys; exit(0 if sys.version_info >= (3, 11) else 1)" 2>/dev/null; then
        print_error "Python 3.11+ required, found $PYTHON_VERSION"
        exit 1
    fi
    print_status "Python $PYTHON_VERSION found"
    
    # Check Node.js (optional but recommended)
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version | cut -d'v' -f2)
        print_status "Node.js $NODE_VERSION found"
    else
        print_warning "Node.js not found - some MCP servers may not work"
    fi
    
    # Check pip
    if ! command -v pip3 &> /dev/null; then
        print_error "pip3 is required but not installed"
        exit 1
    fi
    print_status "pip3 found"
}

# Install Python dependencies
install_dependencies() {
    print_info "Installing Python dependencies..."
    
    # Install MCP SDK
    pip3 install "mcp[cli]" --quiet --user
    print_status "MCP SDK installed"
    
    # Install Git MCP server
    pip3 install mcp-server-git --quiet --user
    print_status "Git MCP server installed"
    
    # Install additional dependencies
    pip3 install psutil --quiet --user
    print_status "Additional dependencies installed"
}

# Create installation directory
setup_directory() {
    print_info "Setting up installation directory..."
    
    if [ -d "$INSTALL_DIR" ]; then
        print_warning "Directory $INSTALL_DIR already exists, backing up..."
        mv "$INSTALL_DIR" "${INSTALL_DIR}.backup.$(date +%s)"
    fi
    
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"
    print_status "Created directory: $INSTALL_DIR"
}

# Download MCP integration files
download_files() {
    print_info "Downloading MCP integration files..."
    
    # For this demo, we'll create the files directly
    # In production, these would be downloaded from GitHub or a web server
    
    # Create the main integration file
    cat > manus_mcp.py << 'EOF'
#!/usr/bin/env python3
"""
Simplified MCP Integration for Manus
Single-file implementation for easy deployment
"""

import asyncio
import json
import logging
import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, Any, Union

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

@dataclass
class MCPTool:
    """Represents an MCP tool with its metadata"""
    name: str
    description: str
    parameters: Dict[str, Any]
    server_name: str
    original_name: str

@dataclass
class ToolResult:
    """Result from tool execution"""
    success: bool
    result: List[Dict[str, Any]] = None
    error: str = None

class SimpleMCPClient:
    """Simplified MCP client for basic integration"""
    
    def __init__(self):
        self.servers = {}
        self.tools = {}
        self.connected = False
    
    async def connect_to_servers(self, config_file: str = "mcp_config.json"):
        """Connect to MCP servers based on configuration"""
        try:
            # Load configuration
            if not Path(config_file).exists():
                self._create_default_config(config_file)
            
            with open(config_file, 'r') as f:
                config = json.load(f)
            
            # Import MCP after ensuring it's installed
            try:
                from mcp import ClientSession, StdioServerParameters
                from mcp.client.stdio import stdio_client
            except ImportError:
                logger.error("MCP SDK not installed. Run: pip install mcp")
                return False
            
            connected_count = 0
            total_tools = 0
            
            for server_config in config.get('servers', []):
                if not server_config.get('enabled', True):
                    continue
                
                try:
                    server_name = server_config['name']
                    command = server_config['command']
                    args = server_config.get('args', [])
                    
                    # Create server parameters
                    server_params = StdioServerParameters(
                        command=command,
                        args=args
                    )
                    
                    # Test connection briefly
                    async with stdio_client(server_params) as (read, write):
                        async with ClientSession(read, write) as session:
                            await session.initialize()
                            tools_result = await session.list_tools()
                            
                            # Store tools
                            for tool in tools_result.tools:
                                tool_name = f"mcp_{server_name}_{tool.name}"
                                self.tools[tool_name] = MCPTool(
                                    name=tool_name,
                                    description=tool.description or f"{tool.name} from {server_name}",
                                    parameters=tool.inputSchema.get('properties', {}) if tool.inputSchema else {},
                                    server_name=server_name,
                                    original_name=tool.name
                                )
                            
                            connected_count += 1
                            total_tools += len(tools_result.tools)
                            logger.info(f"Connected to {server_name}: {len(tools_result.tools)} tools")
                
                except Exception as e:
                    logger.warning(f"Failed to connect to {server_config['name']}: {e}")
            
            self.connected = connected_count > 0
            logger.info(f"MCP Integration: {connected_count} servers, {total_tools} tools")
            return self.connected
            
        except Exception as e:
            logger.error(f"Failed to initialize MCP integration: {e}")
            return False
    
    def _create_default_config(self, config_file: str):
        """Create default MCP configuration"""
        default_config = {
            "servers": [
                {
                    "name": "filesystem",
                    "command": "npx",
                    "args": ["-y", "@modelcontextprotocol/server-filesystem", "/tmp"],
                    "enabled": True,
                    "description": "File system operations"
                },
                {
                    "name": "git",
                    "command": "python3",
                    "args": ["-m", "mcp_server_git", "--repository", "."],
                    "enabled": True,
                    "description": "Git operations"
                }
            ]
        }
        
        with open(config_file, 'w') as f:
            json.dump(default_config, f, indent=2)
        
        logger.info(f"Created default configuration: {config_file}")
    
    async def execute_tool(self, tool_name: str, **kwargs) -> ToolResult:
        """Execute an MCP tool"""
        if not self.connected:
            return ToolResult(success=False, error="Not connected to any MCP servers")
        
        if tool_name not in self.tools:
            return ToolResult(success=False, error=f"Tool '{tool_name}' not found")
        
        try:
            tool = self.tools[tool_name]
            server_name = tool.server_name
            
            # Load server config
            with open("mcp_config.json", 'r') as f:
                config = json.load(f)
                server_config = None
                for s in config['servers']:
                    if s['name'] == server_name:
                        server_config = s
                        break
            
            if not server_config:
                return ToolResult(success=False, error=f"Server config for '{server_name}' not found")
            
            # Import MCP components
            from mcp import ClientSession, StdioServerParameters
            from mcp.client.stdio import stdio_client
            
            # Create connection for this operation
            server_params = StdioServerParameters(
                command=server_config['command'],
                args=server_config.get('args', [])
            )
            
            async with stdio_client(server_params) as (read, write):
                async with ClientSession(read, write) as session:
                    await session.initialize()
                    
                    # Execute the tool
                    result = await session.call_tool(tool.original_name, kwargs)
                    
                    if result.isError:
                        return ToolResult(success=False, error=str(result.content))
                    
                    # Format result
                    formatted_result = []
                    for content in result.content:
                        if hasattr(content, 'text'):
                            formatted_result.append({"type": "text", "text": content.text})
                        else:
                            formatted_result.append({"type": "unknown", "content": str(content)})
                    
                    return ToolResult(success=True, result=formatted_result)
        
        except Exception as e:
            return ToolResult(success=False, error=f"Tool execution failed: {e}")
    
    def get_available_tools(self) -> List[MCPTool]:
        """Get list of all available tools"""
        return list(self.tools.values())
    
    def get_tool_info(self, tool_name: str) -> Optional[MCPTool]:
        """Get information about a specific tool"""
        return self.tools.get(tool_name)

class ManuseMCPIntegration:
    """Main integration class for Manus MCP support"""
    
    def __init__(self):
        self.client = SimpleMCPClient()
        self.initialized = False
    
    async def initialize(self, config_file: str = "mcp_config.json") -> bool:
        """Initialize the MCP integration"""
        logger.info("Initializing Manus MCP Integration...")
        
        success = await self.client.connect_to_servers(config_file)
        self.initialized = success
        
        if success:
            tools = self.client.get_available_tools()
            logger.info(f"MCP Integration ready: {len(tools)} tools available")
        else:
            logger.error("MCP Integration failed to initialize")
        
        return success
    
    async def execute_mcp_tool(self, tool_name: str, **kwargs) -> ToolResult:
        """Execute an MCP tool"""
        if not self.initialized:
            return ToolResult(success=False, error="MCP integration not initialized")
        
        return await self.client.execute_tool(tool_name, **kwargs)
    
    def list_mcp_tools(self) -> List[str]:
        """List all available MCP tool names"""
        return list(self.client.tools.keys())
    
    def get_mcp_tool_info(self, tool_name: str) -> Optional[Dict[str, Any]]:
        """Get detailed information about an MCP tool"""
        tool = self.client.get_tool_info(tool_name)
        if tool:
            return {
                "name": tool.name,
                "description": tool.description,
                "parameters": tool.parameters,
                "server": tool.server_name
            }
        return None

# Global instance for easy access
mcp_integration = ManuseMCPIntegration()

async def setup_mcp_integration():
    """Setup function to initialize MCP integration"""
    return await mcp_integration.initialize()

async def mcp_tool(tool_name: str, **kwargs) -> ToolResult:
    """Convenient function to execute MCP tools"""
    return await mcp_integration.execute_mcp_tool(tool_name, **kwargs)

def list_mcp_tools() -> List[str]:
    """List all available MCP tools"""
    return mcp_integration.list_mcp_tools()

def mcp_tool_info(tool_name: str) -> Optional[Dict[str, Any]]:
    """Get information about an MCP tool"""
    return mcp_integration.get_mcp_tool_info(tool_name)

# Example usage functions
async def demo_mcp_integration():
    """Demonstrate MCP integration capabilities"""
    print("🚀 Manus MCP Integration Demo")
    print("=" * 40)
    
    # Initialize
    success = await setup_mcp_integration()
    if not success:
        print("❌ Failed to initialize MCP integration")
        return
    
    # List available tools
    tools = list_mcp_tools()
    print(f"📊 Available MCP tools: {len(tools)}")
    
    # Show some tools
    for tool_name in tools[:5]:  # Show first 5 tools
        info = mcp_tool_info(tool_name)
        if info:
            print(f"  🔧 {tool_name}: {info['description']}")
    
    # Try some operations
    print("\n📁 Testing filesystem operations...")
    
    # List directory
    result = await mcp_tool("mcp_filesystem_list_directory", path="/tmp")
    if result.success:
        print("✅ Directory listing successful")
    else:
        print(f"❌ Directory listing failed: {result.error}")
    
    # Create a test file
    result = await mcp_tool("mcp_filesystem_write_file", 
                           path="/tmp/mcp_test.txt", 
                           content="Hello from Manus MCP Integration!")
    if result.success:
        print("✅ File creation successful")
    else:
        print(f"❌ File creation failed: {result.error}")
    
    # Read the file back
    result = await mcp_tool("mcp_filesystem_read_file", path="/tmp/mcp_test.txt")
    if result.success:
        print("✅ File reading successful")
        if result.result:
            content = result.result[0].get('text', '')[:50]
            print(f"   Content preview: {content}...")
    else:
        print(f"❌ File reading failed: {result.error}")
    
    print("\n🎉 MCP Integration demo complete!")

if __name__ == "__main__":
    # Run demo if executed directly
    asyncio.run(demo_mcp_integration())
EOF

    chmod +x manus_mcp.py
    print_status "Created manus_mcp.py"
    
    # Create quick test script
    cat > test_mcp.py << 'EOF'
#!/usr/bin/env python3
"""Quick test script for MCP integration"""

import asyncio
import sys
from manus_mcp import setup_mcp_integration, list_mcp_tools, mcp_tool

async def quick_test():
    print("🧪 Quick MCP Integration Test")
    print("=" * 30)
    
    # Initialize
    success = await setup_mcp_integration()
    if not success:
        print("❌ MCP integration failed to initialize")
        return False
    
    # List tools
    tools = list_mcp_tools()
    print(f"✅ MCP integration working: {len(tools)} tools available")
    
    # Test a simple operation
    result = await mcp_tool("mcp_filesystem_list_directory", path="/tmp")
    if result.success:
        print("✅ Tool execution working")
        return True
    else:
        print(f"❌ Tool execution failed: {result.error}")
        return False

if __name__ == "__main__":
    success = asyncio.run(quick_test())
    sys.exit(0 if success else 1)
EOF

    chmod +x test_mcp.py
    print_status "Created test_mcp.py"
    
    # Create usage instructions
    cat > README.md << 'EOF'
# Manus MCP Integration

This directory contains a simplified MCP (Model Context Protocol) integration for Manus.

## Quick Start

1. **Test the installation:**
   ```bash
   python3 test_mcp.py
   ```

2. **Run the demo:**
   ```bash
   python3 manus_mcp.py
   ```

3. **Use in your code:**
   ```python
   from manus_mcp import setup_mcp_integration, mcp_tool, list_mcp_tools
   
   # Initialize (run once)
   await setup_mcp_integration()
   
   # List available tools
   tools = list_mcp_tools()
   print(f"Available tools: {tools}")
   
   # Execute a tool
   result = await mcp_tool("mcp_filesystem_read_file", path="/path/to/file.txt")
   if result.success:
       print(result.result[0]['text'])
   ```

## Available Tools

After initialization, you'll have access to:
- **Filesystem tools**: File operations (read, write, list, search, etc.)
- **Git tools**: Version control operations (status, commit, diff, etc.)

## Configuration

Edit `mcp_config.json` to customize which MCP servers to use.

## For New Manus Sessions

To use MCP integration in a new Manus session:

1. **Install:** Run the one-line installer
2. **Import:** `from manus_mcp import setup_mcp_integration, mcp_tool`
3. **Initialize:** `await setup_mcp_integration()`
4. **Use:** `result = await mcp_tool("tool_name", **params)`

That's it! You now have access to the entire MCP ecosystem.
EOF

    print_status "Created README.md"
}

# Create test Git repository
setup_test_repo() {
    print_info "Setting up test Git repository..."
    
    if [ ! -d ".git" ]; then
        git init --quiet
        git config user.email "test@example.com"
        git config user.name "Test User"
        echo "# MCP Integration Test Repository" > README_git.md
        git add README_git.md
        git commit -m "Initial commit" --quiet
        print_status "Created test Git repository"
    else
        print_status "Git repository already exists"
    fi
}

# Test the installation
test_installation() {
    print_info "Testing MCP integration..."
    
    if python3 test_mcp.py; then
        print_status "MCP integration test passed"
        return 0
    else
        print_error "MCP integration test failed"
        return 1
    fi
}

# Main installation process
main() {
    echo -e "${BLUE}Starting Manus MCP Integration installation...${NC}"
    echo ""
    
    check_prerequisites
    echo ""
    
    install_dependencies
    echo ""
    
    setup_directory
    echo ""
    
    download_files
    echo ""
    
    setup_test_repo
    echo ""
    
    if test_installation; then
        echo ""
        echo -e "${GREEN}🎉 Installation completed successfully!${NC}"
        echo ""
        echo -e "${BLUE}Installation directory:${NC} $INSTALL_DIR"
        echo -e "${BLUE}Quick test:${NC} cd $INSTALL_DIR && python3 test_mcp.py"
        echo -e "${BLUE}Full demo:${NC} cd $INSTALL_DIR && python3 manus_mcp.py"
        echo ""
        echo -e "${YELLOW}For new Manus sessions, use:${NC}"
        echo -e "${BLUE}  from manus_mcp import setup_mcp_integration, mcp_tool${NC}"
        echo -e "${BLUE}  await setup_mcp_integration()${NC}"
        echo -e "${BLUE}  result = await mcp_tool('mcp_filesystem_list_directory', path='/tmp')${NC}"
        echo ""
    else
        echo ""
        print_error "Installation completed but tests failed"
        echo "Check the error messages above and try running the test manually:"
        echo "  cd $INSTALL_DIR && python3 test_mcp.py"
        exit 1
    fi
}

# Run main installation
main

