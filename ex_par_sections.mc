/* $Id: ex05.mc,v 2.1 2005/06/14 22:16:47 jls Exp $ */

/*
 * Copyright 2005 SRC Computers, Inc.  All Rights Reserved.
 *
 *	Manufactured in the United States of America.
 *
 * SRC Computers, Inc.
 * 4240 N Nevada Avenue
 * Colorado Springs, CO 80907
 * (v) (719) 262-0213
 * (f) (719) 262-0223
 *
 * No permission has been granted to distribute this software
 * without the express permission of SRC Computers, Inc.
 *
 * This program is distributed WITHOUT ANY WARRANTY OF ANY KIND.
 */

#include <libmap.h>


void subr (int64_t A[], int64_t B[], int64_t C[], int64_t D[], int64_t Out1[],
            int64_t Out2[], int N0, int N1, int64_t *time, int mapnum) {

    OBM_BANK_A (AL, int64_t, MAX_OBM_SIZE)
    OBM_BANK_B (BL, int64_t, MAX_OBM_SIZE)
    OBM_BANK_C (CL, int64_t, MAX_OBM_SIZE)
    OBM_BANK_D (DL, int64_t, MAX_OBM_SIZE)

    int64_t t0, t1;
    
    Stream_64 SA,SB,SC,SD,SOut1,SOut2;

    read_timer (&t0);



    buffered_dma_cpu (CM2OBM, PATH_0, AL, MAP_OBM_stripe (1,"A"), A, 1, N0*8);

#pragma src parallel sections
{
#pragma src section
{
    streamed_dma_cpu_64 (&SB, PORT_TO_STREAM, B, N0*sizeof(int64_t));
}
#pragma src section
{
    int i;
    int64_t i64,j64;

    for (i=0;i<N0;i++)  {
       get_stream_64 (&SB, &i64);
       j64 = AL[i] + i64;
       put_stream_64 (&SOut1, j64, 1);
    }
}
#pragma src section
{
    streamed_dma_cpu_64 (&SOut1, STREAM_TO_PORT, Out1, N0*sizeof(int64_t));
}
}


// Now for the C * D compute

    buffered_dma_cpu (CM2OBM, PATH_0, CL, MAP_OBM_stripe (1,"C"), C, 1, N1*8);

#pragma src parallel sections
{
#pragma src section
{
    streamed_dma_cpu_64 (&SD, PORT_TO_STREAM, D, N1*sizeof(int64_t));
}
#pragma src section
{
    int i;
    int64_t i64,j64;

    for (i=0;i<N1;i++)  {
       get_stream_64 (&SD, &i64);

       j64 = CL[i] * i64;
       put_stream_64 (&SOut2, j64, 1);
    }
}
#pragma src section
{
    streamed_dma_cpu_64 (&SOut2, STREAM_TO_PORT, Out2, N1*sizeof(int64_t));
}
}

    read_timer (&t1);
    *time = t1 - t0;

    }
