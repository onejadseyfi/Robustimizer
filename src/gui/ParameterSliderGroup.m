% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
classdef ParameterSliderGroup < matlab.ui.componentcontainer.ComponentContainer
    % ParameterSliderGroup is a component class containing a grid of sliders with labels.
    % It represents a group of sliders, each of which corresponds to a parameter.
    %
    % The class is designed to be used in a MATLAB App Designer app, and provides a way to dynamically
    % create a group of sliders and their labels based on the provided slider states.
    % The sliders can be shown or hidden, enabled or disabled, and their values can be set or read.
    % The class also provides an event 'SliderValueChanged' that is triggered when a slider value changes.
    % This component provides a scrollable grid layout to accommodate a large number of sliders.
    properties(Access = public)
        state (:,1) ParameterSliderState    % The state of each slider in the group
    end

    properties(Access = ?matlab.unittest.TestCase, Transient, NonCopyable)
        grid matlab.ui.container.GridLayout
        labels matlab.ui.control.Label
        sliders matlab.ui.control.Slider
    end

    properties (Access = private)
        gridCapacity = 2; % Initial grid layout row count, will be increased as needed
    end

    events (HasCallbackProperty, NotifyAccess = protected)
        SliderValueChanged % Notify when a slider value changes
    end

    methods (Access = protected)
        function setup(comp)
            % Create a grid layout to hold the sliders and labels
            comp.grid = uigridlayout(comp, [comp.gridCapacity 2]);
            comp.grid.RowHeight = repmat( "fit", 1, comp.gridCapacity);
            comp.grid.ColumnWidth = {'fit', '1x'};
            %comp.grid.BackgroundColor = [1 1 1]; % White background
            comp.grid.Scrollable = 'on';

            % Add two empty sliders and labels to the grid, this improves the
            % initial display of the component in the App Designer
            comp.state = repmat(ParameterSliderState, 1, 2);
        end

        function update(comp)
            if length(comp.state) ~= length(comp.sliders) || ...
                length(comp.state) ~= length(comp.labels)
                error('ParameterSliderGroup:update', 'Number of sliders and labels does not match the number of states')
            end
            %fprintf('ParameterSliderGroup.update\n');
            for row = 1:length(comp.state)
                slider = comp.sliders(row);
                label = comp.labels(row);
                
                slider.Limits  = comp.state(row).range;
                slider.Value   = comp.state(row).value;
                slider.Visible = comp.state(row).visible;
                slider.Enable = comp.state(row).enabled;
                slider.ValueChangedFcn = @(~,~) comp.onSliderValueChanged(row);
                
                label.Text = comp.state(row).label;
                label.Visible  = comp.state(row).visible;
                label.Enable = comp.state(row).enabled;
            end
        end

        function syncGridRows(comp)
            nrDesired = length(comp.state);
            nrOfSliders = length(comp.sliders);
            delta = nrDesired - nrOfSliders;
            if delta > 0
                comp.addNSliders(delta);
            elseif delta < 0
                comp.removeLastNSliders(-delta);
            end
        end

        function addNSliders(comp, n)
            comp.increaseGridCapacityTo(length(comp.sliders) + n);
            for i = 1:n
                comp.addSlider();
            end
        end

        function addSlider(comp)
            row = length(comp.sliders) + 1;

            label = uilabel(comp.grid);
            label.HorizontalAlignment = 'right';
            label.Layout.Row = row;
            label.Layout.Column = 1;

            slider = uislider(comp.grid);
            slider.Layout.Row = row;
            slider.Layout.Column = 2;

            comp.labels(row) = label;
            comp.sliders(row) = slider;
        end

        function removeLastNSliders(comp, n)
            n = min(n, length(comp.sliders)); % Make sure we don't remove more sliders than we have
            for i = 1:n
                comp.labels(end).delete();
                comp.sliders(end).delete();
                comp.labels(end) = [];
                comp.sliders(end) = [];
            end
        end

        function increaseGridCapacityTo(comp, n)
            n = max(n, comp.gridCapacity); % Make sure we don't decrease capacity
            if n ~= comp.gridCapacity
                comp.gridCapacity = n;
                comp.grid.RowHeight = repmat( "fit", 1, comp.gridCapacity);
            end
        end

        function onSliderValueChanged(comp, i)
            comp.state(i).value = comp.sliders(i).Value;
            eventData = ParameterSliderEventData(i, comp.state(i).parameterId, comp.state(i).value);
            notify(comp, 'SliderValueChanged', eventData);
        end

    end

    methods
        function set.state(comp, value)
            comp.state = value;
            comp.syncGridRows();
        end
    end


    methods(Static)
        % Test function to display event data when a slider value changes
        function TestDisplayEventData(src, event)
            fprintf('ParameterSliderGroup event: %s\n', event.EventName);
            fprintf('  Slider index: %d\n', event.Index);
            fprintf('  Parameter id: %d\n', event.Id);
            fprintf('  Value: %f\n', event.Value);
        end
        function [f, g] = BuildTestComponent(nSliders)
            % Create a test component with 'nSliders' sliders. When a slider value changes, the
            % TestDisplayEventData function will be called to display the event data.
            f = uifigure;
            grid = uigridlayout(f, [1 1]);
            g = ParameterSliderGroup(grid);
            sliderStates = repmat(ParameterSliderState(), nSliders, 1);
            for i = 1:nSliders
                sliderStates(i).label = sprintf('Slider %d', i);
                sliderStates(i).parameterId = 100 + i;
                sliderStates(i).range = [0 1];
                sliderStates(i).value = i / nSliders;
                sliderStates(i).visible = true;
                sliderStates(i).enabled = true;
            end
            g.state = sliderStates;
            g.SliderValueChangedFcn = @(src,event)ParameterSliderGroup.TestDisplayEventData(src, event);
        end
    end
end
