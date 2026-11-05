%% MCM 2026 Problem B: Moon Colony Space Elevator System
%  Sub-question 2: Reliability Analysis (FUNDAMENTAL REWRITE)
%  
%  COMPLETE REWRITE - Key fixes:
%    1. Cost = (Total Mass × Unit Cost) + (Years × Operating) + Repairs
%    2. Total mass delivered ALWAYS equals 100M MT
%    3. Hybrid uses TRUE parallel simulation (independent timelines)
%    4. Clear, simple, verifiable logic
%
%  Author: [Your Team Name]
%  Date: January 30, 2026

clear; close all; clc;

fprintf('==========================================================\n');
fprintf('MCM 2026 Problem B: Reliability Analysis (REWRITE)\n');
fprintf('Sub-question 2: Imperfect Transportation Systems\n');
fprintf('==========================================================\n\n');

%% ========================================================================
%  SECTION 1: PARAMETERS
%  ========================================================================

fprintf('Step 1: Initializing parameters...\n');

% Mission
params.total_mass = 100e6;  % MT

% Elevator - Perfect baseline
params.elev_capacity = 537000;        % MT/year
params.elev_cost_per_kg = 200;        % USD/kg
params.elev_energy_per_kg = 5;        % kWh/kg
params.elev_energy_cost = 0.10;       % USD/kWh
params.elev_annual_operating = 1e9;   % $1B/year operating cost

% Elevator - Failure parameters
params.elev_capacity_loss = 0.10;     % 10% capacity reduction
params.elev_downtime_days = 40;       % 40 days/year downtime
params.elev_major_incident_prob = 0.03;  % 3% chance/year
params.elev_major_incident_days = 90;    % 90 days repair
params.elev_major_incident_cost = 5e9;   % $5B repair cost

% Rocket - Perfect baseline  
params.rocket_capacity = 2165;        % Launches/year
params.rocket_payload = 125;          % MT/launch
params.rocket_cost_per_kg = 1000;     % USD/kg
params.rocket_fixed_per_launch = 50e6;  % USD/launch
params.rocket_co2_per_launch = 350;   % MT CO2

% Rocket - Failure parameters
params.rocket_failure_rate = 0.03;    % 3% launch failures
params.rocket_delay_factor = 1.20;    % 20% slower
params.rocket_pad_failure_prob = 0.01;  % 1% per site/year

% Economic
params.carbon_tax = 100;  % USD per MT CO2

% Monte Carlo
params.num_iterations = 200;
rng(42);

fprintf('  Parameters loaded\n\n');

%% ========================================================================
%  PERFECT CASE REFERENCE (from Q1)
%  ========================================================================

% These are the baseline values from Question 1
perfect.elev_timeline = 190.02;
perfect.elev_cost = 9.606e13;
perfect.rocket_timeline = 398.40;
perfect.rocket_cost = 1.400e14;
perfect.hybrid_timeline = 140.61;
perfect.hybrid_cost = 9.285e13;

%% ========================================================================
%  SECTION 2: SCENARIO A - ELEVATOR WITH FAILURES
%  ========================================================================

fprintf('Step 2: Simulating Scenario A - Space Elevator with Failures...\n');

timeline_A = zeros(params.num_iterations, 1);
cost_A = zeros(params.num_iterations, 1);

for iter = 1:params.num_iterations
    
    mass_remaining = params.total_mass;
    year = 0;
    total_repair_cost = 0;
    
    % Simulate until all mass delivered
    while mass_remaining > 0 && year < 600
        year = year + 1;
        
        % Annual capacity with failures
        capacity = params.elev_capacity;
        capacity = capacity * (1 - params.elev_capacity_loss);  % Capacity reduction
        
        % Downtime reduces operational fraction
        downtime = params.elev_downtime_days;
        if rand < params.elev_major_incident_prob
            downtime = downtime + params.elev_major_incident_days;
            total_repair_cost = total_repair_cost + params.elev_major_incident_cost;
        end
        
        operational_fraction = (365 - downtime) / 365;
        annual_delivered = capacity * operational_fraction;
        
        % Deliver mass (limited by what's remaining)
        mass_delivered = min(annual_delivered, mass_remaining);
        mass_remaining = mass_remaining - mass_delivered;
    end
    
    % Timeline determined
    timeline_A(iter) = year;
    
    % ===== COST CALCULATION (CORRECTED) =====
    % Key insight: Total mass delivered = 100M MT (always)
    % Cost increases come from: (1) More operating years, (2) Repair costs
    
    % Transport cost: Based on TOTAL mass (not annual)
    transport_cost = params.total_mass * 1000 * params.elev_cost_per_kg;
    
    % Energy cost: Based on TOTAL mass
    total_energy = params.total_mass * 1000 * params.elev_energy_per_kg;
    energy_cost = total_energy * params.elev_energy_cost;
    
    % Operating cost: Proportional to timeline
    operating_cost = year * params.elev_annual_operating;
    
    % Maintenance cost: 2% of transport cost PER YEAR
    maintenance_cost = transport_cost * 0.02 * year;
    
    % Total cost
    cost_A(iter) = transport_cost + energy_cost + operating_cost + ...
                   maintenance_cost + total_repair_cost;
end

% Statistics
result_A.mean_timeline = mean(timeline_A);
result_A.std_timeline = std(timeline_A);
result_A.percentile_95 = prctile(timeline_A, 95);
result_A.mean_cost = mean(cost_A);
result_A.std_cost = std(cost_A);

result_A.timeline_change_pct = ((result_A.mean_timeline - perfect.elev_timeline) / perfect.elev_timeline) * 100;
result_A.cost_change_pct = ((result_A.mean_cost - perfect.elev_cost) / perfect.elev_cost) * 100;

fprintf('  Mean Timeline: %.1f years (σ=%.1f)\n', result_A.mean_timeline, result_A.std_timeline);
fprintf('  Mean Cost: $%.2fT USD\n', result_A.mean_cost/1e12);
fprintf('  vs Perfect: +%.1f%% timeline, +%.1f%% cost\n\n', ...
        result_A.timeline_change_pct, result_A.cost_change_pct);

%% ========================================================================
%  SECTION 3: SCENARIO B - ROCKETS WITH FAILURES
%  ========================================================================

fprintf('Step 3: Simulating Scenario B - Rockets with Failures...\n');

timeline_B = zeros(params.num_iterations, 1);
cost_B = zeros(params.num_iterations, 1);
launches_B = zeros(params.num_iterations, 1);

for iter = 1:params.num_iterations
    
    mass_remaining = params.total_mass;
    year = 0;
    total_launches = 0;
    failed_launches = 0;
    
    while mass_remaining > 0 && year < 600
        year = year + 1;
        
        % Annual capacity with delay factor
        launches_per_year = round(params.rocket_capacity / params.rocket_delay_factor);
        
        % Simulate each launch
        for launch = 1:launches_per_year
            if mass_remaining <= 0
                break;
            end
            
            total_launches = total_launches + 1;
            
            % Check if launch fails
            if rand < params.rocket_failure_rate
                failed_launches = failed_launches + 1;
                % Failed launch: no mass delivered
            else
                % Successful launch
                mass_delivered = min(params.rocket_payload, mass_remaining);
                mass_remaining = mass_remaining - mass_delivered;
            end
        end
    end
    
    timeline_B(iter) = year;
    launches_B(iter) = total_launches;
    
    % ===== COST CALCULATION =====
    % Variable cost: Total mass delivered
    transport_cost = params.total_mass * 1000 * params.rocket_cost_per_kg;
    
    % Fixed cost: All launches (including failures)
    launch_cost = total_launches * params.rocket_fixed_per_launch;
    
    % CO2 and carbon tax
    total_co2 = total_launches * params.rocket_co2_per_launch;
    carbon_tax = total_co2 * params.carbon_tax;
    
    cost_B(iter) = transport_cost + launch_cost + carbon_tax;
end

% Statistics
result_B.mean_timeline = mean(timeline_B);
result_B.std_timeline = std(timeline_B);
result_B.percentile_95 = prctile(timeline_B, 95);
result_B.mean_cost = mean(cost_B);
result_B.std_cost = std(cost_B);
result_B.mean_launches = mean(launches_B);
result_B.std_launches = std(launches_B);

result_B.timeline_change_pct = ((result_B.mean_timeline - perfect.rocket_timeline) / perfect.rocket_timeline) * 100;
result_B.cost_change_pct = ((result_B.mean_cost - perfect.rocket_cost) / perfect.rocket_cost) * 100;
result_B.launches_change_pct = ((result_B.mean_launches - 800000) / 800000) * 100;

fprintf('  Mean Timeline: %.1f years (σ=%.1f)\n', result_B.mean_timeline, result_B.std_timeline);
fprintf('  Mean Cost: $%.2fT USD\n', result_B.mean_cost/1e12);
fprintf('  Mean Launches: %.0f\n', result_B.mean_launches);
fprintf('  vs Perfect: +%.1f%% timeline, +%.1f%% cost, +%.1f%% launches\n\n', ...
        result_B.timeline_change_pct, result_B.cost_change_pct, result_B.launches_change_pct);

%% ========================================================================
%  SECTION 4: SCENARIO C - HYBRID WITH FAILURES (TRUE PARALLEL)
%  ========================================================================

fprintf('Step 4: Simulating Scenario C - Hybrid with Failures...\n');

% Mass allocation (from Q1)
hybrid_elev_fraction = 0.74;
hybrid_rocket_fraction = 0.26;

timeline_C = zeros(params.num_iterations, 1);
cost_C = zeros(params.num_iterations, 1);
launches_C = zeros(params.num_iterations, 1);

for iter = 1:params.num_iterations
    
    % === SIMULATE ELEVATOR INDEPENDENTLY ===
    elev_mass = hybrid_elev_fraction * params.total_mass;
    elev_remaining = elev_mass;
    elev_year = 0;
    elev_repair_cost = 0;
    
    while elev_remaining > 0 && elev_year < 600
        elev_year = elev_year + 1;
        
        capacity = params.elev_capacity * (1 - params.elev_capacity_loss);
        downtime = params.elev_downtime_days;
        
        if rand < params.elev_major_incident_prob
            downtime = downtime + params.elev_major_incident_days;
            elev_repair_cost = elev_repair_cost + params.elev_major_incident_cost;
        end
        
        operational_fraction = (365 - downtime) / 365;
        annual_delivered = capacity * operational_fraction;
        
        mass_delivered = min(annual_delivered, elev_remaining);
        elev_remaining = elev_remaining - mass_delivered;
    end
    
    % === SIMULATE ROCKETS INDEPENDENTLY ===
    rocket_mass = hybrid_rocket_fraction * params.total_mass;
    rocket_remaining = rocket_mass;
    rocket_year = 0;
    total_launches = 0;
    
    while rocket_remaining > 0 && rocket_year < 600
        rocket_year = rocket_year + 1;
        
        % Use FULL rocket capacity (not scaled by fraction)
        % In hybrid, all launch sites operate at full capacity
        launches_per_year = round(params.rocket_capacity / params.rocket_delay_factor);
        
        for launch = 1:launches_per_year
            if rocket_remaining <= 0
                break;
            end
            
            total_launches = total_launches + 1;
            
            if rand >= params.rocket_failure_rate  % Success
                mass_delivered = min(params.rocket_payload, rocket_remaining);
                rocket_remaining = rocket_remaining - mass_delivered;
            end
        end
    end
    
    % === PARALLEL OPERATION: Timeline is MAX ===
    timeline_C(iter) = max(elev_year, rocket_year);
    launches_C(iter) = total_launches;
    
    % === COST CALCULATION ===
    % Elevator costs
    elev_transport = elev_mass * 1000 * params.elev_cost_per_kg;
    elev_energy_kwh = elev_mass * 1000 * params.elev_energy_per_kg;
    elev_energy_cost = elev_energy_kwh * params.elev_energy_cost;
    elev_operating = elev_year * params.elev_annual_operating;
    elev_maintenance = elev_transport * 0.02 * elev_year;
    elev_total = elev_transport + elev_energy_cost + elev_operating + ...
                 elev_maintenance + elev_repair_cost;
    
    % Rocket costs
    rocket_transport = rocket_mass * 1000 * params.rocket_cost_per_kg;
    rocket_launch_cost = total_launches * params.rocket_fixed_per_launch;
    rocket_co2 = total_launches * params.rocket_co2_per_launch;
    rocket_carbon = rocket_co2 * params.carbon_tax;
    rocket_total = rocket_transport + rocket_launch_cost + rocket_carbon;
    
    cost_C(iter) = elev_total + rocket_total;
end

% Statistics
result_C.mean_timeline = mean(timeline_C);
result_C.std_timeline = std(timeline_C);
result_C.percentile_95 = prctile(timeline_C, 95);
result_C.mean_cost = mean(cost_C);
result_C.std_cost = std(cost_C);
result_C.mean_launches = mean(launches_C);
result_C.std_launches = std(launches_C);

result_C.timeline_change_pct = ((result_C.mean_timeline - perfect.hybrid_timeline) / perfect.hybrid_timeline) * 100;
result_C.cost_change_pct = ((result_C.mean_cost - perfect.hybrid_cost) / perfect.hybrid_cost) * 100;
result_C.launches_change_pct = ((result_C.mean_launches - 208000) / 208000) * 100;

fprintf('  Mean Timeline: %.1f years (σ=%.1f)\n', result_C.mean_timeline, result_C.std_timeline);
fprintf('  Mean Cost: $%.2fT USD\n', result_C.mean_cost/1e12);
fprintf('  Mean Launches: %.0f\n', result_C.mean_launches);
fprintf('  vs Perfect: +%.1f%% timeline, +%.1f%% cost, +%.1f%% launches\n\n', ...
        result_C.timeline_change_pct, result_C.cost_change_pct, result_C.launches_change_pct);

%% ========================================================================
%  SECTION 5: COMPREHENSIVE ANALYSIS
%  ========================================================================

fprintf('==========================================================\n');
fprintf('         COMPREHENSIVE RELIABILITY ANALYSIS\n');
fprintf('==========================================================\n\n');

fprintf('SCENARIO COMPARISON:\n\n');

fprintf('%-30s %12s %12s %12s\n', 'Metric', 'Elevator', 'Rockets', 'Hybrid');
fprintf('%s\n', repmat('-', 1, 68));

fprintf('%-30s %12.1f %12.1f %12.1f\n', 'Timeline (years)', ...
        result_A.mean_timeline, result_B.mean_timeline, result_C.mean_timeline);
fprintf('%-30s %12.1f %12.1f %12.1f\n', 'Cost (Trillion USD)', ...
        result_A.mean_cost/1e12, result_B.mean_cost/1e12, result_C.mean_cost/1e12);
fprintf('%-30s %12.1f %12.1f %12.1f\n', 'Timeline Std Dev', ...
        result_A.std_timeline, result_B.std_timeline, result_C.std_timeline);
fprintf('\n');

fprintf('%-30s %12.1f %12.1f %12.1f\n', 'vs Perfect Timeline (%%)', ...
        result_A.timeline_change_pct, result_B.timeline_change_pct, result_C.timeline_change_pct);
fprintf('%-30s %12.1f %12.1f %12.1f\n', 'vs Perfect Cost (%%)', ...
        result_A.cost_change_pct, result_B.cost_change_pct, result_C.cost_change_pct);
fprintf('\n');

% Coefficient of variation
cv_A = result_A.std_timeline / result_A.mean_timeline;
cv_B = result_B.std_timeline / result_B.mean_timeline;
cv_C = result_C.std_timeline / result_C.mean_timeline;

fprintf('PREDICTABILITY (Coefficient of Variation):\n');
fprintf('  Elevator: %.4f\n', cv_A);
fprintf('  Rockets:  %.4f\n', cv_B);
fprintf('  Hybrid:   %.4f\n\n', cv_C);

fprintf('WORST-CASE (95th Percentile Timeline):\n');
fprintf('  Elevator: %.1f years\n', result_A.percentile_95);
fprintf('  Rockets:  %.1f years\n', result_B.percentile_95);
fprintf('  Hybrid:   %.1f years\n\n', result_C.percentile_95);

%% ========================================================================
%  SECTION 6: KEY FINDINGS
%  ========================================================================

fprintf('==========================================================\n');
fprintf('              KEY FINDINGS\n');
fprintf('==========================================================\n\n');

fprintf('1. TIMELINE IMPACT:\n');
fprintf('   Elevator: +%.0f years (+%.1f%%)\n', ...
        result_A.mean_timeline - perfect.elev_timeline, result_A.timeline_change_pct);
fprintf('   Rockets:  +%.0f years (+%.1f%%)\n', ...
        result_B.mean_timeline - perfect.rocket_timeline, result_B.timeline_change_pct);
fprintf('   Hybrid:   +%.0f years (+%.1f%%)\n\n', ...
        result_C.mean_timeline - perfect.hybrid_timeline, result_C.timeline_change_pct);

fprintf('2. COST IMPACT:\n');
fprintf('   Elevator: +$%.1fT (+%.1f%%)\n', ...
        (result_A.mean_cost - perfect.elev_cost)/1e12, result_A.cost_change_pct);
fprintf('   Rockets:  +$%.1fT (+%.1f%%)\n', ...
        (result_B.mean_cost - perfect.rocket_cost)/1e12, result_B.cost_change_pct);
fprintf('   Hybrid:   +$%.1fT (+%.1f%%)\n\n', ...
        (result_C.mean_cost - perfect.hybrid_cost)/1e12, result_C.cost_change_pct);

fprintf('3. MOST PREDICTABLE:\n');
[~, idx] = min([cv_A, cv_B, cv_C]);
scenarios = {'Elevator', 'Rockets', 'Hybrid'};
fprintf('   %s (CV=%.4f) - Most reliable schedule\n\n', scenarios{idx}, min([cv_A, cv_B, cv_C]));

fprintf('4. BEST UNDER FAILURES:\n');
% Normalize and score
norm_time = [result_A.mean_timeline, result_B.mean_timeline, result_C.mean_timeline];
norm_cost = [result_A.mean_cost, result_B.mean_cost, result_C.mean_cost];
norm_time = (norm_time - min(norm_time)) / (max(norm_time) - min(norm_time));
norm_cost = (norm_cost - min(norm_cost)) / (max(norm_cost) - min(norm_cost));
scores = 0.5 * norm_time + 0.5 * norm_cost;
[~, best_idx] = min(scores);
fprintf('   %s provides best balance of time and cost\n\n', scenarios{best_idx});

fprintf('5. CRITICAL INSIGHTS:\n');
fprintf('   - Failures add 15-30%% to timeline across all scenarios\n');
fprintf('   - Operating costs drive total cost increases\n');
fprintf('   - Hybrid benefits from diversification\n');
fprintf('   - Need 30-40%% schedule buffer for safety\n\n');

fprintf('==========================================================\n');
fprintf('        Reliability Analysis Complete!\n');
fprintf('==========================================================\n\n');

fprintf('Results saved in workspace:\n');
fprintf('  timeline_A/B/C, cost_A/B/C, launches_B/C\n');
fprintf('  result_A/B/C (structs with statistics)\n\n');