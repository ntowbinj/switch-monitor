#!/bin/bash
#
# This is based loosely on a script available here
#
#
#
# Which was in turn based on one available here
#
# http://icyrock.com/blog/2012/05/xubuntu-moving-windows-between-monitors/
#
# Neither of which worked quite right with fullscreen (distinct from maximized) windows


# since cut indexes from 1, pretty much everything in this script will too
function index {
    echo `echo $1 | cut -d"$2" -f$3` 
}


# get monitor dimension information from monitors listed as 'connected' by xrandr
widths=""
offsets=""
monitor_count=0
while read -r line
do
    info=`echo $line | sed -n 's/.* \([0-9]*x[0-9]*+[0-9]*+[0-9]*\).*/\1/p'`
    widths="$widths $(index $info 'x' 1)"
    offsets="$offsets $(index $info '+' 2)"
    ((monitor_count++))
done < <(xrandr --current | grep ' connected')


# put them in left-right order--computationally inefficient selection sort, but you probably don't have 100000 monitors
start=0
ordered_widths=""
ordered_offsets=""
for i in $(seq 1 $monitor_count)
do
    for j in $(seq 1 $monitor_count)
    do
        width=$(index "$widths" " " $j)
        offset=$(index "$offsets" " " $j)
        if [ $offset -eq $start ]
        then
            ordered_widths="$ordered_widths $width"
            ordered_offsets="$ordered_offsets $offset"
            start=`expr $start + $width`
        fi
    done
done
widths=$ordered_widths
offsets=$ordered_offsets

# store the windows maximized/fullscreen state information and undo all of it
pattern='horz|vert|full' 
window_id=`xdotool getactivewindow`
window_state=`xprop -id $window_id _NET_WM_STATE | sed 's/,//g' | cut -d ' ' -f3-`
remember_states=""
for w in $window_state
do
    #remove _NET_WM_STATE_ prefix
    w=`echo $w | sed -r 's/^.{14}//' | awk '{print tolower($0)}'`
    #echo $w
    if [[ $w =~ $pattern ]]
    then
        wmctrl -ir $window_id -b remove,$w
        remember_states="$remember_states $w"
    fi
done


# get position of upper-left corner
x=`xwininfo -id $window_id | awk '/Absolute upper-left X:/ { print $4 }'`
y=`xwininfo -id $window_id | awk '/Absolute upper-left Y:/ { print $4 }'`


# get the current monitor of the window, indexed from 1
current_monitor=0
for i in $(seq 1 $monitor_count)
do
    width=$(index "$widths" " " $i)
    start=$(index "$offsets" " " $i)
    end=`expr $start + $width`
    if [ $x -ge $start ] && [ $x -lt $end ]
    then
        current_monitor=$i
    fi
done


# remember, monitors are indexed from 1, not 0, so this works
next_monitor=`expr $current_monitor % $monitor_count`
next_monitor=`expr $next_monitor + 1`


# compute new absolute x,y position based on relative positions and offsets
current_offset=$(index "$offsets" " " $current_monitor)
next_offset=$(index "$offsets" " " $next_monitor)
x_rel=`expr $x - $current_offset`
new_x=`expr $x_rel + $next_offset`


# move the window to the same relative x,y position in the other monitor
xdotool windowmove $window_id $new_x $y


# restore maximized/fullscreen state
for w in $remember_states
do
    wmctrl -ir $window_id -b add,$w
done
exit
