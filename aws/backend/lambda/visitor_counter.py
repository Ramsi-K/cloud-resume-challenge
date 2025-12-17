"""
AWS Lambda function for visitor counter
Implements atomic increment using DynamoDB UpdateItem
"""

import json
import boto3
import os
from botocore.exceptions import ClientError

# Initialize DynamoDB client
dynamodb = boto3.resource("dynamodb")
table_name = os.environ["DYNAMODB_TABLE_NAME"]
table = dynamodb.Table(table_name)


def lambda_handler(event, context):
    """
    Lambda handler for visitor counter

    Supports:
    - POST: Increment counter and return new count
    - GET: Return current count without incrementing
    """

    # CORS headers for all responses
    cors_headers = {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "Content-Type",
        "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
    }

    try:
        # Handle preflight OPTIONS request
        if event.get("httpMethod") == "OPTIONS":
            return {
                "statusCode": 200,
                "headers": cors_headers,
                "body": json.dumps({"message": "CORS preflight"}),
            }

        # Handle POST request - increment counter
        if event.get("httpMethod") == "POST":
            # Atomic increment using UpdateItem
            response = table.update_item(
                Key={"id": "total"},
                UpdateExpression="ADD visit_count :inc",
                ExpressionAttributeValues={":inc": 1},
                ReturnValues="UPDATED_NEW",
            )

            # Extract the new count
            new_count = int(response["Attributes"]["visit_count"])

            return {
                "statusCode": 200,
                "headers": cors_headers,
                "body": json.dumps(
                    {
                        "count": new_count,
                        "message": "Counter incremented successfully",
                    }
                ),
            }

        # Handle GET request - return current count
        elif event.get("httpMethod") == "GET":
            response = table.get_item(Key={"id": "total"})

            if "Item" in response:
                current_count = int(response["Item"]["visit_count"])
            else:
                # Initialize if not exists
                table.put_item(Item={"id": "total", "visit_count": 0})
                current_count = 0

            return {
                "statusCode": 200,
                "headers": cors_headers,
                "body": json.dumps(
                    {
                        "count": current_count,
                        "message": "Current count retrieved successfully",
                    }
                ),
            }

        else:
            return {
                "statusCode": 405,
                "headers": cors_headers,
                "body": json.dumps({"error": "Method not allowed"}),
            }

    except ClientError as e:
        print(f"DynamoDB error: {e}")
        return {
            "statusCode": 500,
            "headers": cors_headers,
            "body": json.dumps({"error": "Database error", "message": str(e)}),
        }

    except Exception as e:
        print(f"Unexpected error: {e}")
        return {
            "statusCode": 500,
            "headers": cors_headers,
            "body": json.dumps(
                {"error": "Internal server error", "message": str(e)}
            ),
        }
