class AzureRmHelper
{
static [void] UploadStorageBlobContent([string] $fileName, [string] $blobName, [string] $containerName, [object] $stgCtx)
	{
        if([FeatureFlightingManager]::GetFeatureStatus("IsSetAzStorageBlobAvailable","*") -eq $true)
        {
            Set-AzStorageBlobContent -Blob $blobName -Container $containerName -File $fileName -Context $stgCtx -Force | Out-Null
        }
        else {
            $blob = $stgCtx.StorageAccount.CreateCloudBlobClient().GetContainerReference($containerName).GetBlockBlobReference($blobName)
            $task = $blob.UploadFromFileAsync($fileName)
            $task.Wait()
            if (-not ($task.IsCompleted -and !$task.IsFaulted))
            {
				#Need to change write method
				Write-Debug "Transferring file" + $fileName + "to storage has failed!!"
            }
        }
    }
}