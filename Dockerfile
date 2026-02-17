FROM python:3.13-alpine

ENV LANG=en_US.UTF-8
ENV PYTHONUNBUFFERED=1
ENV HOME=/cct

# Create a non-root user
ARG USERNAME=python
RUN adduser -g ${USERNAME} --disabled-password ${USERNAME}

WORKDIR ${HOME}

# Add Zscaler Root CA certificate and rebuild CA certificates
ADD https://raw.githubusercontent.com/cfpb/zscaler-cert/3982ebd9edf9de9267df8d1732ff5a6f88e38375/zscaler_root_ca.pem ${HOME}/zscaler-root-public.cert
RUN cp ${HOME}/zscaler-root-public.cert /usr/local/share/ca-certificates/zscaler-root-public.cert && \
    apk add ca-certificates --no-cache --no-check-certificate && \
    update-ca-certificates

RUN apk update --no-cache && \
    apk upgrade --no-cache && \
    apk add --no-cache git && \
    pip install --upgrade pip setuptools

COPY process_globals.py .
COPY process_utils.py .
COPY process_incoming_data.py .

RUN chown -R ${USERNAME}:${USERNAME} ${HOME}
USER ${USERNAME}
