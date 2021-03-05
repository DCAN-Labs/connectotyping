#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include <gsl/gsl_matrix_double.h>
#include <gsl/gsl_linalg.h>

#include "../include/calculate_svd_from_file.h"

int calculate_svd_from_file(char* fileName) {
  FILE *fp = fopen(fileName, "r");
  if (fp == NULL) {
    perror("Unable to open file!");

    exit(1);
  }

  char chunk[12961 + 80];

  const char s[2] = ",";
  int m = 0;
  int n = 0;
  while (fgets(chunk, sizeof(chunk), fp) != NULL) {
	n = 0;
    char *token;

    token = strtok(chunk, s);
    if (strlen(token) > 0) {
		n++;
	}
    while (token != NULL) {
       token = strtok(NULL, s);
       if (token != NULL) {
			n++;
		}
    }
    m++;
  }
  int i = 0;
  int j = 0;
  gsl_matrix *mat = gsl_matrix_alloc(m, n);
  while (fgets(chunk, sizeof(chunk), fp) != NULL) {
    char *token;

    token = strtok(chunk, s);
    while (token != NULL) {
		if (strlen(token) > 0) {
		   double x = atof(token);
		   gsl_matrix_set(mat, i, j, x);

		   j = (j + 1) % n;
		   if (j == 0) {
			 i = (i + 1) % m;
		   }
	   }

       token = strtok(NULL, s);
    }
  }

  clock_t start, end;
  double cpu_time_used;
  start = clock();
  int result = run_svd(mat);
  end = clock();
  cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
  printf("cpu_time_used: %f\n", cpu_time_used);

  fclose(fp);

  return result;
}
