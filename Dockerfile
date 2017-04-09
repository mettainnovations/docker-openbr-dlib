FROM mettainnovations/openbr-dlib:latest

USER root

# Install nvidia driver
RUN  apt install -y module-init-tools libcpprest-dev wget && \
     wget http://us.download.nvidia.com/XFree86/Linux-x86_64/375.39/NVIDIA-Linux-x86_64-375.39.run && \
     sh NVIDIA-Linux-x86_64-375.39.run -a -N --ui=none --no-kernel-module && \
     rm -rf NVIDIA-Linux-*

USER developer
