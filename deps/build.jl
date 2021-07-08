import NetCDF_jll, NetCDFF_jll, IOAPI_jll, MPICH_jll

# Following directions from here: 
# https://github.com/USEPA/CMAQ/blob/master/DOCS/Users_Guide/Tutorials/CMAQ_UG_tutorial_build_library_gcc.md

basedir = joinpath(dirname(@__FILE__), "..")
if basedir == ".."
    basedir = @__DIR__
end

"running in: $basedir"

cd(basedir)
scriptdir = joinpath(basedir, "CCTM", "scripts")

## Compile CMAQ

# Following directions from: https://github.com/USEPA/CMAQ/blob/master/DOCS/Users_Guide/Tutorials/CMAQ_UG_tutorial_benchmark.md

rm("lib", force=true, recursive=true)

mpitemp = joinpath("lib", "mpidir")
mkpath(mpitemp)

for dir in ["lib", "include"]
    mkpath(joinpath(mpitemp, dir))
    for f in readdir(joinpath(MPICH_jll.artifact_dir, dir))
        cp(joinpath(MPICH_jll.artifact_dir, dir, f), joinpath(mpitemp, f), force=true, follow_symlinks=true)
        cp(joinpath(MPICH_jll.artifact_dir, dir, f), joinpath(mpitemp, dir, f), force=true, follow_symlinks=true)
    end
end

cd(scriptdir)

rm("BLD_CCTM_v532_gcc", force=true, recursive=true)
rm("BLD_CCTM_v532_gcc9.1", force=true, recursive=true)

withenv( 
    "IOAPI_DIR"=>IOAPI_jll.artifact_dir,
    "IOAPI_LIB_DIR"=>joinpath(IOAPI_jll.artifact_dir, "lib"),
    "IOAPI_INCL_DIR"=>joinpath(IOAPI_jll.artifact_dir, "include"),
    "NETCDF_DIR"=>NetCDF_jll.artifact_dir,
    "NETCDF_LIB_DIR"=>joinpath(NetCDF_jll.artifact_dir, "lib"),
    "NETCDF_INCL_DIR"=>joinpath(NetCDF_jll.artifact_dir, "include"),
    "NETCDFF_DIR"=>NetCDFF_jll.artifact_dir,
    "NETCDFF_LIB_DIR"=>joinpath(NetCDFF_jll.artifact_dir, "lib"),
    "NETCDFF_INCL_DIR"=>joinpath(NetCDFF_jll.artifact_dir, "include"),
    "MPI_LIB_DIR"=>joinpath(basedir, mpitemp),
    "PATH"=>ENV["PATH"]*":"*MPICH_jll.PATH[],
    "LIBRARY_PATH"=>MPICH_jll.LIBPATH[]*":"*IOAPI_jll.LIBPATH[],
    "LD_LIBRARY_PATH"=>MPICH_jll.LIBPATH[]*":"*IOAPI_jll.LIBPATH[],
    "RPATH"=>MPICH_jll.LIBPATH[]*":"*IOAPI_jll.LIBPATH[],
    ) do

    run(`./bldit_cctm.csh gcc`)
end

mv("BLD_CCTM_v532_gcc", "BLD_CCTM_v532_gcc9.1")

if !isfile(joinpath(scriptdir, "BLD_CCTM_v532_gcc9.1", "CCTM_v532.exe"))
    throw("executable not successfully built")
end