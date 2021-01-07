#!/bin/bash

function echo_info
{
	echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
	echo "Info: ${1}"
	echo
}

function echo_error
{
	echo
	echo -e "\e[91mError: ${1}\e[39m"
	exit 2
}

function exit_0
{
	exit 0 >/dev/null 2>&1
}

function load_config
{
	if [ -f "./src/objToSOFA.cfg" ]; then
		source src/objToSOFA.cfg
	else
		echo_error "./src/objToSOFA.cfg. File does not exist. Not able to load config file. Use -c for config file help."
	fi
}

function check_if_installed
{
	version=""
	if [ ${1} == "blender" ]; then
		version=`blender --version 2>&1`
	fi
	if [ ${1} == "gmsh" ]; then
		version=`gmsh --version 2>&1`
	fi
	if [ ${1} == "python" ]; then
		version=`python --version 2>&1`
	fi
	if [ ${1} == "tetgen" ]; then
		version=`tetgen -h | grep Version 2>&1`
	fi

	[[ $(grep / <<< $(whereis ${1})) ]] && echo -e "\e[92m	- ${2} (installed - ${version})" || echo -e "\e[91m	- ${2} (not installed)"
}

#Script Help
function print_help
{
	echo
	echo "--- Usage ---"
	echo
	echo "./objToSOFA.sh [-bpgsunmvch] [-e x] [-r y] [-a string] filename"
	echo
	echo "--- Parameters ---"
	echo
	echo "	filename: .obj input file"
	echo "	-r y: Refine surface mesh with y amount of edge cuts"
	echo "	-e x: Insert Node Grid with x amount of nodes (grid saved in <filename>.a.node)"
	echo "	-b: Activates Node Grid Honeycomb-Mode (only works with -e)"
	echo "	-p: Preserves Constraints while using Tetgen"
	echo "	-g: Use GMSH instead of Tetgen for tetrahedralization"
	echo "	-s: Open SOFA scene after finishing"
	echo "	-u: Create SOFA scene with CUDA plugin"
	echo "	-n: node-only-mode extracts nodes from .obj file and ignores the rest (saves .node file)"
	echo "	-m: smesh-mode converts .obj to .smesh before tetrahedralization (saves .smesh file)"
	echo "	-a string: hands additional paramters to the tetrahedralization software"
	echo "	-v: save tetrahedral mesh in .vtk format (Medit)"
	echo "	-c: Print config file format help"
	echo "	-h: Show this help"
	echo
	echo "--- Examples ---"
	echo
	echo "	Example 1:"
	echo "	./objToSOFA.sh -s -e 1000 -r 2 liver.obj"
	echo
	echo "	Example 2:"
	echo "	./objToSOFA.sh liver"
	echo
	echo "--- Prerequisites ---"
	echo
	check_if_installed blender Blender
	check_if_installed tetgen Tetgen
	check_if_installed gmsh GMSH
	check_if_installed python Python

	if [ -f "./src/objToSOFA.cfg" ]; then
		source src/objToSOFA.cfg
		if [ -f "${runSOFA_path}" ]; then
			echo -e "\e[92m	- SOFA (optional - installed)"
	    else
	    	echo -e "\e[39m	- SOFA (optional)"
	    	echo
	    	echo -e "\e[93mWarning: SOFA path in config is set but could not be found"
	    fi
	else
		echo -e "\e[39m	- SOFA (optional - set path in config file)"
		echo
		echo -e "\e[93mWarning: Config file could not be found. Use -c for config file help."
	fi
	echo
}

function print_config_help
{
	echo
	echo "--- Config File Name ---"
	echo
	echo "./src/objToSOFA.cfg"
	echo
	echo "--- Config File Format ---"
	echo
	echo '#path to runSofa'
	echo 'runSOFA_path="./pathToSofa/runSofa"'
	echo '#obj file directory'
	echo 'obj_dir="./obj"'
	echo '#output directory'
	echo 'output_dir="./"'
	echo
}

function check_file_exists
{
	#Check if input file exists
	if [ ! -f "${1}" ]; then
		echo_error "${1} does not exist."
	fi
}

function cleanup_files
{
	echo_info "Cleaning up files..."

	if [ -f "${filename}.geo" ]; then
		rm "${filename}.geo"
	fi

	if [ -f "${filename}.1.smesh" ]; then
		rm "${filename}.1.smesh"
	fi

	if [ -f "${filename}.ply" ]; then
		rm "${filename}.ply"
	fi

	if [ -f "${filename}.mesh" ]; then
		rm "${filename}.mesh"
	fi

	if [ -f "${filename}.obj" ]; then
		rm "${filename}.obj"
	fi

	if [ -f "${filename}.stl" ]; then
		rm "${filename}.stl"
	fi

	if [ -f "${filename}.node" ]; then
		rm "${filename}.node"
	fi

	if [ -f "${filename}.a.node" ]; then
		rm "${filename}.a.node"
	fi

	if [ -f "${filename}.smesh" ]; then
		rm "${filename}.smesh"
	fi

	if [ -f "${filename}.mtl" ]; then
		rm "${filename}.mtl"
	fi
}

### PARAMETERS/FLAGS ###

#get last argument
for i in $@; do :; done
filename="$i"

obj="obj"
sofaFlag=false
cudaFlag=false
gmshFlag=false
nodesOnlyFlag=false
smeshFlag=false
gridNodeCount=0
refineCuts=0
vtkFlag=false
honeycombFlag=false
preserveConstraints=false
additionalParameters=""

#Parse Parameters/Flags
while getopts bpgsunmvchr:e:a: opt
do
    case $opt in
	r)	refineCuts=${OPTARG};;
	e)	gridNodeCount=${OPTARG};;
	b)	honeycombFlag=true;;
	p)	preserveConstraints=true;;
	g)	gmshFlag=true;;
	s)	sofaFlag=true;;
	u)	cudaFlag=true;;
	n)	nodesOnlyFlag=true;;
	m)	smeshFlag=true;;
	v)	vtkFlag=true;;
	a)	additionalParameters=${OPTARG};;
	c) 	print_config_help; exit 0;;
	h)	print_help; exit 0;;
    ?)	print_help; exit 0;;
    esac
done

### ERROR HANDLING ###

#Exit on error
set -e
#save last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
#error message before exiting
trap 'cleanup_files;' EXIT

#import config file
load_config

### MAIN SCRIPT ###

#Check if filename is empty
filename=${filename/obj/}

if [ "${filename}" = "" ]; then
	print_help
	echo_error "Given file name is an empty string."
fi

#Check set flags
if [ "${gmshFlag}" = true ]; then
	if [ "${nodesOnlyFlag}" = true ]; then
		echo_error "Cannot use GMSH tetrahedralization (-g) using nodes-only-mode (-n)."
	fi
	if [ "${smeshFlag}" = true ]; then
		echo_error "Cannot use GMSH tetrahedralization (-g) using smesh-mode (-m)."
	fi
fi

if [ "${gridNodeCount}" != 0 ]; then
	if [ "${gmshFlag}" = true ]; then
		echo_error "Cannot insert Node Grid (-e) using GMSH tetrahedralization (-g)."
	fi
	if [ "${smeshFlag}" = true ]; then
		echo_error "Cannot insert Node Grid (-e) using smesh-mode (-m)."
	fi
	if [ "${nodesOnlyFlag}" = true ]; then
		echo_error "Cannot insert Node Grid (-e) using nodes-only-mode (-n)."
	fi
fi

if [ "${nodesOnlyFlag}" = true ]; then
	if [ "${smeshFlag}" = true ]; then
		echo_error "Cannot use nodes-only-mode (-n) using smesh-mode (-m)."
	fi
fi


echo_info "Checking if ${obj_dir}/${filename}.obj exists..."
#Check if input file exists
check_file_exists "${obj_dir}/${filename}.obj"
#Copy .obj file from obj directory
cp ${obj_dir}/${filename}.obj ${filename}.obj

if [ "${refineCuts}" != 0 ]; then
	echo_info "Refining surface mesh with Blender..."
	blender -b -P src/blenderQuadRefine.py -- "${filename}" ${refineCuts}
fi

echo_info "Triangulating ${filename}.obj with Blender..."
blender -b -P src/blenderTriangulate.py -- "${filename}"

#Convert .obj to .ply with Blender
echo_info "Converting .obj to .stl with Blender..."
blender -b -P src/blenderObjToStl.py -- "${filename}"

nodeGridParameters="-f ./${filename}.obj -n ${gridNodeCount} -i"
#NodeGrid
if [ "${gridNodeCount}" != 0 ]; then
	echo_info "Generating Node Grid with ${gridNodeCount} nodes..."
	if [ "${honeycombFlag}" = true ]; then
		nodeGridParameters="${nodeGridParameters} -c"
	fi

	./src/objNodeGridGenerator/objNodeGridGenerator ${nodeGridParameters}
fi

tetgenParameters="-gBNEFV ${additionalParameters} ${filename}"
gmshParameters="${filename}.geo ${additionalParameters} -3 -format msh2 -preserve_numbering_msh2 -o ${filename}.msh"

#GMSH
if [ "${gmshFlag}" = true ]; then
	#Create .geo script for GMSH
	echo_info "Creating .geo script for GMSH..."
	echo -en "Merge '${filename}.stl';\nSurface Loop(1) = {1};\nVolume(1) = {1};" >"${filename}.geo"

	#Tetrahedralize with GMSH
	echo_info "Tetrahedralization with GMSH..."
	gmsh ${gmshParameters}
#Tetgen
else
	if [ "${nodesOnlyFlag}" = true ]; then
		echo_info "Converting of ${filename}.obj to ${filename}.node..."
		#Convert to nodes file using only vertices
		python ./src/objToNode.py ${filename}.obj
		preserveConstraints=false
		tetgenParameters="${tetgenParameters}.node"
	elif [ "${smeshFlag}" = true ]; then
		echo_info "Converting of ${filename}.obj to ${filename}.smesh..."
		#Convert to smesh file format
		python ./src/objToSmesh.py ${filename}.obj
		tetgenParameters="${tetgenParameters}.smesh"
	else
		#Detrahedralize with Tetgen
		if [ "${gridNodeCount}" != 0 ]; then
			#Insert Node Grid with tetgen
			tetgenParameters="-i ${tetgenParameters}.stl"
		else
			tetgenParameters="${tetgenParameters} ${filename}.stl"
		fi
	fi

	if [ "${preserveConstraints}" = true ]; then
		tetgenParameters="-Y ${tetgenParameters}"
	fi

	echo_info "Tetrahedralization with Tetgen..."
	tetgen ${tetgenParameters} || true

	#rename .mesh file
	mv "${filename}.1.mesh" "${filename}.mesh"

	#Convert tetgen .mesh to .msh format
	echo_info "Converting .mesh to .msh with GMSH..."
	gmsh -save -format msh2 -preserve_numbering_msh2 -o "${filename}.msh" "${filename}.mesh"
fi

#Convert to .vtk format for Paraview
if [ "${vtkFlag}" = true ]; then
	gmsh -save -format vtk -o "${filename}.vtk" "${filename}.msh"
fi

#Create SOFA scene
if [ "${cudaFlag}" = true ]; then
	echo_info "Creating SOFA .scn file based on src/sofa_cuda_template.scn..."
	cp src/sofa_cuda_template.scn ${filename}.scn
else
	echo_info "Creating SOFA .scn file based on src/sofa_template.scn..."
	cp src/sofa_template.scn ${filename}.scn
fi

sed -i "s/templateFilename/${filename}/g" ${filename}.scn


#Move files into folder structure
if [ -d "${output_dir}/SOFAScenes/${filename}" ]; then
	rm -r "${output_dir}/SOFAScenes/${filename}"
fi

echo_info "Creating SOFA Scene folder structure..."
mkdir -p ${output_dir}/SOFAScenes
mkdir -p ${output_dir}/SOFAScenes/${filename}

mv ${filename}.msh ${output_dir}/SOFAScenes/${filename}
mv ${filename}.obj ${output_dir}/SOFAScenes/${filename}
mv ${filename}.scn ${output_dir}/SOFAScenes/${filename}

if [ -f "${filename}.vtk" ]; then
	mv ${filename}.vtk ${output_dir}/SOFAScenes/${filename}
fi
if [ -f "${filename}.smesh" ]; then
	mv ${filename}.smesh ${output_dir}/SOFAScenes/${filename}
fi
if [ -f "${filename}.node" ]; then
	mv ${filename}.node ${output_dir}/SOFAScenes/${filename}
fi
if [ -f "${filename}.a.node" ]; then
	mv ${filename}.a.node ${output_dir}/SOFAScenes/${filename}
fi

#Cleaning up files
cleanup_files

#Get absolute scene path
scn_path="${output_dir}/SOFAScenes/${filename}/${filename}.scn"

#Open .scn in SOFA
if [ "${sofaFlag}" = true ]; then
	echo_info "Opening .scn file in SOFA and exiting program..."
    eval "(gnome-terminal -- ${runSOFA_path} --input-file ${scn_path} &)"
fi

echo_info "Finished - exiting program..."
echo ${tetgenParameters}
exit_0