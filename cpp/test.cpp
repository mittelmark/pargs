// -!- C++ -!- //////////////////////////////////////////////////////////////
//
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Detlef Groth
//  Created       : Sat Jun 20 08:07:18 2026
//  Last Modified : <260620.0812>
//
//  Description	  :
//
//  Notes         :
//
//  History
//	
/////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) 2026 University of Potsdam, Germany.
// 
//////////////////////////////////////////////////////////////////////////////

#include "pargs.hpp"
#include <iostream>

int main(int argc, char* argv[]) {
    std::vector<std::string> args(argv, argv + argc);
    std::string doc = R"(Usage: app (-h | --help) [ -V, --version, -v, --verbose -i INT -f FLOAT]
         <INFILE> [<OUTFILE>]

* Options:
    -h, --help               display this help message
    -V, --version            display the application version
    -v, --verbose            set verbose to true
    -i INT, --int INT        give an integer [default: 10]
    -f FLOAT, --float FLOAT  give a float value [default: 10.5]
 * Arguments:
    <INFILE>           mandatory input file
    <OUTFILE>          optional output file [default: '-']
)";
    pargs::Pargs parser(doc, args, "0.0.1", true);
    if (args.size() == 1) {
      std::cout << parser.usage() << std::endl;
      return 0;
   }
   if (parser.parse_bool("-h", "--help", false)) {
      std::cout << parser.help() << std::endl;
      return 0;
   }
   if (parser.parse_bool("-V", "--version", false)) {
      std::cout << parser.version() << std::endl;
      return 0;
   }
   bool verbose = parser.parse_bool("-v", "--verbose", false);
   int x = parser.parse_int("-i", "--int", 10).value_or(0);
   float f = parser.parse_float("-f", "--float", 10.5).value_or(10.5);
   if (!parser.check()) {
      return 1;
   }
   auto positionals = parser.position(2, "-");
     std::cout << "verbose: " << verbose << std::endl;
     std::cout << "int: " << x << std::endl;
     std::cout << "float: " << f << std::endl;
    return 0;
}
