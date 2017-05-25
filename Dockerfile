FROM mettainnovations/openbr-dlib:latest

USER root

# Install nvidia driver
RUN  apt install -y module-init-tools wget && \
     wget http://us.download.nvidia.com/XFree86/Linux-x86_64/381.22/NVIDIA-Linux-x86_64-381.22.run && \
     sh NVIDIA-Linux-x86_64-381.22.run -a -N --ui=none --no-kernel-module && \
     rm -rf NVIDIA-Linux-*

USER developer
