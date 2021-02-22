/*
 * model_tsvd.c
 */

#include <stdio.h>
#include <gsl/gsl_blas.h>
#include <gsl/gsl_linalg.h>

/*
  gsl_matrix_printf prints a matrix as a column vector.  This function
  prints a matrix in block form.
*/
void pretty_print(const gsl_matrix * M)
{
  // Get the dimension of the matrix.
  int rows = M->size1;
  int cols = M->size2;
  // Now print out the data in a square format.
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      printf("%f ", gsl_matrix_get(M, i, j));
    }
    printf("\n");
  } 
}

int main(int argc, char **argv)
{
  // Set the data for our matrix.
  
  double a[] = {1.0, 1.0, 0.0,
		1.0, 2.0, 1.0,
		0.0, 1.0, 4.0};

  // Now create a matrix structure using this data.
  gsl_matrix_view A = gsl_matrix_view_array(a, 3, 3);

  gsl_matrix * V = gsl_matrix_alloc(3, 3);
  gsl_vector * S = gsl_vector_alloc(3);
  gsl_vector * work = gsl_vector_alloc(3);

  /*
    From the gsl documentation: The gsl_linalg_SV_decomp function
    factorizes the M-by-N matrix A into the singular value
    decomposition A = U S V^T for M >= N. On output the matrix A is
    replaced by U. The diagonal elements of the singular value matrix
    S are stored in the vector S. The singular values are non-negative
    and form a non-increasing sequence from S_1 to S_N. The matrix V
    contains the elements of V in untransposed form. To form the
    product U S V^T it is necessary to take the transpose of V. A
    workspace of length N is required in work.
  */
  gsl_linalg_SV_decomp(&A.matrix, V, S, work);

  //  gsl_matrix_fprintf (stdout, &A.matrix, "%g"); cout<<"\n";
  pretty_print(&A.matrix); printf("\n");
  //  gsl_matrix_fprintf (stdout, V, "%g"); cout<<"\n";
  pretty_print(V); printf("\n");
  gsl_vector_fprintf (stdout, S, "%g");

  gsl_matrix_free(V);
  gsl_vector_free(S);
  gsl_vector_free(work);
  
  return 0;
}
