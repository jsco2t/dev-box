# using an admin CMD session create a link to `coffeetime.csx` (in ~/bin), leave this script in the same folder (~/bin):
#   mklink coffeetime.csx C:\Users\jason\Developer\Sources\personal\dev-box\windows\shells\pwsh\bin\coffeetime.csx

dotnet-script "$ENV:HOME/bin/coffeetime.csx"