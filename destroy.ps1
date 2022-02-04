# now reverse the deploy and clean up in each folder
# TODO: fix the remove-item bug BS so the terraform folders are actually removed
$root_dir = Get-Location
Write-Host "Starting in $root_dir ..."

$cluster_dir = "$root_dir\tf-cluster"
$registry_dir = "$root_dir\tf-registry"
$agones_dir = "$root_dir\tf-agones"
$fleet_dir = "$root_dir\tf-fleet"

Write-Host "==Cleaning Up Registry=="
cd $registry_dir
terraform destroy -auto-approve
Remove-Item -Recurse .terraform.lock.hcl
Remove-Item -Recurse terraform.tfstate*

Write-Host "==Cleaning Up Minikube Cluster=="
cd $cluster_dir
terraform destroy -auto-approve
Remove-Item -Recurse .terraform.lock.hcl
Remove-Item -Recurse terraform.tfstate*

Write-Host "==Cleaning Up Agones=="
cd $agones_dir
Remove-Item -Recurse .terraform.lock.hcl
Remove-Item -Recurse terraform.tfstate*

Write-Host "==Cleaning Up Agones Fleet=="
cd $fleet_dir
Remove-Item -Recurse .terraform.lock.hcl
Remove-Item -Recurse terraform.tfstate*

cd $root_dir
Write-Host "Returned to $root_dir - clean up complete"