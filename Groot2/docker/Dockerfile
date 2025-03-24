######################################################################
# - Base stage
#   - This stage serves as the base image for the following stages.
######################################################################

ARG ROS_DISTRO=humble
FROM osrf/ros:${ROS_DISTRO}-desktop AS base

LABEL org.opencontainers.image.title="Groot Docker Image"
LABEL org.opencontainers.image.authors="scx@gapp.nthu.edu.tw"
LABEL org.opencontainers.image.licenses="MIT"

ARG USERNAME=ros
# Use the same UID and GID as the host user
ARG USER_UID=1000
ARG USER_GID=1000

######################################################################
# - User setup stage
#   - Create a non-root user with default bash shell.
######################################################################

FROM base AS user-setup

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && rm -rf /var/lib/apt/lists/*

######################################################################
# - Tools Installation stage
#   - Install common tools for development.
######################################################################

FROM user-setup AS tools

RUN apt-get update && apt-get install -y \
    tree \
    vim \
    git \
    wget \
    curl \
    bash-completion \
    # DDS
    ros-humble-rmw-cyclonedds-cpp \
    # Groot
    libfuse2 \
    fuse3 \
    ros-humble-behaviortree-cpp \
    ros-humble-generate-parameter-library

RUN apt-get update && apt-get dist-upgrade -y \
    && apt-get autoremove -y \
    && apt-get autoclean -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

######################################################################
# - Final stage
#   - Install the main packages and set the entrypoint.
######################################################################

FROM tools AS final

# Set up the user environment
ENV TZ=Asia/Taipei
ENV SHELL=/bin/bash
ENV TERM=xterm-256color
USER $USERNAME
WORKDIR /app

# Set up bashrc
COPY .bashrc /home/$USERNAME/.bashrc.conf
RUN cat /home/$USERNAME/.bashrc.conf >> /home/$USERNAME/.bashrc

# Set up python environment
# RUN pip install --upgrade pip
# RUN pip install --no-cache-dir

CMD ["/bin/bash"]