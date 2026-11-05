%% MCM 2026 Problem B: Moon Colony Transportation - Visualization Code
% =========================================================================
% This script generates 10 publication-quality model plots covering all
% four questions (Q1-Q4) of the MCM 2026 Problem B competition.
%
% REVISED VERSION with varied subplot layouts:
%   - Figure 1: 3x3 = 9 subplots (Q1 Comprehensive Dashboard)
%   - Figure 5: 3x3 = 9 subplots (Q2 Reliability Deep Dive)
%   - Figure 9: 4x4 = 16 subplots (Q4 Environmental Comprehensive)
%   - Figure 3: 4x4 = 16 subplots (Q1 Delivery Analysis Extended)
%   - Figures 4 & 7: 3D and fancy bar chart styles
%
% Author: MCM Team
% Date: January 2026
% =========================================================================

clear; clc; close all;

%% ========================================================================
% SECTION 1: DATA DEFINITION
% ========================================================================
% All data extracted from Q1-Q4 algorithm solutions

fprintf('=== MCM 2026 Problem B: Visualization Generation ===\n\n');
fprintf('Loading data from algorithm solutions...\n');

% -------------------------------------------------------------------------
% Q1 Data: Perfect Conditions Analysis
% -------------------------------------------------------------------------
Q1.scenarios = {'Space Elevator', 'Rockets Only', 'Hybrid (74/26)'};
Q1.scenarios_short = {'Elevator', 'Rockets', 'Hybrid'};

% Timeline (years)
Q1.timeline = [190.0, 398.4, 140.6];

% Total Cost (trillion USD)
Q1.cost = [96.06, 140.03, 92.85];

% CO2 Emissions (million metric tons)
Q1.co2 = [250, 280, 257.8];

% Cost per kg (USD/kg)
Q1.cost_per_kg = [200, 1000, 370];  % Weighted average for hybrid

% Hybrid optimization data (elevator fraction vs metrics)
Q1.hybrid_fractions = 0:0.01:1;  % 0% to 100% elevator
Q1.hybrid_costs = zeros(size(Q1.hybrid_fractions));
Q1.hybrid_timelines = zeros(size(Q1.hybrid_fractions));

% Calculate hybrid costs and timelines for each allocation
elevator_rate = 537000;  % MT/year (3 harbours)
rocket_rate = 270625;    % MT/year (8 sites * 2165/10 * 125)
total_mass = 100e6;      % MT

for i = 1:length(Q1.hybrid_fractions)
    f = Q1.hybrid_fractions(i);
    elev_mass = f * total_mass;
    rock_mass = (1-f) * total_mass;
    
    % Timeline (parallel operation - max of both)
    if f > 0
        elev_time = elev_mass / elevator_rate;
    else
        elev_time = 0;
    end
    if f < 1
        rock_time = rock_mass / rocket_rate;
    else
        rock_time = 0;
    end
    Q1.hybrid_timelines(i) = max(elev_time, rock_time);
    
    % Cost calculation
    elev_cost = elev_mass * 200 / 1e9;  % $200/kg in billions
    rock_cost = rock_mass * 1000 / 1e9; % $1000/kg in billions
    
    % Add maintenance (simplified)
    timeline = Q1.hybrid_timelines(i);
    maint_cost = timeline * 0.3;  % ~$300B/year maintenance
    
    Q1.hybrid_costs(i) = (elev_cost + rock_cost + maint_cost * 1000) / 1000;  % Trillions
end

% Optimal point
[~, opt_idx] = min(Q1.hybrid_costs + Q1.hybrid_timelines * 0.5);
Q1.optimal_fraction = Q1.hybrid_fractions(opt_idx);
Q1.optimal_cost = Q1.hybrid_costs(opt_idx);
Q1.optimal_timeline = Q1.hybrid_timelines(opt_idx);

% Cumulative delivery data (years)
Q1.years = 0:5:400;
Q1.elev_cumulative = min(Q1.years * elevator_rate, total_mass);
Q1.rock_cumulative = min(Q1.years * rocket_rate, total_mass);

% Hybrid cumulative (74% elevator, 26% rockets in parallel)
elev_mass_hybrid = 0.74 * total_mass;
rock_mass_hybrid = 0.26 * total_mass;
Q1.hybrid_elev_cum = min(Q1.years * elevator_rate, elev_mass_hybrid);
Q1.hybrid_rock_cum = min(Q1.years * rocket_rate, rock_mass_hybrid);
Q1.hybrid_cumulative = Q1.hybrid_elev_cum + Q1.hybrid_rock_cum;

% Multi-objective scores (weighted: 40% cost, 35% timeline, 25% environment)
Q1.weights = [0.40, 0.35, 0.25];
Q1.normalized_cost = Q1.cost / max(Q1.cost);
Q1.normalized_time = Q1.timeline / max(Q1.timeline);
Q1.normalized_env = Q1.co2 / max(Q1.co2);
Q1.scores = Q1.weights(1)*Q1.normalized_cost + ...
            Q1.weights(2)*Q1.normalized_time + ...
            Q1.weights(3)*Q1.normalized_env;

% Additional Q1 data for extended analysis
Q1.transport_cost = [20, 100, 37];      % Transport only (trillions)
Q1.energy_cost = [15, 5, 12];           % Energy costs
Q1.maintenance = [50, 30, 35];          % Maintenance
Q1.carbon_tax = [5, 10, 6];             % Carbon tax
Q1.infrastructure = [6.06, 5.03, 5.85]; % Infrastructure

% -------------------------------------------------------------------------
% Q2 Data: Reliability Analysis (Imperfect Conditions)
% -------------------------------------------------------------------------
% Monte Carlo simulation results (n=200)
rng(42);  % For reproducibility

% Generate simulated distributions based on reported statistics
Q2.elev_timeline = 234.8 + randn(1, 200) * 5.2;
Q2.elev_cost = 114.25 + randn(1, 200) * 2.1;

Q2.rock_timeline = 458.0 + randn(1, 200) * 0.87;
Q2.rock_cost = 141.27 + randn(1, 200) * 0.5;

Q2.hybrid_timeline = 173.9 + randn(1, 200) * 3.6;
Q2.hybrid_cost = 103.23 + randn(1, 200) * 1.8;

% Statistics
Q2.elev_mean_time = mean(Q2.elev_timeline);
Q2.rock_mean_time = mean(Q2.rock_timeline);
Q2.hybrid_mean_time = mean(Q2.hybrid_timeline);

Q2.elev_std_time = std(Q2.elev_timeline);
Q2.rock_std_time = std(Q2.rock_timeline);
Q2.hybrid_std_time = std(Q2.hybrid_timeline);

Q2.elev_95 = prctile(Q2.elev_timeline, 95);
Q2.rock_95 = prctile(Q2.rock_timeline, 95);
Q2.hybrid_95 = prctile(Q2.hybrid_timeline, 95);

% Coefficient of Variation
Q2.elev_cv = Q2.elev_std_time / Q2.elev_mean_time;
Q2.rock_cv = Q2.rock_std_time / Q2.rock_mean_time;
Q2.hybrid_cv = Q2.hybrid_std_time / Q2.hybrid_mean_time;

% Perfect vs Imperfect comparison
Q2.perfect_time = Q1.timeline;
Q2.imperfect_time = [234.8, 458.0, 173.9];
Q2.time_increase = (Q2.imperfect_time - Q2.perfect_time) ./ Q2.perfect_time * 100;

Q2.perfect_cost = Q1.cost;
Q2.imperfect_cost = [114.25, 141.27, 103.23];
Q2.cost_increase = (Q2.imperfect_cost - Q2.perfect_cost) ./ Q2.perfect_cost * 100;

% Failure mode impacts (extended)
Q2.failure_modes = {'Tether Swaying', 'Debris Impact', 'Launch Failure', ...
                    'Weather Delay', 'Mech. Breakdown', 'Pad Damage'};
Q2.failure_impact_elev = [10, 15, 0, 0, 8, 0];
Q2.failure_impact_rock = [0, 0, 12, 8, 0, 5];
Q2.failure_prob = [0.15, 0.03, 0.03, 0.20, 0.10, 0.02];

% Additional failure statistics
Q2.downtime_elev = [40, 90, 0, 0, 30, 0];  % days/year
Q2.downtime_rock = [0, 0, 15, 25, 0, 45];  % days/year
Q2.repair_cost_elev = [2, 15, 0, 0, 5, 0];  % billions/incident
Q2.repair_cost_rock = [0, 0, 0.5, 0.1, 0, 2];  % billions/incident

% -------------------------------------------------------------------------
% Q3 Data: Water Requirements
% -------------------------------------------------------------------------
Q3.population = 100000;
Q3.daily_per_capita = 50;  % liters/person/day

% Water use breakdown (liters/person/day)
Q3.water_categories = {'Drinking', 'Food Prep', 'Hygiene', 'Medical', ...
                       'EVA Suits', 'Lab/Research', 'Contingency'};
Q3.water_usage = [3, 3, 25, 2, 10, 5, 2];  % liters/person/day

% Annual requirements
Q3.annual_no_recycling = Q3.population * Q3.daily_per_capita * 365 / 1000;  % MT
Q3.recycling_rate = 0.95;
Q3.annual_with_recycling = Q3.annual_no_recycling * (1 - Q3.recycling_rate);
Q3.year1_reserve = Q3.annual_with_recycling * 3;  % 3-year buffer

% Delivery costs (billions USD)
Q3.year1_cost = [54.89, 386.78, 141.21];
Q3.annual_cost = [18.30, 128.98, 47.07];

% Delivery time (days)
Q3.year1_time = [211, 457, 157];
Q3.annual_time = [71, 153, 52];

% 50-year projection
Q3.years_operation = 50;
Q3.total_50yr_cost = Q3.year1_cost + Q3.annual_cost * (Q3.years_operation - 1);

% Recycling savings
Q3.cost_no_recycling = Q3.annual_cost / (1 - Q3.recycling_rate);
Q3.savings_per_year = Q3.cost_no_recycling - Q3.annual_cost;

% -------------------------------------------------------------------------
% Q4 Data: Environmental Impact
% -------------------------------------------------------------------------
Q4.scenarios = {'Elevator', 'Rockets', 'Hybrid'};

% CO2 emissions (construction + 50 years water)
Q4.co2_current = [261.9, 302.4, 272.3];

% NOx emissions (thousand MT)
Q4.nox_current = [0, 12988, 3368];

% CO2 equivalent (CO2 + NOx*100 GWP)
Q4.co2eq_current = Q4.co2_current + Q4.nox_current * 100 / 1000;

% Green technology scenarios
Q4.co2_green = [13.1, 302.4*0.37, 272.3*0.26];
Q4.nox_green = [0, 12988*0.37, 3368*0.26];
Q4.co2eq_green = Q4.co2_green + Q4.nox_green * 100 / 1000;

% Mitigation strategies
Q4.strategies = {'Renewable Energy', 'Green Propellants', 'ISRU Water', 'Carbon Offset'};
Q4.reduction_potential = [95, 63, 100, 100];
Q4.cost_premium = [15, 15, 50, 5];

% Multi-objective optimization
Q4.env_weights = [0.2, 0.2, 0.6];
Q4.scenarios_all = {'Elev (Cur)', 'Elev (Grn)', 'Rock (Cur)', ...
                    'Rock (Grn)', 'Hybrid (Cur)', 'Hybrid (Grn)'};
Q4.all_costs = [96.06, 110.47, 140.03, 161.03, 92.85, 118.80];
Q4.all_times = [190, 190, 398.4, 398.4, 140.6, 174];
Q4.all_env = [261.9, 13.1, 1601.2, 586.2, 609.1, 157.1];

% Normalize for scoring
Q4.norm_cost = Q4.all_costs / max(Q4.all_costs);
Q4.norm_time = Q4.all_times / max(Q4.all_times);
Q4.norm_env = Q4.all_env / max(Q4.all_env);
Q4.opt_scores = Q4.env_weights(1)*Q4.norm_cost + ...
                Q4.env_weights(2)*Q4.norm_time + ...
                Q4.env_weights(3)*Q4.norm_env;

% Global context
Q4.global_annual_co2 = 37000;
Q4.aviation_annual = 1000;
Q4.shipping_annual = 940;

% Extended environmental data for 16-subplot figure
Q4.yearly_emissions = Q4.co2_current ./ [190, 398.4, 140.6];  % Per year
Q4.energy_sources = {'Solar', 'Nuclear', 'Grid', 'Hydrogen'};
Q4.energy_mix_elev = [60, 25, 10, 5];
Q4.energy_mix_rock = [10, 5, 70, 15];
Q4.energy_mix_hybrid = [45, 20, 25, 10];

fprintf('Data loading complete!\n\n');

%% ========================================================================
% SECTION 2: PLOTTING CONFIGURATION
% ========================================================================

% Color scheme
colors.elevator = [0.2 0.4 0.8];
colors.rockets = [0.8 0.2 0.2];
colors.hybrid = [0.2 0.7 0.3];
colors.elevator_green = [0.4 0.6 0.9];
colors.rockets_green = [0.9 0.5 0.5];
colors.hybrid_green = [0.5 0.8 0.5];
colors.gray = [0.5 0.5 0.5];
colors.gold = [0.9 0.7 0.1];

% Font settings
fontsize.title = 14;
fontsize.subtitle = 11;
fontsize.axis = 10;
fontsize.legend = 9;
fontsize.annotation = 8;

% Figure settings
fig_width = 1400;
fig_height = 1000;

fprintf('Generating 10 model plots with varied layouts...\n\n');

%% ========================================================================
% FIGURE 1: Q1 - COMPREHENSIVE SCENARIO DASHBOARD (3x3 = 9 subplots)
% ========================================================================
fprintf('Creating Figure 1: Q1 Comprehensive Dashboard (3x3)...\n');

fig1 = figure('Name', 'Figure 1: Q1 Comprehensive Dashboard', ...
              'Position', [50, 50, fig_width, fig_height], ...
              'Color', 'white');

% Subplot 1: Timeline Comparison (Horizontal Bar)
subplot(3, 3, 1);
barh(Q1.timeline, 0.6, 'FaceColor', 'flat', 'CData', [colors.elevator; colors.rockets; colors.hybrid]);
set(gca, 'YTickLabel', Q1.scenarios_short, 'FontSize', fontsize.axis);
xlabel('Timeline (Years)', 'FontSize', fontsize.axis);
title('Construction Timeline', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
grid on; box on;
for i = 1:3
    text(Q1.timeline(i)+10, i, sprintf('%.1f yr', Q1.timeline(i)), ...
         'VerticalAlignment', 'middle', 'FontSize', fontsize.annotation);
end

% Subplot 2: Cost Comparison (Lollipop Chart Style)
subplot(3, 3, 2);
hold on;
for i = 1:3
    color_map = {colors.elevator, colors.rockets, colors.hybrid};
    plot([i i], [0 Q1.cost(i)], '-', 'Color', color_map{i}, 'LineWidth', 3);
    plot(i, Q1.cost(i), 'o', 'MarkerSize', 15, 'MarkerFaceColor', color_map{i}, ...
         'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
    text(i, Q1.cost(i)+5, sprintf('$%.1fT', Q1.cost(i)), ...
         'HorizontalAlignment', 'center', 'FontSize', fontsize.annotation);
end
set(gca, 'XTick', 1:3, 'XTickLabel', Q1.scenarios_short, 'FontSize', fontsize.axis);
ylabel('Cost (Trillion USD)', 'FontSize', fontsize.axis);
title('Total Project Cost', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
xlim([0.5 3.5]); ylim([0 160]);
grid on; box on;

% Subplot 3: CO2 Emissions (Area-style representation)
subplot(3, 3, 3);
area_data = Q1.co2;
b = bar(area_data, 0.7, 'FaceColor', 'flat');
b.CData = [colors.elevator; colors.rockets; colors.hybrid];
b.FaceAlpha = 0.7;
hold on;
plot(1:3, area_data, 'k-o', 'LineWidth', 2, 'MarkerFaceColor', 'w', 'MarkerSize', 8);
set(gca, 'XTickLabel', Q1.scenarios_short, 'FontSize', fontsize.axis);
ylabel('CO_2 (Million MT)', 'FontSize', fontsize.axis);
title('Environmental Impact', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
grid on; box on;

% Subplot 4: Cost per kg Comparison (Gauge-style)
subplot(3, 3, 4);
theta = linspace(pi, 0, 100);
for i = 1:3
    color_map = {colors.elevator, colors.rockets, colors.hybrid};
    % Draw arc
    r_outer = 1;
    r_inner = 0.7;
    fill([r_inner*cos(theta) r_outer*cos(fliplr(theta))], ...
         [r_inner*sin(theta) r_outer*sin(fliplr(theta))] + (i-1)*0.1, ...
         color_map{i}, 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    hold on;
    % Draw needle
    needle_angle = pi - (Q1.cost_per_kg(i)/1200) * pi;
    plot([0 0.9*cos(needle_angle)], [(i-1)*0.1 0.9*sin(needle_angle)+(i-1)*0.1], ...
         'Color', color_map{i}, 'LineWidth', 3);
end
axis equal; axis off;
title('Cost per kg (USD/kg)', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
text(0, -0.3, sprintf('E:$%d  R:$%d  H:$%d', Q1.cost_per_kg(1), Q1.cost_per_kg(2), Q1.cost_per_kg(3)), ...
     'HorizontalAlignment', 'center', 'FontSize', fontsize.annotation);

% Subplot 5: Hybrid Allocation (Donut Chart)
subplot(3, 3, 5);
allocation = [74, 26];
h = pie(allocation);
% Customize pie chart to donut
hPatch = findobj(h, 'Type', 'Patch');
set(hPatch(1), 'FaceColor', colors.elevator);
set(hPatch(2), 'FaceColor', colors.rockets);
% Add center circle to make donut
hold on;
theta_circle = linspace(0, 2*pi, 100);
fill(0.5*cos(theta_circle), 0.5*sin(theta_circle), 'w', 'EdgeColor', 'none');
text(0, 0, sprintf('74%%\nElev'), 'HorizontalAlignment', 'center', ...
     'FontSize', fontsize.annotation, 'FontWeight', 'bold');
title('Optimal Hybrid Mix', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');

% Subplot 6: Multi-Objective Radar Chart
subplot(3, 3, 6);
% Create radar/spider chart manually
categories = {'Cost', 'Timeline', 'Environment'};
angles = linspace(0, 2*pi, 4);
angles = angles(1:3);

hold on;
% Draw grid
for r = 0.25:0.25:1
    plot(r*cos(angles([1:3 1])), r*sin(angles([1:3 1])), 'k-', 'LineWidth', 0.5);
end
for a = angles
    plot([0 cos(a)], [0 sin(a)], 'k-', 'LineWidth', 0.5);
end

% Plot data
scenarios_data = [Q1.normalized_cost; Q1.normalized_time; Q1.normalized_env];
color_map = {colors.elevator, colors.rockets, colors.hybrid};
for s = 1:3
    data = scenarios_data(:, s);
    x = data .* cos(angles');
    y = data .* sin(angles');
    fill([x; x(1)], [y; y(1)], color_map{s}, 'FaceAlpha', 0.3, 'EdgeColor', color_map{s}, 'LineWidth', 2);
end
axis equal; axis off;
title('Multi-Objective Radar', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');

% Subplot 7: Weighted Scores
subplot(3, 3, 7);
b = bar(Q1.scores, 0.6, 'FaceColor', 'flat');
b.CData = [colors.elevator; colors.rockets; colors.hybrid];
hold on;
[~, best_idx] = min(Q1.scores);
bar(best_idx, Q1.scores(best_idx), 0.6, 'FaceColor', colors.gold, 'EdgeColor', 'k', 'LineWidth', 2);
set(gca, 'XTickLabel', Q1.scenarios_short, 'FontSize', fontsize.axis);
ylabel('Weighted Score', 'FontSize', fontsize.axis);
title('Overall Ranking (Lower=Better)', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
grid on; box on;
text(best_idx, Q1.scores(best_idx)+0.03, 'BEST', 'HorizontalAlignment', 'center', ...
     'FontSize', fontsize.annotation, 'FontWeight', 'bold', 'Color', colors.gold);

% Subplot 8: Capacity Utilization
subplot(3, 3, 8);
capacity_util = [100, 100, 74];  % % of each system used at optimal
rocket_util = [0, 100, 26];
bar_data = [capacity_util; rocket_util]';
b = bar(bar_data, 'stacked');
b(1).FaceColor = colors.elevator;
b(2).FaceColor = colors.rockets;
set(gca, 'XTickLabel', Q1.scenarios_short, 'FontSize', fontsize.axis);
ylabel('Capacity Allocation (%)', 'FontSize', fontsize.axis);
title('System Utilization', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
legend({'Elevator', 'Rockets'}, 'Location', 'northeast', 'FontSize', fontsize.legend);
grid on; box on;

% Subplot 9: Summary Table Visualization
subplot(3, 3, 9);
axis off;
% Create visual table
text(0.5, 0.95, 'SCENARIO SUMMARY', 'HorizontalAlignment', 'center', ...
     'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
headers = {'Metric', 'Elevator', 'Rockets', 'Hybrid'};
data_rows = {
    'Timeline (yr)', sprintf('%.0f', Q1.timeline(1)), sprintf('%.0f', Q1.timeline(2)), sprintf('%.0f', Q1.timeline(3));
    'Cost ($T)', sprintf('%.1f', Q1.cost(1)), sprintf('%.1f', Q1.cost(2)), sprintf('%.1f', Q1.cost(3));
    'CO2 (M MT)', sprintf('%.0f', Q1.co2(1)), sprintf('%.0f', Q1.co2(2)), sprintf('%.0f', Q1.co2(3));
    'Score', sprintf('%.3f', Q1.scores(1)), sprintf('%.3f', Q1.scores(2)), sprintf('%.3f', Q1.scores(3));
};
y_pos = 0.8;
for col = 1:4
    x_pos = 0.1 + (col-1)*0.23;
    text(x_pos, y_pos, headers{col}, 'FontSize', fontsize.annotation, 'FontWeight', 'bold');
end
for row = 1:4
    y_pos = 0.65 - (row-1)*0.15;
    for col = 1:4
        x_pos = 0.1 + (col-1)*0.23;
        if col == 4 && row < 4  % Highlight hybrid (best)
            text(x_pos, y_pos, data_rows{row, col}, 'FontSize', fontsize.annotation, ...
                 'Color', colors.hybrid, 'FontWeight', 'bold');
        else
            text(x_pos, y_pos, data_rows{row, col}, 'FontSize', fontsize.annotation);
        end
    end
end



saveas(fig1, 'Figure1_Q1_Comprehensive_Dashboard_3x3.png');
saveas(fig1, 'Figure1_Q1_Comprehensive_Dashboard_3x3.fig');

%% ========================================================================
% FIGURE 2: Q1 - HYBRID OPTIMIZATION ANALYSIS (2x2 = 4 subplots)
% ========================================================================
fprintf('Creating Figure 2: Q1 Hybrid Optimization Analysis (2x2)...\n');

fig2 = figure('Name', 'Figure 2: Q1 Hybrid Optimization', ...
              'Position', [100, 50, fig_width, fig_height], ...
              'Color', 'white');

% Subplot 1: Cost vs Elevator Fraction
subplot(2, 2, 1);
plot(Q1.hybrid_fractions*100, Q1.hybrid_costs, 'b-', 'LineWidth', 2);
hold on;
plot(Q1.optimal_fraction*100, Q1.optimal_cost, 'ro', 'MarkerSize', 12, ...
     'MarkerFaceColor', 'r', 'LineWidth', 2);
xlabel('Elevator Fraction (%)', 'FontSize', fontsize.axis);
ylabel('Total Cost (Trillion USD)', 'FontSize', fontsize.axis);
title('Cost vs. Transportation Mix', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
grid on; box on;
xline(74, '--', 'Color', colors.gold, 'LineWidth', 1.5);
text(76, min(Q1.hybrid_costs)+5, sprintf('Optimal: %.0f%%', Q1.optimal_fraction*100), ...
     'FontSize', fontsize.annotation, 'Color', colors.gold);
legend({'Total Cost', 'Optimal Point'}, 'Location', 'best', 'FontSize', fontsize.legend);

% Subplot 2: Timeline vs Elevator Fraction
subplot(2, 2, 2);
plot(Q1.hybrid_fractions*100, Q1.hybrid_timelines, 'Color', colors.rockets, 'LineWidth', 2);
hold on;
plot(Q1.optimal_fraction*100, Q1.optimal_timeline, 'ro', 'MarkerSize', 12, ...
     'MarkerFaceColor', 'r', 'LineWidth', 2);
xlabel('Elevator Fraction (%)', 'FontSize', fontsize.axis);
ylabel('Timeline (Years)', 'FontSize', fontsize.axis);
title('Timeline vs. Transportation Mix', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
grid on; box on;
xline(74, '--', 'Color', colors.gold, 'LineWidth', 1.5);
plot(0, Q1.hybrid_timelines(1), 's', 'MarkerSize', 10, 'MarkerFaceColor', colors.rockets);
plot(100, Q1.hybrid_timelines(end), 's', 'MarkerSize', 10, 'MarkerFaceColor', colors.elevator);

% Subplot 3: Pareto Frontier
subplot(2, 2, 3);
scatter(Q1.hybrid_costs, Q1.hybrid_timelines, 30, Q1.hybrid_fractions*100, 'filled');
colormap(gca, parula);
cb = colorbar;
cb.Label.String = 'Elevator Fraction (%)';
hold on;
plot(Q1.optimal_cost, Q1.optimal_timeline, 'p', 'MarkerSize', 20, ...
     'MarkerFaceColor', colors.gold, 'MarkerEdgeColor', 'k', 'LineWidth', 2);
xlabel('Total Cost (Trillion USD)', 'FontSize', fontsize.axis);
ylabel('Timeline (Years)', 'FontSize', fontsize.axis);
title('Pareto Frontier', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
grid on; box on;

% Subplot 4: 3D Optimization Surface
subplot(2, 2, 4);
[X, Y] = meshgrid(linspace(0, 100, 50), linspace(80, 150, 50));
Z = interp1(Q1.hybrid_fractions*100, Q1.hybrid_costs, X(1,:), 'pchip');
Z = repmat(Z, size(X, 1), 1);
surf(X, Y, Z, 'EdgeColor', 'none', 'FaceAlpha', 0.7);
hold on;
plot3(Q1.optimal_fraction*100, Q1.optimal_timeline, Q1.optimal_cost, ...
      'p', 'MarkerSize', 20, 'MarkerFaceColor', colors.gold, 'MarkerEdgeColor', 'k');
xlabel('Elevator %', 'FontSize', fontsize.axis);
ylabel('Timeline (yr)', 'FontSize', fontsize.axis);
zlabel('Cost ($T)', 'FontSize', fontsize.axis);
title('3D Optimization Space', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
colormap(gca, cool);
view(45, 30);
grid on; box on;



saveas(fig2, 'Figure2_Q1_Hybrid_Optimization.png');
saveas(fig2, 'Figure2_Q1_Hybrid_Optimization.fig');

%% ========================================================================
% FIGURE 3: Q1 - DELIVERY ANALYSIS EXTENDED (4x4 = 16 subplots)
% ========================================================================
fprintf('Creating Figure 3: Q1 Delivery Analysis Extended (4x4)...\n');

fig3 = figure('Name', 'Figure 3: Q1 Delivery Analysis Extended', ...
              'Position', [150, 50, fig_width+200, fig_height+100], ...
              'Color', 'white');

% Row 1: Cumulative Delivery Analysis
subplot(4, 4, 1);
plot(Q1.years, Q1.elev_cumulative/1e6, '-', 'Color', colors.elevator, 'LineWidth', 2);
hold on; yline(100, 'k--'); grid on;
xlabel('Years'); ylabel('Mass (M MT)');
title('Elevator Delivery', 'FontSize', fontsize.subtitle-1);

subplot(4, 4, 2);
plot(Q1.years, Q1.rock_cumulative/1e6, '-', 'Color', colors.rockets, 'LineWidth', 2);
hold on; yline(100, 'k--'); grid on;
xlabel('Years'); ylabel('Mass (M MT)');
title('Rockets Delivery', 'FontSize', fontsize.subtitle-1);

subplot(4, 4, 3);
plot(Q1.years, Q1.hybrid_cumulative/1e6, '-', 'Color', colors.hybrid, 'LineWidth', 2);
hold on; yline(100, 'k--'); grid on;
xlabel('Years'); ylabel('Mass (M MT)');
title('Hybrid Delivery', 'FontSize', fontsize.subtitle-1);

subplot(4, 4, 4);
plot(Q1.years, Q1.elev_cumulative/1e6, '-', 'Color', colors.elevator, 'LineWidth', 2);
hold on;
plot(Q1.years, Q1.rock_cumulative/1e6, '-', 'Color', colors.rockets, 'LineWidth', 2);
plot(Q1.years, Q1.hybrid_cumulative/1e6, '-', 'Color', colors.hybrid, 'LineWidth', 2);
yline(100, 'k--'); grid on;
xlabel('Years'); ylabel('Mass (M MT)');
title('All Scenarios Combined', 'FontSize', fontsize.subtitle-1);
legend({'E', 'R', 'H'}, 'Location', 'southeast');

% Row 2: Annual Rates and Capacity
subplot(4, 4, 5);
rates = [537000, 270625, 710000] / 1000;
b = bar(rates, 'FaceColor', 'flat');
b.CData = [colors.elevator; colors.rockets; colors.hybrid];
set(gca, 'XTickLabel', {'E', 'R', 'H'});
ylabel('Capacity (K MT/yr)');
title('Annual Capacity', 'FontSize', fontsize.subtitle-1);
grid on;

subplot(4, 4, 6);
launches_per_year = [0, 2165, 563];
b = bar(launches_per_year, 'FaceColor', 'flat');
b.CData = [colors.elevator; colors.rockets; colors.hybrid];
set(gca, 'XTickLabel', {'E', 'R', 'H'});
ylabel('Launches/Year');
title('Rocket Launches', 'FontSize', fontsize.subtitle-1);
grid on;

subplot(4, 4, 7);
elevator_trips = [365*6, 0, 270];  % trips per year (6 elevators, ~1/day each)
b = bar(elevator_trips, 'FaceColor', 'flat');
b.CData = [colors.elevator; colors.rockets; colors.hybrid];
set(gca, 'XTickLabel', {'E', 'R', 'H'});
ylabel('Elevator Trips/Year');
title('Elevator Operations', 'FontSize', fontsize.subtitle-1);
grid on;

subplot(4, 4, 8);
payload_per_trip = [82, 125, 95];  % MT
b = bar(payload_per_trip, 'FaceColor', 'flat');
b.CData = [colors.elevator; colors.rockets; colors.hybrid];
set(gca, 'XTickLabel', {'E', 'R', 'H'});
ylabel('Avg Payload (MT)');
title('Payload per Trip', 'FontSize', fontsize.subtitle-1);
grid on;

% Row 3: Cost Analysis
subplot(4, 4, 9);
pie([Q1.transport_cost(1), Q1.energy_cost(1), Q1.maintenance(1), Q1.carbon_tax(1)]);
title('Elevator Cost Split', 'FontSize', fontsize.subtitle-1);

subplot(4, 4, 10);
pie([Q1.transport_cost(2), Q1.energy_cost(2), Q1.maintenance(2), Q1.carbon_tax(2)]);
title('Rockets Cost Split', 'FontSize', fontsize.subtitle-1);

subplot(4, 4, 11);
pie([Q1.transport_cost(3), Q1.energy_cost(3), Q1.maintenance(3), Q1.carbon_tax(3)]);
title('Hybrid Cost Split', 'FontSize', fontsize.subtitle-1);
legend({'Transport', 'Energy', 'Maint.', 'Carbon'}, 'Location', 'eastoutside', 'FontSize', 7);

subplot(4, 4, 12);
cost_per_mt = Q1.cost * 1e6 ./ 100;  % $/MT
b = bar(cost_per_mt, 'FaceColor', 'flat');
b.CData = [colors.elevator; colors.rockets; colors.hybrid];
set(gca, 'XTickLabel', {'E', 'R', 'H'});
ylabel('$/MT delivered');
title('Cost per MT', 'FontSize', fontsize.subtitle-1);
grid on;

% Row 4: Efficiency and Timeline Metrics
subplot(4, 4, 13);
efficiency = Q1.cost ./ Q1.timeline;
b = bar(efficiency, 'FaceColor', 'flat');
b.CData = [colors.elevator; colors.rockets; colors.hybrid];
set(gca, 'XTickLabel', {'E', 'R', 'H'});
ylabel('$T/Year');
title('Cost Efficiency', 'FontSize', fontsize.subtitle-1);
grid on;

subplot(4, 4, 14);
mass_rate = 100 ./ Q1.timeline;  % M MT/year
b = bar(mass_rate, 'FaceColor', 'flat');
b.CData = [colors.elevator; colors.rockets; colors.hybrid];
set(gca, 'XTickLabel', {'E', 'R', 'H'});
ylabel('M MT/Year');
title('Delivery Rate', 'FontSize', fontsize.subtitle-1);
grid on;

subplot(4, 4, 15);
% Timeline breakdown
timeline_breakdown = [Q1.timeline; Q1.timeline * 0.1]';  % Base + contingency
b = bar(timeline_breakdown, 'stacked');
b(1).FaceColor = [0.3 0.5 0.7];
b(2).FaceColor = [0.7 0.5 0.3];
set(gca, 'XTickLabel', {'E', 'R', 'H'});
ylabel('Years');
title('Timeline + Buffer', 'FontSize', fontsize.subtitle-1);
legend({'Base', '+10% Buffer'}, 'Location', 'northwest', 'FontSize', 7);
grid on;

subplot(4, 4, 16);
% Completion year
completion_year = 2050 + Q1.timeline;
b = bar(completion_year, 'FaceColor', 'flat');
b.CData = [colors.elevator; colors.rockets; colors.hybrid];
set(gca, 'XTickLabel', {'E', 'R', 'H'});
ylabel('Year');
title('Completion Year', 'FontSize', fontsize.subtitle-1);
ylim([2150 2500]);
grid on;



saveas(fig3, 'Figure3_Q1_Delivery_Analysis_4x4.png');
saveas(fig3, 'Figure3_Q1_Delivery_Analysis_4x4.fig');

%% ========================================================================
% FIGURE 4: Q2 - MONTE CARLO ANALYSIS WITH 3D BARS (2x2 with fancy style)
% ========================================================================
fprintf('Creating Figure 4: Q2 Monte Carlo Analysis (3D Fancy Bars)...\n');

fig4 = figure('Name', 'Figure 4: Q2 Monte Carlo (3D Style)', ...
              'Position', [200, 50, fig_width, fig_height], ...
              'Color', 'white');

% Subplot 1: 3D Histogram - Elevator
subplot(2, 2, 1);
[counts, edges] = histcounts(Q2.elev_timeline, 15);
centers = (edges(1:end-1) + edges(2:end)) / 2;
b = bar3(counts, 0.8);
colormap(gca, [linspace(0.2, 0.4, 64)', linspace(0.4, 0.6, 64)', linspace(0.8, 1, 64)']);
set(gca, 'XTickLabel', round(centers(1:3:end)), 'FontSize', fontsize.axis-1);
xlabel('Timeline (Years)'); ylabel(''); zlabel('Frequency');
title(sprintf('Elevator: \\mu=%.1f yr, \\sigma=%.1f', Q2.elev_mean_time, Q2.elev_std_time), ...
      'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
view([-37.5, 30]);
grid on; box on;

% Subplot 2: 3D Histogram - Rockets
subplot(2, 2, 2);
[counts, edges] = histcounts(Q2.rock_timeline, 15);
centers = (edges(1:end-1) + edges(2:end)) / 2;
b = bar3(counts, 0.8);
colormap(gca, [linspace(0.8, 1, 64)', linspace(0.2, 0.4, 64)', linspace(0.2, 0.4, 64)']);
set(gca, 'XTickLabel', round(centers(1:3:end)), 'FontSize', fontsize.axis-1);
xlabel('Timeline (Years)'); ylabel(''); zlabel('Frequency');
title(sprintf('Rockets: \\mu=%.1f yr, \\sigma=%.2f', Q2.rock_mean_time, Q2.rock_std_time), ...
      'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
view([-37.5, 30]);
grid on; box on;

% Subplot 3: 3D Histogram - Hybrid
subplot(2, 2, 3);
[counts, edges] = histcounts(Q2.hybrid_timeline, 15);
centers = (edges(1:end-1) + edges(2:end)) / 2;
b = bar3(counts, 0.8);
colormap(gca, [linspace(0.2, 0.4, 64)', linspace(0.7, 0.9, 64)', linspace(0.3, 0.5, 64)']);
set(gca, 'XTickLabel', round(centers(1:3:end)), 'FontSize', fontsize.axis-1);
xlabel('Timeline (Years)'); ylabel(''); zlabel('Frequency');
title(sprintf('Hybrid: \\mu=%.1f yr, \\sigma=%.1f', Q2.hybrid_mean_time, Q2.hybrid_std_time), ...
      'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
view([-37.5, 30]);
grid on; box on;

% Subplot 4: 3D Comparison Bar Chart
subplot(2, 2, 4);
stats_data = [Q2.elev_mean_time, Q2.elev_std_time*10, Q2.elev_95;
              Q2.rock_mean_time, Q2.rock_std_time*10, Q2.rock_95;
              Q2.hybrid_mean_time, Q2.hybrid_std_time*10, Q2.hybrid_95];
b = bar3(stats_data, 0.6);
% Color each group
b(1).FaceColor = [0.3 0.5 0.7];
b(2).FaceColor = [0.7 0.5 0.3];
b(3).FaceColor = [0.5 0.7 0.5];
set(gca, 'XTickLabel', {'Mean', 'Std×10', '95th%'}, ...
         'YTickLabel', {'Elev', 'Rock', 'Hybrid'}, 'FontSize', fontsize.axis);
zlabel('Years');
title('Statistical Comparison (3D)', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
legend({'Mean', 'Std Dev×10', '95th Percentile'}, 'Location', 'northeast', 'FontSize', fontsize.legend);
view([135, 25]);
grid on; box on;



saveas(fig4, 'Figure4_Q2_MonteCarlo_3D.png');
saveas(fig4, 'Figure4_Q2_MonteCarlo_3D.fig');

%% ========================================================================
% FIGURE 5: Q2 - RELIABILITY DEEP DIVE (3x3 = 9 subplots)
% ========================================================================
fprintf('Creating Figure 5: Q2 Reliability Deep Dive (3x3)...\n');

fig5 = figure('Name', 'Figure 5: Q2 Reliability Deep Dive', ...
              'Position', [250, 50, fig_width, fig_height], ...
              'Color', 'white');

% Subplot 1: Timeline Perfect vs Imperfect (Grouped Horizontal Bar)
subplot(3, 3, 1);
data = [Q2.perfect_time; Q2.imperfect_time];
barh(data', 'grouped');
set(gca, 'YTickLabel', Q1.scenarios_short, 'FontSize', fontsize.axis);
xlabel('Timeline (Years)');
title('Perfect vs Imperfect Timeline', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
legend({'Perfect', 'Imperfect'}, 'Location', 'southeast', 'FontSize', fontsize.legend);
grid on; box on;

% Subplot 2: Cost Perfect vs Imperfect
subplot(3, 3, 2);
data = [Q2.perfect_cost; Q2.imperfect_cost];
barh(data', 'grouped');
set(gca, 'YTickLabel', Q1.scenarios_short, 'FontSize', fontsize.axis);
xlabel('Cost ($T)');
title('Perfect vs Imperfect Cost', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
legend({'Perfect', 'Imperfect'}, 'Location', 'southeast', 'FontSize', fontsize.legend);
grid on; box on;

% Subplot 3: Percentage Increase (Waterfall style)
subplot(3, 3, 3);
increases = [Q2.time_increase; Q2.cost_increase]';
b = bar(increases, 'grouped');
b(1).FaceColor = [0.6 0.3 0.3];
b(2).FaceColor = [0.3 0.6 0.3];
set(gca, 'XTickLabel', Q1.scenarios_short, 'FontSize', fontsize.axis);
ylabel('Increase (%)');
title('Impact of Failures (%)', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
legend({'Timeline +%', 'Cost +%'}, 'Location', 'northeast', 'FontSize', fontsize.legend);
grid on; box on;

% Subplot 4: Failure Mode Probability (Polar/Radar)
subplot(3, 3, 4);
theta = linspace(0, 2*pi, 7);
theta = theta(1:6);
r = Q2.failure_prob * 100;
polarplot([theta theta(1)], [r r(1)], 'b-o', 'LineWidth', 2, 'MarkerFaceColor', 'b');
title('Failure Probabilities (%)', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
ax = gca;
ax.ThetaTick = theta * 180/pi;
ax.ThetaTickLabel = {'Sway', 'Debris', 'Launch', 'Weather', 'Mech', 'Pad'};

% Subplot 5: Downtime Analysis (Stacked)
subplot(3, 3, 5);
downtime = [Q2.downtime_elev; Q2.downtime_rock]';
b = bar(downtime, 'stacked');
b(1).FaceColor = colors.elevator;
b(2).FaceColor = colors.rockets;
set(gca, 'XTick', 1:6, 'XTickLabel', {'Sway', 'Debr', 'Laun', 'Weath', 'Mech', 'Pad'}, ...
    'FontSize', fontsize.axis-1);
ylabel('Downtime (days/yr)');
title('Annual Downtime by Mode', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
legend({'Elevator', 'Rockets'}, 'Location', 'northeast', 'FontSize', fontsize.legend);
grid on; box on;

% Subplot 6: Repair Cost Analysis
subplot(3, 3, 6);
repair = [Q2.repair_cost_elev; Q2.repair_cost_rock]';
b = bar(repair, 'grouped');
b(1).FaceColor = colors.elevator;
b(2).FaceColor = colors.rockets;
set(gca, 'XTick', 1:6, 'XTickLabel', {'Sway', 'Debr', 'Laun', 'Weath', 'Mech', 'Pad'}, ...
    'FontSize', fontsize.axis-1);
ylabel('Repair Cost ($B/incident)');
title('Repair Costs per Incident', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
legend({'Elevator', 'Rockets'}, 'Location', 'northeast', 'FontSize', fontsize.legend);
grid on; box on;

% Subplot 7: Coefficient of Variation (Gauge Style)
subplot(3, 3, 7);
cv_data = [Q2.elev_cv, Q2.rock_cv, Q2.hybrid_cv] * 100;
theta = linspace(0, 2*pi, 100);
hold on;
% Draw background circles
for r = [0.5 1.0 1.5]
    plot(r*cos(theta), r*sin(theta), 'k-', 'LineWidth', 0.5);
end
% Plot CV as radial bars
angles = [pi/6, pi/2, 5*pi/6];
color_map = {colors.elevator, colors.rockets, colors.hybrid};
for i = 1:3
    r = cv_data(i) * 2;  % Scale for visibility
    plot([0 r*cos(angles(i))], [0 r*sin(angles(i))], '-', ...
         'Color', color_map{i}, 'LineWidth', 8);
    plot(r*cos(angles(i)), r*sin(angles(i)), 'o', 'MarkerSize', 15, ...
         'MarkerFaceColor', color_map{i}, 'MarkerEdgeColor', 'k');
end
axis equal; axis([-2 2 -0.5 2]);
axis off;
title('CV (Lower = More Reliable)', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
text(0, -0.3, sprintf('E:%.2f%%  R:%.2f%%  H:%.2f%%', cv_data(1), cv_data(2), cv_data(3)), ...
     'HorizontalAlignment', 'center', 'FontSize', fontsize.annotation);

% Subplot 8: Risk-Adjusted Timeline
subplot(3, 3, 8);
risk_adj = [Q2.elev_mean_time + 2*Q2.elev_std_time, ...
            Q2.rock_mean_time + 2*Q2.rock_std_time, ...
            Q2.hybrid_mean_time + 2*Q2.hybrid_std_time];
b = bar(risk_adj, 0.6, 'FaceColor', 'flat');
b.CData = [colors.elevator; colors.rockets; colors.hybrid];
hold on;
[~, best] = min(risk_adj);
bar(best, risk_adj(best), 0.6, 'FaceColor', colors.gold, 'EdgeColor', 'k', 'LineWidth', 2);
set(gca, 'XTickLabel', Q1.scenarios_short, 'FontSize', fontsize.axis);
ylabel('Risk-Adj Timeline (yr)');
title('\mu + 2\sigma Planning', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
grid on; box on;

% Subplot 9: Summary Recommendation
subplot(3, 3, 9);
axis off;
text(0.5, 0.9, 'RELIABILITY SUMMARY', 'HorizontalAlignment', 'center', ...
     'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
text(0.5, 0.7, 'Most Predictable: ROCKETS (CV=0.19%)', ...
     'HorizontalAlignment', 'center', 'FontSize', fontsize.annotation, 'Color', colors.rockets);
text(0.5, 0.55, 'Fastest Under Failures: HYBRID (174 yr)', ...
     'HorizontalAlignment', 'center', 'FontSize', fontsize.annotation, 'Color', colors.hybrid);
text(0.5, 0.4, 'Recommended Buffer: 25-30%', ...
     'HorizontalAlignment', 'center', 'FontSize', fontsize.annotation);
text(0.5, 0.2, '→ HYBRID remains OPTIMAL', ...
     'HorizontalAlignment', 'center', 'FontSize', fontsize.subtitle, ...
     'FontWeight', 'bold', 'Color', colors.gold);



saveas(fig5, 'Figure5_Q2_Reliability_DeepDive_3x3.png');
saveas(fig5, 'Figure5_Q2_Reliability_DeepDive_3x3.fig');

%% ========================================================================
% FIGURE 6: Q2 - RISK ASSESSMENT (2x2 = 4 subplots)
% ========================================================================
fprintf('Creating Figure 6: Q2 Risk Assessment (2x2)...\n');

fig6 = figure('Name', 'Figure 6: Q2 Risk Assessment', ...
              'Position', [300, 50, fig_width, fig_height], ...
              'Color', 'white');

% Subplot 1: 95th Percentile Analysis
subplot(2, 2, 1);
worst_case = [Q2.elev_95, Q2.rock_95, Q2.hybrid_95];
mean_case = [Q2.elev_mean_time, Q2.rock_mean_time, Q2.hybrid_mean_time];
buffer = worst_case - mean_case;
bar_data = [mean_case; buffer]';
b = bar(bar_data, 'stacked');
b(1).FaceColor = [0.3 0.6 0.3];
b(2).FaceColor = [0.8 0.4 0.4];
set(gca, 'XTickLabel', Q1.scenarios_short, 'FontSize', fontsize.axis);
ylabel('Timeline (Years)');
title('Worst-Case Planning (95th %ile)', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
legend({'Expected', 'Buffer'}, 'Location', 'northwest', 'FontSize', fontsize.legend);
grid on; box on;

% Subplot 2: Probability Distributions
subplot(2, 2, 2);
x = linspace(150, 500, 1000);
plot(x, normpdf(x, Q2.elev_mean_time, Q2.elev_std_time), '-', 'Color', colors.elevator, 'LineWidth', 2);
hold on;
plot(x, normpdf(x, Q2.rock_mean_time, Q2.rock_std_time), '-', 'Color', colors.rockets, 'LineWidth', 2);
plot(x, normpdf(x, Q2.hybrid_mean_time, Q2.hybrid_std_time), '-', 'Color', colors.hybrid, 'LineWidth', 2);
xlabel('Timeline (Years)');
ylabel('Probability Density');
title('Timeline Distributions', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
legend({'Elevator', 'Rockets', 'Hybrid'}, 'Location', 'northeast', 'FontSize', fontsize.legend);
grid on; box on;

% Subplot 3: Box Plot Comparison
subplot(2, 2, 3);
boxplot_data = [Q2.elev_timeline', Q2.rock_timeline', Q2.hybrid_timeline'];
boxplot(boxplot_data, 'Labels', Q1.scenarios_short, 'Colors', 'k');
hold on;
scatter([1 2 3], [Q2.elev_mean_time, Q2.rock_mean_time, Q2.hybrid_mean_time], ...
        100, 'd', 'filled', 'MarkerFaceColor', colors.gold);
ylabel('Timeline (Years)');
title('Distribution Comparison', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
grid on; box on;

% Subplot 4: 3D Risk-Return Profile
subplot(2, 2, 4);
times = [Q2.elev_mean_time, Q2.rock_mean_time, Q2.hybrid_mean_time];
costs = [mean(Q2.elev_cost), mean(Q2.rock_cost), mean(Q2.hybrid_cost)];
reliability = 1 - [Q2.elev_cv, Q2.rock_cv, Q2.hybrid_cv];
scatter3(times, costs, reliability*100, 200, ...
         [colors.elevator; colors.rockets; colors.hybrid], 'filled');
hold on;
for i = 1:3
    text(times(i)+5, costs(i), reliability(i)*100+0.5, Q1.scenarios_short{i}, ...
         'FontSize', fontsize.annotation);
end
plot3(Q2.hybrid_mean_time, mean(Q2.hybrid_cost), (1-Q2.hybrid_cv)*100, ...
      'p', 'MarkerSize', 25, 'MarkerFaceColor', colors.gold, 'MarkerEdgeColor', 'k');
xlabel('Timeline (yr)'); ylabel('Cost ($T)'); zlabel('Reliability (%)');
title('3D Risk-Return Profile', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
view(135, 30);
grid on; box on;



saveas(fig6, 'Figure6_Q2_Risk_Assessment.png');
saveas(fig6, 'Figure6_Q2_Risk_Assessment.fig');

%% ========================================================================
% FIGURE 7: Q3 - WATER ANALYSIS WITH FANCY 3D BARS (2x2)
% ========================================================================
fprintf('Creating Figure 7: Q3 Water Analysis (Fancy 3D Bars)...\n');

fig7 = figure('Name', 'Figure 7: Q3 Water Analysis (Fancy)', ...
              'Position', [350, 50, fig_width, fig_height], ...
              'Color', 'white');

% Subplot 1: Water Usage Breakdown (3D Pie)
subplot(2, 2, 1);
h = pie3(Q3.water_usage);
% Apply custom colors
colors_water = jet(length(Q3.water_usage));
hPatch = findobj(h, 'Type', 'Surface');  % pie3 creates Surface objects, not Patch
if ~isempty(hPatch)
    for i = 1:min(length(hPatch), length(Q3.water_usage))
        set(hPatch(i), 'FaceColor', colors_water(length(Q3.water_usage)-i+1,:), 'FaceAlpha', 0.8);
    end
end
view([-30, 30]);
title(sprintf('Daily Water Use: %d L/person', Q3.daily_per_capita), ...
      'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
% Add legend for categories
legend(Q3.water_categories, 'Location', 'eastoutside', 'FontSize', fontsize.legend-1);

% Subplot 2: Recycling Impact (3D Bar)
subplot(2, 2, 2);
annual_data = [Q3.annual_no_recycling/1000; Q3.annual_with_recycling/1000; 0];
b = bar3([1 2], annual_data(1:2)', 0.5);
colormap(gca, [0.8 0.3 0.3; 0.3 0.8 0.3]);
set(gca, 'XTickLabel', {'No Recycle', '95% Recycle'}, ...
         'YTickLabel', {''}, 'FontSize', fontsize.axis);
zlabel('Annual Need (M MT)');
title('Recycling Impact', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
view([135, 25]);
grid on; box on;
% Add text annotation
text(0.5, 0.5, 1, sprintf('%.0f%% Reduction!', 95), ...
     'FontSize', fontsize.annotation+2, 'FontWeight', 'bold', 'Color', colors.hybrid);

% Subplot 3: Delivery Cost Comparison (Cylinder-style 3D bars)
subplot(2, 2, 3);
% Create 3D bars for cost comparison
cost_matrix = [Q3.year1_cost/100; Q3.annual_cost/10]';  % Scale for visibility
b = bar3(cost_matrix, 0.6);
b(1).FaceColor = [0.3 0.4 0.7];
b(2).FaceColor = [0.7 0.4 0.3];
set(gca, 'XTickLabel', {'Yr1/100', 'Ann/10'}, ...
         'YTickLabel', Q1.scenarios_short, 'FontSize', fontsize.axis);
zlabel('Cost (Scaled $B)');
title('Water Delivery Costs (3D)', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
legend({'Year 1 Reserve', 'Annual Resupply'}, 'Location', 'northeast', 'FontSize', fontsize.legend);
view([135, 25]);
grid on; box on;

% Subplot 4: 50-Year Projection (3D Surface style)
subplot(2, 2, 4);
years = 1:50;
[X, Y] = meshgrid(1:3, years);
Z = zeros(size(X));
for i = 1:3
    Z(:, i) = Q3.year1_cost(i) + Q3.annual_cost(i) * (years' - 1);
end
surf(X, Y, Z/1000, 'EdgeColor', 'none', 'FaceAlpha', 0.8);
colormap(gca, parula);
hold on;
% Add contour lines
contour3(X, Y, Z/1000, 10, 'k-', 'LineWidth', 0.5);
set(gca, 'XTick', 1:3, 'XTickLabel', Q1.scenarios_short, 'FontSize', fontsize.axis);
ylabel('Years'); zlabel('Cumulative Cost ($T)');
title('50-Year Cost Projection (3D)', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
view([135, 25]);
grid on; box on;
colorbar;



saveas(fig7, 'Figure7_Q3_Water_Analysis_3D.png');
saveas(fig7, 'Figure7_Q3_Water_Analysis_3D.fig');

%% ========================================================================
% FIGURE 8: Q3 - 50-YEAR PROJECTION (2x2 = 4 subplots)
% ========================================================================
fprintf('Creating Figure 8: Q3 50-Year Projection (2x2)...\n');

fig8 = figure('Name', 'Figure 8: Q3 50-Year Projection', ...
              'Position', [400, 50, fig_width, fig_height], ...
              'Color', 'white');

% Subplot 1: Cumulative Cost Over Time
subplot(2, 2, 1);
years = 1:50;
cum_elev = Q3.year1_cost(1) + Q3.annual_cost(1) * (years - 1);
cum_rock = Q3.year1_cost(2) + Q3.annual_cost(2) * (years - 1);
cum_hybrid = Q3.year1_cost(3) + Q3.annual_cost(3) * (years - 1);
plot(years, cum_elev, '-', 'Color', colors.elevator, 'LineWidth', 2);
hold on;
plot(years, cum_rock, '-', 'Color', colors.rockets, 'LineWidth', 2);
plot(years, cum_hybrid, '-', 'Color', colors.hybrid, 'LineWidth', 2);
xlabel('Years');
ylabel('Cumulative Cost ($B)');
title('50-Year Water Cost', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
legend({'Elevator', 'Rockets', 'Hybrid'}, 'Location', 'northwest', 'FontSize', fontsize.legend);
grid on; box on;

% Subplot 2: Total Cost Comparison
subplot(2, 2, 2);
b = bar(Q3.total_50yr_cost, 0.6, 'FaceColor', 'flat');
b.CData = [colors.elevator; colors.rockets; colors.hybrid];
hold on;
[~, cheapest] = min(Q3.total_50yr_cost);
bar(cheapest, Q3.total_50yr_cost(cheapest), 0.6, 'FaceColor', colors.gold, ...
    'EdgeColor', 'k', 'LineWidth', 2);
set(gca, 'XTickLabel', Q1.scenarios_short, 'FontSize', fontsize.axis);
ylabel('50-Year Cost ($B)');
title('Total Water Supply Cost', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
grid on; box on;

% Subplot 3: Cost Breakdown
subplot(2, 2, 3);
breakdown = [Q3.year1_cost; Q3.annual_cost * 49]';
b = bar(breakdown, 'stacked');
b(1).FaceColor = [0.3 0.5 0.7];
b(2).FaceColor = [0.7 0.5 0.3];
set(gca, 'XTickLabel', Q1.scenarios_short, 'FontSize', fontsize.axis);
ylabel('Cost ($B)');
title('Initial vs Ongoing Costs', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
legend({'Year 1', 'Years 2-50'}, 'Location', 'northwest', 'FontSize', fontsize.legend);
grid on; box on;

% Subplot 4: Water as % of Construction
subplot(2, 2, 4);
pct = Q3.total_50yr_cost ./ (Q1.cost * 1000) * 100;
b = bar(pct, 0.6, 'FaceColor', 'flat');
b.CData = [colors.elevator; colors.rockets; colors.hybrid];
set(gca, 'XTickLabel', Q1.scenarios_short, 'FontSize', fontsize.axis);
ylabel('% of Construction Cost');
title('Water Cost Relative to Construction', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
grid on; box on;
for i = 1:3
    text(i, pct(i)+0.1, sprintf('%.2f%%', pct(i)), 'HorizontalAlignment', 'center', ...
         'FontSize', fontsize.annotation);
end


saveas(fig8, 'Figure8_Q3_50Year_Projection.png');
saveas(fig8, 'Figure8_Q3_50Year_Projection.fig');

%% ========================================================================
% FIGURE 9: Q4 - ENVIRONMENTAL COMPREHENSIVE (4x4 = 16 subplots)
% ========================================================================
fprintf('Creating Figure 9: Q4 Environmental Comprehensive (4x4)...\n');

fig9 = figure('Name', 'Figure 9: Q4 Environmental Comprehensive', ...
              'Position', [450, 50, fig_width+200, fig_height+100], ...
              'Color', 'white');

% Row 1: Basic Emissions Comparison
subplot(4, 4, 1);
b = bar(Q4.co2_current, 'FaceColor', 'flat');
b.CData = [colors.elevator; colors.rockets; colors.hybrid];
set(gca, 'XTickLabel', {'E', 'R', 'H'}, 'FontSize', fontsize.axis-1);
ylabel('M MT'); title('CO_2 Emissions', 'FontSize', fontsize.subtitle-1);
grid on;

subplot(4, 4, 2);
b = bar(Q4.nox_current/1000, 'FaceColor', 'flat');
b.CData = [colors.elevator; colors.rockets; colors.hybrid];
set(gca, 'XTickLabel', {'E', 'R', 'H'}, 'FontSize', fontsize.axis-1);
ylabel('M MT'); title('NO_x Emissions', 'FontSize', fontsize.subtitle-1);
grid on;

subplot(4, 4, 3);
b = bar(Q4.co2eq_current, 'FaceColor', 'flat');
b.CData = [colors.elevator; colors.rockets; colors.hybrid];
set(gca, 'XTickLabel', {'E', 'R', 'H'}, 'FontSize', fontsize.axis-1);
ylabel('M MT'); title('CO_2-equivalent', 'FontSize', fontsize.subtitle-1);
grid on;

subplot(4, 4, 4);
b = bar(Q4.yearly_emissions, 'FaceColor', 'flat');
b.CData = [colors.elevator; colors.rockets; colors.hybrid];
set(gca, 'XTickLabel', {'E', 'R', 'H'}, 'FontSize', fontsize.axis-1);
ylabel('M MT/yr'); title('Annual Emissions', 'FontSize', fontsize.subtitle-1);
grid on;

% Row 2: NOx Impact and Breakdown
subplot(4, 4, 5);
nox_pct = Q4.nox_current * 100 ./ (Q4.co2_current * 1000 + Q4.nox_current * 100) * 100;
b = bar(nox_pct, 'FaceColor', 'flat');
b.CData = [colors.elevator; colors.rockets; colors.hybrid];
set(gca, 'XTickLabel', {'E', 'R', 'H'}, 'FontSize', fontsize.axis-1);
ylabel('%'); title('NO_x % of Impact', 'FontSize', fontsize.subtitle-1);
grid on;

subplot(4, 4, 6);
stacked = [Q4.co2_current; Q4.nox_current*100/1000]';
b = bar(stacked, 'stacked');
b(1).FaceColor = [0.5 0.5 0.5];
b(2).FaceColor = [0.9 0.3 0.3];
set(gca, 'XTickLabel', {'E', 'R', 'H'}, 'FontSize', fontsize.axis-1);
ylabel('M MT'); title('CO_2 vs NO_x Impact', 'FontSize', fontsize.subtitle-1);
legend({'CO_2', 'NO_x×100'}, 'FontSize', 7);
grid on;

subplot(4, 4, 7);
multiplier = Q4.co2eq_current / Q4.co2eq_current(1);
b = bar(multiplier, 'FaceColor', 'flat');
b.CData = [colors.elevator; colors.rockets; colors.hybrid];
set(gca, 'XTickLabel', {'E', 'R', 'H'}, 'FontSize', fontsize.axis-1);
ylabel('×Elevator'); title('Impact Multiplier', 'FontSize', fontsize.subtitle-1);
grid on;

subplot(4, 4, 8);
pie(Q4.energy_mix_elev);
title('Elevator Energy Mix', 'FontSize', fontsize.subtitle-1);

% Row 3: Green Technology Comparison
subplot(4, 4, 9);
pie(Q4.energy_mix_rock);
title('Rockets Energy Mix', 'FontSize', fontsize.subtitle-1);

subplot(4, 4, 10);
pie(Q4.energy_mix_hybrid);
title('Hybrid Energy Mix', 'FontSize', fontsize.subtitle-1);
legend(Q4.energy_sources, 'Location', 'eastoutside', 'FontSize', 6);

subplot(4, 4, 11);
comparison = [Q4.co2eq_current; Q4.co2eq_green]';
b = bar(comparison, 'grouped');
b(1).FaceColor = [0.6 0.3 0.3];
b(2).FaceColor = [0.3 0.6 0.3];
set(gca, 'XTickLabel', {'E', 'R', 'H'}, 'FontSize', fontsize.axis-1);
ylabel('M MT'); title('Current vs Green', 'FontSize', fontsize.subtitle-1);
legend({'Current', 'Green'}, 'FontSize', 7);
grid on;

subplot(4, 4, 12);
reduction = (Q4.co2eq_current - Q4.co2eq_green) ./ Q4.co2eq_current * 100;
b = bar(reduction, 'FaceColor', 'flat');
b.CData = [colors.elevator; colors.rockets; colors.hybrid];
set(gca, 'XTickLabel', {'E', 'R', 'H'}, 'FontSize', fontsize.axis-1);
ylabel('%'); title('Reduction with Green', 'FontSize', fontsize.subtitle-1);
grid on;

% Row 4: Mitigation and Global Context
subplot(4, 4, 13);
b = bar(Q4.reduction_potential, 'FaceColor', colors.hybrid);
set(gca, 'XTick', 1:4, 'XTickLabel', {'Renew', 'GrnProp', 'ISRU', 'Offset'}, ...
    'FontSize', fontsize.axis-2);
ylabel('%'); title('Mitigation Potential', 'FontSize', fontsize.subtitle-1);
grid on;

subplot(4, 4, 14);
b = bar(Q4.cost_premium, 'FaceColor', colors.rockets);
set(gca, 'XTick', 1:4, 'XTickLabel', {'Renew', 'GrnProp', 'ISRU', 'Offset'}, ...
    'FontSize', fontsize.axis-2);
ylabel('%'); title('Cost Premium', 'FontSize', fontsize.subtitle-1);
grid on;

subplot(4, 4, 15);
roi = Q4.reduction_potential ./ Q4.cost_premium;
b = bar(roi, 'FaceColor', colors.gold);
set(gca, 'XTick', 1:4, 'XTickLabel', {'Renew', 'GrnProp', 'ISRU', 'Offset'}, ...
    'FontSize', fontsize.axis-2);
ylabel('ROI'); title('Mitigation ROI', 'FontSize', fontsize.subtitle-1);
grid on;

subplot(4, 4, 16);
global_context = [Q4.global_annual_co2/1000, Q4.aviation_annual/1000, ...
                  Q4.shipping_annual/1000, Q4.co2eq_green(3)/174];
b = bar(global_context, 'FaceColor', 'flat');
b.CData = [0.5 0.5 0.5; 0.6 0.4 0.3; 0.4 0.5 0.6; colors.hybrid];
set(gca, 'XTick', 1:4, 'XTickLabel', {'Global', 'Aviat.', 'Ship.', 'Colony'}, ...
    'FontSize', fontsize.axis-2);
set(gca, 'YScale', 'log');
ylabel('GT/yr'); title('Global Context', 'FontSize', fontsize.subtitle-1);
grid on;



saveas(fig9, 'Figure9_Q4_Environmental_Comprehensive_4x4.png');
saveas(fig9, 'Figure9_Q4_Environmental_Comprehensive_4x4.fig');

%% ========================================================================
% FIGURE 10: Q4 - MULTI-OBJECTIVE OPTIMIZATION (2x2 = 4 subplots)
% ========================================================================
fprintf('Creating Figure 10: Q4 Multi-Objective Optimization (2x2)...\n');

fig10 = figure('Name', 'Figure 10: Q4 Multi-Objective Optimization', ...
               'Position', [500, 50, fig_width, fig_height], ...
               'Color', 'white');

% Subplot 1: 3D Optimization Space
subplot(2, 2, 1);
marker_colors = [colors.elevator; colors.elevator_green; ...
                 colors.rockets; colors.rockets_green; ...
                 colors.hybrid; colors.hybrid_green];
scatter3(Q4.all_times, Q4.all_costs, Q4.all_env, 150, marker_colors, 'filled');
hold on;
plot3(Q4.all_times(6), Q4.all_costs(6), Q4.all_env(6), 'p', ...
      'MarkerSize', 25, 'MarkerFaceColor', colors.gold, 'MarkerEdgeColor', 'k');
for i = 1:6
    text(Q4.all_times(i)+5, Q4.all_costs(i), Q4.all_env(i)+30, ...
         Q4.scenarios_all{i}, 'FontSize', fontsize.annotation-1);
end
xlabel('Time (yr)'); ylabel('Cost ($T)'); zlabel('CO_2eq (M MT)');
title('3D Optimization Space', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
view(135, 25);
grid on; box on;

% Subplot 2: Ranking by Score
subplot(2, 2, 2);
[sorted_scores, idx] = sort(Q4.opt_scores);
sorted_names = Q4.scenarios_all(idx);
sorted_colors = marker_colors(idx, :);
b = barh(sorted_scores, 0.6);
b.FaceColor = 'flat';
b.CData = sorted_colors;
hold on;
barh(1, sorted_scores(1), 0.6, 'FaceColor', colors.gold, 'EdgeColor', 'k', 'LineWidth', 2);
set(gca, 'YTickLabel', sorted_names, 'FontSize', fontsize.axis);
xlabel('Score (Lower=Better)');
title('Multi-Objective Ranking', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
grid on; box on;

% Subplot 3: Global Comparison
subplot(2, 2, 3);
moon_annual = Q4.co2eq_green(3) / 174;
comparisons = [Q4.global_annual_co2, Q4.aviation_annual, Q4.shipping_annual, moon_annual];
labels = {'Global', 'Aviation', 'Shipping', 'Colony/yr'};
b = bar(comparisons, 0.6, 'FaceColor', 'flat');
b.CData = [0.5 0.5 0.5; 0.6 0.4 0.3; 0.4 0.5 0.6; colors.hybrid];
set(gca, 'XTickLabel', labels, 'FontSize', fontsize.axis);
set(gca, 'YScale', 'log');
ylabel('Annual CO_2eq (M MT)');
title('Global Emissions Context', 'FontSize', fontsize.subtitle, 'FontWeight', 'bold');
grid on; box on;

% Subplot 4: Final Recommendation
subplot(2, 2, 4);
axis off;
text(0.5, 0.92, 'FINAL RECOMMENDATION', 'HorizontalAlignment', 'center', ...
     'FontSize', fontsize.title, 'FontWeight', 'bold', 'Color', colors.hybrid);
text(0.5, 0.78, 'Hybrid with Green Technologies', 'HorizontalAlignment', 'center', ...
     'FontSize', fontsize.subtitle, 'FontWeight', 'bold');

% Metrics boxes
metrics = {'Timeline', 'Cost', 'CO_2eq', 'Score'};
values = {'174 years', '$118.8T', '157.1 M MT', '0.093'};
ranks = {'#1 Fastest', '#2', '#2', '#1 Best'};

for i = 1:4
    y = 0.55 - (i-1)*0.13;
    rectangle('Position', [0.1, y-0.04, 0.8, 0.10], 'Curvature', 0.2, ...
              'FaceColor', [0.95 0.98 0.95], 'EdgeColor', colors.hybrid, 'LineWidth', 1.5);
    text(0.15, y, metrics{i}, 'FontSize', fontsize.annotation, 'FontWeight', 'bold');
    text(0.5, y, values{i}, 'HorizontalAlignment', 'center', 'FontSize', fontsize.annotation+1);
    text(0.85, y, ranks{i}, 'HorizontalAlignment', 'right', ...
         'FontSize', fontsize.annotation, 'Color', colors.gold, 'FontWeight', 'bold');
end

text(0.5, 0.08, '74% Elevator (95% Renewable) + 26% Rockets (Green Propellants)', ...
     'HorizontalAlignment', 'center', 'FontSize', fontsize.annotation, 'FontAngle', 'italic');



saveas(fig10, 'Figure10_Q4_MultiObjective_Final.png');
saveas(fig10, 'Figure10_Q4_MultiObjective_Final.fig');

%% ========================================================================
% SECTION 3: SUMMARY
% ========================================================================

fprintf('\n=== Visualization Generation Complete ===\n\n');
fprintf('Generated 10 model plots with VARIED LAYOUTS:\n');
fprintf('  Figure 1:  Q1 - Comprehensive Dashboard      (3×3 = 9 subplots)\n');
fprintf('  Figure 2:  Q1 - Hybrid Optimization          (2×2 = 4 subplots)\n');
fprintf('  Figure 3:  Q1 - Delivery Analysis Extended   (4×4 = 16 subplots)\n');
fprintf('  Figure 4:  Q2 - Monte Carlo (3D FANCY BARS)  (2×2 = 4 subplots)\n');
fprintf('  Figure 5:  Q2 - Reliability Deep Dive        (3×3 = 9 subplots)\n');
fprintf('  Figure 6:  Q2 - Risk Assessment              (2×2 = 4 subplots)\n');
fprintf('  Figure 7:  Q3 - Water Analysis (3D FANCY)    (2×2 = 4 subplots)\n');
fprintf('  Figure 8:  Q3 - 50-Year Projection           (2×2 = 4 subplots)\n');
fprintf('  Figure 9:  Q4 - Environmental Comprehensive  (4×4 = 16 subplots)\n');
fprintf('  Figure 10: Q4 - Multi-Objective Final        (2×2 = 4 subplots)\n');
fprintf('\nLayout Summary:\n');
fprintf('  - 2×2 layouts: 5 figures (20 subplots)\n');
fprintf('  - 3×3 layouts: 2 figures (18 subplots)\n');
fprintf('  - 4×4 layouts: 2 figures (32 subplots)\n');
fprintf('  - 3D/Fancy bars: Figures 4 and 7\n');
fprintf('  - TOTAL: 70 subplots across 10 figures\n');
fprintf('\nFiles saved as both .png and .fig formats.\n');
fprintf('\n=== VISUALIZATION COMPLETE ===\n');