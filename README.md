# objToSOFA
objToSOFA is a linux bash script. It Tetrahedralizes a .obj file triangle/quad mesh using TetGen or GMSH and imports it into SOFA, offering several customization parameters including the insertion of a node grid using [objNodeGridGenerator](https://github.com/h4ppywastaken/objNodeGridGenerator).

![CMPP_FlowDiagram](https://user-images.githubusercontent.com/25606631/104106520-d5d58d80-52b6-11eb-979c-f654dc33f2a2.png)

## Prerequisites
The script automatically checks if prerequisites are installed if you use ".\objToSOFA.sh -h".

 - [objNodeGridGenerator](https://github.com/h4ppywastaken/objNodeGridGenerator) (executable already included in [src](./src/objNodeGridGenerator/))
 - [TetGen](http://www.wias-berlin.de/software/index.jsp?id=TetGen)
 - [GMSH](http://gmsh.info/)
 - [Blender](https://www.blender.org/)
 - [Python](https://www.python.org/)

## Usage

Execute in console from within objToSOFA folder with command ".\objToSOFA.sh [parameters]".

## Parameters

Use ".\objToSOFA -?" or ".\objToSOFA -h" to see the help context.

## Main Contributors

[h4ppywastaken](https://github.com/h4ppywastaken)

## Contributing

Feel free to open an issue or create a pull request at any time.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) file for details.
