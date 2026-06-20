// -!- C++ -!- //////////////////////////////////////////////////////////////
//
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Detlef Groth
//  Created       : Sat Jun 20 08:07:18 2026
//  Last Modified : <260620.0942>
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
    std::string doc = R"(Usage: {0} (-h | --help) [ -V, --version, -v, --verbose subcommand -i INT -f FLOAT]
         <INFILE> [<OUTFILE>]

* Options:
    -h, --help              - display this help message
    -V, --version           - display the application version
    -v, --verbose           - set verbose to true
    -i INT, --int INT       - give an integer [default: 10]
    -f FLOAT, --float FLOAT - give a float value [default: 10.5]

* Subcommands:
    check                   - checking some text
    run                     - run the code
    round                   - round some number
* Arguments:
    <INFILE>           mandatory input file
    <OUTFILE>          optional output file [default: '-']
)";
    pargs::Pargs parser(doc, args, "0.0.1", true);
    if (args.size() == 1) {
      std::cout << parser.usage() << std::endl;
      return 0;
   }
   if (parser.parse_bool("-h", "--help").value_or(false)) {
      std::cout << parser.help() << std::endl;
      return 0;
   }
   if (parser.parse_bool("-V", "--version").value_or(false)) {
      std::cout << parser.version() << std::endl;
      return 0;
   }
   // check for subcommands
   std::string s ;
   std::vector<std::string> scmd{"check","run","round"};
   s = parser.subcommand(scmd).value_or("error") ;
    if (s=="error") {
        return 1;
    }
    
   std::string appname = parser.appname(); 
   bool verbose = parser.parse_bool("-v", "--verbose").value_or(false);
   int x = parser.parse_int("-i", "--int").value_or(10);
   float f = parser.parse_float("-f", "--float").value_or(10.5);
   std::string str = parser.parse_string("-s", "--string","Hi").value_or("Hi");
   if (!parser.check()) {
      return 1;
   }
    auto positionals = parser.position(2, "-");
    if (positionals[0] == "-") {
        parser.error("Missing <INFILE> argument!");
        return 1;
    }
    std::cout << "infile: '" << positionals[0] << "'" << " outfile: '" << positionals[1] << "'" << std::endl;
    std::cout << "appname: " << appname << std::endl;
    std::cout << "subcommand: " << s << std::endl;
    std::cout << "str: " << str << std::endl;    
    std::cout << "verbose: " << verbose << std::endl;
    std::cout << "int: " << x << std::endl;
    std::cout << "float: " << f << std::endl;
    return 0;
}
