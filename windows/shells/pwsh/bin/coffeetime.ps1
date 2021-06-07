# The following script is a wrapper on top of `coffeetime.csx`. The intention here is to use this as a simplified method
# for invoking coffeetime. In most cases you will want to create a folder in your home directory (say ~/bin) and create
# symbolic links to this file and the coffeetime.csx file. You can then add `~/bin` to your path and have an easy
# way to execute scripts in this repository.
#
# That can be done as follows (must be in some other directory - like ~/bin ):
#   mklink coffeetime.csx C:\Users\jason\Developer\Sources\personal\dev-box\windows\shells\pwsh\bin\coffeetime.csx
#   mklink coffeetime.ps1 C:\Users\jason\Developer\Sources\personal\dev-box\windows\shells\pwsh\bin\coffeetime.ps1
#
# In this example if `~/bin` is in your path, then you can run `coffeetime` from any location from powershell using:
#   coffeetime.ps1 {parameters here}

& dotnet-script "$ENV:HOME/bin/coffeetime.csx" $args
#dotnet-script "$ENV:HOME/bin/coffeetime.csx"
