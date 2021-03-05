/****************************************************************************
 * run_svd.h
 *
 * Paul Reiners
 *
 * Lorem ipsum dolor sit amet.
 ***************************************************************************/

#ifndef RUN_SVD_H
#define RUN_SVD_H

int run_svd(const gsl_matrix * M);
void pretty_print(const gsl_matrix * M);
int calculate_svd_from_file(char* fileName);

#endif // RUN_SVD_H
