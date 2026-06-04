# MCP Error Handling Patterns on AWS

Demonstrates how different error response strategies in an MCP (Model Context Protocol) server affect AI agent behavior. Compares three failure modes:

- **`isError: true`** (Layer 3) — graceful, recoverable; the agent reads the message and self-corrects
- **JSON-RPC protocol error** (Layer 2) — the agent receives a numeric code and halts
- **Transport error / timeout** (Layer 1) — opaque HTTP 500; the agent has no actionable information

## Architecture

- **DynamoDB** — Car inventory table
- **Lambda** (5s timeout) — MCP server with 5 tools demonstrating different error patterns
- **API Gateway HTTP API** — IAM-authenticated endpoint (`POST /mcp`)

## Tools

| Tool | Behavior |
|------|----------|
| `get_car_details` | Returns car data or `null` — standard working tool |
| `search_cars_by_type` | Searches by body type — standard working tool |
| `get_car_details_with_graceful_error` | Returns `isError: true` with helpful message when car not found |
| `get_car_details_with_protocol_error` | Returns JSON-RPC error code `-32603` when car not found |
| `get_car_details_with_timeout` | Simulates slow operation (sleep 15s) that exceeds Lambda timeout (5s) |

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with a profile
- [Kiro CLI](https://kiro.dev/docs/cli/) for agent testing
- [mcp-proxy-for-aws](https://pypi.org/project/mcp-proxy-for-aws/) (`uvx mcp-proxy-for-aws@latest`)

## Deployment

```bash
cd environments/dev
cp backend.hcl.example backend.hcl    # Fill with your values
cp terraform.tfvars.example terraform.tfvars  # Fill with your values
terraform init -backend-config=backend.hcl
terraform plan -out=tfplan
terraform apply tfplan
```

## Seed Data

```bash
export AWS_PROFILE=your-profile
./seed/seed_cars.sh
```

## Testing

The `test/` folder contains everything needed to validate the error patterns:

- **Kiro CLI agent** (`test/.kiro/`) — pre-configured agent that connects to the MCP server. Update the endpoint URL in `test/.kiro/agents/error-demo-agent.json` after deployment.
- **Postman collection** (`test/postman_collection.json`) — four requests to inspect raw HTTP responses for each error type.
- **curl script** (`test/test_errors.sh`) — runs all tests from the command line with SigV4 auth.
- **Credentials helper** (`test/export_credentials.sh`) — exports temporary AWS SSO credentials for Postman.

See [`test/README.md`](test/README.md) for full instructions.

### Quick start

```bash
# After terraform apply:
cd test/
kiro-cli chat --agent error-demo-agent
```

## Cleanup

```bash
cd environments/dev
terraform destroy
```

## License

MIT
