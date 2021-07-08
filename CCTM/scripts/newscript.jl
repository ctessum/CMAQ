import NetCDF_jll, NetCDFF_jll, IOAPI_jll, MPICH_jll

basedir = joinpath(dirname(@__FILE__), "../..")
if basedir == "../.."
    basedir = @__DIR__
end

"running in: $basedir"


scriptdir = joinpath(basedir, "CCTM", "scripts")
cd(scriptdir)

mpitemp = joinpath("lib", "mpidir")

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

    run(`./run_cctm_Bench_2016_12SE1.csh`)
end
