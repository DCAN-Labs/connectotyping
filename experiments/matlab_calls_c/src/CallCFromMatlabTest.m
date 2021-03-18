classdef CallCFromMatlabTest < matlab.unittest.TestCase
    methods(Test)
        function matlabCallsCSvd(testCase)
            cA = [1.0, 0.0, 0.0, 0.0, 2.0, 0.0, 0.0, 3.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 0.0, 0.0, 0.0];
            mA = [1.0, 0.0, 0.0, 0.0, 2.0; 0.0, 0.0, 3.0, 0.0, 0.0; 0.0, 0.0, 0.0, 0.0, 0.0; 0.0, 2.0, 0.0, 0.0, 0.0];

            [expectedU, expectedS, expectedV] = svd(mA);
            [U, S, V] = gsl_svd(4, 5, cA);
            epsilon = 0.01;
            singularCount = 0;
            sIndex = 1;
            while abs(S(sIndex)) > epsilon
                singularCount = singularCount + 1;
                sIndex = sIndex + 1;
            end
            uSize = size(U);
            uRowCount = uSize(1);
            for row = 1 : uRowCount
                for col = 1 : singularCount
                    expSolution = expectedU(row, col);
                    actSolution = U(row, col);
                    testCase.verifyEqual(actSolution, expSolution,'AbsTol', epsilon)
                end
            end
            for col = 1 : singularCount
                expSolution = expectedS(col, col);
                actSolution = S(col);
                testCase.verifyEqual(actSolution, expSolution,'AbsTol', epsilon)
            end
            vSize = size(V);
            vRowCount = vSize(1);
            for row = 1 : vRowCount
                for col = 1 : singularCount
                    expSolution = expectedV(row, col);
                    actSolution = V(row, col);
                    testCase.verifyEqual(actSolution, expSolution,'AbsTol', epsilon)
                end
            end
        end
    end
end

