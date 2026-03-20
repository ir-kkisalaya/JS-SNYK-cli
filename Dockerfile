# Base image
FROM node:20-alpine

## Invisirisk setup

ARG ir_proxy

ENV http_proxy=${ir_proxy} \
    https_proxy=${ir_proxy} \
    HTTP_PROXY=${ir_proxy} \
    HTTPS_PROXY=${ir_proxy}

RUN if [ -n "${ir_proxy}" ]; then \
      echo "Value of https_proxy: ${https_proxy}" && \
      curl -L -k -s -o /tmp/pse.crt https://pse.invisirisk.com/ca && \
      cp /tmp/pse.crt /usr/local/share/ca-certificates/pse.crt && \
      echo "CA certificate successfully retrieved and copied to /usr/local/share/ca-certificates/" && \
      update-ca-certificates; \
    fi

# App directory
WORKDIR /app

# Copy dependency files first
COPY package*.json ./

# Install dependencies
RUN npm install --legacy-peer-deps

# Copy project files
COPY . .

# Expose port (change if your app uses another)
EXPOSE 3000

########################################### InvisiRisk Cleanup script start #########
# Cleanup: Remove PSE CA certificate and reset proxy environment variables
RUN if [ -n "$ir_proxy" ]; then \
      rm -f /usr/local/share/ca-certificates/pse.crt && update-ca-certificates --fresh; \
    else \
      echo "Skipping CA trust update since ir_proxy is not set"; \
    fi

# Reset proxy environment variables
ENV http_proxy=""
ENV https_proxy=""
ENV HTTP_PROXY=""
ENV HTTPS_PROXY=""
########################################### InvisiRisk Cleanup script end ########

# Start command
CMD ["npm", "start"]
