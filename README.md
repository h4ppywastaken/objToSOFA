# objToSOFA
objToSOFA is a linux bash script. It Tetrahedralizes a .obj file triangle/quad mesh using TetGen or GMSH and imports it into SOFA, offering several customization parameters including the insertion of a node grid using [objNodeGridGenerator](https://github.com/h4ppywastaken/objNodeGridGenerator).

## Prerequisites
The script automatically checks if prerequisites are installed if you use ".\objToSOFA.sh -h".

 - gcc/make (for building from source with [Makefile](Makefile))
 - [objNodeGridGenerator](https://github.com/h4ppywastaken/objNodeGridGenerator)
 - [TetGen](http://www.wias-berlin.de/software/index.jsp?id=TetGen)
 - [GMSH](http://gmsh.info/)
 - [Blender](https://www.blender.org/)
 - [Python](https://www.python.org/)


## Build

Use "make" with [Makefile](Makefile) or use gcc (see [Makefile](Makefile) for gcc commands).

## Usage

Execute in console from within solarsystem folder with command ".\objToSOFA.sh [parameters]".

## Parameters

Use ".\objToSOFA -?" or ".\objToSOFA -h" to see the help context.

## Main Contributors

[h4ppywastaken](https://github.com/h4ppywastaken)

## Contributing

Feel free to open an issue or create a pull request at any time.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) file for details.
