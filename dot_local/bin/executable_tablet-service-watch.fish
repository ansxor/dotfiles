#!/usr/bin/env fish

set VENDOR_ID 056A # Replace with your device's vendor ID
set PRODUCT_ID 0374 # Replace with your device's product ID
set SYSTEMD_UNIT "opentabletdriver.service" # Replace with your systemd unit name

function check_device_present
    set device_count (lsusb | grep -c -i "$VENDOR_ID:$PRODUCT_ID")
    test $device_count -gt 0
    return $status
end

function check_service_status
    systemctl --user is-active $SYSTEMD_UNIT >/dev/null 2>&1
    return $status
end

function handle_device_state --argument-names present
    if test $present -eq 0
        if not check_service_status
            echo "Device connected and service not running - starting service"
            systemctl --user start $SYSTEMD_UNIT
        else
            echo "Device connected but service already running - no action needed"
        end
    else
        if check_service_status
            echo "Device disconnected - stopping service"
            systemctl --user stop $SYSTEMD_UNIT
        else
            echo "Device disconnected but service already stopped - no action needed"
        end
    end
end

# Check initial state
if check_device_present
    handle_device_state 0
else
    handle_device_state 1
end

# Monitor udev events
udevadm monitor --udev | while read -l line
    if string match -q "*$VENDOR_ID*$PRODUCT_ID*" -- $line
        # Wait a moment for device to settle
        sleep 1

        if check_device_present
            handle_device_state 0
        else
            handle_device_state 1
        end
    end
end
