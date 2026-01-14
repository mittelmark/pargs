// -!- C++ -!- ///////////////////////////////////////////////////////////////
//
// Copyright (C) 2026 MicroEmacs User.
//x
// All rights reserved.
//
// Synopsis:    
// Authors:     MicroEmacs User
//
//////////////////////////////////////////////////////////////////////////////

#include <iostream>
#include "pargs.hpp"
int main (int argc, char * argv[]) {
    Pargs pargs = Pargs();
    std::cout << pargs.getMessage() << std::endl;
    return(0);
}

