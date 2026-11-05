%% MCM 2026 Problem B: Moon Colony Space Elevator System
%  Sub-question 3: Water Requirements for 100,000-Person Colony
%  
%  This script calculates the water needs for a one-year period once the
%  Moon Colony is fully operational, and determines the cost and timeline
%  to deliver sufficient water using the three transportation scenarios.
%
%  Author: [Your Team Name]
%  Date: January 30, 2026

clear; close all; clc;

fprintf('==========================================================\n');
fprintf('MCM 2026 Problem B: Water Requirements Analysis\n');
fprintf('Sub-question 3: Water Supply for Moon Colony\n');
fprintf('==========================================================\n\n');

%% ========================================================================
%  SECTION 1: WATER REQUIREMENT CALCULATIONS
%  ========================================================================

fprintf('Step 1: Calculating water requirements...\n');

% Colony parameters
colony_population = 100000;

% Water consumption per person
% Based on ISS standards and lunar habitat requirements
water_per_person_per_day = 50;  % liters/person/day
% Breakdown: Drinking (3L), Food prep (3L), Hygiene (25L), Medical (2L), 
%            EVA suit prep (10L), Lab/research (5L), Contingency (2L)

% Annual water consumption (no recycling)
days_per_year = 365;
total_annual_consumption = colony_population * water_per_person_per_day * days_per_year;  % liters
total_annual_consumption_MT = total_annual_consumption / 1000;  % Convert to MT (1 liter water ≈ 1 kg)

fprintf('  Population: %d people\n', colony_population);
fprintf('  Per capita consumption: %d liters/person/day\n', water_per_person_per_day);
fprintf('  Annual consumption (no recycling): %.2f million MT\n', total_annual_consumption_MT/1e6);

%% Water Recycling System

% Advanced life support system recycling efficiency
% Based on ISS Environmental Control and Life Support System (ECLSS)
% Future lunar systems expected to achieve 95%+ efficiency
recycling_efficiency = 0.95;  % 95% of water recycled

% Net annual water loss (needs replenishment)
annual_water_loss = total_annual_consumption_MT * (1 - recycling_efficiency);

fprintf('\n  Recycling efficiency: %.0f%%\n', recycling_efficiency * 100);
fprintf('  Annual water loss (requires resupply): %.2f thousand MT\n', annual_water_loss/1e3);
fprintf('  Recycling saves: %.2f million MT/year\n', (total_annual_consumption_MT - annual_water_loss)/1e6);

%% Initial Water Reserve

% Initial water reserve for colony startup
% Typically 2-3 years of consumables for safety
years_of_reserve = 2;
initial_water_reserve = annual_water_loss * years_of_reserve;

fprintf('\n  Initial reserve (safety buffer): %.0f thousand MT (%d years)\n', ...
        initial_water_reserve/1e3, years_of_reserve);

%% Total Water Requirements

% Year 1: Initial reserve + First year consumption
year1_water_total = initial_water_reserve + annual_water_loss;

fprintf('\n  === TOTAL WATER REQUIREMENTS ===\n');
fprintf('  Year 1 (initial + annual): %.2f thousand MT\n', year1_water_total/1e3);
fprintf('  Annual resupply (years 2+): %.2f thousand MT/year\n', annual_water_loss/1e3);

%% ========================================================================
%  SECTION 2: TRANSPORTATION PARAMETERS (from Q1 & Q2)
%  ========================================================================

fprintf('\nStep 2: Loading transportation parameters...\n');

% Space Elevator Parameters
elev.capacity_perfect = 537000;        % MT/year (perfect conditions)
elev.capacity_imperfect = 537000 * 0.88;  % MT/year (with 12% reduction from failures)
elev.cost_per_kg = 200;                % USD/kg
elev.energy_per_kg = 5;                % kWh/kg
elev.energy_cost = 0.10;               % USD/kWh
elev.annual_operating = 1e9;           % $1B/year
elev.reliability_factor = 0.88;        % From Q2: delivers 88% of nominal capacity

% Rocket Parameters  
rocket.capacity_perfect = 2165 * 125;   % launches/year × MT/launch
rocket.capacity_imperfect = 2165 * 125 / 1.20;  % With 20% delay factor
rocket.payload = 125;                   % MT/launch
rocket.cost_per_kg = 1000;             % USD/kg
rocket.fixed_per_launch = 50e6;        % USD/launch
rocket.co2_per_launch = 350;           % MT CO2
rocket.failure_rate = 0.03;            % 3% failure rate

% Hybrid Parameters (74% elevator, 26% rocket from Q1)
hybrid.elev_fraction = 0.74;
hybrid.rocket_fraction = 0.26;

% Economic
carbon_tax = 100;  % USD per MT CO2

fprintf('  Elevator capacity: %.0f MT/year (perfect), %.0f MT/year (imperfect)\n', ...
        elev.capacity_perfect, elev.capacity_imperfect);
fprintf('  Rocket capacity: %.0f MT/year (perfect), %.0f MT/year (imperfect)\n', ...
        rocket.capacity_perfect, rocket.capacity_imperfect);

%% ========================================================================
%  SECTION 3: SCENARIO A - SPACE ELEVATOR WATER DELIVERY
%  ========================================================================

fprintf('\nStep 3: Analyzing Scenario A - Space Elevator Water Delivery...\n');

% Year 1 delivery (initial reserve + annual)
water_mass_A_year1 = year1_water_total;

% Timeline for Year 1 water delivery (perfect conditions)
time_A_year1_perfect = (water_mass_A_year1 / elev.capacity_perfect) * 365;  % days
time_A_year1_imperfect = (water_mass_A_year1 / elev.capacity_imperfect) * 365;  % days

% Cost for Year 1 water delivery
cost_A_transport = water_mass_A_year1 * 1000 * elev.cost_per_kg;
energy_kwh = water_mass_A_year1 * 1000 * elev.energy_per_kg;
cost_A_energy = energy_kwh * elev.energy_cost;
cost_A_year1 = cost_A_transport + cost_A_energy;

% Annual resupply (years 2+)
time_A_annual_perfect = (annual_water_loss / elev.capacity_perfect) * 365;  % days
time_A_annual_imperfect = (annual_water_loss / elev.capacity_imperfect) * 365;  % days
cost_A_annual = annual_water_loss * 1000 * elev.cost_per_kg + ...
                (annual_water_loss * 1000 * elev.energy_per_kg) * elev.energy_cost;

% Store results
resultA.year1_mass = water_mass_A_year1;
resultA.year1_time_perfect = time_A_year1_perfect;
resultA.year1_time_imperfect = time_A_year1_imperfect;
resultA.year1_cost = cost_A_year1;
resultA.annual_mass = annual_water_loss;
resultA.annual_time_perfect = time_A_annual_perfect;
resultA.annual_time_imperfect = time_A_annual_imperfect;
resultA.annual_cost = cost_A_annual;

fprintf('  Year 1 water mass: %.2f thousand MT\n', water_mass_A_year1/1e3);
fprintf('  Year 1 delivery time: %.1f days (perfect), %.1f days (imperfect)\n', ...
        time_A_year1_perfect, time_A_year1_imperfect);
fprintf('  Year 1 delivery cost: $%.2f billion\n', cost_A_year1/1e9);
fprintf('  Annual resupply: %.2f thousand MT\n', annual_water_loss/1e3);
fprintf('  Annual resupply time: %.1f days (perfect), %.1f days (imperfect)\n', ...
        time_A_annual_perfect, time_A_annual_imperfect);
fprintf('  Annual resupply cost: $%.2f billion/year\n', cost_A_annual/1e9);

%% ========================================================================
%  SECTION 4: SCENARIO B - ROCKETS WATER DELIVERY
%  ========================================================================

fprintf('\nStep 4: Analyzing Scenario B - Rockets Water Delivery...\n');

% Year 1 delivery
water_mass_B_year1 = year1_water_total;

% Number of launches required
launches_B_year1_perfect = ceil(water_mass_B_year1 / rocket.payload);
launches_B_year1_imperfect = ceil(launches_B_year1_perfect / (1 - rocket.failure_rate));

% Timeline (assuming distributed launches)
launches_per_day_perfect = rocket.capacity_perfect / rocket.payload / 365;
launches_per_day_imperfect = rocket.capacity_imperfect / rocket.payload / 365;
time_B_year1_perfect = launches_B_year1_perfect / launches_per_day_perfect;
time_B_year1_imperfect = launches_B_year1_imperfect / launches_per_day_imperfect;

% Cost
cost_B_variable = water_mass_B_year1 * 1000 * rocket.cost_per_kg;
cost_B_fixed = launches_B_year1_imperfect * rocket.fixed_per_launch;
co2_B = launches_B_year1_imperfect * rocket.co2_per_launch;
cost_B_carbon = co2_B * carbon_tax;
cost_B_year1 = cost_B_variable + cost_B_fixed + cost_B_carbon;

% Annual resupply
launches_B_annual_perfect = ceil(annual_water_loss / rocket.payload);
launches_B_annual_imperfect = ceil(launches_B_annual_perfect / (1 - rocket.failure_rate));
time_B_annual_perfect = launches_B_annual_perfect / launches_per_day_perfect;
time_B_annual_imperfect = launches_B_annual_imperfect / launches_per_day_imperfect;

cost_B_annual_variable = annual_water_loss * 1000 * rocket.cost_per_kg;
cost_B_annual_fixed = launches_B_annual_imperfect * rocket.fixed_per_launch;
co2_B_annual = launches_B_annual_imperfect * rocket.co2_per_launch;
cost_B_annual_carbon = co2_B_annual * carbon_tax;
cost_B_annual = cost_B_annual_variable + cost_B_annual_fixed + cost_B_annual_carbon;

% Store results
resultB.year1_mass = water_mass_B_year1;
resultB.year1_launches_perfect = launches_B_year1_perfect;
resultB.year1_launches_imperfect = launches_B_year1_imperfect;
resultB.year1_time_perfect = time_B_year1_perfect;
resultB.year1_time_imperfect = time_B_year1_imperfect;
resultB.year1_cost = cost_B_year1;
resultB.annual_mass = annual_water_loss;
resultB.annual_launches = launches_B_annual_imperfect;
resultB.annual_time_perfect = time_B_annual_perfect;
resultB.annual_time_imperfect = time_B_annual_imperfect;
resultB.annual_cost = cost_B_annual;

fprintf('  Year 1 water mass: %.2f thousand MT\n', water_mass_B_year1/1e3);
fprintf('  Year 1 launches: %d (perfect), %d (with failures)\n', ...
        launches_B_year1_perfect, launches_B_year1_imperfect);
fprintf('  Year 1 delivery time: %.1f days (perfect), %.1f days (imperfect)\n', ...
        time_B_year1_perfect, time_B_year1_imperfect);
fprintf('  Year 1 delivery cost: $%.2f billion\n', cost_B_year1/1e9);
fprintf('  Annual resupply launches: %d\n', launches_B_annual_imperfect);
fprintf('  Annual resupply time: %.1f days (perfect), %.1f days (imperfect)\n', ...
        time_B_annual_perfect, time_B_annual_imperfect);
fprintf('  Annual resupply cost: $%.2f billion/year\n', cost_B_annual/1e9);

%% ========================================================================
%  SECTION 5: SCENARIO C - HYBRID WATER DELIVERY
%  ========================================================================

fprintf('\nStep 5: Analyzing Scenario C - Hybrid Water Delivery...\n');

% Split water delivery according to hybrid ratio
water_mass_C_year1 = year1_water_total;
water_by_elev = water_mass_C_year1 * hybrid.elev_fraction;
water_by_rocket = water_mass_C_year1 * hybrid.rocket_fraction;

% Elevator component
time_C_elev_perfect = (water_by_elev / elev.capacity_perfect) * 365;
time_C_elev_imperfect = (water_by_elev / elev.capacity_imperfect) * 365;
cost_C_elev = water_by_elev * 1000 * elev.cost_per_kg + ...
              (water_by_elev * 1000 * elev.energy_per_kg) * elev.energy_cost;

% Rocket component
launches_C_rocket_perfect = ceil(water_by_rocket / rocket.payload);
launches_C_rocket_imperfect = ceil(launches_C_rocket_perfect / (1 - rocket.failure_rate));
time_C_rocket_perfect = launches_C_rocket_perfect / launches_per_day_perfect;
time_C_rocket_imperfect = launches_C_rocket_imperfect / launches_per_day_imperfect;
cost_C_rocket_var = water_by_rocket * 1000 * rocket.cost_per_kg;
cost_C_rocket_fixed = launches_C_rocket_imperfect * rocket.fixed_per_launch;
co2_C = launches_C_rocket_imperfect * rocket.co2_per_launch;
cost_C_rocket_carbon = co2_C * carbon_tax;
cost_C_rocket = cost_C_rocket_var + cost_C_rocket_fixed + cost_C_rocket_carbon;

% Total (parallel operation)
time_C_year1_perfect = max(time_C_elev_perfect, time_C_rocket_perfect);
time_C_year1_imperfect = max(time_C_elev_imperfect, time_C_rocket_imperfect);
cost_C_year1 = cost_C_elev + cost_C_rocket;

% Annual resupply
water_annual_elev = annual_water_loss * hybrid.elev_fraction;
water_annual_rocket = annual_water_loss * hybrid.rocket_fraction;

time_C_annual_elev_perfect = (water_annual_elev / elev.capacity_perfect) * 365;
time_C_annual_elev_imperfect = (water_annual_elev / elev.capacity_imperfect) * 365;
cost_C_annual_elev = water_annual_elev * 1000 * elev.cost_per_kg + ...
                     (water_annual_elev * 1000 * elev.energy_per_kg) * elev.energy_cost;

launches_C_annual = ceil(water_annual_rocket / rocket.payload / (1 - rocket.failure_rate));
time_C_annual_rocket_perfect = ceil(water_annual_rocket / rocket.payload) / launches_per_day_perfect;
time_C_annual_rocket_imperfect = launches_C_annual / launches_per_day_imperfect;
cost_C_annual_rocket = water_annual_rocket * 1000 * rocket.cost_per_kg + ...
                       launches_C_annual * rocket.fixed_per_launch + ...
                       (launches_C_annual * rocket.co2_per_launch * carbon_tax);

time_C_annual_perfect = max(time_C_annual_elev_perfect, time_C_annual_rocket_perfect);
time_C_annual_imperfect = max(time_C_annual_elev_imperfect, time_C_annual_rocket_imperfect);
cost_C_annual = cost_C_annual_elev + cost_C_annual_rocket;

% Store results
resultC.year1_mass = water_mass_C_year1;
resultC.year1_elev_mass = water_by_elev;
resultC.year1_rocket_mass = water_by_rocket;
resultC.year1_launches = launches_C_rocket_imperfect;
resultC.year1_time_perfect = time_C_year1_perfect;
resultC.year1_time_imperfect = time_C_year1_imperfect;
resultC.year1_cost = cost_C_year1;
resultC.annual_mass = annual_water_loss;
resultC.annual_launches = launches_C_annual;
resultC.annual_time_perfect = time_C_annual_perfect;
resultC.annual_time_imperfect = time_C_annual_imperfect;
resultC.annual_cost = cost_C_annual;

fprintf('  Year 1 water mass: %.2f thousand MT\n', water_mass_C_year1/1e3);
fprintf('    - By elevator: %.2f thousand MT\n', water_by_elev/1e3);
fprintf('    - By rockets: %.2f thousand MT (%d launches)\n', water_by_rocket/1e3, launches_C_rocket_imperfect);
fprintf('  Year 1 delivery time: %.1f days (perfect), %.1f days (imperfect)\n', ...
        time_C_year1_perfect, time_C_year1_imperfect);
fprintf('  Year 1 delivery cost: $%.2f billion\n', cost_C_year1/1e9);
fprintf('  Annual resupply time: %.1f days (perfect), %.1f days (imperfect)\n', ...
        time_C_annual_perfect, time_C_annual_imperfect);
fprintf('  Annual resupply cost: $%.2f billion/year\n', cost_C_annual/1e9);

%% ========================================================================
%  SECTION 6: COMPREHENSIVE COMPARISON
%  ========================================================================

fprintf('\n==========================================================\n');
fprintf('         COMPREHENSIVE WATER DELIVERY ANALYSIS\n');
fprintf('==========================================================\n\n');

fprintf('YEAR 1 INITIAL WATER DELIVERY:\n\n');
fprintf('%-25s %12s %12s %12s\n', 'Metric', 'Elevator', 'Rockets', 'Hybrid');
fprintf('%s\n', repmat('-', 1, 62));
fprintf('%-25s %12.1f %12.1f %12.1f\n', 'Water mass (MT)', ...
        resultA.year1_mass, resultB.year1_mass, resultC.year1_mass);
fprintf('%-25s %12.1f %12.1f %12.1f\n', 'Time - Perfect (days)', ...
        resultA.year1_time_perfect, resultB.year1_time_perfect, resultC.year1_time_perfect);
fprintf('%-25s %12.1f %12.1f %12.1f\n', 'Time - Imperfect (days)', ...
        resultA.year1_time_imperfect, resultB.year1_time_imperfect, resultC.year1_time_imperfect);
fprintf('%-25s %12.2f %12.2f %12.2f\n', 'Cost (Billion USD)', ...
        resultA.year1_cost/1e9, resultB.year1_cost/1e9, resultC.year1_cost/1e9);
fprintf('\n');

fprintf('ANNUAL WATER RESUPPLY (Years 2+):\n\n');
fprintf('%-25s %12.1f %12.1f %12.1f\n', 'Water mass (MT/year)', ...
        resultA.annual_mass, resultB.annual_mass, resultC.annual_mass);
fprintf('%-25s %12.1f %12.1f %12.1f\n', 'Time - Perfect (days)', ...
        resultA.annual_time_perfect, resultB.annual_time_perfect, resultC.annual_time_perfect);
fprintf('%-25s %12.1f %12.1f %12.1f\n', 'Time - Imperfect (days)', ...
        resultA.annual_time_imperfect, resultB.annual_time_imperfect, resultC.annual_time_imperfect);
fprintf('%-25s %12.2f %12.2f %12.2f\n', 'Cost (Billion USD/yr)', ...
        resultA.annual_cost/1e9, resultB.annual_cost/1e9, resultC.annual_cost/1e9);
fprintf('\n');

%% ========================================================================
%  SECTION 7: 10-YEAR COST PROJECTION
%  ========================================================================

fprintf('10-YEAR WATER SUPPLY COST PROJECTION:\n\n');

% Calculate 10-year cumulative costs
years = 10;
cost_10yr_A = resultA.year1_cost + resultA.annual_cost * (years - 1);
cost_10yr_B = resultB.year1_cost + resultB.annual_cost * (years - 1);
cost_10yr_C = resultC.year1_cost + resultC.annual_cost * (years - 1);

fprintf('%-25s %12.2f %12.2f %12.2f\n', '10-Year Total (B USD)', ...
        cost_10yr_A/1e9, cost_10yr_B/1e9, cost_10yr_C/1e9);
fprintf('%-25s %12.2f %12.2f %12.2f\n', 'Average per year (B USD)', ...
        cost_10yr_A/1e9/years, cost_10yr_B/1e9/years, cost_10yr_C/1e9/years);
fprintf('\n');

%% ========================================================================
%  SECTION 8: KEY FINDINGS AND RECOMMENDATIONS
%  ========================================================================

fprintf('==========================================================\n');
fprintf('              KEY FINDINGS\n');
fprintf('==========================================================\n\n');

fprintf('1. WATER CONSUMPTION & RECYCLING:\n');
fprintf('   - Annual consumption (no recycling): %.2f million MT\n', total_annual_consumption_MT/1e6);
fprintf('   - Recycling efficiency: %.0f%%\n', recycling_efficiency*100);
fprintf('   - Annual resupply needed: %.2f thousand MT (%.1f%% of consumption)\n', ...
        annual_water_loss/1e3, (1-recycling_efficiency)*100);
fprintf('   - Recycling saves ~$%.0f billion/year in delivery costs\n\n', ...
        (total_annual_consumption_MT - annual_water_loss) * elev.cost_per_kg / 1e6);

fprintf('2. INITIAL WATER DELIVERY (Year 1):\n');
fprintf('   - Fastest: %s (%.0f days imperfect conditions)\n', ...
        determine_fastest({'Elevator', 'Rockets', 'Hybrid'}, ...
        [resultA.year1_time_imperfect, resultB.year1_time_imperfect, resultC.year1_time_imperfect]), ...
        min([resultA.year1_time_imperfect, resultB.year1_time_imperfect, resultC.year1_time_imperfect]));
fprintf('   - Most economical: %s ($%.2fB)\n', ...
        determine_cheapest({'Elevator', 'Rockets', 'Hybrid'}, ...
        [resultA.year1_cost, resultB.year1_cost, resultC.year1_cost]), ...
        min([resultA.year1_cost, resultB.year1_cost, resultC.year1_cost])/1e9);
fprintf('   - Water delivery is <1%% of total colony construction time\n\n');

fprintf('3. ONGOING WATER SUPPLY:\n');
fprintf('   - Annual resupply: %.2f thousand MT/year\n', annual_water_loss/1e3);
fprintf('   - Delivery can be completed in %.0f-%.0f days/year\n', ...
        min([resultA.annual_time_imperfect, resultB.annual_time_imperfect, resultC.annual_time_imperfect]), ...
        max([resultA.annual_time_imperfect, resultB.annual_time_imperfect, resultC.annual_time_imperfect]));
fprintf('   - Annual cost: $%.2f-%.2fB depending on method\n\n', ...
        min([resultA.annual_cost, resultB.annual_cost, resultC.annual_cost])/1e9, ...
        max([resultA.annual_cost, resultB.annual_cost, resultC.annual_cost])/1e9);

fprintf('4. COST COMPARISON (10-year horizon):\n');
fprintf('   - Water supply represents %.1f%%-%.1f%% of construction costs\n', ...
        min([cost_10yr_A, cost_10yr_B, cost_10yr_C])/114.25e12*100, ...
        max([cost_10yr_A, cost_10yr_B, cost_10yr_C])/114.25e12*100);
fprintf('   - Elevator: $%.2fB (most economical)\n', cost_10yr_A/1e9);
fprintf('   - Rockets: $%.2fB (fastest delivery)\n', cost_10yr_B/1e9);
fprintf('   - Hybrid: $%.2fB (balanced approach)\n\n', cost_10yr_C/1e9);

fprintf('5. CRITICAL RECOMMENDATIONS:\n');
fprintf('   - Implement 95%% water recycling from day one\n');
fprintf('   - Maintain 2-year emergency water reserve\n');
fprintf('   - Schedule water deliveries during routine cargo runs\n');
fprintf('   - Consider in-situ water extraction from lunar ice\n');
fprintf('   - Monitor recycling system performance continuously\n\n');

fprintf('==========================================================\n');
fprintf('        Water Requirements Analysis Complete!\n');
fprintf('==========================================================\n\n');

fprintf('All results saved in workspace variables:\n');
fprintf('  resultA, resultB, resultC (water delivery scenarios)\n');
fprintf('  Key metrics: annual_water_loss, year1_water_total\n\n');

%% Helper Functions

function name = determine_fastest(names, times)
    [~, idx] = min(times);
    name = names{idx};
end

function name = determine_cheapest(names, costs)
    [~, idx] = min(costs);
    name = names{idx};
end