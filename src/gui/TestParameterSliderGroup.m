% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
% FILEPATH: /h:/code/robustimizer-internal/test/ParameterSliderGroupTest.m

classdef TestParameterSliderGroup < matlab.uitest.TestCase
    methods (Test)
        function test_changing_the_slider_state_is_reflected_in_the_ui(testCase)
            % Given
            [fig, sliderGroup] = ParameterSliderGroup.BuildTestComponent(5);

            % When changing the state of one of the sliders (arbitrarly the second one)
            sliderGroup.state(2).label = 'TestLabel';
            sliderGroup.state(2).value = 0.1;
            sliderGroup.state(2).range = [-10, 10];
            drawnow; % Force the UI to call the update function on sliderGroup

            % Then
            testCase.verifyEqual(sliderGroup.labels(2).Text, 'TestLabel');
            testCase.verifyEqual(sliderGroup.sliders(2).Value, 0.1);
            testCase.verifyEqual(sliderGroup.sliders(2).Limits, [-10, 10]);
            delete(fig);
        end

        function test_setting_the_slider_state_hidden_is_reflected_in_the_ui(testCase)
            % Given
            [fig, sliderGroup] = ParameterSliderGroup.BuildTestComponent(1);
            testCase.verifyEqual(sliderGroup.sliders(1).Visible, matlab.lang.OnOffSwitchState.on);

            % When
            sliderGroup.state(1).visible = false;
            drawnow; % Force the UI to call the update function on sliderGroup

            % Then
            testCase.verifyEqual(sliderGroup.sliders(1).Visible, matlab.lang.OnOffSwitchState.off);
            delete(fig);
        end

        function test_setting_the_slider_state_disabled_is_reflected_in_the_ui(testCase)
            % Given
            [fig, sliderGroup] = ParameterSliderGroup.BuildTestComponent(1);
            testCase.verifyEqual(sliderGroup.sliders(1).Enable, matlab.lang.OnOffSwitchState.on);

            % When
            sliderGroup.state(1).enabled = false;
            drawnow; % Force the UI to call the update function on sliderGroup

            % Then
            testCase.verifyEqual(sliderGroup.sliders(1).Enable, matlab.lang.OnOffSwitchState.off);
            delete(fig);
        end

        function test_changing_the_slider_in_the_ui_is_reflected_in_the_state(testCase)
            % Given
            [fig, sliderGroup] = ParameterSliderGroup.BuildTestComponent(1);
            drawnow; % Force the UI to call the update function on sliderGroup
            testCase.verifyNotEqual(sliderGroup.state(1).value, 0.9);

            % When
            testCase.choose(sliderGroup.sliders(1), 0.9);

            % Then
            testCase.verifyEqual(sliderGroup.state(1).value, 0.9);
            delete(fig);
        end

        function test_changing_the_slider_in_the_ui_triggers_the_callback(testCase)
            % Given
            [fig, sliderGroup] = ParameterSliderGroup.BuildTestComponent(3);
            sliderGroup.state(1).parameterId = 101;
            sliderGroup.state(2).parameterId = 102;
            sliderGroup.state(3).parameterId = 103;
            callbacksSeenForIds = [];
            function testCallback(src, event)
                testCase.verifyEqual(src, sliderGroup);
                testCase.verifyEqual(event.Id, int16(event.Index + 100));
                testCase.verifyEqual(event.Value, event.Index * 0.1, 'AbsTol', 1e-6);
                fprintf('Callback for %d, value = %d\n', event.Id, event.Value);
                callbacksSeenForIds = [callbacksSeenForIds, event.Id];
            end
            sliderGroup.SliderValueChangedFcn = @(src,event)testCallback(src, event);
            drawnow; % Force the UI to call the update function on sliderGroup

            % When
            testCase.choose(sliderGroup.sliders(1), 0.1);
            testCase.choose(sliderGroup.sliders(2), 0.2);
            testCase.choose(sliderGroup.sliders(3), 0.3);

            % Then
            testCase.verifyEqual(callbacksSeenForIds, [int16(101), int16(102), int16(103)]);
            delete(fig);
        end
    end
end