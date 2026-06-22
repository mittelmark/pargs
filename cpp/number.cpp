#include "include/pargs.hpp"
#include <iostream>
#include <iomanip>
int main(int argc, char* argv[]) {
    std::vector<std::string> args(argv, argv + argc);
    std::string doc = R"(
Usage: {0} (-h | --help) [ -v,--verbose | --round 2 ] FLOAT

* Options:
  -h, --help             - display this help message
  -v, --verbose          - set verbose to true
  -r INT, --round INT    - give the rounding integer [default: 2]

* Arguments:
  <FLOAT>                - some number which should be squard and rounded
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
    bool verbose = parser.parse_bool("-v", "--verbose"
                                     ).value_or(false);
    int round = parser.parse_int("-r", "--round").value_or(2);
    auto positionals = parser.position(1, "-");
    if (positionals[0] == "-") {
        parser.error("Missing <FLOAT> argument!");
    } else if (!parser.is_number(positionals[0])) {
        parser.error("Error: The item '" + positionals[0] + 
                     "' seems not to be a number!");
    }
    if (!parser.has_error()) {
        auto square = std::stof(positionals[0]);
        std::cout << "square of: " <<  square << " is " <<
              std::fixed <<
              std::setprecision(round) <<
              square*square <<  std::endl;
    } 
    return 0;
}
