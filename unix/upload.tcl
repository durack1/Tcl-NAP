proc upload_sf {
    file
} {
    set passwd Harvey.Davies@csiro.au
    package require ftp
    set s [ftp::Open upload.sourceforge.net anonymous $passwd -mode passive]
    ftp::Cd $s /incoming
    ftp::Put $s $file
    ftp::Close $s
}
