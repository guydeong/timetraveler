#!/bin/sh

# Function to get/renew SSL certificate
setup_ssl() {
    # Replace yourdomain.com with your actual domain
    certbot --nginx -d yourdomain.com --non-interactive --agree-tos --email your-email@example.com

    # Set up automatic renewal
    echo "0 0,12 * * * certbot renew --quiet" | crontab -
}

# Start nginx in the background
nginx

# Set up SSL if we have a domain configured
if [ ! -z "$DOMAIN" ]; then
    setup_ssl
fi

# Keep the container running and log to stdout
tail -f /var/log/nginx/access.log /var/log/nginx/error.log