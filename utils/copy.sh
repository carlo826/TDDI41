# Copy
cp -r /root/tddi41_redo/etc/${hostname}/* /etc

# Restart all services
/etc/init.d/networking restart
/etc/init.d/bind9 restart
/etc/init.d/ntp restart