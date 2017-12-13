WORKERS=$(ssh -C -x -q -o ConnectTimeout=5 -o StrictHostKeyChecking=no cloudsigma@$1 "sudo docker node ls -q")
echo $WORKERS

for WORKER in $WORKERS
do
	IP=$(ssh -C -x -q -o ConnectTimeout=2 -o StrictHostKeyChecking=no cloudsigma@$1 "sudo docker node inspect $WORKER --format '{{ .Status.Addr  }}'")
	echo ========================= $IP =================================
	OUTPUT=$(ssh -C -x -q -o ConnectTimeout=5 -o StrictHostKeyChecking=no  cloudsigma@$IP "sudo docker container logs jqueuing_manager")
	echo $OUTPUT
done
