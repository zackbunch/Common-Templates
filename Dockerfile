# Use an official Python base image (alpine is smaller, slim is safer for prod)
FROM python:3.12-slim

# Set the working directory
WORKDIR /app