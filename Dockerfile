ARG BASE_IMAGE
FROM $BASE_IMAGE as base

# SPDX-License-Identifier: GPL-2.0

# user data provided by the host system via the make file
# without these, the container will fail-safe and be unable to write output
ARG USERNAME
ARG USERID
ARG USERGNAME
ARG USERGID

# Put the user name and ID into the ENV, so the runtime inherits them
ENV USERNAME=${USERNAME:-nouser} \
	USERID=${USERID:-65533} \
	USERGNAME=${USERGNAME:-users} \
	USERGID=${USERGID:-nogroup}

# match the building user. This will allow output only where the building
# user has write permissions
RUN groupadd -g $USERGID $USERGNAME && \
        useradd -m -u $USERID -g $USERGID -g "users" $USERNAME && \
        adduser $USERNAME $USERGNAME

# Install OS updates, security fixes and utils
RUN apt -y update -qq && apt -y upgrade && \
	DEBIAN_FRONTEND=noninteractive apt -y install \
		ca-certificates \
		curl \
		dirmngr \
		git \
		less

WORKDIR /app
COPY src/ .

RUN julia -e 'using Pkg; Pkg.activate("."); Pkg.instantiate()'

# we map the user owning the image so permissions for i/o will work
USER $USERNAME
ENTRYPOINT [ "julia" ]
