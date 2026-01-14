/* -*- C -*- *****************************************************************
 *
 * Copyright (C) 2026 MicroEmacs User.
 *
 * All rights reserved.
 *
 * Synopsis:    
 * Authors:     MicroEmacs User
 *
 *****************************************************************************/
#include <stdio.h>
#include "pargs.h"

int main (int argc, char * argv[]) {
    Pargs *pargs = {};
    printf("%s\n",Pargs_GetMessage(pargs));
    return(0);
}

