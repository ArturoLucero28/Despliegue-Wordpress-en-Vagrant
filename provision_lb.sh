sudo apt-get update
sudo apt-get upgrade

sudo apt-get install -y nginx

cat <<EOF | sudo tee /etc/nginx/sites-available/default
upstream backend {
    server 192.168.33.21;  # IP del servidor web 1
    server 192.168.33.22;  # IP del servidor web 2
}

server {
    listen 80;
    server_name localhost;

    location / {
        proxy_pass http://backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF


sudo systemctl restart nginx
