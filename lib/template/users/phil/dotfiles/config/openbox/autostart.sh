# ~/.config/openbox/autostart.sh

# Lock screen after 5 minutes using slock (type password and press enter to unlock (no feedback))
xautolock -time 5 -locker slock &

# Set a background image
feh --bg-scale $HOME/Pictures/wallpaper.jpg

# Run the compositing manager with drop shadows
xcompmgr -cC -t-3 -l-5 -r5 &

# Start Docky the dock launcher
docky &

