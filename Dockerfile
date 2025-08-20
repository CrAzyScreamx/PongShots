FROM eclipse-temurin:21-jre-alpine


# Creating another user to run the app
RUN adduser -D appuser
RUN mkdir /app

COPY Java/app/build/libs/app.jar /app/app.jar
RUN chown -R appuser:appuser /app
USER appuser

# HealthCheck to auto stop the container
HEALTHCHECK --interval=5s --timeout=10s --retries=3 CMD nc -z localhost 8080 || exit 1

# Environment Variable for HOST
ENV SERVER_ADDRESS=0.0.0.0

EXPOSE 8080
ENTRYPOINT [ "java", "-jar", "/app/app.jar", "--server.address=${SERVER_ADDRESS}" ]