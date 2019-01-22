if (!(IsLoaded(".\Include.ps1"))) {. .\Include.ps1; RegisterLoaded(".\Include.ps1")}

$Path = ".\Bin\NVIDIA-zjazz12\zjazz_cuda.exe"
$Uri = "https://github.com/zjazz/zjazz_cuda_miner/releases/download/1.2/zjazz_cuda_win64_1.2.zip"

$Commands = [PSCustomObject]@{
    # "bitcash" = " -a bitcash" #Bitcash (testing)
    "cuckoo"  = " -a bitcash " #Cuckoo (testing nlpool) --cuckoo-cpu-assist-min 
    #"x22i"    = " -a x22i" #SUQA (testing)
}

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
    [PSCustomObject]@{
        Type      = "NVIDIA"
        Path      = $Path
        Arguments = "-d $($Config.SelGPUDSTM.Replace(' ', ' -d ')) --api-bind $($Variables.NVIDIAMinerAPITCPPort) -o stratum+tcp://$($Pools.(Get-Algorithm($_)).Host):$($Pools.(Get-Algorithm($_)).Port) -u $($Pools.(Get-Algorithm($_)).User) -p $($Pools.(Get-Algorithm($_)).Pass)$($Commands.$_)"
        HashRates = [PSCustomObject]@{(Get-Algorithm($_)) = $Stats."$($Name)_$(Get-Algorithm($_))_HashRate".week * .98 * 2000} # substract 2% devfee + Temp fix for nlpool wrong hashrate
        API       = "ccminer"
        Port      = $Variables.NVIDIAMinerAPITCPPort #4068
        Wrap      = $false
        URI       = $Uri
        User      = $Pools.(Get-Algorithm($_)).User
        Host      = $Pools.(Get-Algorithm $_).Host
        Coin      = $Pools.(Get-Algorithm $_).Coin
        PreventCPUMining      = $true
    }
}