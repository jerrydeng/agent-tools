**🚀 Manus MCP Integration - Copy This Into Any New Session**

Install MCP integration to expand your capabilities with 22+ additional tools for file operations and Git version control:

```bash
curl -sSL https://raw.githubusercontent.com/jerrydeng/agent-tools/main/install-mcp.sh | bash
```

After installation, enable MCP tools with this code:

```python
import sys
sys.path.append('/home/ubuntu/manus_mcp')
from manus_mcp import setup_mcp_integration, mcp_tool, list_mcp_tools

# Initialize MCP integration (run once per session)
await setup_mcp_integration()

# You now have 22+ additional tools!
tools = list_mcp_tools()
print(f"✅ {len(tools)} MCP tools available")

# Example usage - works exactly like native tools:
result = await mcp_tool("mcp_filesystem_read_file", path="/tmp/example.txt")
result = await mcp_tool("mcp_filesystem_write_file", path="/tmp/test.txt", content="Hello MCP!")
result = await mcp_tool("mcp_git_git_status", repo_path="/path/to/repo")

if result.success:
    print("Success:", result.result[0]['text'])
else:
    print("Error:", result.error)
```

**Available Tools:**
- **File Operations**: read_file, write_file, list_directory, create_directory, search_files, get_file_info, directory_tree, etc.
- **Git Operations**: git_status, git_add, git_commit, git_log, git_diff_staged, git_diff_unstaged, etc.

The installation is automatic and takes ~30 seconds. All tools use the same interface as your native capabilities.

