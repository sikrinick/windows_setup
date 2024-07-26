function Print-ComputerInfo {

    Get-WmiObject -Class Win32_ComputerSystem -Property Manufacturer, Model

    $processor = (Get-WmiObject Win32_Processor).Name
    Write-Object "CPU: $processor"

    $ramGb = [Math]::Round((Get-WmiObject -Class Win32_ComputerSystem -ComputerName localhost).TotalPhysicalMemory/1Gb)
    Write-Object "RAM: $(ramGb)GB"

    $capacity = foreach ($disk in Get-WmiObject -Class Win32_DiskDrive)
    {
        [Math]::Round(($disk.Size / 1GB), 2)
    }
    Write-Object "SSD: $(($capacity | Measure-Object -Sum).Sum)GB"
}