#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <unistd.h>
#include <sys/types.h>
#include <time.h>

#include <gsl/gsl_matrix_double.h>
#include <gsl/gsl_linalg.h>

#include "../include/calculate_svd_from_file.h"
#include "../include/calculate_svd_runtime.h"

int main(int argc, char *argv[]) {
  char* usage = "Usage: project [-f] [-t]";
  if (argc == 1 || (argc == 2 && strcmp(argv[1], "-h") == 0))
  {
      printf("%s\n", usage);

      return 0;
  }

  char* arg0 = argv[1];
  int tflag = strcmp(arg0, "-t") == 0 ? 1 : 0;
  int fflag = strcmp(arg0, "-f") == 0 ? 1 : 0;


  if (tflag)
  {
    calculate_svd_time();
  } else if (fflag) {
    calculate_svd_from_file();
  } else {
	  printf("Invalid option.\n");
	  
	  return 1;
  }

  return 0;
}
