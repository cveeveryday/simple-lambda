"""
Simple Lambda function that returns 200 OK on HTTP GET request.
"""

import json

def handler(event, context):
    # Create a standard Python dictionary
    output = {"message": "OK", "status": "all systems go"}
    
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(output) # This turns the dictionary into a string automatically
    }
