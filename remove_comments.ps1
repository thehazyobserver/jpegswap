# PowerShell script to remove comments from Solidity file
$content = Get-Content SwapPool_temp.sol
$newContent = @()
$inMultiLineComment = $false

foreach ($line in $content) {
    # Check if starting a multi-line comment
    if ($line -match '^\s*/\*') {
        $inMultiLineComment = $true
        # Check if it's also ending on the same line
        if ($line -match '\*/\s*$') {
            $inMultiLineComment = $false
        }
        continue
    }
    
    # Check if ending a multi-line comment
    if ($inMultiLineComment -and $line -match '\*/') {
        $inMultiLineComment = $false
        continue
    }
    
    # Skip lines inside multi-line comments
    if ($inMultiLineComment) {
        continue
    }
    
    # Add line if not in comment
    $newContent += $line
}

# Save to new file
$newContent | Set-Content SwapPool_clean.sol
Write-Host "Original lines: $($content.Count)"
Write-Host "Clean lines: $($newContent.Count)"
Write-Host "Removed: $(($content.Count) - ($newContent.Count)) lines"
