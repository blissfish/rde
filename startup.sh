#!/usr/bin/env bash
if [ `id -u $USERNAME 2>/dev/null || echo -1` -ge 0 ]
then
        # user already exists
        echo $USERNAME user already exists - cleaning up any stale VNC sessions
        # kill any running processes
        su -c "vncserver -kill :1" $USERNAME >/dev/null 2>&1
        rm -r /tmp/.X1-lock >/dev/null 2>&1
        rm -r -f /tmp/.X11-unix/X1 >/dev/null 2>&1
        rm /tmp/file >/dev/null 2>&1
else
        # user does not exist - create user
        echo creating user $USERNAME
        useradd -m $USERNAME
        # temporarily set password to username !!!! Replace
        (echo $PASSWORD; echo $PASSWORD) | passwd $USERNAME
        usermod -aG sudo $USERNAME
        # setup vnc password for user
        su -c "echo $VNC_PASSWORD >/tmp/file" $USERNAME
        su -c "echo $VNC_PASSWORD >>/tmp/file" $USERNAME
        su -c "echo n >>/tmp/file" $USERNAME
        su -c "vncpasswd </tmp/file >/tmp/vncpasswd.1 2>/tmp/vncpasswd.2" $USERNAME
fi

su -c "vncserver :1 -geometry $VNC_RESOLUTION -depth 24" $USERNAME
su -c "tail -F /home/$USERNAME/.vnc/*.log" $USERNAME
