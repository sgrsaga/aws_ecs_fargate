FROM alpine:3

RUN apk add --update --no-cache \
    python3 \
    py3-pip \
    jq \
    && pip3 install --upgrade pip \
    && pip3 install awscli

RUN wget https://releases.hashicorp.com/terraform/1.4.0/terraform_1.4.0_linux_amd64.zip \
    && unzip terraform_1.4.0_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform_1.4.0_linux_amd64.zip

CMD [ "sh" ]