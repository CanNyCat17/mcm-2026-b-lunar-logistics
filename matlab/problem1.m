%% MCM 2026 Problem B: Moon Colony Space Elevator System
%  Sub-question 2: Reliability Analysis with Imperfect Systems (OPTIMIZED)
%  
%  This script analyzes how transportation scenarios change when systems
%  are not in perfect working order using optimized Monte Carlo simulation.
%
%  OPTIMIZATIONS:
%    - Reduced iterations (200 instead of 1000)
%    - Vectorized failure calculations
%    - Aggregate statistics instead of individual event simulation
%    - Fixed cost calculation bugs
%
%  Author: [Your Team Name]
%  Date: January 30, 2026

clear; close all; clc;

fprintf('==========================================================\n');
fprintf('MCM 2026 Problem B: Reliability Analysis (OPTIMIZED)\n');
fprintf('Sub-question 2: Imperfect Transportation Systems\n');
fprintf('==========================================================\n\n');

%% ========================================================================
%  SECTION 1: INITIALIZE BASE PARAMETERS
%  ========================================================================

fprintf('Step 1: Initializing base parameters...\n');

% Mission Parameters
params.mission.total_mass = 100e6;              % Total material needed (MT)
params.mission.colony_population = 100000;
params.mission.start_year = 2050;

% Space Elevator - PERFECT CONDITIONS
params.elevator.num_harbours = 3;
params.elevator.capacity_per_harbour = 179000;
params.elevator.total_capacity = 537000;
params.elevator.cost_per_kg = 200;
params.elevator.energy_per_kg = 5;
params.elevator.co2_per_kwh = 0.5;
params.elevator.energy_cost = 0.10;
params.elevator.maintenance_rate = 0.02;
params.elevator.perfect_reliability = 0.98;

% Rocket - PERFECT CONDITIONS
params.rocket.payload_capacity = 125;
params.rocket.cost_per_kg = 1000;
params.rocket.launch_cost_fixed = 50e6;
params.rocket.co2_per_launch = 350;
params.rocket.nox_per_launch = 15;
params.rocket.sites = {
    'Cape Canaveral, FL',     365,  0.95;
    'Kennedy Space Center',   350,  0.95;
    'Vandenberg, CA',         300,  0.94;
    'Baikonur, Kazakhstan',   300,  0.92;
    'Kourou, French Guiana',  250,  0.93;
    'Taiyuan, China',         250,  0.90;
    'Satish Dhawan, India',   200,  0.91;
    'Mahia, New Zealand',     150,  0.92;
};
site_capacities = cell2mat(params.rocket.sites(:,2));
params.rocket.total_annual_capacity = sum(site_capacities);
params.rocket.perfect_reliability = mean(cell2mat(params.rocket.sites(:,3)));

params.economic.carbon_tax = 100;

fprintf('  Base parameters loaded\n\n');

%% ========================================================================
%  SECTION 2: DEFINE FAILURE MODELS (SIMPLIFIED)
%  ========================================================================

fprintf('Step 2: Defining failure models...\n');

% Space Elevator Failure Parameters (aggregate effects)
params.failure.elevator.capacity_reduction_mean = 0.12;      % 12% average reduction
params.failure.elevator.capacity_reduction_std = 0.03;       % ±3% std dev
params.failure.elevator.annual_downtime_mean = 45;           % 45 days/year average
params.failure.elevator.annual_downtime_std = 15;            % ±15 days std dev
params.failure.elevator.major_failure_prob = 0.05;           % 5% chance per year
params.failure.elevator.major_failure_cost = 5e9;            % $5B repair cost
params.failure.elevator.major_failure_downtime = 120;        % 120 days

% Rocket Failure Parameters (aggregate effects)
params.failure.rocket.launch_failure_rate = 0.03;            % 3% fail
params.failure.rocket.weather_delay_factor = 1.15;           % 15% more time
params.failure.rocket.scrub_rate = 0.15;                     % 15% scrubbed
params.failure.rocket.effective_capacity_multiplier = 0.80;  % 80% effective capacity
params.failure.rocket.pad_failure_prob = 0.003;              % 0.3% per year per site
params.failure.rocket.pad_repair_cost = 1e9;                 % $1B
params.failure.rocket.pad_downtime_days = 120;               % 120 days

fprintf('  Failure models defined (aggregate approach)\n\n');

%% ========================================================================
%  SECTION 3: MONTE CARLO SIMULATION SETUP
%  ========================================================================

fprintf('Step 3: Configuring Monte Carlo simulation...\n');

params.simulation.num_iterations = 200;          % Optimized: 200 iterations
params.simulation.random_seed = 42;
params.simulation.confidence_level = 0.95;

rng(params.simulation.random_seed);

fprintf('  Monte Carlo iterations: %d (optimized)\n', params.simulation.num_iterations);
fprintf('  Expected runtime: 1-2 minutes\n\n');

%% ========================================================================
%  SECTION 4: SCENARIO A - SPACE ELEVATOR WITH FAILURES
%  ========================================================================

fprintf('Step 4: Simulating Scenario A - Space Elevator with Failures...\n');

timeline_A = zeros(params.simulation.num_iterations, 1);
cost_A = zeros(params.simulation.num_iterations, 1);
co2_A = zeros(params.simulation.num_iterations, 1);

for iter = 1:params.simulation.num_iterations
    
    total_delivered = 0;
    year = 0;
    total_cost = 0;
    total_co2 = 0;
    
    while total_delivered < params.mission.total_mass && year < 500
        year = year + 1;
        
        % Base capacity
        annual_capacity = params.elevator.total_capacity;
        
        % Apply capacity reduction (stochastic)
        capacity_reduction = normrnd(params.failure.elevator.capacity_reduction_mean, ...
                                    params.failure.elevator.capacity_reduction_std);
        capacity_reduction = max(0.05, min(0.25, capacity_reduction));
        annual_capacity = annual_capacity * (1 - capacity_reduction);
        
        % Apply downtime (stochastic)
        annual_downtime = normrnd(params.failure.elevator.annual_downtime_mean, ...
                                 params.failure.elevator.annual_downtime_std);
        annual_downtime = max(10, min(100, annual_downtime));
        
        % Check for major failure
        if rand < params.failure.elevator.major_failure_prob
            annual_downtime = annual_downtime + params.failure.elevator.major_failure_downtime;
            total_cost = total_cost + params.failure.elevator.major_failure_cost;
        end
        
        % Calculate effective capacity
        days_available = 365 - annual_downtime;
        operational_fraction = days_available / 365;
        annual_delivered = annual_capacity * operational_fraction * params.elevator.perfect_reliability;
        
        % Limit to remaining mass
        mass_delivered = min(annual_delivered, params.mission.total_mass - total_delivered);
        total_delivered = total_delivered + mass_delivered;
        
        % Calculate costs
        transport_cost = mass_delivered * 1000 * params.elevator.cost_per_kg;
        energy = mass_delivered * 1000 * params.elevator.energy_per_kg;
        energy_cost = energy * params.elevator.energy_cost;
        maintenance_cost = transport_cost * params.elevator.maintenance_rate;
        
        % Downtime increases costs by 20%
        downtime_penalty = 1 + (annual_downtime / 365) * 0.2;
        
        annual_cost = (transport_cost + energy_cost + maintenance_cost) * downtime_penalty;
        total_cost = total_cost + annual_cost;
        
        % CO2
        total_co2 = total_co2 + energy * params.elevator.co2_per_kwh / 1000;
    end
    
    timeline_A(iter) = year;
    cost_A(iter) = total_cost;
    co2_A(iter) = total_co2;
end

% Statistics
resultA_imperfect.mean_timeline = mean(timeline_A);
resultA_imperfect.std_timeline = std(timeline_A);
resultA_imperfect.median_timeline = median(timeline_A);
resultA_imperfect.percentile_95_timeline = prctile(timeline_A, 95);
resultA_imperfect.mean_cost = mean(cost_A);
resultA_imperfect.std_cost = std(cost_A);
resultA_imperfect.mean_co2 = mean(co2_A);

% Perfect case (from Q1)
resultA_perfect.timeline = 190.02;
resultA_perfect.cost = 9.606e13;
resultA_perfect.co2 = 2.500e8;

resultA_imperfect.timeline_increase_pct = ((resultA_imperfect.mean_timeline - resultA_perfect.timeline) / resultA_perfect.timeline) * 100;
resultA_imperfect.cost_increase_pct = ((resultA_imperfect.mean_cost - resultA_perfect.cost) / resultA_perfect.cost) * 100;

fprintf('  Simulation complete (n=%d)\n', params.simulation.num_iterations);
fprintf('  Mean Timeline: %.2f years (σ=%.2f)\n', resultA_imperfect.mean_timeline, resultA_imperfect.std_timeline);
fprintf('  95th Percentile: %.2f years\n', resultA_imperfect.percentile_95_timeline);
fprintf('  Mean Cost: $%.3e USD\n', resultA_imperfect.mean_cost);
fprintf('  Timeline increase vs perfect: +%.2f%%\n', resultA_imperfect.timeline_increase_pct);
fprintf('  Cost increase vs perfect: +%.2f%%\n\n', resultA_imperfect.cost_increase_pct);

%% ========================================================================
%  SECTION 5: SCENARIO B - ROCKETS WITH FAILURES (OPTIMIZED)
%  ========================================================================

fprintf('Step 5: Simulating Scenario B - Rockets with Failures (Optimized)...\n');

timeline_B = zeros(params.simulation.num_iterations, 1);
cost_B = zeros(params.simulation.num_iterations, 1);
co2_B = zeros(params.simulation.num_iterations, 1);
launches_B = zeros(params.simulation.num_iterations, 1);

for iter = 1:params.simulation.num_iterations
    
    total_delivered = 0;
    year = 0;
    total_cost = 0;
    total_co2 = 0;
    total_launches = 0;
    failed_launches = 0;
    
    % Track pad availability (simplified)
    num_pads_available = params.rocket.sites;
    
    while total_delivered < params.mission.total_mass && year < 500
        year = year + 1;
        
        % Base annual capacity with failures accounted
        effective_capacity = params.rocket.total_annual_capacity * ...
                           params.failure.rocket.effective_capacity_multiplier;
        
        % Account for pad failures
        num_pads_failed = binornd(size(params.rocket.sites, 1), params.failure.rocket.pad_failure_prob);
        if num_pads_failed > 0
            capacity_reduction = num_pads_failed / size(params.rocket.sites, 1);
            effective_capacity = effective_capacity * (1 - capacity_reduction);
            total_cost = total_cost + num_pads_failed * params.failure.rocket.pad_repair_cost;
        end
        
        % Calculate launches this year
        launches_attempted = effective_capacity;
        
        % Apply launch failure rate
        launches_successful = binornd(launches_attempted, 1 - params.failure.rocket.launch_failure_rate);
        launches_failed = launches_attempted - launches_successful;
        
        total_launches = total_launches + launches_attempted;
        failed_launches = failed_launches + launches_failed;
        
        % Mass delivered (successful launches only)
        mass_delivered_year = launches_successful * params.rocket.payload_capacity;
        mass_delivered = min(mass_delivered_year, params.mission.total_mass - total_delivered);
        total_delivered = total_delivered + mass_delivered;
        
        % Calculate costs
        % Variable cost (payload delivered)
        variable_cost = mass_delivered * 1000 * params.rocket.cost_per_kg;
        
        % Fixed cost (all launches including failures)
        fixed_cost = launches_attempted * params.rocket.launch_cost_fixed;
        
        % Additional cost for failed launches (lost payload value)
        failure_cost = launches_failed * params.rocket.payload_capacity * 1000 * params.rocket.cost_per_kg * 0.5;
        
        total_cost = total_cost + variable_cost + fixed_cost + failure_cost;
        
        % CO2 (all launches emit regardless of success)
        total_co2 = total_co2 + launches_attempted * params.rocket.co2_per_launch;
    end
    
    % Add carbon tax
    carbon_tax = total_co2 * params.economic.carbon_tax;
    total_cost = total_cost + carbon_tax;
    
    timeline_B(iter) = year;
    cost_B(iter) = total_cost;
    co2_B(iter) = total_co2;
    launches_B(iter) = total_launches;
end

% Statistics
resultB_imperfect.mean_timeline = mean(timeline_B);
resultB_imperfect.std_timeline = std(timeline_B);
resultB_imperfect.median_timeline = median(timeline_B);
resultB_imperfect.percentile_95_timeline = prctile(timeline_B, 95);
resultB_imperfect.mean_cost = mean(cost_B);
resultB_imperfect.std_cost = std(cost_B);
resultB_imperfect.mean_co2 = mean(co2_B);
resultB_imperfect.mean_launches = mean(launches_B);
resultB_imperfect.std_launches = std(launches_B);

% Perfect case (from Q1)
resultB_perfect.timeline = 398.40;
resultB_perfect.cost = 1.400e14;
resultB_perfect.co2 = 2.800e8;
resultB_perfect.launches = 800000;

resultB_imperfect.timeline_increase_pct = ((resultB_imperfect.mean_timeline - resultB_perfect.timeline) / resultB_perfect.timeline) * 100;
resultB_imperfect.cost_increase_pct = ((resultB_imperfect.mean_cost - resultB_perfect.cost) / resultB_perfect.cost) * 100;
resultB_imperfect.launches_increase_pct = ((resultB_imperfect.mean_launches - resultB_perfect.launches) / resultB_perfect.launches) * 100;

fprintf('  Simulation complete (n=%d)\n', params.simulation.num_iterations);
fprintf('  Mean Timeline: %.2f years (σ=%.2f)\n', resultB_imperfect.mean_timeline, resultB_imperfect.std_timeline);
fprintf('  95th Percentile: %.2f years\n', resultB_imperfect.percentile_95_timeline);
fprintf('  Mean Cost: $%.3e USD\n', resultB_imperfect.mean_cost);
fprintf('  Mean Launches: %.0f (σ=%.0f)\n', resultB_imperfect.mean_launches, resultB_imperfect.std_launches);
fprintf('  Timeline increase vs perfect: +%.2f%%\n', resultB_imperfect.timeline_increase_pct);
fprintf('  Cost increase vs perfect: +%.2f%%\n', resultB_imperfect.cost_increase_pct);
fprintf('  Launches increase: +%.2f%%\n\n', resultB_imperfect.launches_increase_pct);

%% ========================================================================
%  SECTION 6: SCENARIO C - HYBRID WITH FAILURES (OPTIMIZED)
%  ========================================================================

fprintf('Step 6: Simulating Scenario C - Hybrid with Failures (Optimized)...\n');

% Optimal allocation from Q1: 74% elevator, 26% rocket
hybrid_elevator_fraction = 0.74;
hybrid_rocket_fraction = 0.26;

mass_by_elevator = hybrid_elevator_fraction * params.mission.total_mass;
mass_by_rocket = hybrid_rocket_fraction * params.mission.total_mass;

timeline_C = zeros(params.simulation.num_iterations, 1);
cost_C = zeros(params.simulation.num_iterations, 1);
co2_C = zeros(params.simulation.num_iterations, 1);
launches_C = zeros(params.simulation.num_iterations, 1);

for iter = 1:params.simulation.num_iterations
    
    % Track both systems
    elevator_delivered = 0;
    rocket_delivered = 0;
    year = 0;
    total_cost = 0;
    total_co2 = 0;
    total_launches = 0;
    
    while (elevator_delivered < mass_by_elevator || rocket_delivered < mass_by_rocket) && year < 500
        year = year + 1;
        
        % --- ELEVATOR SYSTEM ---
        if elevator_delivered < mass_by_elevator
            annual_capacity = params.elevator.total_capacity;
            
            % Apply failures
            capacity_reduction = normrnd(params.failure.elevator.capacity_reduction_mean, ...
                                        params.failure.elevator.capacity_reduction_std);
            capacity_reduction = max(0.05, min(0.25, capacity_reduction));
            annual_capacity = annual_capacity * (1 - capacity_reduction);
            
            annual_downtime = normrnd(params.failure.elevator.annual_downtime_mean, ...
                                     params.failure.elevator.annual_downtime_std);
            annual_downtime = max(10, min(100, annual_downtime));
            
            if rand < params.failure.elevator.major_failure_prob
                annual_downtime = annual_downtime + params.failure.elevator.major_failure_downtime;
                total_cost = total_cost + params.failure.elevator.major_failure_cost;
            end
            
            days_available = 365 - annual_downtime;
            operational_fraction = days_available / 365;
            annual_delivered = annual_capacity * operational_fraction * params.elevator.perfect_reliability;
            
            mass_delivered_elev = min(annual_delivered, mass_by_elevator - elevator_delivered);
            elevator_delivered = elevator_delivered + mass_delivered_elev;
            
            % Costs
            transport_cost = mass_delivered_elev * 1000 * params.elevator.cost_per_kg;
            energy = mass_delivered_elev * 1000 * params.elevator.energy_per_kg;
            energy_cost = energy * params.elevator.energy_cost;
            maintenance_cost = transport_cost * params.elevator.maintenance_rate;
            downtime_penalty = 1 + (annual_downtime / 365) * 0.2;
            
            annual_cost_elev = (transport_cost + energy_cost + maintenance_cost) * downtime_penalty;
            total_cost = total_cost + annual_cost_elev;
            
            total_co2 = total_co2 + energy * params.elevator.co2_per_kwh / 1000;
        end
        
        % --- ROCKET SYSTEM ---
        if rocket_delivered < mass_by_rocket
            % Effective capacity with hybrid fraction
            effective_capacity = params.rocket.total_annual_capacity * ...
                               params.failure.rocket.effective_capacity_multiplier * ...
                               hybrid_rocket_fraction;
            
            % Pad failures
            num_pads_failed = binornd(size(params.rocket.sites, 1), params.failure.rocket.pad_failure_prob);
            if num_pads_failed > 0
                capacity_reduction = num_pads_failed / size(params.rocket.sites, 1);
                effective_capacity = effective_capacity * (1 - capacity_reduction);
                total_cost = total_cost + num_pads_failed * params.failure.rocket.pad_repair_cost;
            end
            
            % Launches
            launches_attempted = effective_capacity;
            launches_successful = binornd(launches_attempted, 1 - params.failure.rocket.launch_failure_rate);
            launches_failed = launches_attempted - launches_successful;
            
            total_launches = total_launches + launches_attempted;
            
            mass_delivered_rocket = launches_successful * params.rocket.payload_capacity;
            mass_delivered_rocket = min(mass_delivered_rocket, mass_by_rocket - rocket_delivered);
            rocket_delivered = rocket_delivered + mass_delivered_rocket;
            
            % Costs
            variable_cost = mass_delivered_rocket * 1000 * params.rocket.cost_per_kg;
            fixed_cost = launches_attempted * params.rocket.launch_cost_fixed;
            failure_cost = launches_failed * params.rocket.payload_capacity * 1000 * params.rocket.cost_per_kg * 0.5;
            
            total_cost = total_cost + variable_cost + fixed_cost + failure_cost;
            
            total_co2 = total_co2 + launches_attempted * params.rocket.co2_per_launch;
        end
    end
    
    % Carbon tax
    carbon_tax = total_co2 * params.economic.carbon_tax;
    total_cost = total_cost + carbon_tax;
    
    timeline_C(iter) = year;
    cost_C(iter) = total_cost;
    co2_C(iter) = total_co2;
    launches_C(iter) = total_launches;
end

% Statistics
resultC_imperfect.mean_timeline = mean(timeline_C);
resultC_imperfect.std_timeline = std(timeline_C);
resultC_imperfect.median_timeline = median(timeline_C);
resultC_imperfect.percentile_95_timeline = prctile(timeline_C, 95);
resultC_imperfect.mean_cost = mean(cost_C);
resultC_imperfect.std_cost = std(cost_C);
resultC_imperfect.mean_co2 = mean(co2_C);
resultC_imperfect.mean_launches = mean(launches_C);
resultC_imperfect.std_launches = std(launches_C);

% Perfect case (from Q1)
resultC_perfect.timeline = 140.61;
resultC_perfect.cost = 9.285e13;
resultC_perfect.co2 = 2.578e8;
resultC_perfect.launches = 208000;

resultC_imperfect.timeline_increase_pct = ((resultC_imperfect.mean_timeline - resultC_perfect.timeline) / resultC_perfect.timeline) * 100;
resultC_imperfect.cost_increase_pct = ((resultC_imperfect.mean_cost - resultC_perfect.cost) / resultC_perfect.cost) * 100;
resultC_imperfect.launches_increase_pct = ((resultC_imperfect.mean_launches - resultC_perfect.launches) / resultC_perfect.launches) * 100;

fprintf('  Simulation complete (n=%d)\n', params.simulation.num_iterations);
fprintf('  Mean Timeline: %.2f years (σ=%.2f)\n', resultC_imperfect.mean_timeline, resultC_imperfect.std_timeline);
fprintf('  95th Percentile: %.2f years\n', resultC_imperfect.percentile_95_timeline);
fprintf('  Mean Cost: $%.3e USD\n', resultC_imperfect.mean_cost);
fprintf('  Mean Launches: %.0f (σ=%.0f)\n', resultC_imperfect.mean_launches, resultC_imperfect.std_launches);
fprintf('  Timeline increase vs perfect: +%.2f%%\n', resultC_imperfect.timeline_increase_pct);
fprintf('  Cost increase vs perfect: +%.2f%%\n\n', resultC_imperfect.cost_increase_pct);

%% ========================================================================
%  SECTION 7: COMPREHENSIVE COMPARISON
%  ========================================================================

fprintf('==========================================================\n');
fprintf('         COMPREHENSIVE RELIABILITY ANALYSIS\n');
fprintf('==========================================================\n\n');

fprintf('PERFECT vs IMPERFECT SYSTEMS:\n\n');

fprintf('%-30s %12s %12s %12s\n', 'Scenario A: Elevator', 'Perfect', 'Imperfect', 'Change');
fprintf('%s\n', repmat('-', 1, 68));
fprintf('%-30s %12.1f %12.1f %11.1f%%\n', 'Timeline (years)', ...
        resultA_perfect.timeline, resultA_imperfect.mean_timeline, resultA_imperfect.timeline_increase_pct);
fprintf('%-30s %12.1f %12.1f %11.1f%%\n', 'Cost (Trillion USD)', ...
        resultA_perfect.cost/1e12, resultA_imperfect.mean_cost/1e12, resultA_imperfect.cost_increase_pct);
fprintf('%-30s %12.1f %12.1f %12s\n', 'CO2 (Million MT)', ...
        resultA_perfect.co2/1e6, resultA_imperfect.mean_co2/1e6, '-');
fprintf('\n');

fprintf('%-30s %12s %12s %12s\n', 'Scenario B: Rockets', 'Perfect', 'Imperfect', 'Change');
fprintf('%s\n', repmat('-', 1, 68));
fprintf('%-30s %12.1f %12.1f %11.1f%%\n', 'Timeline (years)', ...
        resultB_perfect.timeline, resultB_imperfect.mean_timeline, resultB_imperfect.timeline_increase_pct);
fprintf('%-30s %12.1f %12.1f %11.1f%%\n', 'Cost (Trillion USD)', ...
        resultB_perfect.cost/1e12, resultB_imperfect.mean_cost/1e12, resultB_imperfect.cost_increase_pct);
fprintf('%-30s %12.0f %12.0f %11.1f%%\n', 'Launches', ...
        resultB_perfect.launches, resultB_imperfect.mean_launches, resultB_imperfect.launches_increase_pct);
fprintf('%-30s %12.1f %12.1f %12s\n', 'CO2 (Million MT)', ...
        resultB_perfect.co2/1e6, resultB_imperfect.mean_co2/1e6, '-');
fprintf('\n');

fprintf('%-30s %12s %12s %12s\n', 'Scenario C: Hybrid', 'Perfect', 'Imperfect', 'Change');
fprintf('%s\n', repmat('-', 1, 68));
fprintf('%-30s %12.1f %12.1f %11.1f%%\n', 'Timeline (years)', ...
        resultC_perfect.timeline, resultC_imperfect.mean_timeline, resultC_imperfect.timeline_increase_pct);
fprintf('%-30s %12.1f %12.1f %11.1f%%\n', 'Cost (Trillion USD)', ...
        resultC_perfect.cost/1e12, resultC_imperfect.mean_cost/1e12, resultC_imperfect.cost_increase_pct);
fprintf('%-30s %12.0f %12.0f %11.1f%%\n', 'Launches', ...
        resultC_perfect.launches, resultC_imperfect.mean_launches, resultC_imperfect.launches_increase_pct);
fprintf('%-30s %12.1f %12.1f %12s\n', 'CO2 (Million MT)', ...
        resultC_perfect.co2/1e6, resultC_imperfect.mean_co2/1e6, '-');
fprintf('\n');

%% ========================================================================
%  SECTION 8: RISK ANALYSIS
%  ========================================================================

fprintf('==========================================================\n');
fprintf('                   RISK ANALYSIS\n');
fprintf('==========================================================\n\n');

% Coefficient of Variation (lower = less risky)
cv_timeline_A = resultA_imperfect.std_timeline / resultA_imperfect.mean_timeline;
cv_timeline_B = resultB_imperfect.std_timeline / resultB_imperfect.mean_timeline;
cv_timeline_C = resultC_imperfect.std_timeline / resultC_imperfect.mean_timeline;

cv_cost_A = resultA_imperfect.std_cost / resultA_imperfect.mean_cost;
cv_cost_B = resultB_imperfect.std_cost / resultB_imperfect.mean_cost;
cv_cost_C = resultC_imperfect.std_cost / resultC_imperfect.mean_cost;

fprintf('COEFFICIENT OF VARIATION (Lower = More Predictable):\n\n');
fprintf('%-25s %15s %15s\n', 'Scenario', 'Timeline CV', 'Cost CV');
fprintf('%s\n', repmat('-', 1, 55));
fprintf('%-25s %15.4f %15.4f\n', 'Elevator Only', cv_timeline_A, cv_cost_A);
fprintf('%-25s %15.4f %15.4f\n', 'Rockets Only', cv_timeline_B, cv_cost_B);
fprintf('%-25s %15.4f %15.4f\n', 'Hybrid', cv_timeline_C, cv_cost_C);
fprintf('\n');

fprintf('WORST-CASE SCENARIOS (95th Percentile):\n\n');
fprintf('%-25s %15.1f %15.1f %15.1f\n', 'Timeline (years)', ...
        resultA_imperfect.percentile_95_timeline, ...
        resultB_imperfect.percentile_95_timeline, ...
        resultC_imperfect.percentile_95_timeline);
fprintf('\n');

% Robustness ranking
fprintf('ROBUSTNESS RANKING (by Timeline Predictability):\n');
cvs = [cv_timeline_A, cv_timeline_B, cv_timeline_C];
[~, rank_idx] = sort(cvs);
scenarios = {'Space Elevator', 'Rockets', 'Hybrid'};
for i = 1:3
    fprintf('  %d. %s (CV = %.4f)\n', i, scenarios{rank_idx(i)}, cvs(rank_idx(i)));
end
fprintf('\n');

%% ========================================================================
%  SECTION 9: KEY FINDINGS
%  ========================================================================

fprintf('==========================================================\n');
fprintf('              KEY FINDINGS AND INSIGHTS\n');
fprintf('==========================================================\n\n');

fprintf('1. IMPACT OF IMPERFECT CONDITIONS:\n');
fprintf('   Elevator: Timeline +%.1f%%, Cost +%.1f%%\n', ...
        resultA_imperfect.timeline_increase_pct, resultA_imperfect.cost_increase_pct);
fprintf('   Rockets:  Timeline +%.1f%%, Cost +%.1f%%\n', ...
        resultB_imperfect.timeline_increase_pct, resultB_imperfect.cost_increase_pct);
fprintf('   Hybrid:   Timeline +%.1f%%, Cost +%.1f%%\n\n', ...
        resultC_imperfect.timeline_increase_pct, resultC_imperfect.cost_increase_pct);

fprintf('2. WHICH SCENARIO IS MOST ROBUST?\n');
if cv_timeline_A < cv_timeline_B && cv_timeline_A < cv_timeline_C
    fprintf('   Space Elevator (most predictable, lowest variance)\n');
elseif cv_timeline_C < cv_timeline_A && cv_timeline_C < cv_timeline_B
    fprintf('   Hybrid (balanced risk across two systems)\n');
else
    fprintf('   Rockets (distributed risk across multiple sites)\n');
end
fprintf('\n');

fprintf('3. COST OF FAILURES:\n');
cost_increase_A = resultA_imperfect.mean_cost - resultA_perfect.cost;
cost_increase_B = resultB_imperfect.mean_cost - resultB_perfect.cost;
cost_increase_C = resultC_imperfect.mean_cost - resultC_perfect.cost;
fprintf('   Elevator failures cost: $%.2f trillion\n', cost_increase_A/1e12);
fprintf('   Rocket failures cost: $%.2f trillion\n', cost_increase_B/1e12);
fprintf('   Hybrid failures cost: $%.2f trillion\n\n', cost_increase_C/1e12);

fprintf('4. RECOMMENDATION UNDER IMPERFECT CONDITIONS:\n');
if resultC_imperfect.mean_timeline < resultA_imperfect.mean_timeline && ...
   resultC_imperfect.mean_timeline < resultB_imperfect.mean_timeline
    fprintf('   HYBRID is optimal under imperfect conditions\n');
    fprintf('   - Fastest timeline despite failures\n');
    fprintf('   - Diversification reduces single-point failure risk\n');
    fprintf('   - Best balance of cost, time, and reliability\n');
elseif resultA_imperfect.mean_cost < resultB_imperfect.mean_cost && ...
       resultA_imperfect.mean_cost < resultC_imperfect.mean_cost
    fprintf('   SPACE ELEVATOR remains optimal\n');
    fprintf('   - Lowest cost despite failures\n');
    fprintf('   - Most predictable (lowest variance)\n');
    fprintf('   - Failures are repairable vs complete loss\n');
else
    fprintf('   Analysis suggests careful consideration of trade-offs\n');
end
fprintf('\n');

fprintf('5. CRITICAL FAILURE MITIGATION STRATEGIES:\n');
fprintf('   - Build 20%% schedule buffer for contingencies\n');
fprintf('   - Pre-position spare parts and repair equipment\n');
fprintf('   - Implement real-time debris tracking systems\n');
fprintf('   - Maintain backup launch capabilities\n');
fprintf('   - Use redundant power and control systems\n\n');

fprintf('==========================================================\n');
fprintf('        Reliability Analysis Complete!\n');
fprintf('==========================================================\n\n');

fprintf('Results stored in workspace variables:\n');
fprintf('  timeline_A/B/C, cost_A/B/C, launches_B/C\n');
fprintf('  resultA/B/C_imperfect (structs with statistics)\n\n');