#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include <gsl/gsl_math.h>
#include <gsl/gsl_matrix.h>
#include <gsl/gsl_vector.h>
#include <gsl/gsl_linalg.h>

#include "mex.h"

static double
get_double(const mxArray *array_ptr)
{
    double *pr;
    pr = mxGetPr(array_ptr);
    double result = (double) *pr;
    
    return result;
}

/* Create MATLAB mxArray from gsl_vector */
mxArray *gslvector2MATLAB(gsl_vector *V)
{
    mxArray *mx;
    double *data, *target;
    size_t i, n, stride;
    if( V ) {
        n = V->size;
        data = V->data;
        stride = V->stride;
        mx = mxCreateDoubleMatrix(n,1,mxREAL);
        target = (double *) mxGetData(mx);
        while( n-- ) {
            *target++ = *data;
            data += stride;
        }
    } else {
        mx = mxCreateDoubleMatrix(0,0,mxREAL);
    }
    return mx;
}

/* Create MATLAB mxArray from gsl_matrix */
mxArray *gslmatrix2MATLAB(gsl_matrix *M)
{
    mxArray *mx;
    double *data, *target;
    size_t i, j, m, n;
    if( M ) {
        m = M->size1;
        n = M->size2;
        data = M->data;
        mx = mxCreateDoubleMatrix(m,n,mxREAL);
        target = (double *) mxGetData(mx);
        for( i=0; i<m; i++ ) {
            for( j=0; j<n; j++ ) {
                target[i+j*m] = data[j]; /* tranpose */
            }
            data += M->tda;
        }
    } else {
        mx = mxCreateDoubleMatrix(0,0,mxREAL);
    }
    return mx;
}

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] ) {
    int i;

   /* You should put code here to check nrhs, nlhs, prhs[0], prhs[1], prhs[2] */

    int m = (int) get_double(prhs[0]);
    int n = (int) get_double(prhs[1]);
    double *mexArray =  mxGetPr(prhs[2]);
   
  gsl_matrix * B;
  gsl_matrix * V;
  gsl_vector * S;
  gsl_vector * work;
  gsl_matrix_view A = gsl_matrix_view_array(mexArray, m, n);
  if (n > m) {
    B = gsl_matrix_alloc(n, m);
    V = gsl_matrix_alloc(m, m);
    S = gsl_vector_alloc(m);
    work = gsl_vector_alloc(m);

    gsl_matrix_transpose_memcpy(B, &A.matrix);
  } else {
    B = gsl_matrix_alloc(m, n);
    V = gsl_matrix_alloc(n, n);
    S = gsl_vector_alloc(n);
    work = gsl_vector_alloc(n);

    gsl_matrix_memcpy(B, &A.matrix);
  }

    gsl_linalg_SV_decomp(B, V, S, work);

    /* call custom routines to copy data as transpose */
    if (m < n) {
		plhs[0] = gslmatrix2MATLAB(V);
		plhs[2] = gslmatrix2MATLAB(B);
	} else {
		plhs[2] = gslmatrix2MATLAB(V);
		plhs[0] = gslmatrix2MATLAB(B);
	}
    plhs[1] = gslvector2MATLAB(S);

  gsl_matrix_free(B);
  gsl_matrix_free(V);
  gsl_vector_free(S);
  gsl_vector_free(work);
}
