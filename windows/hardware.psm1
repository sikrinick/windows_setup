function Print-ComputerInfo {
    $info = Get-WmiObject -Class Win32_ComputerSystem -Property Manufacturer, Model
    Write-Output "Model: $info"

    $processor = (Get-WmiObject Win32_Processor).Name
    Write-Output "CPU: $processor"

    $ramGb = [Math]::Round((Get-WmiObject -Class Win32_ComputerSystem -ComputerName localhost).TotalPhysicalMemory/1Gb)
    Write-Output "RAM: $($ramGb)GB"

    $capacity = foreach ($disk in Get-WmiObject -Class Win32_DiskDrive)
    {
        [Math]::Round(($disk.Size / 1GB), 2)
    }
    Write-Output "SSD: $(($capacity | Measure-Object -Sum).Sum)GB"
}
