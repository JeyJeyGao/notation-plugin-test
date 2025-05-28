FROM alpine:latest

# Install basic utilities
RUN apk add --no-cache curl

# Create a simple app
RUN echo "#!/bin/sh" > /app.sh && \
    echo "echo 'Hello from Notation-signed container!'" >> /app.sh && \
    echo "echo 'This image was signed using Notation with Azure Key Vault'" >> /app.sh && \
    echo "echo 'Current time: \$(date)'" >> /app.sh && \
    chmod +x /app.sh

# Set working directory
WORKDIR /app

# Copy application script
COPY /app.sh /app/

# Set the entrypoint
ENTRYPOINT ["/app.sh"]
