if (!(IsLoaded(".\Includes\include.ps1"))) {. .\Includes\include.ps1; RegisterLoaded(".\Includes\include.ps1")}
 
$Path = ".\Bin\NVIDIA-Ethminer\ethminer.exe"
$Uri = "https://github.com/MrPlusGH/NPlusMiner-MinersBinaries/raw/master/MinersBinaries/EthMiner/ethminer-0.19.0-alpha.0-cuda10.0-windows-amd64.zip"
$Commands = [PSCustomObject]@{
    #"ethash" = "" #Ethash(fastest)
}
$Port = $Variables.NVIDIAMinerAPITCPPort
$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
	$Algo =$_
	$AlgoNorm = Get-Algorithm($_)

    $Pools.($AlgoNorm) | foreach {
        $Pool = $_
        invoke-Expression -command ( $MinerCustomConfigCode )
        If ($AbortCurrentPool) {Return}

        $Arguments = "--cuda-devices $($Config.SelGPUDSTM) --api-port -$Port -U -P stratum://$($Pool.User):x@$($Pool.Host):$($Password)"

        [PSCustomObject]@{
            Type      = "NVIDIA"
            Path      = $Path
            Arguments = Merge-Command -Slave $Arguments -Master $CustomCmdAdds -Type "Command"
            HashRates = [PSCustomObject]@{($AlgoNorm) = $Stats."$($Name)_$($AlgoNorm)_HashRate".Week} 
            API       = "ethminer"
            Port      = $Variables.NVIDIAMinerAPITCPPort
            Wrap      = $false
            URI       = $Uri    
            User      = $Pool.User
            Host = $Pool.Host
            Coin = $Pool.Coin
        }
    }
}
