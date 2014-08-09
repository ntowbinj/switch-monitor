#!/bin/bash

pattern='horz|vert|full' 
screen_width=`xdpyinfo | awk '/dimensions:/ { print $2; exit }' | cut -d"x" -f1`
display_width=`xdotool getdisplaygeometry | cut -d" " -f1`
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
x=`xwininfo -id $window_id | awk '/Absolute upper-left X:/ { print $4 }'`
y=`xwininfo -id $window_id | awk '/Absolute upper-left Y:/ { print $4 }'`

# Subtract any offsets caused by panels or window decorations
x_offset=`xwininfo -id $window_id | awk '/Relative upper-left X:/ { print $4 }'`
y_offset=`xwininfo -id $window_id | awk '/Relative upper-left Y:/ { print $4 }'`
x=`expr $x - $x_offset`
y=`expr $y - $y_offset`

# Compute new X position
new_x=`expr $x + $display_width`

# If we would move off the right-most monitor, we set it to the left one.
# We also respect the window's width here: moving a window off more than half its width won't happen.
width=`xdotool getwindowgeometry $window_id | awk '/Geometry:/ { print $2 }'|cut -d"x" -f1`
if [ `expr $new_x + $width / 2` -gt $screen_width ]; then
  new_x=`expr $new_x - $screen_width`
fi

# Don't move off the left side.
if [ $new_x -lt 0 ]; then
  new_x=0
fi

# Move the window
xdotool windowmove $window_id $new_x $y
for w in $remember_states
do
    wmctrl -ir $window_id -b add,$w
done
exit
