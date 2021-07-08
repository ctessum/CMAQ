using NetCDF


read_files = cd(readdir, pwd())
for oldfile in read_files
    if occursin(".nc", oldfile) == true
    
    
       for (varname, var) in NetCDF.open(oldfile).vars
            #println(length(size(var)))
            println(var.dim)
            dims = Vector{String}(undef, length(var.dim))
            i = 1
            
            for dim in var.dim
                dims[i] = dim.name
                i +=1
                
    
            end
            
            fourD = ["COL", "ROW", "LAY", "TSTEP"]
            daytime = ["DATE-TIME", "VAR", "TSTEP"]
            if dims == fourD
                vardata = ncread(oldfile,varname, start=[1,1,1,1], count = [1,1,-1, -1]) 

            elseif dims == daytime
                vardata = ncread(oldfile, varname)


            else     
                var
                println(dims)


            end
        end
    end              
end

#=for (varname, var) in NetCDF.open(oldfile).vars
    println(length(size(var)))
    println(var.dim)
    dims = Vector{String}(undef, length(var.dim))
    
    i = 1
    for dim in var.dim
        dims[i] = dim.name
        i +=1
    end
    
    fourD = ["COL", "ROW", "LAY", "TSTEP"]
    daytime = ["DATE-TIME", "VAR", "TSTEP"]
    if dims == fourD
        vardata = ncread(oldfile,varname, start=[1,1,1,1], count = [1,1,-1, -1]) 
        nccreate(newfile,varname,"COL",1,"ROW",1,"LAY",var.dim[3].dimlen,"TSTEP",var.dim[4].dimlen)
    elseif dims == daytime
        vardata = ncread(oldfile, varname)
        nccreate(newfile,varname,"DATE-TIME",var.dim[1].dimlen,"VAR",var.dim[2].dimlen,"TSTEP",var.dim[3].dimlen)
    else
        println(dims)
    end      
    
    ncwrite(vardata,newfile,varname)
end
=#

#=newdir = "/Users/Minwoo/Desktop/Input_copy/clone/"
rm(newdir, force=true, recursive=true)
mkpath(newdir)

for (root, dirs, files) in walkdir("./gridded_area_copy")
    for file in files
        if occursin(".nc", file)
            mkpath(joinpath(newdir, root))
            cp_netcdf(joinpath(root, file), joinpath(newdir, root, file))
        
        else #just copying the files without .nc
            mkpath(joinpath(newdir, root))
            cp(joinpath(root, file), joinpath(newdir, root, file), force = true)
        end
    end
end

=#
#"/Users/Minwoo/Desktop/Input_copy/CMAQv5.3.2_Benchmark_2Day_Input/emis/inln_point/cmv_c3"