FROM oraclelinux:7-slim

ARG NODE_VERSION=14.x

RUN yum -y update
RUN yum -y install oracle-release-el7 oracle-nodejs-release-el7 && \
    yum-config-manager --disable ol7_developer_EPEL && \
    yum -y install oracle-instantclient19.3-basiclite && \
    rm -rf /var/cache/yum

RUN (curl -sL https://rpm.nodesource.com/setup_$NODE_VERSION | bash -) \
  && yum clean all -y \
  && yum update -y \
  && yum install -y nodejs \
  && yum autoremove -y \
  && yum clean all -y \
  && npm install npm --global
RUN rm -rf /var/cache/yum

RUN useradd -ms /bin/bash node
RUN mkdir -p /home/node/app/node_modules && chown -R node:node /home/node/app

RUN npm install -g yarn

RUN mkdir -p /home/node/app/infra/tmp
RUN chmod 775 -R /home/node/app/infra/tmp

RUN mkdir -p /etc/localtime
RUN chmod 775 -R /etc/localtime
RUN chown node /etc/localtime
ENV TZ=America/Campo_Grande
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN chown node /home/node/app

WORKDIR /home/node/app

COPY app/package.json app/yarn.* ./

RUN yarn

COPY --chown=node:node ./app .

RUN yarn build

USER node

CMD ["yarn", "start"]

EXPOSE 3000
