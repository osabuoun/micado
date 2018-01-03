EXPERIMENT_NAME="customer_app3"
EXPERIMENT_IMAGE="osabuoun/python_echo_app"
INSTANCE_COUNT="5"

declare -a commands=(
    "sudo docker service create -t --name $EXPERIMENT_NAME $EXPERIMENT_IMAGE"
    "sudo docker service scale $EXPERIMENT_NAME=$INSTANCE_COUNT"
    "sudo docker service ps $EXPERIMENT_NAME"
    "sudo docker service logs jqueuer_stack_experiment_manager"
)

for command in "${commands[@]}"
do
   echo "$command"
   output=$(ssh -C -x -q -o ConnectTimeout=5 -o StrictHostKeyChecking=no cloudsigma@$1 $command)
   echo $output
   # or do whatever with individual element of the array
done

# You can access them using echo "${arr[0]}", "${arr[1]}" also