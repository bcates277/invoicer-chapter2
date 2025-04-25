FROM golang:latest

# Create app group and user
RUN addgroup --gid 10001 app
RUN adduser --gid 10001 --uid 10001 \
    --home /app --shell /sbin/nologin \
    --disabled-password app

# Create statics directory and add static files
RUN mkdir /app/statics/
ADD statics /app/statics/

# Copy the application binary
COPY bin/invoicer /app/invoicer

# Ensure the reports directory exists and has the correct permissions for the 'app' user
RUN mkdir /app/reports && chown app:app /app/reports

USER app
EXPOSE 8080
WORKDIR /app
ENTRYPOINT ["/app/invoicer"]
