$path = "$PSScriptRoot"
if (!(Test-Path $path\wordle_words.txt)) {
    $words = Get-Content $path\words.txt 
    $nums=$()
    for($n=48;$n -le 57;$n++) {
        $nums+=[char][byte]$n 
        }
    $lets=$()
    for($l=65;$l -le 90;$l++) {
        $lets+=[char][byte]$l 
        }
    $specs = "~!@#$%^&*_-+=`|\(){}[]:;""'<>,.?/".ToCharArray()
    $wordle_words = @() 
    foreach ($w in $words) {
        $w_array = $w.ToCharArray()
        if (($w -cmatch "^[^A-Z]*$") -and ($w -match "^[^0-9]*$") -and (!((Compare-Object -ReferenceObject $w_array -DifferenceObject $specs -IncludeEqual).SideIndicator -contains '==')) -and ($w_array.Count -eq 5)) {
            $wordle_words += $w
            }
        }
    $wordle_words | Set-Content $path\wordle_words.txt
    }
else {$wordle_words = Get-Content $path\wordle_words.txt }
$answerWord = Get-Random $wordle_words -Count 1
$answerWord = $answerWord.ToUpper()
$word = $answerWord
$guessNumber = 0
$Guess = $null
$solved = $false
$guessReport = @()
while (!($solved) -and ($guessNumber -le 6)) {
    $guessNumber++
    $Guess = Read-Host "Guess #$($guessNumber)"
    $guess = $guess.ToUpper()
    if ($Guess -eq $word) {
        $solved = $true
    }
    else {
        $solved = $false
    }
    $guessOut = @{}
    $guessOut.Attempt = $guessNumber
    $matchedIndices = @{}
    $matchedLetters = @{}
    for ($i = 0; $i -lt $guess.Length; $i++) {
        $guessLetter = $guess[$i]
        $guessOut.Letter = $guessLetter
        if ($guessLetter -eq $word[$i]) {
            $guessOut.Color = "Green"
            $matchedIndices[$i] = $true
            $matchedLetters[$guessLetter]++
        }
        elseif ($word.Contains($guessLetter)) {
            $wordIndices = @(0..($word.Length - 1)) | Where-Object { $_ -notin $matchedIndices.Keys } 
            $wordIndex = $wordIndices | Where-Object { $word[$_] -eq $guessLetter } | Select-Object -First 1

            if ($null -ne $wordIndex) {
                if ($matchedLetters.ContainsKey($guessLetter)) {
                    if ($matchedLetters[$guessLetter] -lt ($word -eq $guessLetter).Count) {
                        $guessOut.Color = "Yellow"
                        $matchedIndices[$wordIndex] = $true
                        $matchedLetters[$guessLetter]++
                    } else {
                        $guessOut.Color = "Gray"
                    }
                } else {
                    $guessOut.Color = "Yellow"
                    $matchedIndices[$wordIndex] = $true
                    $matchedLetters[$guessLetter] = 1
                }
            } else {
                $guessOut.Color = "Gray"
            }
        }
        else {
            $guessOut.Color = "Gray"
        }
        $guessReport += [pscustomobject]$guessOut
    }
    for ($x = 1; $x -le $guessNumber; $x++) {
        Write-Host "`nGuess $($x): " -NoNewLine
        foreach ($printLetter in ($guessReport | Where-Object {$_.Attempt -eq $x})) {
            Write-Host "$($printLetter.letter)" -ForegroundColor "$($printLetter.color)" -NoNewline
        }
    }
    Write-Host "`n"
}
Write-Host " Answer: $($word.ToUpper())"