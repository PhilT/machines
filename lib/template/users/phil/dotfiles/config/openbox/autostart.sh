# ~/.config/openbox/autostart.sh

# Lock screen after 30 minutes using slock (type password and press enter to unlock (no feedback))
xautolock -time 30 -locker slock &

# Set a random background image
cd $HOME/wallpaper/; feh --bg-scale "$(ls | shuf -n1)"

# Run the compositing manager with drop shadows
xcompmgr -cC -t-3 -l-5 -r5 &

# Start Docky the dock launcher
docky &

