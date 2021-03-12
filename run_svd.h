/****************************************************************************
 * run_svd.h
 *
 * Paul Reiners
 *
 * Lorem ipsum dolor sit amet.
 ***************************************************************************/

#ifndef RUN_SVD_H
#define RUN_SVD_H

void run_svd(const size_t M, const size_t N, double A_data[]);
void pretty_print(const gsl_matrix * M);
void pretty_print_vector(const gsl_vector * M);

#endif // RUN_SVD_H
