#!/bin/bash
#  Script to generate the problem dependent files used
#     in the nozzle case for Miranda
#  Script will: 
#           1)  Ensure gridgen exists in local folder,
#                  if not it is downloaded and built.
#           2)  Compile and run the papam_nozzle.f90 routines 
#                  for use in the grid generation and initialization.
#           3)  Generate the Grid using gridgen
#           4)  Make the 2d initialization file, grid file and 
#                  parameters file.
#           5)  Tar up the dependent files for use in nozzle case




#  Check to see if gridgen-c exists
ggEXEC="gridgen/gridgen"
ggCONF="gridgen/configure"
one=1

# bash check if directory exists
if [ -e $ggEXEC ]; then
    echo "gridgen-c exists... check complete"
    download=0
    build=0 
else 
    if [ -e $ggCONF ]; then
	build=1
	download=0
    else
	build=1
	download=1
    fi
fi

#  Download the files
if [ $download -eq $one ]; then
    echo "Downloading gridgen-c from repository"
    #svn checkout http://gridgen-c.googlecode.com/svn
    #mv svn/gridgen .
    #rm -rf svn
    git clone https://github.com/sakov/gridgen-c.git
    mv gridgen-c/gridgen .
    rm -rf gridgen-c
fi

#  Build the executable
if [ $build -eq $one ]; then
    echo "Building gridgen-c from source"
    cd gridgen
    ./configure
    make
    cd ..
    echo "Build Successful"
fi

#  Compile and run the f90 routines
ifort exp_nozzle.f90 -o exp_noz
./exp_noz 0

#  Using the boundary data from above, make the mesh
$ggEXEC -v noz.prm

#  Re-run the f90 routine and make the initialization file
./exp_noz 1

#  Tar-up and problem dependent files and label
#  also include the papam_nozzle.f90 file that was used to generate the current mesh
TARFILE=GRID_exp_$(date +%Y.%m.%d_%H.%M.%S).tgz
mkdir GRID
cp nozzle.grid nozzle_init.tec nozzle.inflow exp_nozzle.f90 GRID
mv GRID/nozzle_init.tec GRID/nozzle.init
tar cvzf $TARFILE GRID
#rm -rf GRID

#  All done... clean up and echo result
echo "Initialization complete"

