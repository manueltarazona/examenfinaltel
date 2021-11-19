echo "iniciar servicio de firewall"
service firewalld start
service NetworkManager stop
chkconfig NetworkManager off
systemctl enable firewalld
firewall-cmd --get-active-zones

echo "eliminar la interfaz eth1 y añadiendola a la zona interna"
firewall-cmd --zone=public --remove-interface=eth1 --permanent
firewall-cmd --zone=internal --add-interface=eth1 --permanent

echo "definiendo reglas"
firewall-cmd --direct --permanent --add-rule ipv4 nat POSTROUTING 0 -o eth0 -j MASQUERADE
firewall-cmd --direct --permanent --add-rule ipv4 filter FORWARD 0 -i eth1 -o eth0 -j ACCEPT
firewall-cmd --direct --permanent --add-rule ipv4 filter FORWARD 0 -i eth0 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT

echo "agregamos los servicios"
firewall-cmd --zone=internal --add-service=http --permanent
firewall-cmd --zone=internal --add-service=https --permanent
firewall-cmd --zone=internal --add-service=steam-streaming --permanent
firewall-cmd --zone=internal --add-masquerade --permanent

echo "rediccionamiento de puerto"
firewall-cmd --zone=dmz --add-service=steam-streaming --permanent
sudo firewall-cmd --zone=dmz --add-forward-port=port=8080:proto=tcp:toport=8080:toaddr=192.168.100.2 --permanent
sudo firewall-cmd --zone=dmz --permanent --add-port=8080/tcp --add-port=8080/udp


echo "habilitamos el firewall"
systemctl enable firewalld
firewall-cmd --zone=dmz --list-all
vi /etc/selinux/config

echo "instalacion e inicio de http"
yum install httpd -y
systemctl start httpd
systemctl enable httpd


