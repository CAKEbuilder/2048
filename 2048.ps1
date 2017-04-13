
# definitions
$debug = 1

# store the value in each position
$posValue = @(0) * 16

# used for keeping position values formatted to fit the game piece correctly
$posValueCentered = @($null) * 16

$posFGColor = @("White") * 16
$posBGColor = @("DarkMagenta") * 16
$global:pieceJustSpawned = @(0) * 16

$defaultfG = "white"
$defaultBG = "darkgray"

$posCoords = @($null) * 16
$posCoords[0]  =  "2.3"   # created as strings so we can split on the period, then we cast as int later
$posCoords[1]  =  "10.3"
$posCoords[2]  = "18.3"
$posCoords[3]  = "26.3"
$posCoords[4]  =  "2.8"
$posCoords[5]  =  "10.8"
$posCoords[6]  = "18.8"
$posCoords[7]  = "26.8"
$posCoords[8]  =  "2.13"
$posCoords[9]  =  "10.13"
$posCoords[10] = "18.13"
$posCoords[11] = "26.13"
$posCoords[12] =  "2.18"
$posCoords[13] =  "10.18"
$posCoords[14] = "18.18"
$posCoords[15] = "26.18"

# allow the first piece to spawn
$global:didAnyPiecesMove = $true

# capture original values so players don't hate you
$originalCursorState = [console]::CursorVisible
$originalBackgroundColor = [console]::BackgroundColor   # DarkMagenta
# all available colors: [Enum]::GetValues([ConsoleColor])

# setup the properties of the game
[console]::CursorVisible = $false
#[console]::BackgroundColor = "DarkGray"


<#

  not to scale, used for reference
  ###############
  # 0  1  2  3  #
  # 4  5  6  7  #
  # 8  9  10 11 #
  # 12 13 14 15 #
  ###############

#>

if($debug -eq 1) {
    Set-PSBreakpoint -Variable breakHere
}
else {
    if(Get-PSBreakpoint) {
        Get-PSBreakpoint | Remove-PSBreakpoint
    }
}

<#
# write-buffer no color
function Write-Buffer ([string] $str, [int] $x = 0, [int] $y = 0) {
    [console]::setcursorposition($x,$y)
    Write-Host $str -NoNewline
}
#>

# write-buffer with color
function Write-Buffer ([string] $str, [int] $x = 0, [int] $y = 0,[string]$fg = $defaultFG,[string]$bg = $defaultBG) {
    [console]::setcursorposition($x,$y)
    Write-Host $str -NoNewline -ForegroundColor $fg -BackgroundColor $bg
}

function restoreConsole {
    [console]::CursorVisible = $originalCursorState
    [console]::BackgroundColor = $originalBackgroundColor
    clear
}

function shiftRight {
    # check each position (processing from right to left)
    for($pos=15;$pos -ge 0;$pos--) {
        # there's nothing to do if the value is empty, or if we're evaluating a value in the right most column (these cant ever move right)
        if(($posValue[$pos] -ne 0) -and ($posValue[$pos] -ne $null) -and ($pos -ne 3) -and ($pos -ne 7) -and ($pos -ne 11) -and ($pos -ne 15)) {
            # keep working on this position as it moves right until you can no longer do anything with it
            $posTemp = $pos
            $done = $false
            $global:didAnyPiecesMove = $false
            do {
                # check the value to the right
                $nextValueRight = $posValue[$posTemp+1]
                if($nextValueRight -eq 0) {
                    # we can move to this position
                    # set the right value
                    $posValue[$posTemp+1] = $posValue[$posTemp]
                    $posValueCentered[$posTemp+1] = $posValueCentered[$posTemp]
                    # update the old value
                    $posValue[$posTemp] = 0
                    $posValueCentered[$posTemp] = "     "
                    # stay with this value
                    $posTemp = $posTemp + 1
                    # identify that at least one piece moved. if when we're done evaluating all the pieces we find none have moved, we won't spawn a new piece.
                    $global:didAnyPiecesMove = $true
                }
                elseif($nextValueRight -eq $posValue[$posTemp]) {
                    # we can multiply the next position by 2
                    $posValue[$posTemp+1] = $posValue[$posTemp+1] * 2
                    $posValueCentered[$posTemp+1] = $posValueCentered[$posTemp]
                    # update the old value
                    $posValue[$posTemp] = 0
                    $posValueCentered[$posTemp] = "     "
                    # stay with this value
                    $posTemp = $posTemp + 1
                    $done = $true
                    $global:didAnyPiecesMove = $true
                }
                else {
                    # we can not do anything else with this position
                    $done = $true
                }

                # if $posTemp is in the right column, then we're done
                if(($posTemp -eq 3) -or ($posTemp -eq 7) -or ($posTemp -eq 11) -or ($posTemp -eq 15)) {
                    $done = $true
                }
            } until ($done)
        }
    }
}

function shiftLeft {
    # check each position (processing from left to right)
    for($pos=0;$pos -le 15;$pos++) {
        if(($posValue[$pos] -ne 0) -and ($posValue[$pos] -ne $null) -and ($pos -ne 0) -and ($pos -ne 4) -and ($pos -ne 8) -and ($pos -ne 12)) {
            $posTemp = $pos
            $done = $false
            $global:didAnyPiecesMove = $false
            do {
                $nextValueLeft = $posValue[$posTemp-1]
                if($nextValueLeft -eq 0) {
                    $posValue[$posTemp-1] = $posValue[$posTemp]
                    $posValueCentered[$posTemp-1] = $posValueCentered[$posTemp]
                    $posValue[$posTemp] = 0
                    $posValueCentered[$posTemp] = "     "
                    $posTemp = $posTemp - 1
                    $global:didAnyPiecesMove = $true
                }
                elseif($nextValueLeft -eq $posValue[$posTemp]) {
                    $posValue[$posTemp-1] = $posValue[$posTemp-1] * 2
                    $posValueCentered[$posTemp-1] = $posValueCentered[$posTemp]
                    $posValue[$posTemp] = 0
                    $posValueCentered[$posTemp] = "     "
                    $posTemp = $posTemp - 1
                    $done = $true
                    $global:didAnyPiecesMove = $true
                }
                else {
                    $done = $true
                }

                if(($posTemp -eq 0) -or ($posTemp -eq 4) -or ($posTemp -eq 8) -or ($posTemp -eq 12)) {
                    $done = $true
                }
            } until ($done)
        }
    }
}

function shiftUp {
    # check each position (processing from top to bottom)
    # shiftUp/Down are different from shiftLeft/Right. we can't use $pos sequencially, need to hop around
    for($pos=0;$pos -le 15;$pos=($pos+4)) {
        if(($posValue[$pos] -ne 0) -and ($posValue[$pos] -ne $null) -and ($pos -ne 0) -and ($pos -ne 1) -and ($pos -ne 2) -and ($pos -ne 3)) {
            $posTemp = $pos
            $done = $false
            $global:didAnyPiecesMove = $false
            do {
                $nextValueUp = $posValue[$posTemp-4]
                if($nextValueUp -eq 0) {
                    $posValue[$posTemp-4] = $posValue[$posTemp]
                    $posValueCentered[$posTemp-4] = $posValueCentered[$posTemp]
                    $posValue[$posTemp] = 0
                    $posValueCentered[$posTemp] = "     "
                    $posTemp = $posTemp - 4
                    $global:didAnyPiecesMove = $true
                }
                elseif($nextValueUp -eq $posValue[$posTemp]) {
                    $posValue[$posTemp-4] = $posValue[$posTemp-4] * 2
                    $posValueCentered[$posTemp-4] = $posValueCentered[$posTemp]
                    $posValue[$posTemp] = 0
                    $posValueCentered[$posTemp] = "     "
                    $posTemp = $posTemp - 4
                    $done = $true
                    $global:didAnyPiecesMove = $true
                }
                else {
                    $done = $true
                }

                if(($posTemp -eq 0) -or ($posTemp -eq 1) -or ($posTemp -eq 2) -or ($posTemp -eq 3)) {
                    $done = $true
                }
            } until ($done)
        }
        # if we're at the top row, we'll need to move left and start agian at the bottom
        if($pos -eq 12) {
        $pos = (-3)   # we want it to be 4, but we're going to add 4 once we loop in for() again in a moment
        }
        if($pos -eq 13) {
            $pos = (-2)
        }
        if($pos -eq 14) {
            $pos = (-1)
        }
    }
}

function shiftDown {
    # check each position (processing from bottom to top)
    for($pos=15;$pos -ge 0;$pos=($pos-4)) {
        if(($posValue[$pos] -ne 0) -and ($posValue[$pos] -ne $null) -and ($pos -ne 12) -and ($pos -ne 13) -and ($pos -ne 14) -and ($pos -ne 15)) {
            $posTemp = $pos
            $done = $false
            $global:didAnyPiecesMove = $false
            do {
                $nextValueDown = $posValue[$posTemp+4]
                if($nextValueDown -eq 0) {
                    $posValue[$posTemp+4] = $posValue[$posTemp]
                    $posValueCentered[$posTemp+4] = $posValueCentered[$posTemp]
                    $posValue[$posTemp] = 0
                    $posValueCentered[$posTemp] = "     "
                    $posTemp = $posTemp + 4
                    $global:didAnyPiecesMove = $true
                }
                elseif($nextValueDown -eq $posValue[$posTemp]) {
                    $posValue[$posTemp+4] = $posValue[$posTemp+4] * 2
                    $posValueCentered[$posTemp+4] = $posValueCentered[$posTemp]
                    $posValue[$posTemp] = 0
                    $posValueCentered[$posTemp] = "     "
                    $posTemp = $posTemp + 4
                    $done = $true
                    $global:didAnyPiecesMove = $true
                }
                else {
                    $done = $true
                }

                if(($posTemp -eq 12) -or ($posTemp -eq 13) -or ($posTemp -eq 14) -or ($posTemp -eq 15)) {
                    $done = $true
                }
            } until ($done)
        }
        # if we're at the top row, we'll need to move left and start agian at the bottom
        if($pos -eq 3) {
        $pos = 18   # we want it to be 14, but we're going to subtract 4 once we loop in for() again in a moment
        }
        if($pos -eq 2) {
            $pos = 17
        }
        if($pos -eq 1) {
            $pos = 16
        }
    }
}

function updateColors {
    # before drawing the board, let's update the colors of each pos
    for($i=0;$i -le 15;$i++) {
        if($posValue[$i] -eq 2) {
            $posFGColor[$i] = "white"
            $posBGColor[$i] = "darkgreen"
        }
        if($posValue[$i] -eq 4) {
            $posFGColor[$i] = "white"
            $posBGColor[$i] = "darkred"
        }
        if($posValue[$i] -eq 8) {
            $posFGColor[$i] = "white"
            $posBGColor[$i] = "darkred"
        }
        if($posValue[$i] -eq 16) {
            $posFGColor[$i] = "white"
            $posBGColor[$i] = "darkred"
        }
        if($posValue[$i] -eq 32) {
            $posFGColor[$i] = "white"
            $posBGColor[$i] = "darkred"
        }
        if($posValue[$i] -eq 64) {
            $posFGColor[$i] = "white"
            $posBGColor[$i] = "darkred"
        }
        if($posValue[$i] -eq 128) {
            $posFGColor[$i] = "white"
            $posBGColor[$i] = "darkred"
        }
        if($posValue[$i] -eq 256) {
            $posFGColor[$i] = "white"
            $posBGColor[$i] = "darkred"
        }
        if($posValue[$i] -eq 512) {
            $posFGColor[$i] = "white"
            $posBGColor[$i] = "darkred"
        }
        if($posValue[$i] -eq 1024) {
            $posFGColor[$i] = "white"
            $posBGColor[$i] = "darkred"
        }
        if($posValue[$i] -eq 2048) {
            $posFGColor[$i] = "white"
            $posBGColor[$i] = "darkred"
        }
    }
}

function drawBoard {
    # let's insert each position
    for($i=0;$i -lt 16;$i++) {
        # center each posValue
        if($posValue[$i] -gt 0) {
            # single digit
            if($posValue[$i] -lt 10) {
                $posValueCentered[$i] = "  " + $posValue[$i] + "  "
            }
            # two digit (same as single, I just like having each check separate)
            if(($posValue[$i] -ge 10) -and ($posValue[$i] -le 100)) {
                $posValueCentered[$i] = "  " + $posValue[$i] + " "
            }
            # three digit
            if(($posValue[$i] -ge 100) -and ($posValue[$i] -le 1000)) {
                $posValueCentered[$i] = " " + $posValue[$i] + " "
            }
            # four digit
            if(($posValue[$i] -ge 1000) -and ($posValue[$i] -le 10000)) {
                $posValueCentered[$i] = $posValue[$i] + " "
            }
            # five digit
            if(($posValue[$i] -ge 10000) -and ($posValue[$i] -le 100000)) {
                $posValueCentered[$i] = $posValue[$i]
            }
        }

        $x = [int]$posCoords[$i].Split('.')[0]
        $y = [int]$posCoords[$i].Split('.')[1]
        #write-buffer $posValueCentered[$i] $x $y $posFGColor[$i] $posBGColor[$i]
        write-buffer $posValueCentered[$i] $x $y

        # prepare the symbol to use for drawing the piece border. if a piece is 0 or $null, "erase" the piece border by overwriting the previous border with spaces. also erase the old value
        if(($posValue[$i] -eq 0) -or ($posValue[$i] -eq $null)) {
            $topBottomSymbol = " "
            $leftRightSymbol = " "
        }
        else {
            $topBottomSymbol = "_"
            $leftRightSymbol = "|"
        }

        # _dev attempt to create some kind of animation to indicate which piece just spawned
        # if the piece just spawned, do an animation. otherwise, just do the normal piece border drawing function
        if($global:pieceJustSpawned[$i] -eq 1) {
            # draw the piece borders. do the tops/bottoms, then lefts/rights
            for($b=0;$b -lt 5;$b++) {
                # top
                write-buffer $topBottomSymbol ($x+$b) ($y-2)
                # bottom
                write-buffer $topBottomSymbol ($x+$b) ($y+1)

            }
        
            for($b=(-1);$b -lt 2;$b++) {
                # left
                write-buffer $leftRightSymbol ($x-1) ($y+$b)
                # right
                write-buffer $leftRightSymbol ($x+5) ($y+$b)
            }
        }
        else {
            for($b=0;$b -lt 5;$b++) {
                write-buffer $topBottomSymbol ($x+$b) ($y-2)
                write-buffer $topBottomSymbol ($x+$b) ($y+1)

            }
        
            for($b=(-1);$b -lt 2;$b++) {
                write-buffer $leftRightSymbol ($x-1) ($y+$b)
                write-buffer $leftRightSymbol ($x+5) ($y+$b)
            }
        }

        # set the cursor position off the board. I was leaving the cursor in the last position and overwriting stuff. a cursor pos reset used to exist in write-buffer, but putting it here will reduce overhead, not repeating this instruction on every call of write-buffer
        [console]::setcursorposition(0,40)
    }

}

function createObject {
    
    # only create a new object if during our last turn we moved a piece.

    if($global:didAnyPiecesMove) {

        # determine the starting value of the new object
        #   the probability of a 2 is 90%
        #   the probability of a 4 is 10%

        $r = Get-Random -min 1 -max 11   # 11 or 10?
        $randValue = $r

        if($randValue -eq 4) {
            $value = 4
        }
        else {
            $value = 2
        }

        # loop until the random position we've tried is empty
        do {
            # randomly choose an empty position
            $r = Get-Random -min 0 -max 16   # 16 board positions
            $randPos = $posValue[$r]
        } until ($randPos -eq 0)

        $posValue[$r] = $value
        # reset the "just spawned" array
        $global:pieceJustSpawned = @(0) * 16
        # set the piece that just spawned
        $global:pieceJustSpawned[$r] = 1
    }

}

function detectGameOver {

    # for each position, check the surrounding positions. if they have the same value as the current position, the game can play on
    for($i=0;$i -le 15;$i++) {

        # for each position, check above/below/left/right for equivallent values
        $validMovesRemaining = $true
        $canWeSpawnNewPieces = $posValue | group | where name -eq 0 | select -expandproperty count

        if(!$canWeSpawnNewPieces) {
            $above = $null
            $below = $null
            $right = $null
            $left  = $null

            # above position
            if(($i -ne 0) -and ($i -ne 1) -and ($i -ne 2) -and ($i -ne 3)) {
                $above = $posValue[$i-4]
            }

            # below position
            if(($i -ne 12) -and ($i -ne 13) -and ($i -ne 14) -and ($i -ne 15)) {
                $below = $posValue[$i+4]
            }
        
            # right position
            if(($i -ne 3) -and ($i -ne 7) -and ($i -ne 11) -and ($i -ne 15)) {
                $right = $posValue[$i+1]
            }

            # left position
            if(($i -ne 0) -and ($i -ne 4) -and ($i -ne 8) -and ($i -ne 12)) {
                $left = $posValue[$i-1]
            }

            # evaluate each direction
            if(($posValue[$i] -eq $posValue[$above]) -or ($posValue[$i] -eq $posValue[$below]) -or ($posValue[$i] -eq $posValue[$right]) -or ($posValue[$i] -eq $posValue[$left])) {
                # then there are still valid moves on the board
                $validMovesRemaining = $true
            }

        }

    }

    if(!$validMovesRemaining) {
        clear
        write-host "game over"
        restoreConsole
        exit
    }


}







# prepare the board
clear

# draw the game borders. only needs to happen once, then we just append to the screen with Write-Buffer
for($i=0;$i -le 21;$i++) {
    # top
    if($i -eq 0) {
        write-host ("#" * 33)
    }
    # bottom
    elseif($i -eq (21)) {
        write-host ("#" * 33)
    }
    # middle
    else {
        write-host "#" (" " * (33-4)) "#"
    }

}

# colorize the board
for($i=1;$i -le 20;$i++) {
    # fill in the entire play space with a color
    for($a=1;$a -le 31;$a++) {
        write-buffer " " $a $i "white" $defaultBG
    }

}

# draw the grid columns
# only need to do this on init since these positions are never touched by anything later
# would be faster to just write-host exactly what you need.
for($i=1;$i -le 20;$i++) {
    write-buffer "|" 8 $i "gray" $defaultBG
    write-buffer "|" 16 $i "gray" $defaultBG
    write-buffer "|" 24 $i "gray" $defaultBG
}

for($i=1;$i -le 31;$i++) {
    # draw the grid rows
    write-buffer "-" $i 5 "gray" $defaultBG
    write-buffer "-" $i 10 "gray" $defaultBG
    write-buffer "-" $i 15 "gray" $defaultBG
}



# play!
while (1 -eq 1) {

    updateColors
    detectGameOver
    createObject
    drawBoard
    
    # don't continue until the player inputs a valid key
    $validInput = $false
    do {
        $playerInput = [System.Console]::ReadKey() 
        if(($playerInput.key -eq "UpArrow") -or ($playerInput.key -eq "LeftArrow") -or ($playerInput.key -eq "RightArrow") -or ($playerInput.key -eq "DownArrow") -or ($playerInput.key -eq "Escape") -or ($playerInput.key -eq "Spacebar")) {
            $validInput = $true
        }
    } until ($validInput)
    
    # move stuff
    switch ($playerInput.key) {
        UpArrow {
            shiftUp
        }
        LeftArrow {
            shiftLeft
        }
        RightArrow {
            shiftRight
        }
        DownArrow {
            shiftDown
        }
        Spacebar {
            $breakHere = 1
        }
        Escape {
            restoreConsole
            exit
        }
    }
}


