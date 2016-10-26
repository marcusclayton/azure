Class Something {

    $name
    $date
    $color = "cyan"
    $type

    [void]Delete() {

        Write-Host "Deleting the thing." `
        -foregroundcolor $this.color

    }
}

$new = [something]::new()
$new.Delete()
$new.color = "green"
$new.Delete()

$new.name = "Marcus"
$new.date = get-date -Format "MMddyyy"
$new.type = "new"
$new
$new | gm 