# Stage 1: Build
FROM node:18-alpine AS build
WORKDIR /app

# Copy dependency files from the subfolder to the current WORKDIR (/app)
COPY react-app/package*.json ./

# DEBUG: Check if files actually copied
RUN ls -al

# Install dependencies
RUN npm install

# Copy the rest of the application code from the subfolder
COPY react-app/ .

# Build the app
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:alpine-slim
RUN rm -rf /usr/share/nginx/html/*
COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]