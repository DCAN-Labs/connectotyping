mex -v -L/home/miran045/reine097/c-libs/lib/ -R2017b gsl_svd.c -lgsl -lgslcblas -lm
callCFromMatlabTests = matlab.unittest.TestSuite.fromClass(?CallCFromMatlabTest);
result = run(callCFromMatlabTests);
