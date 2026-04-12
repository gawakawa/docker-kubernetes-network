FROM python:3.12.3-alpine
COPY . .
RUN apk add --no-cache python3-dev libffi-dev gcc musl-dev make
RUN pip install --upgrade pip
RUN pip install Flask flask-socketio gevent gevent-websocket redis
CMD ["python", "app.py"]
