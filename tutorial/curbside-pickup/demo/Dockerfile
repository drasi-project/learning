# Simple nginx container to serve the showcase page
FROM nginx:alpine

# Copy the index.html file
COPY index.html /usr/share/nginx/html/

# Use default nginx configuration
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]