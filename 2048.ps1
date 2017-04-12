
# definitions
$debug = 1
$boardWidth = 30
$boardHeight = 18

# track the value in each of the 16 positions (0-15)
#$pos = @(" ") * 16
# temporarily use the position number as the value
$posValue = @(0) * 16

# we'll format posValue and keep indexed here so the value appears in the center of each game piece
$posValueCentered = @($null) * 16

$posCoords = @($null) * 16
# created as strings so we can split on the period, then we cast as int later
$posCoords[0]  =  "2.3"
$posCoords[1]  =  "9.3"
$posCoords[2]  = "16.3"
$posCoords[3]  = "23.3"
$posCoords[4]  =  "2.7"
$posCoords[5]  =  "9.7"
$posCoords[6]  = "16.7"
$posCoords[7]  = "23.7"
$posCoords[8]  =  "2.11"
$posCoords[9]  =  "9.11"
$posCoords[10] = "16.11"
$posCoords[11] = "23.11"
$posCoords[12] =  "2.15"
$posCoords[13] =  "9.15"
$posCoords[14] = "16.15"
$posCoords[15] = "23.15"

$originalCursorState = [console]::CursorVisible

[console]::CursorVisible = $false


<#
    positions: (x,y)
    each position is the left most character and goes right for a total of 5 characters

    [0]  =   2,3 (through 6,3)
    [1]  =   9,3
    [2]  =  16,3
    [3]  =  23,3
    [4]  =   2,7
    [5]  =   9,7
    [6]  =  16,7
    [7]  =  23,7
    [8]  =   2,11
    [9]  =   9,11
    [10] =  16,11
    [11] =  23,11
    [12] =   2,15
    [13] =   9,15
    [14] =  16,15
    [15] =  23,15

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

# buffer the board to the screen
function Write-Buffer ([string] $str, [int] $x = 0, [int] $y = 0) {
    [console]::setcursorposition($x,$y)
    Write-Host $str -NoNewline
}













function shiftUp {

    for($pos=0;$pos -le 15;$pos=($pos+4)) {
        if( ($posValue[$pos] -ne 0) -and ($posValue[$pos] -ne $null) -and ($pos -ne 0) -and ($pos -ne 1) -and ($pos -ne 2) -and ($pos -ne 3) ) {

            $posTemp = $pos
            $done = $false
            do {

                $nextValueDown = $posValue[$posTemp-4]

                if($nextValueDown -eq 0) {
                    $posValue[$posTemp-4] = $posValue[$posTemp]
                    $posValueCentered[$posTemp-4] = $posValueCentered[$posTemp]

                    $posValue[$posTemp] = 0
                    $posValueCentered[$posTemp] = "     "

                    $posTemp = $posTemp - 4
                }
                elseif($nextValueDown -eq $posValue[$posTemp]) {
                    $posValue[$posTemp-4] = $posValue[$posTemp-4] * 2
                    $posValueCentered[$posTemp-4] = $posValueCentered[$posTemp]

                    $posValue[$posTemp] = 0
                    $posValueCentered[$posTemp] = "     "

                    $posTemp = $posTemp - 4
                }
                else {
                    $done = $true
                }

                if( ($posTemp -eq 0) -or ($posTemp -eq 1) -or ($posTemp -eq 2) -or ($posTemp -eq 3) ) {
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
    # Up/Down are different from left and right. from bottom to top, we want to process the positions in this order:
    #   15, 11, 7, 3
    #   14, 10, 6, 2
    #   13, 9, 5, 1
    #   12, 8, 4, 0
    
    for($pos=15;$pos -ge 0;$pos=($pos-4)) {
        if( ($posValue[$pos] -ne 0) -and ($posValue[$pos] -ne $null) -and ($pos -ne 12) -and ($pos -ne 13) -and ($pos -ne 14) -and ($pos -ne 15) ) {

            $posTemp = $pos
            $done = $false
            do {

                $nextValueDown = $posValue[$posTemp+4]

                if($nextValueDown -eq 0) {
                    $posValue[$posTemp+4] = $posValue[$posTemp]
                    $posValueCentered[$posTemp+4] = $posValueCentered[$posTemp]

                    $posValue[$posTemp] = 0
                    $posValueCentered[$posTemp] = "     "

                    $posTemp = $posTemp + 4
                }
                elseif($nextValueDown -eq $posValue[$posTemp]) {
                    $posValue[$posTemp+4] = $posValue[$posTemp+4] * 2
                    $posValueCentered[$posTemp+4] = $posValueCentered[$posTemp]

                    $posValue[$posTemp] = 0
                    $posValueCentered[$posTemp] = "     "

                    $posTemp = $posTemp + 4
                }
                else {
                    $done = $true
                }

                if( ($posTemp -eq 12) -or ($posTemp -eq 13) -or ($posTemp -eq 14) -or ($posTemp -eq 15) ) {
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












function shiftLeft {
    # check each position (processing from left to right)
    for($pos=0;$pos -le 15;$pos++) {
        if( ($posValue[$pos] -ne 0) -and ($posValue[$pos] -ne $null) -and ($pos -ne 0) -and ($pos -ne 4) -and ($pos -ne 8) -and ($pos -ne 12) ) {

            $posTemp = $pos
            $done = $false
            do {

                $nextValueLeft = $posValue[$posTemp-1]

                if($nextValueLeft -eq 0) {
                    $posValue[$posTemp-1] = $posValue[$posTemp]
                    $posValueCentered[$posTemp-1] = $posValueCentered[$posTemp]

                    $posValue[$posTemp] = 0
                    $posValueCentered[$posTemp] = "     "

                    $posTemp = $posTemp - 1
                }
                elseif($nextValueLeft -eq $posValue[$posTemp]) {
                    $posValue[$posTemp-1] = $posValue[$posTemp-1] * 2
                    $posValueCentered[$posTemp-1] = $posValueCentered[$posTemp]

                    $posValue[$posTemp] = 0
                    $posValueCentered[$posTemp] = "     "

                    $posTemp = $posTemp - 1
                }
                else {
                    $done = $true
                }

                if( ($posTemp -eq 0) -or ($posTemp -eq 4) -or ($posTemp -eq 8) -or ($posTemp -eq 12) ) {
                    $done = $true
                }

            } until ($done)
        }
    }


}

















function shiftRight {
    # check each position (processing from right to left)
    for($pos=15;$pos -ge 0;$pos--) {
        # there's nothing to do if the value is empty, or if we're evaluating a value in the right most column (these cant ever move right)
        if( ($posValue[$pos] -ne 0) -and ($posValue[$pos] -ne $null) -and ($pos -ne 3) -and ($pos -ne 7) -and ($pos -ne 11) -and ($pos -ne 15) ) {
            # keep working on this position as it moves right until you can no longer do anything with it
            $posTemp = $pos
            $done = $false
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
                }
                else {
                    # we can not do anything else with this position
                    $done = $true
                }

                # if $posTemp is in the right column, then we're done
                if( ($posTemp -eq 3) -or ($posTemp -eq 7) -or ($posTemp -eq 11) -or ($posTemp -eq 15) ) {
                    $done = $true
                }

            } until ($done)
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

        # _dev
        # set the cursor position off the board. I was leaving the cursor in the last position and overwriting stuff. a cursor pos reset used to exist in write-buffer, but putting it here will reduce overhead, not repeating this instruction on every call of write-buffer
        [console]::setcursorposition(0,30)

    }
}










function createObject {

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

    # detect game over. need to add to this a check for if any valid moves exist. if the board is filled and no moves can be made, then game over
    # count the number of times 0 appears in the array of positions. if it exists 0 times, then the board is filled. game over
    $isTheBoardFilled = $posValue | group | where name -eq 0 | select -expandproperty count
    if(!$isTheBoardFilled) {
        clear
        write-host "game over"

        [console]::CursorVisible = $originalCursorState

        exit
    }
    <#
    #>

    # if we're here, then there is at least one empty position on the board to fill
    # loop until the random position we've tried is empty
    do {
        # randomly choose an empty position
        $r = Get-Random -min 0 -max 16   # 16 board positions
        $randPos = $posValue[$r]
    } until ($randPos -eq 0)

    $posValue[$r] = $value
   
}



































# prepare the board
clear

# draw the game borders. only needs to happen once, then we just append to the screen with Write-Buffer
for($i=0;$i -le $boardHeight;$i++) {
    # top
    if($i -eq 0) {
        write-host ("#" * $boardWidth)
    }
    # bottom
    elseif($i -eq ($boardHeight)) {
        write-host ("#" * $boardWidth)
    }
    # middle
    else {
        write-host "#" (" " * ($boardWidth-4)) "#"
    }

}


# play!
while (1 -eq 1) {

    createObject

    drawBoard
    
    # don't continue until the player inputs a valid key
    $validInput = $false
    do {
        # read the input        
        $playerInput = [System.Console]::ReadKey() 
        
        if(($playerInput.key -eq "UpArrow") -or ($playerInput.key -eq "LeftArrow") -or ($playerInput.key -eq "RightArrow") -or ($playerInput.key -eq "DownArrow") -or ($playerInput.key -eq "Escape")) {
            $validInput = $true
        }
        
    } until ($validInput)
    
    # move objects
    switch ($playerInput.key) {
        UpArrow {
            # up
            shiftUp
        }
        LeftArrow {
            # left
            shiftLeft
        }
        RightArrow {
            # right
            shiftRight
        }
        DownArrow {
            # down
            shiftDown
        }
        Escape {
            [console]::CursorVisible = $originalCursorState
            exit
        }
    }

}








# end gracefully
write-host ""
write-host ""
write-host ""
write-host ""
write-host ""
write-host ""
write-host ""
write-host ""
write-host ""
write-host ""
write-host ""
write-host ""
write-host ""

