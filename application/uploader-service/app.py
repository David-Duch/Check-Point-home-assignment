import os
import boto3

s3 = boto3.client("s3")
sqs = boto3.client("sqs")

QUEUE_URL = os.environ["SQS_QUEUE"]
BUCKET = os.environ["S3_BUCKET"]
PATH = os.environ.get("S3_PATH", "")


def lambda_handler(event, context):
    response = sqs.receive_message(
        QueueUrl=QUEUE_URL, MaxNumberOfMessages=10, WaitTimeSeconds=0
    )

    messages = response.get("Messages", [])
    print(messages)
    for msg in messages:
        print(msg)
        obj_key = PATH + msg["MessageId"] + ".txt"
        s3.put_object(Bucket=BUCKET, Key=obj_key, Body=msg["Body"])
        sqs.delete_message(QueueUrl=QUEUE_URL, ReceiptHandle=msg["ReceiptHandle"])

    return {"processed_messages": len(messages)}
