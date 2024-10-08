fastfetch 

LFCD="$GOPATH"  # source
LFCD="/home/spencerb/.config/lf/lfcd.sh"                                #  pre-built binary, make sure to use absolute path
if [ -f "$LFCD" ]; then
    source "$LFCD"
fi