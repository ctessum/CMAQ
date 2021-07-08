using NetCDF

read_files = cd(readdir, pwd())
for oldfile in read_files
    if occursin(".nc", oldfile) == true
        new = split(oldfile,".")
        newfile = new[1] * "_new.nc"
        rm(newfile, force = true)
    

       #println(oldfile)
       #println(newfile)
       for (varname, var) in NetCDF.open(oldfile).vars
            #println(length(size(var)))
            #println(var.dim)
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