param(
    [Parameter(Mandatory=$true)]
    [String]
    $registry_name,
    [Parameter(Mandatory=$true)]
    [String]
    $registry_port
)

echo "registry name: $registry_name"
echo "registry port: $registry_port"

$check_running = docker inspect -f '{{.State.Running}}' "${registry_name}"

if (-not $check_running) { 
    docker run -d -e REGISTRY_HTTP_ADDR=0.0.0.0:5000 --restart=always -p "${registry_port}:5000" --name "${registry_name}" registry:2    
}

docker pull gcr.io/agones-images/xonotic-example:0.7
docker tag gcr.io/agones-images/xonotic-example:0.7 localhost:${registry_port}/xonotic-gameserver:latest
docker push localhost:${registry_port}/xonotic-gameserver:latest