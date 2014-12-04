#!/bin/sh
export AWS_CLOUDWATCH_HOME=/opt/CloudWatch-1.0.20.0
export JAVA_HOME=/usr/lib/jvm/jre

# Get the timestamp from 5 hours ago, to avoid getting > 1440 metrics (which errors).
# also, remove the +0000 from the timestamp, because the cloudwatch cli tries to enforce
# ISO 8601, but doesn't understand it.
DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ" -d "5 hours ago")

SERVICES='AmazonS3 AmazonRDS AWSDataTransfer AmazonEC2'

for service in $SERVICES; do

  COST=$(/opt/CloudWatch-1.0.20.0/bin/mon-get-stats EstimatedCharges --aws-credential-file aws_credentials --namespace "AWS/Billing" --statistics Sum --dimensions "ServiceName=${service},Currency=USD" --start-time $DATE |tail -1 |awk '{print $3}')

  if [ -z $COST ]; then
     echo "failed to retrieve $service metric from CloudWatch.."
      else
         echo "stats.prod.ops.billing.ec2_${service} $COST `date +%s`" |nc localhost 2023
          fi

        done

        # one more time, for the sum:
        COST=$(/opt/CloudWatch-1.0.20.0/bin/mon-get-stats EstimatedCharges --aws-credential-file aws_credentials --namespace "AWS/Billing" --statistics Sum --dimensions "Currency=USD" --start-time $DATE |tail -1 |awk '{print $3}')

        if [ -z $COST ]; then
           echo "failed to retrieve EstimatedCharges metric from CloudWatch.."
            exit 1
          else
             echo "stats.prod.ops.billing.ec2_total_estimated $COST `date +%s`" |nc localhost 2023
           fi
  fi
done
