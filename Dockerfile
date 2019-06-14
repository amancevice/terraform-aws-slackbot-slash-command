ARG RUNTIME=nodejs10.x

FROM lambci/lambda:build-${RUNTIME} AS build
COPY . .
RUN npm install --package-lock-only
RUN npm install --production
RUN zip -r package.zip .

FROM lambci/lambda:build-${RUNTIME} AS test
COPY --from=hashicorp/terraform:0.12.2 /bin/terraform /bin/
COPY --from=build /var/task/package.zip .
ARG AWS_DEFAULT_REGION=us-east-1
RUN terraform init
RUN terraform fmt -check
RUN terraform validate
