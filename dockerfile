# Stage 1: Build
FROM node:18-alpine AS build
WORKDIR /app

# Copy dependency files from the subfolder
COPY react-app/package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY react-app/ .

# Build the app
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:alpine-slim
# Clean default nginx files
RUN rm -rf /usr/share/nginx/html/*
# Copy build output from the build stage
COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]