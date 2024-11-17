function prompt {
    # Segment 1: Username
    $userSegment = "$(whoami) "
    Write-Host $userSegment -NoNewline -ForegroundColor White -BackgroundColor DarkGreen

    # Segment 2: Current directory
    $dirSegment = "$(Get-Location) "
    Write-Host $dirSegment -NoNewline -ForegroundColor Black -BackgroundColor Cyan

    # Segment 3: Git status (if in a git repo)
    if (Test-Path .git) {
        $gitSegment = "  $(git rev-parse --abbrev-ref HEAD) "
        Write-Host $gitSegment -NoNewline -ForegroundColor White -BackgroundColor DarkMagenta
    }

    # Return to new line
    return " "
}

