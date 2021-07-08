using NetCDF
for (root, dirs, files) in walkdir(".")
    for file in files
        if occursin(".nc", file)
        println("root: $root, file: $file")
        new = split("$file",".")
        newfile = new[1] * "_copy.nc"
        println(newfile)
        cp(joinpath(root, file), newfile, force = true) #"$file", newfile ,force = true)
        #println("/Users/Minwoo/Desktop/gridded_area_copy/gridded/simple/" * newfile)
        mv(newfile, "/Users/Minwoo/Desktop/Input_copy/gridded_area_copy/gridded/simple/" * newfile, force = true)
        end
    end
end


#cd(pwd() * "/simple") #change it to /simple
read_files = readdir(joinpath(pwd(), "simple"), join=true)
for oldfile in read_files
    if occursin(".nc", oldfile) == true
        new = split(oldfile,".")
        newfile = new[1] * "_new.nc"
        rm(newfile, force = true)
    

    println(oldfile)
    println(newfile)
    for (varname, var) in NetCDF.open(oldfile).vars
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
                var
                println(dims)


            end      

            #if varname.first == "TFLAG"
                #continue
                #end
            
            ncwrite(vardata,newfile,varname)
            #end
        
        end
    end
end 

#mv("$file" * "_copy.nc", "/Users/Minwoo/Desktop/gridded_area_copy/gridded/simple/")
#cd("/Users/Minwoo/Desktop/gridded_area_copy/gridded")

#mv("emis_mole_all_20160702_cb6_bench_new_new.nc", "/Users/Minwoo/Desktop/gridded_area_copy/gridded/simple/emis_mole_all_20160702_cb6_bench_new_new.nc")
#To do : simplify "/Users/Minwoo/....... =   "pwd()" * "/simple/" * newfile