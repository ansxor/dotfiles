#!/usr/bin/env fish

# Get the active workspace information
set active_workspace (hyprctl activeworkspace)

# Extract the current monitor from the active workspace
set current_monitor (echo $active_workspace | grep -oP 'on monitor \K[^:]+' | string trim)

# Get all monitors from hyprctl
set all_monitors (hyprctl monitors | grep -oP '^Monitor \K[^ ]+')

# Track the state change for notification
set monitors_toggled_off 0
set monitors_toggled_on 0

# Loop through all monitors and toggle their state except the current one
for monitor in $all_monitors
    if test "$monitor" != "$current_monitor"
        # Check the current dpms state of the monitor
        set monitor_state (hyprctl monitors | grep -A 15 "Monitor $monitor" | grep "dpmsStatus" | awk '{print $2}')

        if test "$monitor_state" = 1
            hyprctl dispatch dpms off "$monitor"
            set monitors_toggled_off (math $monitors_toggled_off + 1)
        else
            hyprctl dispatch dpms on "$monitor"
            set monitors_toggled_on (math $monitors_toggled_on + 1)
        end
    end
end

# Send a notification based on the actions performed
if test "$monitors_toggled_off" -gt 0
    hyprctl notify 1 1500 "rgb(ffffff)" "Focus Mode Enabled: $monitors_toggled_off monitor(s) turned off"
end

if test "$monitors_toggled_on" -gt 0
    hyprctl notify 1 1500 "rgb(ffffff)" "Focus Mode Disabled: $monitors_toggled_on monitor(s) turned on"
end
