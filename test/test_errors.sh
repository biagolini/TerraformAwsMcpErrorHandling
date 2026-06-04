#!/bin/bash
# Test MCP error patterns via API Gateway with SigV4 authentication.
# Usage: ./test_errors.sh <api-endpoint> <aws-profile>
# Example: ./test_errors.sh https://abc123.execute-api.us-east-1.amazonaws.com/mcp my-profile

ENDPOINT="${1:?Usage: ./test_errors.sh <api-endpoint> <aws-profile>}"
PROFILE="${2:?Usage: ./test_errors.sh <api-endpoint> <aws-profile>}"
REGION="us-east-1"
CREDS="$(aws configure get aws_access_key_id --profile $PROFILE):$(aws configure get aws_secret_access_key --profile $PROFILE)"

echo "=== Test: Success ==="
curl -X POST "$ENDPOINT" \
  --aws-sigv4 "aws:amz:$REGION:execute-api" \
  --user "$CREDS" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"get_car_details","arguments":{"car_id":"toyota_corolla_2020"}}}' \
  -w "\nHTTP Status: %{http_code}\n" \
  -s

echo ""
echo "=== Test: Timeout (Layer 1 - Transport) ==="
echo "Waiting ~5s for Lambda to timeout..."
curl -X POST "$ENDPOINT" \
  --aws-sigv4 "aws:amz:$REGION:execute-api" \
  --user "$CREDS" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"get_car_details_with_timeout","arguments":{"car_id":"toyota_corolla_2020"}}}' \
  -w "\nHTTP Status: %{http_code}\n" \
  -s

echo ""
echo "=== Test: Protocol Error (Layer 2) ==="
curl -X POST "$ENDPOINT" \
  --aws-sigv4 "aws:amz:$REGION:execute-api" \
  --user "$CREDS" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"get_car_details_with_protocol_error","arguments":{"car_id":"INVALID-999"}}}' \
  -w "\nHTTP Status: %{http_code}\n" \
  -s

echo ""
echo "=== Test: Graceful Error (Layer 3 - isError: true) ==="
curl -X POST "$ENDPOINT" \
  --aws-sigv4 "aws:amz:$REGION:execute-api" \
  --user "$CREDS" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"get_car_details_with_graceful_error","arguments":{"car_id":"INVALID-999"}}}' \
  -w "\nHTTP Status: %{http_code}\n" \
  -s
