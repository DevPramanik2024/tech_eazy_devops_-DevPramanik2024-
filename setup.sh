#!/bin/bash
# setup.sh - EC2 user-data script

# Step 1: Update the system packages
sudo yum update -y

# Step 2: Install Java 21 (Amazon Corretto)
sudo yum install -y java-21-amazon-corretto

# Step 3: Install Git and Maven
sudo yum install -y git
sudo yum install -y maven

# Step 4: Clone the project from GitHub
git clone https://github.com/techeazy-consulting/techeazy-devops.git

# Step 5: Move into project directory
cd techeazy-devops

# Step 6: Build the Spring Boot app
mvn clean package

# Step 7: Run the app on port 80 (required by assignment)
sudo nohup java -jar target/techeazy-devops-0.0.1-SNAPSHOT.jar --server.port=80 &
