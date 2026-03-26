# Stage 1: Build
FROM node:18-alpine AS build
WORKDIR /app

# Instead of pathing from the root, let's copy the specific folder
# This ensures that even if context is weird, we target the right spot
COPY ./react-app/package.json ./package.json
COPY ./react-app/package-lock.json ./package-lock.json

# If this fails, the build stops here and we know the path is the issue
RUN ls -la /app

RUN npm install

# Copy everything else from the subfolder
COPY ./react-app/ .

RUN npm run build

# Stage 2: Serve
FROM nginx:alpine-slim
RUN rm -rf /usr/share/nginx/html/*
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]