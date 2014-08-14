# About
This is a small bash script to move a window between monitors on a distro with the X Window System.

For some reason, in a number of distros, there is no built-in way to configure a keyboard shortcut to move a window from one monitor to another.

In Mint, there are keyboard shortcut options for moving to an _edge_, which can be used to to move non-maximized window to the left edge of the left-most monitor or right edge of the right-most monitor.  However, there are limitations to this approach.

There are other scripts floating around, but I have not found one that works quite right with F11 fullscreen (as opposed to _maximized_) windows, nor one that supports three or more monitors.  Also, this script should detect (horizontal) monitor sizes and left-right order for you. 


# Usage
Running the script with no arguments will move the current window to the right.  Running it with a positive or negative integer argument will move it right or left by so many monitors:

```bash
./switch-monitor.sh -3
```

# Install
To install, place the script in a desired location, make sure it's executable:

```bash
chmod +x switch-monitors.sh
```

Then edit Keyboard Settings > Keyboard Shortcuts and add a custom shortcut that executes this script upon the desired keypressing, either by supplying an absolute path to the script or by putting the script on your PATH. I use Ctrl+m.  If you have more than one monitor and would like to move it in more than one direction, you could set up an alternate keypressing for the command "switch-monitor.sh -1".

# Dependencies
This script uses xdotool, wmctrl, xwininfo, and xprop.  In Mint and Ubuntu, you'll probably only need to install xdotool.  In other distros you may need to install others.

