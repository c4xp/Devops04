# Use an official Node runtime as the parent image
FROM node:lts
ARG PORT=${PORT}
ENV PORT=${PORT}
# Set the working directory in the container to /app
WORKDIR /app
# Copy the current directory contents into the container at /app
ADD . /app
# Make the container's port available to the outside world
EXPOSE ${PORT}
# Run app.js using node when the container launches
CMD ["node", "app.js"]