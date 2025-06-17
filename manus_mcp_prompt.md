**🚀 Complete Enhanced Manus MCP Integration - Copy This Into Any New Session**

Install the complete enhanced MCP integration to expand your capabilities with 59 tools across 8 categories:

```bash
curl -sSL https://raw.githubusercontent.com/jerrydeng/agent-tools/main/install-complete-mcp.sh | bash
```

After installation, enable all enhanced MCP tools with this code:

```python
import sys
sys.path.append('/home/ubuntu/manus_mcp')
from manus_mcp import setup_mcp_integration, mcp_tool, list_mcp_tools, get_mcp_tools_by_category

# Initialize complete MCP integration (run once per session)
await setup_mcp_integration()

# You now have 59 additional tools across 8 categories!
tools = list_mcp_tools()
print(f"✅ {len(tools)} MCP tools available")

# Show tools by category
categories = ["filesystem", "git", "system", "web", "data", "database", "ai", "cloud"]
for category in categories:
    cat_tools = get_mcp_tools_by_category(category)
    print(f"{category.upper()}: {len(cat_tools)} tools")

# Example usage - works exactly like native tools:
result = await mcp_tool("mcp_filesystem_read_file", path="/tmp/example.txt")
result = await mcp_tool("mcp_filesystem_write_file", path="/tmp/test.txt", content="Hello Complete MCP!")
result = await mcp_tool("mcp_git_status", repo_path="/path/to/repo")
result = await mcp_tool("mcp_system_disk_usage")
result = await mcp_tool("mcp_data_hash_sha256", data="test data")

if result.success:
    print("Success:", result.result[0]['text'])
else:
    print("Error:", result.error)
```

**Complete Tool Categories (59 tools total):**

• **File Operations** (10 tools): 
  - `mcp_filesystem_read_file`, `mcp_filesystem_write_file`, `mcp_filesystem_list_directory`
  - `mcp_filesystem_create_directory`, `mcp_filesystem_delete_file`, `mcp_filesystem_move_file`
  - `mcp_filesystem_copy_file`, `mcp_filesystem_get_file_info`, `mcp_filesystem_search_files`, `mcp_filesystem_watch_directory`

• **Git Operations** (10 tools):
  - `mcp_git_status`, `mcp_git_log`, `mcp_git_diff`, `mcp_git_add`, `mcp_git_commit`
  - `mcp_git_branch`, `mcp_git_checkout`, `mcp_git_pull`, `mcp_git_push`, `mcp_git_clone`

• **System Operations** (8 tools):
  - `mcp_system_run_command`, `mcp_system_get_env`, `mcp_system_set_env`, `mcp_system_process_list`
  - `mcp_system_kill_process`, `mcp_system_disk_usage`, `mcp_system_memory_info`, `mcp_system_network_info`

• **Web Operations** (6 tools):
  - `mcp_web_fetch_url`, `mcp_web_download_file`, `mcp_web_post_request`, `mcp_web_api_call`
  - `mcp_web_parse_html`, `mcp_web_extract_links`

• **Data Operations** (11 tools):
  - `mcp_data_json_parse`, `mcp_data_json_format`, `mcp_data_csv_read`, `mcp_data_csv_write`
  - `mcp_data_xml_parse`, `mcp_data_base64_encode`, `mcp_data_base64_decode`
  - `mcp_data_hash_md5`, `mcp_data_hash_sha256`, `mcp_data_compress`, `mcp_data_decompress`

• **Database Operations** (5 tools):
  - `mcp_database_sqlite_query`, `mcp_database_sqlite_insert`, `mcp_database_sqlite_create_table`
  - `mcp_database_postgres_query`, `mcp_database_postgres_insert`

• **AI & Memory** (4 tools):
  - `mcp_ai_memory_store`, `mcp_ai_memory_retrieve`, `mcp_ai_memory_search`, `mcp_ai_vector_search`

• **Cloud Operations** (5 tools):
  - `mcp_cloud_aws_s3_list`, `mcp_cloud_aws_s3_upload`, `mcp_cloud_aws_s3_download`
  - `mcp_cloud_aws_ec2_list`, `mcp_cloud_cloudflare_dns`

**Key Features:**
- **59 tools** providing comprehensive system access
- **8 categories** covering all major operation types
- **Built-in implementations** - works without external dependencies
- **External server support** - automatically connects to available MCP servers
- **Production ready** - tested and validated
- **Single command installation** - ~60 seconds setup

The installation automatically detects and connects to available external MCP servers while providing built-in implementations for all tools. This gives you immediate access to file systems, version control, system operations, web APIs, data processing, databases, AI operations, and cloud services through a unified interface.

