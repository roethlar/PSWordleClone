$alphabetArray = @()
for ($ascii = 65; $ascii -le 90; $ascii++) {
    $alphabetHash = @{}
    $alphabetHash.Letter = [char]$ascii
    $alphabetHash.Color = "Gray"
    $alphabetArray += [pscustomobject]$alphabetHash
}

$answerWord = "HAPPYMONKEY"
$guess =      "PAPGMAPPEYR"
$guessArray = $guess.ToCharArray()
$answerWordArray = $answerWord.ToCharArray()
$guessLetterCounts = @()
$answerLetterCounts = @()

<#
$guessDisplay = @()
foreach ($gl in $guess.ToCharArray()) {
    $glcount = 0
    $a = @{}
    $a.Letter = $gl
    $glTotal = ($guess.ToCharArray() | Where-Object {$_ -eq $gl}).Count
    $a.Total = $glTotal
    if ($glTotal -le ($guessDisplay | Where-Object {$_.letter -eq $gl}).Count) {
        for ($i = 0; $i -lt 5; $i++) {
            if ($gl -eq $answerWord[$i]) {
                $glCount++
                $a.Color = "Green"
            }
            elseif (($answerWord -match $gl) -and ($glTotal -ge $glCount) -and $guessDisplay[$i].Color -ne "Green") {
                $glCount++
                $a.Color = "Yellow"
            }
        $a.Found = $glCount
        $guessDisplay += [pscustomobject]$a
        }
    }
    else {
        $a.Color = "Grey"
        $guessDisplay += [pscustomobject]$a
    }
}
$guessDisplay
#>
$guessUniques = $guessArray | Select-Object -Unique
foreach ($gu in $guessUniques) {
    $b = @{}
    $b.Letter = $gu
    $b.count = ($guessArray | Where-Object {$_ -eq $gu}).Count
    $guessLetterCounts += [PSCustomObject]$b
}
$guessLetterCounts | Format-Table -AutoSize
"`n`r"
$answerWordUniques = $answerWordArray | Select-Object -Unique
foreach ($au in $answerWordUniques) {
    $c = @{}
    $c.Letter = $au
    $c.count = ($answerWordArray | Where-Object {$_ -eq $au}).Count
    $answerLetterCounts += [PSCustomObject]$c
}
$answerLetterCounts | Format-Table -AutoSize
