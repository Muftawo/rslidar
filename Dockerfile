FROM stereolabs/zed:3.5-runtime-cuda11.0-ubuntu18.04

ARG DEBIAN_FRONTEND=noninteractive

COPY . /

# install git
RUN apt update
RUN apt upgrade -y
RUN apt install git -y

# initiate submodules
RUN cd /ws/src/rslidar_sdk && \
    git submodule init && \
    git submodule update

# setting environment for ros installation
RUN apt update && apt install locales
RUN locale-gen en_US en_US.UTF-8
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
RUN export LANG=en_US.UTF-8

RUN apt update && apt install curl gnupg2 lsb-release
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
RUN sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list'

#install ros2
RUN apt update
RUN apt install ros-eloquent-ros-base -y
RUN echo source /opt/ros/eloquent/setup.bash >> /root/.bashrc
RUN apt install -y python3-argcomplete
RUN pip3 install -U argcomplete

# install ros2 option dependecies
RUN apt-get update && apt-get install -y python3-opencv python3-colcon-common-extensions
RUN pip3 install argparse scipy pandas

## install rs-lidar dependecies
# YAML
RUN apt-get update
RUN apt-get install -y libyaml-cpp-dev
# pcap
RUN apt-get install -y  libpcap-dev
# protobuf
RUN apt-get install -y libprotobuf-dev protobuf-compiler

## Compile and Run rslidar
RUN source /opt/ros/eloquent/setup.bash
RUN cd /ws && \
    colcon build && \
    source install/setup.bash && \
    ros2 launch rslidar_sdk start.py


 