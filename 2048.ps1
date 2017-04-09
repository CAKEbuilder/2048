


function Write-Buffer ([string] $str, [int] $x = 0, [int] $y = 0) {
    [console]::setcursorposition($x,$y)
    Write-Host $str -NoNewline
}


# prepare the board
clear

# let's try a matrix. fixed values everywhere. the board size should never be different
# we're going to track all positions of the board at all times.
# matrix[y,x]
$matrix = New-Object 'object[,]' 6,6


# define the matrix by comprising each location as a space. we will overwrite each position when necessary
# need a more elegant way of doing this
for($i=0;$i -lt 6;$i++) {
    for($h=0;$h -lt 6;$h++) {
        $matrix[$h,$i] = " "
    }
}


# find a random location in the play space for the first object
# play space = 1,1 through 4,4
# apparently -max must = 5 to produce 4s, but won't produce 5s?
$objX = Get-Random -min 1 -max 5
$objY = Get-Random -min 1 -max 5

# add the obj to the matrix
$matrix[$objY,$objX] = 2


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

# draw the board
for($x=0;$x -lt 6;$x++) {
    for($y=0;$y -lt 6;$y++) {
        write-buffer $matrix[$y,$x] $x $y
    }
}


