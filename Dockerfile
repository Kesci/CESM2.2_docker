FROM ubuntu:latest

LABEL maintainer="Widget_An <anchunyu@heywhale.com>"

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

RUN apt-get update && apt-get -y upgrade && apt-get autoremove && apt-get autoclean
RUN apt-get install apt-utils
RUN apt-get update && apt-get install -y software-properties-common && add-apt-repository ppa:gfd-dennou/ppa && apt-get install -y spml

RUN apt-get install -y file unzip git doxygen
RUN apt-get -y install build-essential gfortran cmake wget m4 csh zlib1g-dev perl libxml-libxml-perl libxml2 libxml2-dev libblas-dev liblapack-dev

RUN cd /opt && mkdir cesm && cd cesm && mkdir Downloads && mkdir Library && mkdir output && mkdir input

RUN cd /opt/cesm/Downloads \
    && wget https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.1.tar.gz \
    && tar zxvf openmpi-4.1.1.tar.gz \
    && cd openmpi-4.1.1 \
    && ./configure --prefix=/opt/cesm/Library/.local/openmpi \
    && make -j \
    && make install

ENV MPI_HOME=/opt/cesm/Library/.local/openmpi
ENV PATH=${MPI_HOME}/bin:$PATH
ENV LD_LIBRARY_PATH=${MPI_HOME}/lib:$LD_LIBRARY_PATH
ENV MANPATH=${MPI_HOME}/share/man:$MANPATH
ENV MPICC=mpicc
ENV MPICXX=mpicxx
ENV MPIFC=mpif90

RUN cd /opt/cesm/Downloads \
    && wget https://cesm2-2-1254542291.cos.ap-nanjing.myqcloud.com/hdf5-1.13.0.tar.gz \
    && tar -xvzf hdf5-1.13.0.tar.gz \
    && cd hdf5-1.13.0/ \
    && CC=mpicc CFLAGS=-w ./configure --prefix=/opt/cesm/Library --with-zlib --enable-hl --enable-fortran --enable-parallel \
    && make check -j \
    && make install

ENV HDF5=/opt/cesm/Library
ENV LD_LIBRARY_PATH=/opt/cesm/Library/lib:$LD_LIBRARY_PATH
ENV CPPFLAGS=-I/opt/cesm/Library/include 
ENV LDFLAGS="-L/opt/cesm/Library/lib -llapack -lblas"

RUN cd /opt/cesm/Downloads \
    && wget https://cesm2-2-1254542291.cos.ap-nanjing.myqcloud.com/netcdf-c-4.8.1.tar.gz \
    && tar -xvzf netcdf-c-4.8.1.tar.gz \
    && cd netcdf-c-4.8.1 \
    && ./configure --prefix=/opt/cesm/Library --disable-dap \
    && make check -j \
    && make install \
    && libtool --finish /opt/cesm/Downloads/netcdf-c-4.8.1/plugins

RUN cd /opt/cesm/Downloads \
    && wget https://cesm2-2-1254542291.cos.ap-nanjing.myqcloud.com/netcdf-fortran-4.5.4.tar.gz \
    && tar zxvf netcdf-fortran-4.5.4.tar.gz \
    && cd netcdf-fortran-4.5.4 \
    && ./configure --prefix=${NETCDF} --disable-fortran-type-check \
    && make -j \
    && make check -j \
    && make install \
    && cp /opt/cesm/Downloads/netcdf-fortran-4.5.4/fortran/netcdf.mod /opt/cesm/Library/include/ \
    && cp /opt/cesm/Downloads/netcdf-fortran-4.5.4/fortran/netcdf.inc /opt/cesm/Library/include/

RUN cd /opt/cesm/Downloads \
    && wget https://cesm2-2-1254542291.cos.ap-nanjing.myqcloud.com/pnetcdf-1.12.3.tar.gz \
    && tar zxvf pnetcdf-1.12.3.tar.gz \
    && cd pnetcdf-1.12.3 \
    && ./configure --prefix=/opt/cesm/Library/ --enable-shared --enable-fortran --enable-large-file-test CC=mpicc CXX=mpicxx FC=mpifort F77=mpifort \
    && make -j \
    && make install

ENV PATH=/opt/cesm/Library/bin:$PATH
ENV NETCDF=/opt/cesm/Library
ENV NETCDF_PATH=/opt/cesm/Library
ENV NETCDF_C_PATH=/opt/cesm/Library
ENV NETCDF_FORTRAN_PATH=/opt/cesm/Library
ENV NETCDF_FORTRAN=/opt/cesm/Library
ENV NETCDF_FORTRAN_LIBRARY=/opt/cesm/Library/lib
ENV NETCDF_FORTRAN_INCLUDE_DIR=/opt/cesm/Library/include
ENV LIB_NETCDF=/opt/cesm/Library/lib
ENV LIB_NETCDF_C=/opt/cesm/Library/lib
ENV LIB_NETCDF_FORTRAN=/opt/cesm/Library/lib
ENV NetCDF_C_PATH=/opt/cesm/Library/
ENV NetCDF_Fortran_PATH=/opt/cesm/Library
ENV NetCDF=/opt/cesm/Library
ENV PnetCDF=/opt/cesm/Library
ENV PNETCDF_PATH=/opt/cesm/Library
ENV PNetCDF_PATH=/opt/cesm/Library
ENV NetCDF_Fortran_LIBRARY=/opt/cesm/Library/lib
ENV NetCDF_Fortran_INCLUDE_DIR=/opt/cesm/Library/include
ENV LDFLAGS="-L/opt/cesm/Library/lib -lnetcdff -llapack -lblas"
ENV LIBS="-lnetcdf -lhdf5_hl -lhdf5 -lz"

RUN cd /opt/cesm/Downloads \
    && wget https://cesm2-2-1254542291.cos.ap-nanjing.myqcloud.com/my_cesm_sandbox.tar.gz \
    && cd .. \
    && tar zxvf Downloads/my_cesm_sandbox.tar.gz \
    && git config --global --add safe.directory /opt/cesm/my_cesm_sandbox/components/cdeps

RUN cd ~ \
    && mkdir .cime \
    && cd .cime \
    && wget https://cesm2-2-1254542291.cos.ap-nanjing.myqcloud.com/config_compilers.xml \
    && wget https://cesm2-2-1254542291.cos.ap-nanjing.myqcloud.com/config_machines.xml

