FROM alpine:latest

LABEL maintainer="Mark <mark.binlab@gmail.com>"

ARG HOME=/var/lib/bastion

ARG USER=bastion
ARG GROUP=bastion
ARG UID=4096
ARG GID=4096

ARG GITHOME=/var/lib/git
ARG GITBIN=/usr/local/bin/gitea
ARG GITUID=1000
ARG GITGID=1000
ARG GIT_SSH_HOST=gitea.service.consul.
ARG GIT_SSH_PORT=222


ENV HOST_KEYS_PATH_PREFIX="/usr"
ENV HOST_KEYS_PATH="${HOST_KEYS_PATH_PREFIX}/etc/ssh"
ENV SSH_LOG_LEVEL="INFO"

COPY bastion /usr/sbin/bastion
COPY git-proxy.sh $GITBIN

# Primary bastion user
RUN addgroup -S -g ${GID} ${GROUP} \
    && adduser -D -h ${HOME} -s /bin/ash -g "${USER} service" \
           -u ${UID} -G ${GROUP} ${USER} \
    && sed -i "s/${USER}:!/${USER}:*/g" /etc/shadow \
    && set -x \
    && apk add --no-cache openssh-server openssh-client \
    && echo "Welcome to Bastion!" > /etc/motd \
    && chmod +x /usr/sbin/bastion \
    && mkdir -p ${HOST_KEYS_PATH} \
    && mkdir /etc/ssh/auth_principals \
    && echo "bastion" > /etc/ssh/auth_principals/bastion

# git redirect user
RUN addgroup -S -g ${GITGID} git \
    && adduser -D -h ${GITHOME} -s ${GITBIN} -g "git service" \
           -u ${GITUID} -G git git \
    && sed -i "s/git:!/git:*/g" /etc/shadow \
    && sed -i "s/GIT_SSH_HOST/${GIT_SSH_HOST}/g" ${GITBIN} \
    && sed -i "s/GIT_SSH_PORT/${GIT_SSH_PORT}/g" ${GITBIN} \
    && set -x \
    && chmod +x ${GITBIN}

EXPOSE 22/tcp

VOLUME ${HOST_KEYS_PATH}

ENTRYPOINT ["bastion"]
