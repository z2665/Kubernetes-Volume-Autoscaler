FROM python:3.13-alpine3.23@sha256:bf88c40985006a79ca25458159a4da1dffc457f9ae234e948b2d6df56ca5ebd2 AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN apk upgrade --no-cache && \
    python -m pip install --no-cache-dir --upgrade pip

WORKDIR /app
COPY requirements.txt ./
RUN python -m pip install --no-cache-dir -r requirements.txt && \
    python -m pip uninstall -y pip setuptools wheel && \
    rm -rf /usr/local/lib/python3.13/ensurepip

COPY *.py ./
RUN chmod a+x /app/main.py

FROM scratch
LABEL org.opencontainers.image.source="https://github.com/z2665/Kubernetes-Volume-Autoscaler" \
      org.opencontainers.image.version="1.0.9"
COPY --from=runtime / /
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    LANG=C.UTF-8 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
WORKDIR /app
USER 10001:10001
CMD ["python", "-u", "./main.py"]
