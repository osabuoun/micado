declare -a commands=(
    "curl -o experiment.json $2"
    "cat experiment.json"
    "curl --data @experiment.json http://$1:8777/experiment/add"
)

for command in "${commands[@]}"
do
   echo "$command"
   output=$(ssh -C -x -q -o ConnectTimeout=5 -o StrictHostKeyChecking=no cloudsigma@$1 $command)
   echo $output
   # or do whatever with individual element of the array
done

# You can access them using echo "${arr[0]}", "${arr[1]}" also