echo $1
echo $2
output=$(ssh -C -x -q -o ConnectTimeout=5 -o StrictHostKeyChecking=no cloudsigma@$1 $2)
echo $output
