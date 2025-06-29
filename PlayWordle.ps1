$path = $PSScriptRoot
if (Test-Path "$path\wordle_words.csv") {
    $words = Import-Csv "$path\wordle_words.csv"
    $possibleAnswers = ($words | Where-Object { $_.Answer -eq 1 }).Word
    $badGuesses = ($words | Where-Object { $_.Answer -eq 0 }).Word
}
else {
    Write-Host "Database not found!"
    break
}

function ChangeColor($letter,$color) {
    foreach ($item in $alphabetArray) {
        if ($item.Letter -eq $letter) {
            $item.Color = $color
        }
    }
}

function PrintAlphabet() {
    foreach ($alpha in $alphabetArray) {
        Write-Host "$($alpha.Letter) " -ForegroundColor $alpha.Color -NoNewline
    }
}

function PrintGuesses($guessNumber) {
    for ($x = 1; $x -le $guessNumber; $x++) {
        Write-Host "`nGuess $($x): " -NoNewline
        foreach ($printLetter in ($guessReport | Where-Object {$_.Attempt -eq $x})) {
            Write-Host "$($printLetter.Letter)" -ForegroundColor "$($printLetter.Color)" -NoNewline
        }
    }
}

function ProcessGuess($guess, $word) {
    $result = @()
    $wordArray = $word.ToCharArray()
    $guessArray = $guess.ToCharArray()
    
    # Create arrays to track used letters
    $wordUsed = @($false) * $word.Length
    $guessProcessed = @($false) * $guess.Length
    
    # First pass: Mark exact matches (Green)
    for ($i = 0; $i -lt $guess.Length; $i++) {
        if ($guessArray[$i] -eq $wordArray[$i]) {
            $result += @{
                Position = $i
                Letter = $guessArray[$i]
                Color = "Green"
            }
            $wordUsed[$i] = $true
            $guessProcessed[$i] = $true
            
            # Update alphabet color
            if (($alphabetArray | Where-Object {$_.Letter -eq $guessArray[$i]}).Color -ne "Green") {
                ChangeColor $guessArray[$i] "Green"
            }
        }
    }
    
    # Second pass: Mark wrong position matches (Yellow)
    for ($i = 0; $i -lt $guess.Length; $i++) {
        if (-not $guessProcessed[$i]) {
            $foundMatch = $false
            for ($j = 0; $j -lt $word.Length; $j++) {
                if (-not $wordUsed[$j] -and $guessArray[$i] -eq $wordArray[$j]) {
                    $result += @{
                        Position = $i
                        Letter = $guessArray[$i]
                        Color = "Yellow"
                    }
                    $wordUsed[$j] = $true
                    $foundMatch = $true
                    
                    # Update alphabet color (only if not already green)
                    if (($alphabetArray | Where-Object {$_.Letter -eq $guessArray[$i]}).Color -ne "Green") {
                        ChangeColor $guessArray[$i] "Yellow"
                    }
                    break
                }
            }
            
            # If no match found, mark as gray
            if (-not $foundMatch) {
                $result += @{
                    Position = $i
                    Letter = $guessArray[$i]
                    Color = "Gray"
                }
                ChangeColor $guessArray[$i] "DarkGray"
            }
        }
    }
    
    # Sort result by position to maintain order
    return $result | Sort-Object Position
}

# Initialize alphabet array
$alphabetArray = @()
for ($ascii = 65; $ascii -le 90; $ascii++) {
    $alphabetHash = @{}
    $alphabetHash.Letter = [char]$ascii
    $alphabetHash.Color = "Gray"
    $alphabetArray += [pscustomobject]$alphabetHash
}

$answerWord = Get-Random $possibleAnswers -Count 1
$answerWord = $answerWord.ToUpper()
$word = $answerWord
$guessNumber = 0
$Guess = $null
$solved = $false
$guessReport = @()

Clear-Host 
Write-Host "`n`r"
PrintAlphabet

while (!($solved) -and ($guessNumber -lt 6)) {
    $guessNumber++
    $Guess = Read-Host "`nGuess $($guessNumber)"
    $guess = $Guess.ToUpper()
    
    if ($guess -eq $word) {$solved = $true}
    
    if ((($possibleAnswers -contains $guess) -or ($badGuesses -contains $guess)) -and ($guess.Length -eq 5)) {
        # Process the guess using the new function
        $guessResult = ProcessGuess $guess $word
        
        # Add results to guess report
        foreach ($letterResult in $guessResult) {
            $guessOut = @{}
            $guessOut.Attempt = $guessNumber
            $guessOut.Letter = $letterResult.Letter
            $guessOut.Color = $letterResult.Color
            $guessReport += [pscustomobject]$guessOut
        }
        
        Clear-Host
        "`n"
        PrintAlphabet
        PrintGuesses -guessNumber $guessNumber
    } 
    else {
        Clear-Host
        Write-Host "`n$Guess is not a valid guess. Try again."
        $guessNumber--
        "`n"
        PrintAlphabet
        PrintGuesses -guessNumber $guessNumber
    }
}

Write-Host "`n`r"
if ($solved) {
    Write-Host "`nAnswer : $($word.ToUpper())" -ForegroundColor White -BackgroundColor Green
}
else {  
    Write-Host "`nAnswer : $($word.ToUpper())" -ForegroundColor White -BackgroundColor DarkRed
}
