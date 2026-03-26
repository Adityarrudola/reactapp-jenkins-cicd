# Stage 1: Build React App
FROM node:18-alpine AS build
WORKDIR /app

# Copy only dependency files first (for caching)
COPY react-app/package*.json ./

RUN npm install

# Copy full app
COPY react-app/ .

# Build production files
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]