param(
    [Parameter(Mandatory=$true)]
    [String]
    $mode
)

# Basically cd into each folder and terraform init/apply
# get current working directory
$root_dir = Get-Location
Write-Host -ForegroundColor DarkYellow "Starting in $root_dir ..."

$cluster_dir = "$root_dir\tf-cluster"
$registry_dir = "$root_dir\tf-registry"
$agones_dir = "$root_dir\tf-agones"
$fleet_dir = "$root_dir\tf-fleet"

Write-Host -ForegroundColor DarkYellow "==Deploying Minikube Cluster=="
cd $cluster_dir
terraform init
if ($mode -eq "apply") {
    Write-Host -ForegroundColor DarkYellow "==Applying Cluster Changes=="
    terraform apply -auto-approve
    
} else {
    Write-Host -ForegroundColor DarkYellow "NOTE: Validation Only"
    terraform validate
}

Write-Host -ForegroundColor DarkYellow "==Deploying Registry=="
cd $registry_dir
terraform init
if ($mode -eq "apply") {
    Write-Host -ForegroundColor DarkYellow "==Applying Registry Changes=="
    terraform apply -auto-approve
    
} else {
    Write-Host -ForegroundColor DarkYellow "NOTE: Validation Only"
    terraform validate
}

#

Write-Host -ForegroundColor DarkYellow "==Deploying Agones==" 
cd $agones_dir
terraform init
helm repo update
if ($mode -eq "apply") {
    Write-Host -ForegroundColor DarkYellow "==Applying Agones Changes=="
    terraform apply -auto-approve
    
} else {
    Write-Host -ForegroundColor DarkYellow "NOTE: Validation Only"
    terraform validate
}

Write-Host -ForegroundColor DarkYellow "==Deploying Agones Fleet=="
cd $fleet_dir
terraform init
if ($mode -eq "apply") {
    Write-Host -ForegroundColor DarkYellow "==Applying Agones Fleet Changes=="
    terraform apply -auto-approve
    
} else {
    Write-Host -ForegroundColor DarkYellow "NOTE: Validation Only"
    terraform validate
}

cd $root_dir
Write-Host -ForegroundColor DarkYellow "Returned to $root_dir"
Write-Host -ForegroundColor DarkYellow "Sleeping 10 and then checking for gameservers..."
sleep 10
minikube -p gs-cluster kubectl -- -n gameservers get gameservers
minikube -p gs-cluster kubectl -- -n gameservers get pods -o wide