FROM ros:galactic-ros-base

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y sudo \
    && usermod -aG sudo ros \
    && echo "ros ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ros \
    && chmod 0440 /etc/sudoers.d/ros
# Базовые инструменты + Nav2 + SLAM Toolbox + (опционально) desktop для RViz
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-galactic-desktop \
    ros-galactic-navigation2 \
    ros-galactic-nav2-bringup \
    ros-galactic-slam-toolbox \
    ros-galactic-robot-localization \
    ros-galactic-twist-mux \
    ros-galactic-teleop-twist-keyboard \
    ros-galactic-joy \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-vcstool \
    git nano less tmux \
 && rm -rf /var/lib/apt/lists/*

# rosdep (не критично, но удобно)
RUN rosdep init || true && rosdep update || true

# Пользователь без root
ARG USERNAME=ros
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} ${USERNAME} \
 && useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USERNAME}

# Workspace
RUN mkdir -p /home/${USERNAME}/ros2_ws/src \
 && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/ros2_ws

# EntryPoint
COPY ros_entrypoint.sh /ros_entrypoint.sh
RUN chmod +x /ros_entrypoint.sh

USER ${USERNAME}
WORKDIR /home/${USERNAME}

# Автоподхват окружения при входе в контейнер
RUN echo '\n# === ros2lab2 auto-setup ===' >> ~/.bashrc && \
    echo 'source /opt/ros/galactic/setup.bash' >> ~/.bashrc && \
    echo 'if [ -f ~/ros2_ws/install/setup.bash ]; then source ~/ros2_ws/install/setup.bash; fi' >> ~/.bashrc && \
    echo 'export ROS_DOMAIN_ID=${ROS_DOMAIN_ID:-0}' >> ~/.bashrc && \
    echo 'export ROS_LOCALHOST_ONLY=0' >> ~/.bashrc && \
    echo 'export RMW_IMPLEMENTATION=${RMW_IMPLEMENTATION:-rmw_fastrtps_cpp}' >> ~/.bashrc && \
    echo 'alias cw="cd ~/ros2_ws"' >> ~/.bashrc && \
    echo 'alias cws="cd ~/ros2_ws/src"' >> ~/.bashrc

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
