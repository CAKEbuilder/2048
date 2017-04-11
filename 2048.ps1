
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

        # prepare the symbol to use for drawing the piece border. if a piece is 0 or $null, "erase" the piece border by overwriting the previous border with spaces
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
    
    write-host ""
    write-host ""
    write-host ""
    write-host ""
    write-host ""
    pause   # really want to wait for valid input

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

