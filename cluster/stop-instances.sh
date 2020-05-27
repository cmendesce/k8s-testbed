set -e

IDS=$(aws ec2 describe-instances --output json | jq -r '.Reservations[].Instances | map(.InstanceId) | join(", ")')

for id in $IDS
do
  aws ec2 stop-instances --instance-id $id
done
