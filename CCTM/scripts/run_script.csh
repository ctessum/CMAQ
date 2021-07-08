#!/bin/csh
setenv CMAQ_DATA $HOME/CMAQ/data
setenv MPI_LIB_DIR /usr/
setenv IOAPI_INCL_DIR /Users/Minwoo/Desktop/CMAQ/LIBRARIES/ioapi-3.2/ioapi
setenv IOAPI_LIB_DIR /Users/Minwoo/Desktop/CMAQ/LIBRARIES/ioapi-3.2/Linux2_x86_64gfort_openmpi_4.0.1_gcc_9.1.0
setenv NETCDF_LIB_DIR /Users/Minwoo/Desktop/CMAQ/LIBRARIES/netcdf-c-4.7.0-gcc9.1.0/lib
setenv NETCDF_INCL_DIR /Users/Minwoo/Desktop/CMAQ/LIBRARIES/netcdf-c-4.7.0-gcc9.1.0/include
setenv NETCDFF_LIB_DIR /Users/Minwoo/Desktop/CMAQ/LIBRARIES/netcdf-fortran-4.4.5-gcc9.1.0/lib
setenv NETCDFF_INCL_DIR /Users/Minwoo/Desktop/CMAQ/LIBRARIES/netcdf-fortran-4.4.5-gcc9.1.0/include
#setenv DYLD_FALLBACK_LIBRARY_PATH /Users/Minwoo/Desktop/CMAQ/LIBRARIES/netcdf-fortran-4.4.5-gcc9.1.0/lib:/Users/Minwoo/Desktop/CMAQ/LIBRARIES/netcdf-c-4.7.0-gcc9.1.0/lib:/Users/Minwoo/Desktop/CMAQ/LIBRARIES/ioapi-3.2/Linux2_x86_64gfort_openmpi_4.0.1_gcc_9.1.0
./run_cctm_Bench_2016_12SE1.csh
#./run_column_Bench_2016_12SE1.csh | & tee cctm.log


#./run_cctm_2016_12US1_column.csh | & tee cctm.log
#add another script


#run_cctm_Bench_2016_12SE1.csh
#run_column_Bench_2016_12SE1.csh