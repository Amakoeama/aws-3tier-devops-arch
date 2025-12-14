#!/bin/bash
set -e

echo "Pulling latest app artifact..."
aws s3 cp s3://amakoe-3tier-artifacts/main.py /opt/app/main.py

echo "Restarting FastAPI service..."
sudo systemctl restart fastapi

echo "Deployment complete."
