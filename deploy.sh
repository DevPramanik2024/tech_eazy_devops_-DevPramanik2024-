#!/bin/bash

# Step 1: Accept stage input like 'dev' or 'prod'
STAGE=$1
CONFIG_FILE="${STAGE}_config"

# Step 2: Load config values (AMI ID, instance type, etc.)
if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ Config file $CONFIG_FILE not found!"
  exit 1
fi

# Load config variables
source $CONFIG_FILE



# Step 3: Launch EC2 instance with setup.sh script as user-data
echo "🚀 Launching EC2 instance..."

INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type $INSTANCE_TYPE \
  --key-name $KEY_NAME \
 --security-group-ids $SEC_GROUP="sg-0d9d8437670b1bf76" \
  --subnet-id $SUBNET_ID \
  --user-data file://setup.sh \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=techeazy-devops}]' \
  --query 'Instances[0].InstanceId' \
  --output text)

echo "✅ Instance launched: $INSTANCE_ID"


# Step 4: Wait for instance to boot and get public IP
echo "⏳ Waiting 90 seconds for instance to initialize..."
sleep 90

# Get public IP
PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text)

echo "🌍 EC2 Public IP: $PUBLIC_IP"



# Step 5: Test if app is reachable via port 80
echo "🧪 Testing application on http://$PUBLIC_IP:80"
curl -I http://$PUBLIC_IP:80


# Step 6: Stop EC2 instance to save cost
echo "⏱ Waiting 2 mins before stopping instance..."
sleep 120

aws ec2 stop-instances --instance-ids $INSTANCE_ID
echo "🛑 EC2 instance stopped."
