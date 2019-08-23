if (Test-Path pre-configure.ps1) {
    . ./pre-configure.ps1
}
if (Test-Path configure.ps1) {
    . ./configure.ps1
}
if (Test-Path post-configure.ps1) {
    . ./post-configure.ps1
}
if (Test-Path pre-run.ps1) {
    . ./pre-run.ps1
}
. ./run.ps1
if (Test-Path post-run.ps1) {
    . ./post-run.ps1
}