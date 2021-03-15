/****************************************************************************
 * Paul Reiners
 ***************************************************************************/

#ifndef RUN_SVD_H
#define RUN_SVD_H

#include <stddef.h>

#include <gsl/gsl_matrix.h>

void run_svd(const size_t M, const size_t N, double A_data[]);
void pretty_print(const gsl_matrix * M);
void pretty_print_vector(const gsl_vector * M);
void run_svd_example();

#endif // RUN_SVD_H
