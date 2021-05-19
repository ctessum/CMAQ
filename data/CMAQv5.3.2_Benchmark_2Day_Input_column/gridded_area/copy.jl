using NetCDF

# oldfile = "emis_mole_all_20160701_cb6_bench.nc"
# newfile = "emis_mole_all_20160701_cb6_bench_new.nc"



# for varname in NetCDF.open(oldfile).vars
#     vardata = ncread(oldfile,varname.first, start=[1,1,1,1], count = [1,1,-1, -1]) 
#     if varname.first == "TFLAG"
#      continue
#      end
#     nccreate(newfile,varname.first,"COL",1,"ROW",1,"LAY",1,"TSTEP",25)
#     ncwrite(vardata,newfile,varname.first)
# end

# for filename in readdir("."); 
#     if contains(filename, ".nc"); 
#         println(filename); 
#     end; 
# end

using NetCDF

read_files = cd(readdir, pwd())
for oldfile in read_files
    if occursin(".nc", oldfile) == true
    
       new = split(oldfile,".")
       newfile = new[1] * "_new.nc"

       #println(oldfile)
       #println(newfile)

        for varname in NetCDF.open(oldfile).vars
            if length(keys(varname.first)) == 3
                vardata = ncread(oldfile,varname.first, start=[1,1,1], count = [1,1,-1])
            elseif length(keys(varname.first)) == 4 
                vardata = ncread(oldfile,varname.first, start=[1,1,1,1], count = [1,1,-1, -1]) 
            elseif length(keys(varname.first)) > 5
                vardata = ncread(oldfile,varname.first, start = ones(length(keys(varname.first))
            end    

            if varname.first == "TFLAG"
            continue
            end
        
            nccreate(newfile,varname.first,"COL",1,"ROW",1,"LAY",1,"TSTEP",25)
            ncwrite(vardata,newfile,varname.first)
        end
    end
end

using NetCDF

read_files = cd(readdir, pwd())
for oldfile in read_files
    if occursin(".nc", oldfile) == true
    
       #new = split(oldfile,".")
       #newfile = new[1] * "_new.nc"

       #println(oldfile)
       #rintln(newfile)
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

            elseif dims == daytime
                vardata = ncread(oldfile, varname)




            else     
                var
                println(dims)


            end      

            if varname.first == "TFLAG"
                continue
                end
            
                nccreate(newfile,varname.first,"COL",1,"ROW",1,"LAY",1,"TSTEP",25)
                ncwrite(vardata,newfile,varname.first)
            end


          
        end
    end
end





    







#readdir(abspath("base"), join=true)cd