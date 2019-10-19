ARG RUNTIME=nodejs10.x
ARG TERRAFORM=latest

FROM lambci/lambda:build-${RUNTIME} AS build
COPY . .
RUN npm install --package-lock-only
RUN npm install --production
RUN zip -r package.zip .

FROM hashicorp/terraform:${TERRAFORM} AS test
COPY --from=build /var/task/package.zip .
ARG AWS_DEFAULT_REGION=us-east-1
RUN terraform init
RUN terraform fmt -check
RUN terraform validate
