#Requires -Version 3.0
function Get-MrTop10Counter {

<#
.SYNOPSIS
  Gets performance counter data from local and remote computers.
 
.DESCRIPTION
  The Get-MrTop10Counter function gets live, real-time performance counter
  data directly from the performance monitoring instrumentation in Windows.
 
.PARAMETER ComputerName
  Gets data from the specified computers. Type the NetBIOS name, an Internet
  Protocol (IP) address, or the fully qualified domain names of the computers.
  The default value is the local computer.
 
.EXAMPLE
  Get-MrTop10Counter -ComputerName Server01, Server02

.INPUTS
  None
 
.OUTPUTS
  PSCustomObject
 
.NOTES
  Author:  Mike F Robbins
  Website: http://mikefrobbins.com
  Twitter: @mikefrobbins
#>

  [CmdletBinding()]
  param (
    [ValidateNotNullOrEmpty()]
    [string]$ComputerName = $env:COMPUTERNAME
  )

  $Params = @{
    Counter = '\Disque physique(*)\% d''inactivité',
              '\Disque physique(*)\Moyenne disque s/lecture',
              '\Disque physique(*)\Moyenne disque s/écriture',
              '\Disque physique(*)\Taille de file d''attente du disque actuelle',
              '\Mémoire\Octets disponibles',
              '\Mémoire\Pages/s',
              '\Interface réseau(*)\Total des octets/s',
              '\Interface réseau(*)\Longueur de la file d''attente de sortie',
              '\Processeur logique de l''hyperviseur Hyper-V(*)\% de la durée d''exécution totale',
              '\Fichier d''échange(*)\Pourcentage d''utilisation'        
    ErrorAction = 'SilentlyContinue'
  }
 
  if ($PSBoundParameters.ComputerName) {
    $Params.ComputerName = $ComputerName
  }

  $Counters = (Get-Counter @Params).CounterSamples

  foreach ($Counter in $Counters){
    [pscustomobject]@{
      ComputerName = $ComputerName
      CounterSetName = $Counter.Path -replace "^\\\\$ComputerName\\|\(.*$"
      Counter = $Counter.Path -replace '^.*\\'
      Instance = $Counter.InstanceName
      Value = $Counter.CookedValue
      TimeStamp = $Counter.Timestamp
    }
  }
}