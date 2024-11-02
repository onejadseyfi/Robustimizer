% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
classdef TestParametersDefinition < matlab.unittest.TestCase
    properties
        params
    end
    
    methods(TestMethodSetup)
        function setup(test)
            test.params = ParametersDefinition();
        end
    end
    
    methods(Test)

        function testThatParametersDefinitionIsInitiallyEmpty(test)
            % Given the default ParametersDefinition object test.params
            % Then it should be empty
            test.verifyEmpty(test.params.designVariables);
            test.verifyEmpty(test.params.designRanges);
            test.verifyEmpty(test.params.noiseVariables);
            test.verifyEmpty(test.params.noiseRanges);
            test.verifyEmpty(test.params.names);
            test.verifyEmpty(test.params.ranges);
            test.verifyEqual(test.params.count, 0);
        end

        function testThatResizingTheVariablesAlsoResizesTheRanges(test)
            % Given the default ParametersDefinition object test.params
            % When the design variables are resized
            test.params.resizeDesignVariables(5);
            % Then the ranges are resized as well
            test.verifyEqual(height(test.params.designVariables), 5);
            test.verifyEqual(height(test.params.designRanges), 5);

            % Shrinking should also shrink the ranges
            test.params.resizeDesignVariables(2);
            test.verifyEqual(height(test.params.designVariables), 2);
            test.verifyEqual(height(test.params.designRanges), 2);
        end

        function testThatSettingTheDesignVariableNamesWorks(test)
            test.params.setDesignVariables(["foo"; "bar"; "baz"]);
            test.verifyEqual(test.params.designVariables, ["foo"; "bar"; "baz"]);
        end

        function testThatSettingTheDesignRangesWorks(test)
            test.params.setDesignRanges([0 1; 0 2; 0 3]);
            test.verifyEqual(test.params.designRanges, [0 1; 0 2; 0 3]);
        end

        function testThatDesignVariablesNamesAndRangesKeepEqualSize(test)
            % Grow to two variables by setting names
            test.params.setDesignVariables(["var1"; "var2"]);
            test.verifyEqual(test.params.names, ["var1"; "var2"]);
            test.verifyEqual(test.params.ranges, [0 1; 0 1]);

            % Grow to three variables by setting ranges
            test.params.setDesignRanges([0 1; 0 2; 0 3]);
            test.verifyEqual(height(test.params.names), 3);
            test.verifyEqual(height(test.params.ranges), 3);

            % Shrink to one variables by setting names
            test.params.setDesignVariables("design variable 1");
            test.verifyEqual(height(test.params.names), 1);
            test.verifyEqual(height(test.params.ranges), 1);
        end

        function testThatSettingNegativeDesignVariablesSizeResultsInError(test)
            test.verifyError(@()test.params.resizeDesignVariables(-1), "ParametersDefinition:InvalidSizeError");
        end

        function testThatSettingNegativeNoiseVariablesSizeResultsInError(test)
            test.verifyError(@()test.params.resizeNoiseVariables(-1), "ParametersDefinition:InvalidSizeError");
        end

        function testDependentPropertiesAreUpdated(test)
            % Given that the design and noise variables are defined
            test.params.setDesignVariables(["DV1"; "DV2"]);
            test.params.setDesignRanges([0 1; 0 2]);
            test.params.setNoiseVariables(["NV1"; "NV2"]);
            test.params.setNoiseRanges([1 1; 2 2]);

            % Then the dependent properties are updated and correct
            test.verifyEqual(test.params.count, 4);
            test.verifyEqual(test.params.names, ["DV1"; "DV2"; "NV1"; "NV2"]);
            test.verifyEqual(test.params.ranges, [0 1; 0 2; 1 1; 2 2]);
        end

        function testCanQueryForEmptyDesignRanges(test)
            % Given the non-empty design ranges
            test.params.setDesignRanges([0 1; 0 2]);
            % Then hasEmptyDesignRanges should return false
            test.verifyFalse(test.params.hasEmptyDesignRanges);

            % When one of the ranges is made empty
            test.params.setDesignRanges([0 1; 0 0]);
            % Then hasEmptyDesignRanges should return true
            test.verifyTrue(test.params.hasEmptyDesignRanges);
        end

        function testCanQueryForEmptyNoiseRanges(test)
            % Given the non-empty noise ranges
            test.params.setNoiseRanges([0 1; 0 2]);
            % Then hasEmptyNoiseRanges should return false
            test.verifyFalse(test.params.hasEmptyNoiseRanges);

            % When one of the ranges is made empty
            test.params.setNoiseRanges([0 1; 0 0]);
            % Then hasEmptyNoiseRanges should return true
            test.verifyTrue(test.params.hasEmptyNoiseRanges);
        end

        function testCanQueryForDesignIndicesInCombinedNames(test)
            % Given the design and noise variables
            test.params.setDesignVariables(["DV1"; "DV2"; "DV3"]);
            test.params.setNoiseVariables(["NV1"; "NV2"]);
            % Then the indices should be [1 2 3]
            test.verifyEqual(test.params.designIndices, [1 2 3]);
        end

        function testCanQueryForNoiseIndicesInCombinedNames(test)
            % Given the design and noise variables
            test.params.setDesignVariables(["DV1"; "DV2"; "DV3"]);
            test.params.setNoiseVariables(["NV1"; "NV2"]);
            % Then the indices should be [4 5]
            test.verifyEqual(test.params.noiseIndices, [4 5]);
        end

        function incompleteDesignRangesShouldBeDetected(test)
            % Given the design variables
            test.params.setDesignVariables(["DV1"; "DV2"; "DV3"]);
            % And the design ranges
            test.params.setDesignRanges([NaN NaN; 0 NaN; NaN 0]);
            % Then the incomplete range should be detected
            [errorRows, messages] = ParametersDefinition.validateDesignVariableRanges(test.params.designRanges, test.params.designVariables);
            test.verifyEqual(errorRows, [1; 2; 3]);
            test.verifyEqual(length(messages), 3);
        end

        function invalidDesignRangesShouldBeDetected(test)
            % Given the design variables
            test.params.setDesignVariables(["DV1"; "DV2"; "DV3"]);
            % And the design ranges
            test.params.setDesignRanges([0 1; 0 0; 0 -1]);
            % Then the empty range and upper < lower should be detected
            [errorRows, messages] = ParametersDefinition.validateDesignVariableRanges(test.params.designRanges, test.params.designVariables);
            test.verifyEqual(errorRows, [2; 3]);
            test.verifyEqual(length(messages), 2);
        end

        function incompleteNoiseRangesShouldBeDetected(test)
            % Given the noise variables
            test.params.setNoiseVariables(["NV1"; "NV2"; "NV3"]);
            % And the noise ranges
            test.params.setNoiseRanges([NaN NaN; 0 NaN; NaN 0]);
            % Then the incomplete range should be detected
            [errorRows, messages] = ParametersDefinition.validateNoiseVariableRanges(test.params.noiseRanges, test.params.noiseVariables);
            test.verifyEqual(errorRows, [1; 2; 3]);
            test.verifyEqual(length(messages), 3);
        end

        function invalidNoiseRangesShouldBeDetected(test)
            % Given the noise variables
            test.params.setNoiseVariables(["NV1"; "NV2"; "NV3"]);
            % And the noise ranges
            test.params.setNoiseRanges([0 1; 0 0; 0 -1]);
            % Then the empty range (= 0 stddev) and upper < lower (= negative stddev) should be detected
            [errorRows, messages] = ParametersDefinition.validateNoiseVariableRanges(test.params.noiseRanges, test.params.noiseVariables);
            test.verifyEqual(errorRows, [2; 3]);
            test.verifyEqual(length(messages), 2);
        end
    end
end