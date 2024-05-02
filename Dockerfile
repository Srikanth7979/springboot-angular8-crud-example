# Stage 1: Build Angular app
FROM node:14 AS angular-builder

WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install Angular CLI globally
RUN npm install -g @angular/cli@8.3.29

# Install dependencies
RUN npm install

# Copy the entire project to the working directory
COPY . .

# Build the Angular app
RUN ng build --prod

# Stage 2: Build Spring Boot app
FROM maven:3.8.3-jdk-11 AS spring-builder

WORKDIR /app

# Copy the entire Spring Boot project to the working directory
COPY . .

# Build the Spring Boot app
RUN mvn clean package

# Stage 3: Create the final image
FROM openjdk:11-jre-slim

WORKDIR /app

# Copy the JAR file built from the Spring Boot app
COPY --from=spring-builder /app/target/*.jar app.jar

# Expose port 8080
EXPOSE 8081

# Run the Spring Boot application
CMD ["java", "-jar", "app.jar"]
