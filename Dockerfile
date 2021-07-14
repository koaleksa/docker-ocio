FROM centos:7

# yum installs
RUN yum -y update && \
    yum -y install epel-release && \
    yum -y install centos-release-scl && \
    yum -y install \
    gcc-c++ \
    devtoolset-7-gcc-c++ \
    wget \
    curl \
    which \
    make \
    python-devel \
    git

# install newish CMake, older ones do not find python properly 
RUN mkdir -p /tmp/cmake && \
    pushd /tmp/cmake && \
    wget 'https://cmake.org/files/v3.20/cmake-3.20.1-linux-x86_64.sh' && \
    bash cmake-3.20.1-linux-x86_64.sh --prefix=/usr/local --exclude-subdir && \
    popd && \
    rm -rf /tmp/cmake

# pystring_install step requires git user and email to be set for some reason so
# just make them up
RUN git config --global user.name "abc" && \
    git config --global user.email "abc@example.com"

# OCIO
ARG OCIO_ROOT=/opt/ocio
ARG OCIO_VER=2.0.1
WORKDIR ${OCIO_ROOT}/src
RUN curl -O -L https://github.com/AcademySoftwareFoundation/OpenColorIO/archive/v${OCIO_VER}.tar.gz && \
    tar -xvzf v${OCIO_VER}.tar.gz && \
    cd OpenColorIO-${OCIO_VER} && \
    # enable gcc 7
    source /opt/rh/devtoolset-7/enable && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    make install

ENV PYTHONPATH=/usr/local/lib/python2.7/site-packages:${PYTHONPATH}
ENV LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}

# cleanup
WORKDIR /
RUN rm -rf ${OCIO_ROOT} && \
    yum erase -y gcc-c++ make cmake3 python-devel git && \
    rm -rf /var/cache/yum && \
    hash -r
