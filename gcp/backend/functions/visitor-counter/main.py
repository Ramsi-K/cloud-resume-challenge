"""
GCP Cloud Function for visitor counter
Implements atomic increment in Firestore with rate limiting and CORS
"""

import json
import time
from datetime import datetime, timedelta
from typing import Dict, Any, Tuple
import functions_framework
from google.cloud import firestore
from flask import Request, Response
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize Firestore client
db = firestore.Client()

# Rate limiting configuration
RATE_LIMIT_REQUESTS = 100  # requests per IP per minute
RATE_LIMIT_WINDOW = 60  # seconds


def check_rate_limit(ip_address: str) -> bool:
    """
    Check if IP address is within rate limits
    Returns True if allowed, False if rate limited
    """
    try:
        # Use IP address as document ID in rate_limits collection
        rate_limit_ref = db.collection("rate_limits").document(ip_address)

        # Get current document
        doc = rate_limit_ref.get()
        current_time = datetime.utcnow()

        if doc.exists:
            data = doc.to_dict()
            last_request = data.get("last_request")
            request_count = data.get("request_count", 0)

            # Check if we're in the same minute window
            if (
                last_request
                and (current_time - last_request).total_seconds()
                < RATE_LIMIT_WINDOW
            ):
                if request_count >= RATE_LIMIT_REQUESTS:
                    logger.warning(f"Rate limit exceeded for IP: {ip_address}")
                    return False

                # Increment counter
                rate_limit_ref.update(
                    {
                        "request_count": request_count + 1,
                        "last_request": current_time,
                    }
                )
            else:
                # New window, reset counter
                rate_limit_ref.set(
                    {"request_count": 1, "last_request": current_time}
                )
        else:
            # First request from this IP
            rate_limit_ref.set(
                {"request_count": 1, "last_request": current_time}
            )

        return True

    except Exception as e:
        logger.error(f"Rate limiting error: {str(e)}")
        # Allow request if rate limiting fails
        return True


def get_client_ip(request: Request) -> str:
    """Extract client IP address from request"""
    # Check for forwarded IP first (from load balancer)
    forwarded_for = request.headers.get("X-Forwarded-For")
    if forwarded_for:
        return forwarded_for.split(",")[0].strip()

    # Check for real IP
    real_ip = request.headers.get("X-Real-IP")
    if real_ip:
        return real_ip

    # Fall back to remote address
    return request.environ.get("REMOTE_ADDR", "unknown")


def create_cors_response(
    data: Dict[str, Any], status_code: int = 200
) -> Response:
    """Create response with CORS headers"""
    response = Response(
        response=json.dumps(data),
        status=status_code,
        mimetype="application/json",
    )

    # Add CORS headers
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Content-Type"
    response.headers["Access-Control-Max-Age"] = "3600"

    return response


@functions_framework.http
def visitor_counter(request: Request) -> Response:
    """
    Cloud Function to handle visitor counter requests
    Supports GET (retrieve count) and POST (increment count)
    """

    # Handle preflight OPTIONS request
    if request.method == "OPTIONS":
        return create_cors_response({})

    try:
        # Get client IP for rate limiting
        client_ip = get_client_ip(request)
        logger.info(f"Request from IP: {client_ip}, Method: {request.method}")

        # Check rate limiting
        if not check_rate_limit(client_ip):
            return create_cors_response(
                {
                    "error": "Rate limit exceeded",
                    "message": f"Maximum {RATE_LIMIT_REQUESTS} requests per minute allowed",
                },
                429,
            )

        # Reference to visitor counter document
        counter_ref = db.collection("counters").document("visitor_count")

        if request.method == "GET":
            # Get current count without incrementing
            doc = counter_ref.get()
            if doc.exists:
                count = doc.to_dict().get("count", 0)
            else:
                count = 0

            return create_cors_response(
                {
                    "count": count,
                    "method": "GET",
                    "timestamp": datetime.utcnow().isoformat(),
                }
            )

        elif request.method == "POST":
            # Increment counter atomically
            transaction = db.transaction()

            @firestore.transactional
            def increment_counter(transaction, counter_ref):
                # Get current document
                doc = counter_ref.get(transaction=transaction)

                if doc.exists:
                    current_count = doc.to_dict().get("count", 0)
                else:
                    current_count = 0

                new_count = current_count + 1

                # Update document
                transaction.set(
                    counter_ref,
                    {
                        "count": new_count,
                        "last_updated": datetime.utcnow(),
                        "last_ip": client_ip,
                    },
                )

                return new_count

            # Execute transaction
            new_count = increment_counter(transaction, counter_ref)

            logger.info(f"Visitor count incremented to: {new_count}")

            return create_cors_response(
                {
                    "count": new_count,
                    "method": "POST",
                    "timestamp": datetime.utcnow().isoformat(),
                    "message": "Counter incremented successfully",
                }
            )

        else:
            return create_cors_response(
                {
                    "error": "Method not allowed",
                    "message": "Only GET and POST methods are supported",
                },
                405,
            )

    except Exception as e:
        logger.error(f"Function error: {str(e)}")
        return create_cors_response(
            {
                "error": "Internal server error",
                "message": "An error occurred processing your request",
            },
            500,
        )
