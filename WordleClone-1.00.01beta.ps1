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
            Write-Host "$($printLetter.Letter)" -BackgroundColor "$($printLetter.Color)" -ForegroundColor White -NoNewline
        }
    }
}
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
PrintAlphabet
while (!($solved) -and ($guessNumber -lt 6)) {
    $guessNumber++
    $Guess = Read-Host "`nGuess $($guessNumber)"
    $guess = $Guess.ToUpper()
    if ($guess -eq $word) {$solved = $true}
    if ((($possibleAnswers -contains $guess) -or ($badGuesses -contains $guess)) -and ($guess.Length -eq 5)) {
        $guessOut = @{}
        $guessOut.Attempt = $guessNumber
        for ($i = 0; $i -lt $guess.Length; $i++) {
            $guessLetter = $guess[$i]
            $guessOut.Letter = $guessLetter
            if ($guessLetter -eq $word[$i]) {
                if (($alphabetArray | Where-Object {$_.Letter -eq $guessLetter}).Color -ne "Green") {
                    ChangeColor $guessLetter "Green"
                }
                $guessOut.Color = "Green"
            } 
            elseif ($word.Contains($guessLetter) -and !($word[$i] -eq $guessLetter) -and $guess.Split($guessLetter).Count -le ($word.Split($guessLetter).Count)) {
                if (($alphabetArray | Where-Object {$_.Letter -eq $guessLetter}).Color -ne "Green") {
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
if ($solved) {
    Write-Host "`n Answer: $($word.ToUpper())" -ForegroundColor White -BackgroundColor Green
}
else {  
    Write-Host "`nAnswer : $($word.ToUpper())" -ForegroundColor White -BackgroundColor DarkRed
}