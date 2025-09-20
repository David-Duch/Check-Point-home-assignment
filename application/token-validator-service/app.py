import os
import json
import boto3
from flask import Flask, request, jsonify
import time

app = Flask(__name__)
sqs = boto3.client("sqs", region_name=os.getenv("AWS_REGION", "us-east-1"))

# ECS injects the secret value directly into this env var
TOKEN_VALUE = os.getenv("TOKEN_PARAM")
SQS_URL = os.getenv("SQS_URL")

def validate_payload(payload, token_value):
    errors = []
    data = payload.get("data")
    if not data:
        errors.append("Missing 'data' key in payload")
    else:
        required_keys = ["email_subject", "email_sender", "email_timestream", "email_content"]
        missing_keys = [k for k in required_keys if k not in data]
        if missing_keys:
            errors.append(f"Missing keys in data: {missing_keys}")
        try:
            int(data.get("email_timestream", ""))
        except (ValueError, TypeError):
            errors.append(f"email_timestream is not a valid integer: {data.get('email_timestream')}")

    if payload.get("token") != token_value:
        errors.append("Invalid token")
    return errors

def send_to_sqs(data):
    sqs.send_message(
        QueueUrl=SQS_URL,
        MessageBody=json.dumps(data),
        MessageGroupId="default", 
        MessageDeduplicationId=str(time.time_ns()) 
    )

@app.route("/message", methods=["POST"])
def message():
    payload = request.get_json(force=True)
    
    if not TOKEN_VALUE:
        return jsonify({
            "status": "error",
            "message": "TOKEN_PARAM environment variable is missing or empty",
            "token_param": TOKEN_VALUE
        }), 500

    errors = validate_payload(payload, TOKEN_VALUE)
    if errors:
        return jsonify({"status": "rejected", "errors": errors, "token_param": TOKEN_VALUE}), 400

    try:
        send_to_sqs(payload["data"])
    except Exception as e:
        return jsonify({"status": "error", "message": f"SQS send failed: {str(e)}", "token_param": TOKEN_VALUE}), 500

    return jsonify({"status": "accepted"}), 200

@app.route("/health", methods=["GET"])
def health():
    return "OK", 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", "5000")))
