# Import the CSV file if it exists, else exit
$path = $PSScriptRoot
$csvPath = "$path\wordle_words.csv"
if (Test-Path $csvPath) {
    $words = Import-Csv $csvPath
    $possibleAnswers = $words | Where-Object { $_.Answer -eq 1 } | Select-Object -ExpandProperty Word
    $badGuesses = $words | Where-Object { $_.Answer -eq 0 } | Select-Object -ExpandProperty Word
}
else {
    Write-Host "Database not found!"
    break
}

# Define functions
function ChangeColor($letter, $color) {
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
            Write-Host "$($printLetter.Letter)" -ForegroundColor $printLetter.Color -NoNewline
        }
    }
}

# Initialize alphabet array
$alphabetArray = @{}
65..90 | ForEach-Object {
    $alphabetArray.Add([char]$_, [pscustomobject]@{ Letter = [char]$_; Color = "Gray" })
}

# Select a random word from possible answers
$answerWord = Get-Random $possibleAnswers -Count 1
$word = $answerWord.ToUpper()
$guessNumber = 0
$Guess = $null
$solved = $false
$guessReport = @()

# Print alphabet and start the game loop
PrintAlphabet
while (!($solved) -and ($guessNumber -lt 6)) {
    $guessNumber++
    $Guess = Read-Host "`nGuess $($guessNumber)"
    $guess = $Guess.ToUpper()
    if ($guess -eq $word) {
        $solved = $true
    }
    if (($possibleAnswers -contains $guess -or $badGuesses -contains $guess) -and $guess.Length -eq 5) {
        $guessOut = @{}
        $guessOut.Attempt = $guessNumber
        for ($i = 0; $i -lt $guess.Length; $i++) {
            $guessLetter = $guess[$i]
            $guessOut.Letter = $guessLetter
            if ($guessLetter -eq $word[$i]) {
                if ($alphabetArray[$guessLetter].Color -ne "Green") {
                    ChangeColor $guessLetter "Green"
                }
                $guessOut.Color = "Green"
            } 
            elseif ($word.Contains($guessLetter) -and !($word[$i] -eq $guessLetter) -and $guess.Split($guessLetter).Count -le ($word.Split($guessLetter).Count)) {
                if ($alphabetArray[$guessLetter].Color -ne "Green") {
                    ChangeColor $guessLetter "Yellow"
                }
                $guessOut.Color = "Yellow"
            } 
            else {
                ChangeColor $guessLetter "DarkGray"
                $guessOut.Color = "Gray"
            }
            $guessReport += [pscustomobject]$guessOut
        }
        # Print the alphabet and guesses
        "`n" * 2
        PrintAlphabet
        PrintGuesses -guessNumber $guessNumber
    } 
    else {
        # Print invalid guess message
        Write-Host "`n$Guess is not a valid guess. Try again."
        $guessNumber--
        "`n" * 2
        PrintAlphabet
        PrintGuesses -guessNumber $guessNumber
    }
}

# Print the result
if ($solved) {
    Write-Host "`n Answer: $($word.ToUpper())" -ForegroundColor White -BackgroundColor Green
}
else {  
    Write-Host "`nAnswer : $($word.ToUpper())" -ForegroundColor White -BackgroundColor DarkRed
}
