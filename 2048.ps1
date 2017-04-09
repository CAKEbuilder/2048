
# definitions
$debug = 1

# we will track the value of each object in this array, adding values as we spawn new objects
$object = @()

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

    $object += $value


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
            $valid = $true
        }

    } until ($valid)

}

# attempt to move objects to the right
function shiftRight {

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

    # draw the board
    for($x=0;$x -lt 6;$x++) {
        for($y=0;$y -lt 6;$y++) {
            write-buffer $matrix[$y,$x] $x $y
        }
    }

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
        }
        LeftArrow {
            # left
        }
        RightArrow {
            # right
            shiftRight
        }
        DownArrow {
            # down
        }
        Escape {
            exit
        }
    }





}







