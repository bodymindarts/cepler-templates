FROM alpine

RUN apk add curl bash perl-utils
RUN curl -L https://k14s.io/install.sh | bash

RUN mkdir /workspace

WORKDIR /workspace

COPY templates /workspace/templates
COPY bin /workspace/bin

ENV PATH=${PATH}:/workspace/bin

CMD process
