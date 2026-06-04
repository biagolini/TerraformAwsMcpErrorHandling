import json
import os
import time
import boto3
from decimal import Decimal

TABLE_NAME = os.environ["TABLE_NAME"]
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE_NAME)

TOOLS = [
    {
        "name": "get_car_details",
        "description": "Get detailed information about a specific car by its ID. Returns null if not found.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "car_id": {
                    "type": "string",
                    "description": "The unique car identifier (e.g., toyota_corolla_2020)",
                }
            },
            "required": ["car_id"],
        },
    },
    {
        "name": "search_cars_by_type",
        "description": "Search available cars by body type. Valid types: sedan, suv, minivan, truck, hatchback, coupe.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "body_type": {
                    "type": "string",
                    "description": "Car body type to search for",
                }
            },
            "required": ["body_type"],
        },
    },
    {
        "name": "get_car_details_with_graceful_error",
        "description": "Get car details with graceful error handling. Returns a helpful error message if the car is not found.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "car_id": {
                    "type": "string",
                    "description": "The unique car identifier (e.g., toyota_corolla_2020)",
                }
            },
            "required": ["car_id"],
        },
    },
    {
        "name": "get_car_details_with_timeout",
        "description": "Get car details but with a simulated slow operation that exceeds the Lambda timeout (demonstrates transport-level failure).",
        "inputSchema": {
            "type": "object",
            "properties": {
                "car_id": {
                    "type": "string",
                    "description": "The unique car identifier (e.g., toyota_corolla_2020)",
                }
            },
            "required": ["car_id"],
        },
    },
    {
        "name": "get_car_details_with_protocol_error",
        "description": "Get car details but returns a JSON-RPC protocol error code when car is not found (demonstrates protocol-level failure).",
        "inputSchema": {
            "type": "object",
            "properties": {
                "car_id": {
                    "type": "string",
                    "description": "The unique car identifier (e.g., toyota_corolla_2020)",
                }
            },
            "required": ["car_id"],
        },
    },
]


class DecimalEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, Decimal):
            return int(o) if o % 1 == 0 else float(o)
        return super().default(o)


def handle_initialize(req_id):
    return {
        "jsonrpc": "2.0",
        "id": req_id,
        "result": {
            "protocolVersion": "2025-03-26",
            "capabilities": {"tools": {"listChanged": False}},
            "serverInfo": {"name": "mcp-error-handling-server", "version": "1.0.0"},
        },
    }


def handle_tools_list(req_id):
    return {"jsonrpc": "2.0", "id": req_id, "result": {"tools": TOOLS}}


def handle_tools_call(req_id, params):
    tool_name = params.get("name")
    arguments = params.get("arguments", {})

    if tool_name == "get_car_details":
        item = table.get_item(Key={"car_id": arguments["car_id"]}).get("Item")
        return {
            "jsonrpc": "2.0",
            "id": req_id,
            "result": {
                "content": [{"type": "text", "text": json.dumps(item, cls=DecimalEncoder)}]
            },
        }

    elif tool_name == "search_cars_by_type":
        resp = table.query(
            IndexName="body-type-index",
            KeyConditionExpression="body_type = :bt",
            FilterExpression="available = :av",
            ExpressionAttributeValues={":bt": arguments["body_type"].lower(), ":av": "yes"},
        )
        return {
            "jsonrpc": "2.0",
            "id": req_id,
            "result": {
                "content": [{"type": "text", "text": json.dumps(resp.get("Items", []), cls=DecimalEncoder)}]
            },
        }

    elif tool_name == "get_car_details_with_graceful_error":
        item = table.get_item(Key={"car_id": arguments["car_id"]}).get("Item")
        if not item:
            return {
                "jsonrpc": "2.0",
                "id": req_id,
                "result": {
                    "content": [
                        {
                            "type": "text",
                            "text": f"Car '{arguments['car_id']}' not found in inventory. "
                            f"Valid car IDs use the format like 'toyota_corolla_2020'. "
                            f"Use the search_cars_by_type tool to find available cars.",
                        }
                    ],
                    "isError": True,
                },
            }
        return {
            "jsonrpc": "2.0",
            "id": req_id,
            "result": {
                "content": [{"type": "text", "text": json.dumps(item, cls=DecimalEncoder)}]
            },
        }

    elif tool_name == "get_car_details_with_timeout":
        # Simulates a slow operation that exceeds the Lambda timeout
        time.sleep(15)
        item = table.get_item(Key={"car_id": arguments["car_id"]}).get("Item")
        return {
            "jsonrpc": "2.0",
            "id": req_id,
            "result": {
                "content": [{"type": "text", "text": json.dumps(item, cls=DecimalEncoder)}]
            },
        }

    elif tool_name == "get_car_details_with_protocol_error":
        item = table.get_item(Key={"car_id": arguments["car_id"]}).get("Item")
        if not item:
            return {
                "jsonrpc": "2.0",
                "id": req_id,
                "error": {
                    "code": -32603,
                    "message": "Internal error: car not found",
                },
            }
        return {
            "jsonrpc": "2.0",
            "id": req_id,
            "result": {
                "content": [{"type": "text", "text": json.dumps(item, cls=DecimalEncoder)}]
            },
        }

    else:
        return {
            "jsonrpc": "2.0",
            "id": req_id,
            "error": {"code": -32601, "message": f"Unknown tool: {tool_name}"},
        }


def handle_request(body):
    method = body.get("method")
    req_id = body.get("id")
    params = body.get("params", {})

    if method == "initialize":
        return handle_initialize(req_id)
    elif method == "notifications/initialized":
        return None
    elif method == "tools/list":
        return handle_tools_list(req_id)
    elif method == "tools/call":
        return handle_tools_call(req_id, params)
    elif method == "ping":
        return {"jsonrpc": "2.0", "id": req_id, "result": {}}
    else:
        return {
            "jsonrpc": "2.0",
            "id": req_id,
            "error": {"code": -32601, "message": f"Method not found: {method}"},
        }


def handler(event, context):
    body = json.loads(event.get("body", "{}"))

    if isinstance(body, list):
        responses = [r for req in body if (r := handle_request(req))]
        result = responses if len(responses) > 1 else responses[0] if responses else ""
    else:
        result = handle_request(body)

    if result is None:
        return {"statusCode": 202, "body": ""}

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(result, cls=DecimalEncoder),
    }
