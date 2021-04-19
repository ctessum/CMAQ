using CMAQ
using Test

basedir = joinpath(dirname(@__FILE__), "..")
if basedir == ".."
    basedir = @__DIR__
end

"running in: $basedir"

cd(basedir)
scriptdir = joinpath(basedir, "CCTM", "scripts")

@testset "CMAQ.jl" begin
    if !isfile(joinpath(scriptdir, "BLD_CCTM_v532_gcc9.1", "CCTM_v532.exe"))
        throw("executable not successfully built")
    end
end




