import os
import json
import boto3
from flask import Flask, request, jsonify
import time

app = Flask(__name__)
region = os.getenv("AWS_REGION", "us-east-1")
ssm = boto3.client("ssm", region_name=region)
sqs = boto3.client("sqs", region_name=region)

TOKEN_PARAM = os.getenv("TOKEN_PARAM", "/secure_token")
SQS_URL = os.getenv("SQS_URL")

def validate_payload(payload, token_value):
    try:
        data = payload["data"]
        if payload.get("token") != token_value:
            return False
        if not all(k in data for k in ["email_subject","email_sender","email_timestream","email_content"]):
            return False
        int(data["email_timestream"])
        return True
    except (KeyError, ValueError, TypeError):
        return False

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
    token_param = ssm.get_parameter(Name=TOKEN_PARAM, WithDecryption=True)
    token_value = token_param["Parameter"]["Value"]
    if validate_payload(payload, token_value):
        send_to_sqs(payload["data"])
        return jsonify({"status":"accepted"}), 200
    return jsonify({"status":"rejected due to failed validation"}), 400

@app.route("/health", methods=["GET"])
def health():
    return "OK", 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", "5000")))
