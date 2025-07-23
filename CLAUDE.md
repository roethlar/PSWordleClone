# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a PowerShell implementation of Wordle that recreates the popular word guessing game. The game allows 6 attempts to guess a 5-letter word with colored feedback (Green for correct position, Yellow for correct letter wrong position, Gray for letters not in the word).

## How to Run

```powershell
./PlayWordle.ps1
```

The script will automatically load the word database from `wordle_words.csv` and start a new game session.

## Architecture

The codebase consists of a single main script with several key components:

### Word Database (`wordle_words.csv`)
- CSV file containing valid words with an `Answer` flag (1 for possible answers, 0 for valid guesses only)
- Loaded at startup to populate `$possibleAnswers` and `$badGuesses` arrays

### Core Functions
- `ProcessGuess()` - Handles the two-pass algorithm for determining letter colors, properly managing duplicate letters
- `ChangeColor()` - Updates the alphabet display colors based on guess results  
- `PrintAlphabet()` - Displays the current state of all letters A-Z with color coding
- `PrintGuesses()` - Shows previous guesses with their color-coded results

### Game State Management
- `$alphabetArray` - Tracks color state of each letter in the alphabet
- `$guessReport` - Stores all guess attempts with their color results
- Two-pass duplicate letter handling: exact matches first (Green), then wrong position matches (Yellow)

## Known Issues

The README notes that duplicate letter handling isn't perfect, so this area may need attention for improvements.

## Testing

`test_arrays.ps1` contains experimental code for testing duplicate letter scenarios with longer words.