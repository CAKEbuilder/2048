
# definitions
$debug = 1

# we will track the value of each object in this array
# _dev can't access this from within a function. maybe it needs to be global
$global:objects = @()
# _dev store the coords. not doing a multi. for now, position 0 will contain coords for object 0, with x and y dilimited with a period (x.y)
$global:objectCoords = @()

# track all positions of the board at all times. remember that $matrix represents the entire board, not just the play space
# matrix[y,x]
$matrix = New-Object 'object[,]' 6,6

# define the matrix size by defining each position as a space. we will overwrite each position when necessary
# need a more elegant way of doing this
for($i=0;$i -lt 6;$i++) {
    for($h=0;$h -lt 6;$h++) {
        $matrix[$h,$i] = " "
    }
}



if($debug -eq 1) {
    Set-PSBreakpoint -Variable breakHere
}
else {
    # remove breakpoints, if any exists
    if(Get-PSBreakpoint) {
        Get-PSBreakpoint | Remove-PSBreakpoint
    }
}


# buffer the matrix to the screen
function Write-Buffer ([string] $str, [int] $x = 0, [int] $y = 0) {
    [console]::setcursorposition($x,$y)
    Write-Host $str -NoNewline
}

# call this function when we need to spawn a new object. create either a 2 or a 4, then spawn it
function createObject {

    # determine the starting value of the new object
    #   the probability of a 2 is 90%
    #   the probability of a 4 is 10%

    $rand = Get-Random -min 1 -max 11   # 11 or 10?

    if($rand -eq 4) {
        $value = 4
    }
    else {
        $value = 2
    }

    $global:objects += $value


    # find a random, empty location in the play space for the object
    #   play space = 1,1 through 4,4
    #   apparently -max must = 5 to produce 4s, but won't produce 5s?
    $valid = $false
    do {
        $x = Get-Random -min 1 -max 5
        $y = Get-Random -min 1 -max 5

        if($matrix[$y,$x] -eq " ") {
            # we can spawn the object here
            $matrix[$y,$x] = $value
            # save the coords of this object
            $global:objectCoords += "$x.$y"
            $valid = $true
        }

    } until ($valid)

}

function drawBoard {

    for($x=0;$x -lt 6;$x++) {
        for($y=0;$y -lt 6;$y++) {
            write-buffer $matrix[$y,$x] $x $y
        }
    }

}

# _dev
function shiftLeft {
    write-buffer "                " 0 10
    write-buffer "shiftLeft" 0 10
}

function shiftDown {
    write-buffer "                " 0 10
    write-buffer "shiftDown" 0 10
}

function shiftUp {
    write-buffer "                " 0 10
    write-buffer "shiftUp" 0 10
}









# _dev
# this is working. however, you didn't account for what happens when an object contains >1 digit. 16 is being represented in one square as "1"...


# attempt to move objects to the right
function shiftRight {

    write-buffer "                " 0 10
    write-buffer "shiftRight" 0 10

    # we want to evaluate each object starting from the right most objects
    # how can we order $global:objectCoords based on the y coords?

    # evaluate each row, starting from the top
    for($i=1;$i -le 4;$i++) {

        # evaluate each position in the row, starting from the right
        for($r=4;$r -ge 1;$r--) {

            # if the position we're checking has an object, let's process that object by moving it right until we cannot anymore
            if($global:objectCoords -contains "$r.$i") {

                # which object are we working on?
                $currentObjectIndex = $global:objectCoords.IndexOf("$r.$i")

                do {

                    # get the current object
                    $currentObject = $global:objects[$currentObjectIndex]
        
                    # get current object's x and y
                    $x = [int]$global:objectCoords[$currentObjectIndex].Split('.')[0]
                    $y = [int]$global:objectCoords[$currentObjectIndex].Split('.')[1]

                    # free up the old position
                    $matrix[$y,$x] = " "
       
                    # if the adjacent right position is a space
                    if($matrix[$y,($x+1)] -eq " ") {
                        # update the coords
                        $x = $x + 1
                        $global:objectCoords[$currentObjectIndex] = "$x.$y"
                    }
                    # if the adjacent right position is a value that matches the current object
                    elseif($matrix[$y,($x+1)] -eq $currentObject) {
                        
                        # delete the next right object and multiply the current object by 2
                        #   which object is to the right of me?
                        $x = $x + 1
                        $objectToOverwite = $global:objectCoords.IndexOf("$x.$y")
                        $global:objects[$objectToOverwite] = " "
                        $global:objectCoords[$objectToOverwite] = $null
                        $currentObject = $currentObject * 2
                        
                        # update the coords
                        $global:objectCoords[$currentObjectIndex] = "$x.$y"
                        $global:objects[$currentObjectIndex] = $currentObject
                    }
        
                    # update the matrix
                    $matrix[$y,$x] = $currentObject

                    # can we move again? we can if the next position to the right is a space or the same number as the current object
                    if(($matrix[$y,($x+1)] -eq " ") -or ($matrix[$y,($x+1)] -eq $currentObject) ) {
                        $cannotMove = $false
                    }
                    else {
                        $cannotMove = $true
                    }

                } until ($cannotMove)

            }

        }

    }
}



















# make sure we init with one object. on first run of the game, we'll add the second object
createObject


# build the top and bottom borders
for($i=0;$i -lt 6;$i++) {
    # top border
    $matrix[0,$i] = "#"

    # left border
    $matrix[$i,0] = "#"

    # right border
    $matrix[$i,5] = "#"
    
    # bottom border
    $matrix[5,$i] = "#"
}




# prepare the board
clear

# play!
while(1 -eq 1) {

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
            exit
        }
    }





}







