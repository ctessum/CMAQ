import Tar
import GZip
import GitCommand

# Following directions from here: 
# https://github.com/USEPA/CMAQ/blob/master/DOCS/Users_Guide/Tutorials/CMAQ_UG_tutorial_build_library_gcc.md

basedir = joinpath(dirname(@__FILE__), "..")
if basedir == ".."
    basedir = @__DIR__
end

"running in: $basedir"

libdir = joinpath(basedir, "LIBRARIES")
ncbinpath = joinpath(libdir, "netcdf-c-4.7.0-gcc9.1.0")
ncfbinpath = joinpath(libdir, "netcdf-fortran-4.4.5-gcc9.1.0")
ioapi_bin = "Linux2_x86_64gfort_openmpi_4.0.1_gcc_9.1.0"
ioapi_bin_path = joinpath(libdir, "ioapi-3.2", ioapi_bin)
scriptdir = joinpath(basedir, "CCTM", "scripts")

cd(basedir)
rm("LIBRARIES", force=true, recursive=true)

## Install netCDF-C

# 2. Load module environment for a compiler (Intel|GCC|PGI) and mpi package corresponding to that compiler (e.g. openmpi).
run(`which gfortran`)
run(`gfortran --version`)
gfortranversion = VersionNumber(chomp(read(`gfortran -dumpversion`, String)))
run(`which gcc`)
run(`gcc -dumpversion`)
run(`which g++`)
run(`which mpifort`)

# 3. Create a LIBRARY directory where you would like to install the libraries required for CMAQ
mkpath(libdir)

# 4. Change directories to the new LIBRARIES Directory
cd(libdir)

# 5. Download netCDF-C from the following website https://www.unidata.ucar.edu/downloads/netcdf/index.jsp
nctar = download("ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-c-4.7.0.tar.gz")
Tar.extract(GZip.open(nctar), joinpath(libdir, "ncsrc"))

# 8. Create a target installation directory that includes the loaded module environment name
mkpath(ncbinpath)

# 12. Run the configure command
cd(joinpath(libdir, "ncsrc", "netcdf-c-4.7.0"))
run(`./configure --prefix=$ncbinpath --disable-netcdf-4 --disable-dap`)

# 13. Check that the configure command worked correctly, then run the install command
run(`make check install`)

## Install netCDF-Fortran

# 1. Download netCDF-Fortran from the following website https://www.unidata.ucar.edu/downloads/netcdf/index.jsp
ncftar = download("ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-fortran-4.4.5.tar.gz")

# 2. Untar the tar.gz file
Tar.extract(GZip.open(ncftar), joinpath(libdir, "ncfsrc"))

# 3. Change directories to netcdf-fortran-4.4.5
cd(joinpath(libdir, "ncfsrc", "netcdf-fortran-4.4.5"))

withenv("LD_LIBRARY_PATH"=>joinpath(ncbinpath, "lib"),
        "CPPFLAGS"=>"-I"*joinpath(ncbinpath, "include"),
    ) do
    # 11. Run the configure command
    run(`./configure --prefix=$ncfbinpath`)
    # 12. Run the make check command
    run(`make`)# check`) # TODO: `make check` here gives a "malformed URL" error.
    # 13. Run the make install command
    run(`make install`)
end


## Install I/O API

# 1. Change directories to one level up from your current location
cd(libdir)


GitCommand.git() do git
    # 2. Download I/O API
    run(`$git clone https://github.com/cjcoats/ioapi-3.2`)
    # 3. change directories to the ioapi-3.2 directory
    cd(joinpath(libdir, "ioapi-3.2"))
    # 2. Change branches to 20200828 for a tagged stable version
    run(`$git checkout -b 20200828`)
end

# 3. Change directories to the ioapi directory
cd(joinpath(libdir, "ioapi-3.2", "ioapi"))

# 4. copy the Makefile.nocpl file to create a Makefile
cp("Makefile.nocpl", "Makefile", force=true)

# 5. Set the BIN environment variable to include the loaded module name

# 6. Copy an existing Makeinclude file to have this BIN name at the end
if gfortranversion >= VersionNumber("10")
    # macOS homebrew currently uses gfortran 10.
    
    # Add in the a compiler flag to ignore the implicit declaration of functions,
    # which is illegal in macOS gcc compiler.
    lines = readlines("Makeinclude.Linux2_x86_64gfort10")
    open("Makeinclude.$ioapi_bin", "w") do w
        for line in lines
            if startswith(line, "MFLAGS")
                line = replace(line, "=" => "= -Wno-implicit-function-declaration", count=1)
                println(w, line)
            else
                println(w, line)
            end
        end
    end

else
    cp("Makeinclude.Linux2_x86_64gfort", "Makeinclude.$ioapi_bin")
end

# 7. Create a BIN directory where the library and m3tools executables will be installed
mkdir(ioapi_bin_path)

# 5. Set the HOME directory to be your LIBRARY install directory
withenv("LD_LIBRARY_PATH"=>"$ncfbinpath/lib", "HOME"=>libdir, "BIN"=>ioapi_bin) do
    # 6. Run the make command to compile and link the ioapi library
    run(`make fixed_src`)
    run(`make`)
end

# Workaround for syntax error issue as described by:
# https://www.cmascenter.org/ioapi/documentation/all_versions/html/AVAIL.html#cmaq
cp(joinpath("fixed_src", "STATE3.EXT"), "STATE3.EXT", force=true)

# 8. Change directories to the m3tools directory
cd(joinpath(libdir, "ioapi-3.2", "m3tools"))

# 9. Copy the Makefile.nocpl to create a Makefile
# 10. Edit line 65 of the Makefile to use the NCDIR and NFDIR environment variables 
#     that you have set in the above steps to locate the netcdf C and netcdf Fortran libraries
lines = readlines("Makefile.nocpl")
open("Makefile", "w") do w
    for line in lines
        if startswith(line, " LIBS")
            line = replace(line, " -lnetcdf " => " -L$ncbinpath/lib -lnetcdf ", count=1)
            line = replace(line, " -lnetcdff " => " -L$ncfbinpath/lib -lnetcdff ", count=1)
            println(w, line)
        else
            println(w, line)
        end
    end
end

# 11. Run make to compile the m3tools
withenv("LD_LIBRARY_PATH"=>"$ncfbinpath/lib", "HOME"=>libdir, "BIN"=>ioapi_bin) do
    run(`make`)
end

## Compile CMAQ

# Following directions from: https://github.com/USEPA/CMAQ/blob/master/DOCS/Users_Guide/Tutorials/CMAQ_UG_tutorial_benchmark.md

cd(scriptdir)

rm("BLD_CCTM_v532_gcc", force=true, recursive=true)

withenv(
    "IOAPI_INCL_DIR"=>joinpath(libdir, "ioapi-3.2", "ioapi"), 
    "IOAPI_LIB_DIR"=>ioapi_bin_path,
    "NETCDF_LIB_DIR"=>joinpath(ncbinpath, "lib"),
    "NETCDF_INCL_DIR"=>joinpath(ncbinpath, "include"),
    "NETCDFF_LIB_DIR"=>joinpath(ncfbinpath, "lib"),
    "NETCDFF_INCL_DIR"=>joinpath(ncfbinpath, "include"),
    "MPI_LIB_DIR"=>"/usr/", # This may need to be changed for HPC systems.
    ) do

    run(`./bldit_cctm.csh gcc`)
end

if !isfile(joinpath(scriptdir, "BLD_CCTM_v532_gcc", "CCTM_v532.exe"))
    throw("executable not successfully built")
end