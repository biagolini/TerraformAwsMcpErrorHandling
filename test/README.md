# Testing MCP Error Handling Patterns

This folder contains tools for testing the MCP server's error handling behavior from two perspectives:

1. **Kiro CLI** — observe how an AI agent reacts to each error type
2. **Postman / curl** — inspect the raw HTTP responses the MCP client receives

## Kiro CLI Testing

### Setup

```bash
cd test/
kiro-cli chat --agent error-demo-agent
```

Run `/tools` to confirm all five tools are loaded, then test each scenario:

```
Search for available SUVs using the search_cars_by_type tool
```

```
Get details for the car toyota_corolla_2020 using the get_car_details_with_timeout tool
```

```
Get details for car INVALID-999 using the get_car_details_with_protocol_error tool
```

```
Get details for car INVALID-999 using the get_car_details_with_graceful_error tool
```

## Postman Testing

### 1. Export AWS credentials

If you use AWS SSO, generate temporary credentials:

```bash
./export_credentials.sh your-profile
```

This creates `credentials.json` with values to copy into Postman:

```json
{
  "aws_access_key_id": "ASIA...",
  "aws_secret_access_key": "...",
  "aws_session_token": "...",
  "expires": "..."
}
```

> Credentials expire after ~1h. Re-run the script to refresh.

### 2. Import the collection

1. Open Postman → **Import** → select `postman_collection.json`
2. Set the collection variable `api_endpoint` to your API Gateway URL (from `terraform output api_endpoint`)

### 3. Configure authentication

In Postman, create an environment with these variables (from `credentials.json`):

| Variable | Value |
|----------|-------|
| `aws_access_key_id` | from credentials.json |
| `aws_secret_access_key` | from credentials.json |
| `aws_session_token` | from credentials.json |

The collection inherits AWS Signature V4 auth (region: `us-east-1`, service: `execute-api`).

### 4. Expected results

| Request | HTTP Status | Response Body |
|---------|-------------|---------------|
| Success | 200 | `{"jsonrpc":"2.0","id":1,"result":{"content":[{"type":"text","text":"...car data..."}]}}` |
| Timeout (Layer 1) | 500 | `{"message":"Internal Server Error"}` |
| Protocol Error (Layer 2) | 200 | `{"jsonrpc":"2.0","id":3,"error":{"code":-32603,"message":"Internal error: car not found"}}` |
| Graceful Error (Layer 3) | 200 | `{"jsonrpc":"2.0","id":4,"result":{"content":[...],"isError":true}}` |

## curl Testing

```bash
./test_errors.sh https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/mcp your-profile
```

This runs all four test scenarios sequentially and shows the HTTP status code for each.
