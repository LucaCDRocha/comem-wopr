# First stage: build the frontend
FROM node:20-alpine AS build
WORKDIR /app
COPY . .
RUN npm ci
RUN npm run build

# Final stage: build the application
FROM ruby:3.2-alpine
WORKDIR /app
COPY --chown=wopr:wopr . .
RUN addgroup -S wopr && adduser -S wopr -G wopr && \
    chown -R wopr:wopr /app
RUN apk add --no-cache build-base
RUN bundle install
COPY --chown=wopr:wopr --from=build /app/public/ ./public/
CMD bundle exec ruby app.rb
