FROM python:3.13-slim
WORKDIR /app
COPY app.py .
RUN pip install flask boto3
EXPOSE 5000
CMD ["python", "app.py"]
