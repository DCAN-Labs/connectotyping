filename = '../../data/TC_in_1069_131072.csv';
A = readmatrix(filename);
[U,S,V] = svd(A,'econ');
