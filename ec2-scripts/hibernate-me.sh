#!/bin/bash
INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`  
REGION="`echo \"$EC2_AVAIL_ZONE\" | sed 's/[a-z]$//'`"      
aws ec2 stop-instances --region $REGION --instance-ids $INSTANCE_ID --hibernate
