ARG RUNTIME=nodejs10.x

FROM lambci/lambda:build-${RUNTIME} AS install
COPY --from=hashicorp/terraform:0.12.0 /bin/terraform /bin/
COPY . .
RUN npm install --production
RUN terraform init

FROM install AS build
ARG AWS_DEFAULT_REGION=us-east-1
RUN zip -r package.zip *
RUN terraform fmt -check
RUN terraform validate
RUN zip package.zip *.tf index.js package.layer.zip
