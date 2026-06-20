/*
 * pargs.hpp - Command line parsing for C++ applications.
 * Translated from pargs.py by Detlef Groth, University of Potsdam, Germany
 * 2025-12-15
 *
 * NAME
 *
 * pargs.hpp - A simple header-only class for command line argument parsing
 * in C++ applications.
 *
 * DESCRIPTION
 *
 * The pargs module supports parsing the following types of command line options:
 *
 * - long and short options
 * - boolean flags
 * - key value options with defaults if argument was not given
 * - check for wrong option names
 * - positional argument parsing with defaults
 * - usage function line based on provided help page
 * - help function based on provided help page
 *
 * The order of parsing should be the following:
 *
 * - parser creation with doc, argv and version as arguments
 * - usage check - optional if you need
 * - help check
 * - subcommand check (subcommand) - optional if you use that
 * - flag check (parse) - usually for version check
 * - option check for key value (parse) - optional if you need
 * - wrong option check (check) - mandatory to check for invalid ones
 * - positionals check (positional) - optional if you need that
 *
 * EXAMPLE
 *
 * #include "pargs.hpp"
 * #include <iostream>
 *
 * int main(int argc, char* argv[]) {
 *     std::vector<std::string> args(argv, argv + argc);
 *     std::string doc = R"(Usage: app (-h | --help) [ -V, --version, -v, --verbose -i INT -f FLOAT]
 *          <INFILE> [<OUTFILE>]
 *
 * Options:
 *     -h, --help               display this help message
 *     -V, --version            display the application version
 *     -v, --verbose            set verbose to true
 *     -i INT, --int INT        give an integer [default: 10]
 *     -f FLOAT, --float FLOAT  give a float value [default: 10.5]
 *
 * Arguments:
 *     <INFILE>           mandatory input file
 *     <OUTFILE>          optional output file [default: '-']
 * )";
 *
 *     pargs::Pargs parser(doc, args, "0.0.1", true);
 *
 *     if (args.size() == 1) {
 *         std::cout << parser.usage() << std::endl;
 *         return 0;
 *     }
 *
 *     if (parser.parse_bool("-h", "--help", false)) {
 *         std::cout << parser.help() << std::endl;
 *         return 0;
 *     }
 *
 *     if (parser.parse_bool("-V", "--version", false)) {
 *         std::cout << parser.version() << std::endl;
 *         return 0;
 *     }
 *
 *     bool verbose = parser.parse_bool("-v", "--verbose", false);
 *     int x = parser.parse_int("-i", "--int", 10).value_or(0);
 *     float f = parser.parse_float("-f", "--float", 10.5).value_or(10.5);
 *
 *     if (!parser.check()) {
 *         return 1;
 *     }
 *
 *     auto positionals = parser.position(2, "-");
 *     std::cout << "verbose: " << verbose << std::endl;
 *     std::cout << "int: " << x << std::endl;
 *     std::cout << "float: " << f << std::endl;
 *
 *     return 0;
 * }
 */

#ifndef PARGS_HPP
#define PARGS_HPP

#include <string>
#include <vector>
#include <regex>
#include <optional>
#include <iostream>
#include <algorithm>
#include <sstream>

namespace pargs {

class Pargs {
public:
    /**
     * Initialize parser with default help page and state color support for error messages.
     *
     * @param doc - the help page (documentation string)
     * @param argv - the argument vector
     * @param version - the application version [default: "0.0.0"]
     * @param color - should error messages use color [default: true]
     */
    Pargs(const std::string& doc, std::vector<std::string>& argv,
          const std::string& version = "0.0.0", bool color = true)
        : doc_(doc), argv_(argv), version_(version), color_(color) {
        
        // Parse key=val syntax into separate arguments
        size_t i = 1;
        while (i < argv_.size()) {
            size_t eq_pos = argv_[i].find('=');
            if (eq_pos != std::string::npos) {
                std::string key = argv_[i].substr(0, eq_pos);
                std::string val = argv_[i].substr(eq_pos + 1);
                argv_[i] = key;
                argv_.insert(argv_.begin() + i + 1, val);
            }
            ++i;
        }

        // Set color codes
        if (color_) {
            RED_ = "\033[31m";
            DEF_ = "\033[0m";
        } else {
            RED_ = "";
            DEF_ = "";
        }
    }

    /**
     * Check for any not supported option present in argv.
     * Should be used only after the parse methods. Returns true
     * if the check was successful, and false if not.
     */
    bool check() {
        std::regex option_regex("^--?\\w");
        for (const auto& arg : argv_) {
            if (std::regex_search(arg, option_regex)) {
                error("Error: Wrong argument: '" + arg + "'!");
                std::cout << usage() << std::endl;
                return false;
            }
        }
        return true;
    }

    /**
     * Display colored error message.
     *
     * @param msg - the message to display
     */
    void error(const std::string& msg) const {
        std::cout << RED_ << msg << DEF_ << std::endl;
    }

    /**
     * Display full help page.
     */
    std::string help() const {
        return format_string(doc_);
    }

    /**
     * Parse boolean flag option.
     *
     * @param ashort - short option name like '-v'
     * @param along - long option name like '--verbose'
     * @param default_val - default value if the option is not given [default: false]
     * @return the parsed boolean value
     */
    std::optional<bool> parse_bool(const std::string& ashort, const std::string& along) {
        int idx = find_arg(ashort, along);
        if (idx > -1) {
            bool res = true;
            
            // Check if next argument is TRUE/FALSE/0/1
            if (idx + 1 < static_cast<int>(argv_.size())) {
                std::string next_arg = argv_[idx + 1];
                std::transform(next_arg.begin(), next_arg.end(), next_arg.begin(),
                             [](unsigned char c) { return std::tolower(c); });
                
                if (next_arg == "false" || next_arg == "0") {
                    argv_.erase(argv_.begin() + idx);
                    res = false;
                } else if (next_arg == "true" || next_arg == "1") {
                    argv_.erase(argv_.begin() + idx);
                }
            }
            
            argv_.erase(argv_.begin() + idx);
            return res;
        }
        return std::nullopt;
    }

    /**
     * Parse integer option.
     *
     * @param ashort - short option name like '-i'
     * @param along - long option name like '--int'
     * @return optional containing the parsed integer value, or empty if parsing failed
     */
    std::optional<int> parse_int(const std::string& ashort, const std::string& along) {
        int idx = find_arg(ashort, along);
        if (idx > -1) {
            if (idx + 1 >= static_cast<int>(argv_.size())) {
                error("Error: Missing argument for " + ashort + "," + along + "!");
                std::cout << usage() << std::endl;
                return std::nullopt;
            }

            std::string val_str = argv_[idx + 1];
            if (std::regex_match(val_str, std::regex("[0-9]+"))) {
                int val = std::stoi(val_str);
                argv_.erase(argv_.begin() + idx, argv_.begin() + idx + 2);
                return val;
            } else {
                error("Error: wrong argument for " + ashort + "," + along + "! Not an integer!");
                std::cout << usage() << std::endl;
                return std::nullopt;
            }
        }
        return std::nullopt;
    }

    /**
     * Parse float option.
     *
     * @param ashort - short option name like '-f'
     * @param along - long option name like '--float'
     * @param default_val - default value if the option is not given
     * @return optional containing the parsed float value, or empty if parsing failed
     */
    std::optional<float> parse_float(const std::string& ashort, const std::string& along) {
        int idx = find_arg(ashort, along);
        if (idx > -1) {
            if (idx + 1 >= static_cast<int>(argv_.size())) {
                error("Error: Missing argument for " + ashort + "," + along + "!");
                std::cout << usage() << std::endl;
                return std::nullopt;
            }

            std::string val_str = argv_[idx + 1];
            if (std::regex_match(val_str, std::regex("[.0-9]+"))) {
                float val = std::stof(val_str);
                argv_.erase(argv_.begin() + idx, argv_.begin() + idx + 2);
                return val;
            } else {
                error("Error: Wrong argument for " + ashort + "," + along + "! Not a float!");
                std::cout << usage() << std::endl;
                return std::nullopt;
            }
        }
        return std::nullopt;
    }

    /**
     * Parse string option.
     *
     * @param ashort - short option name like '-s'
     * @param along - long option name like '--string'
     * @param default_val - default value if the option is not given
     * @return optional containing the parsed string value, or empty if parsing failed
     */
    std::optional<std::string> parse_string(const std::string& ashort,
                                             const std::string& along,
                                             const std::string& default_val = "") {
        int idx = find_arg(ashort, along);
        if (idx > -1) {
            if (idx + 1 >= static_cast<int>(argv_.size())) {
                error("Error: Missing argument for " + ashort + "," + along + "!");
                std::cout << usage() << std::endl;
                return std::nullopt;
            }

            std::string val = argv_[idx + 1];
            argv_.erase(argv_.begin() + idx, argv_.begin() + idx + 2);
            return val;
        }
        return default_val;
    }

    /**
     * Check first argument for a valid subcommand.
     *
     * @param names - vector of valid subcommands to search against
     * @return subcommand name if valid, or empty string
     */
    std::optional<std::string> subcommand(const std::vector<std::string>& names) {
        if (argv_.size() < 2) {
            return std::nullopt;
        }

        auto it = std::find(names.begin(), names.end(), argv_[1]);
        if (it != names.end()) {
            std::string cmd = argv_[1];
            argv_.erase(argv_.begin() + 1);
            return cmd;
        } else {
            error("Error: Wrong subcommand '" + argv_[1] + "'!");
            std::string valid_cmds = join_vector(names, "','");
            error("Valid subcommands are '" + valid_cmds + "'!");
            std::cout << usage() << std::endl;
            return std::nullopt;
        }
    }

    /**
     * Display docu text until the first empty line within that text.
     */
    std::string usage() const {
        std::istringstream stream(doc_);
        std::string line;
        std::string res;
        int n = 0;

        while (std::getline(stream, line)) {
            n++;
            if (n > 1 && std::regex_match(line, std::regex("\\s*"))) {
                break;
            }
            res += line + "\n";
        }

        return format_string(res);
    }

    /**
     * Display application version.
     */
    std::string version() const {
        return version_;
    }

    /**
     * Returns the main filename with which the application was called.
     */
    std::string appname() const {
        if (argv_.empty()) {
            return "";
        }
        return argv_[0];
    }

    /**
     * Check for positional arguments.
     * Should be called after parse and check methods, so usually last.
     *
     * @param max - maximal number of arguments [default: 1]
     * @param default_val - value if argument is missing [default: "-"]
     * @return vector of positional arguments
     */
    std::vector<std::string> position(size_t max = 1, const std::string& default_val = "-") const {
        std::vector<std::string> res;
        for (size_t i = 1; i <= max; ++i) {
            if (i < argv_.size()) {
                res.push_back(argv_[i]);
            } else {
                res.push_back(default_val);
            }
        }
        return res;
    }

private:
    std::string doc_;
    std::vector<std::string> argv_;
    std::string version_;
    bool color_;
    std::string RED_;
    std::string DEF_;

    /**
     * Find the index of an argument by short or long name.
     * Returns -1 if not found.
     */
    int find_arg(const std::string& ashort, const std::string& along) const {
        for (size_t i = 0; i < argv_.size(); ++i) {
            if (argv_[i] == ashort || argv_[i] == along) {
                return static_cast<int>(i);
            }
        }
        return -1;
    }

    /**
     * Format string by replacing {0} with the applications name.
     */
    std::string format_string(const std::string& str) const {
        std::string result = str;
        std::string app_name = appname();
        
        // Replace {0} with applications name
        size_t pos = 0;
        while ((pos = result.find("{0}", pos)) != std::string::npos) {
            result.replace(pos, 3, app_name);
            pos += app_name.length();
        }
        
        return result;
    }

    /**
     * Join vector of strings with a delimiter.
     */
    static std::string join_vector(const std::vector<std::string>& vec,
                                   const std::string& delim) {
        std::string result;
        for (size_t i = 0; i < vec.size(); ++i) {
            if (i > 0) result += delim;
            result += vec[i];
        }
        return result;
    }
};

} // namespace pargs

#endif // PARGS_HPP
