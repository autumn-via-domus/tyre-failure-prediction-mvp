-- ============================================================
-- EV Predictive Maintenance MVP — Database Schema
-- Единый временной ряд телеметрии электромобиля (2020–2025)
-- ============================================================
-- Таблица 1: сырая телеметрия (все 30 колонок из датасета)
CREATE TABLE IF NOT EXISTS raw_ev_telemetry (
    id BIGSERIAL PRIMARY KEY,
    timestamp TIMESTAMPTZ NOT NULL,
    soc NUMERIC(6, 2),
    soh NUMERIC(6, 2),
    battery_voltage NUMERIC(8, 3),
    battery_current NUMERIC(8, 3),
    battery_temperature NUMERIC(6, 2),
    charge_cycles NUMERIC(10, 2),
    motor_temperature NUMERIC(6, 2),
    motor_vibration NUMERIC(8, 3),
    motor_torque NUMERIC(8, 3),
    motor_rpm NUMERIC(8, 2),
    power_consumption NUMERIC(8, 3),
    brake_pad_wear NUMERIC(6, 3),
    brake_pressure NUMERIC(8, 3),
    reg_brake_efficiency NUMERIC(6, 3),
    tire_pressure NUMERIC(6, 3),
    tire_temperature NUMERIC(6, 2),
    suspension_load NUMERIC(8, 3),
    ambient_temperature NUMERIC(6, 2),
    ambient_humidity NUMERIC(6, 2),
    load_weight NUMERIC(8, 3),
    driving_speed NUMERIC(6, 2),
    distance_traveled NUMERIC(12, 3),
    idle_time NUMERIC(10, 2),
    route_roughness NUMERIC(6, 3),
    rul NUMERIC(12, 2),
    failure_probability INTEGER,
    maintenance_type INTEGER,
    ttf NUMERIC(12, 2),
    component_health_score NUMERIC(6, 3),
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_raw_timestamp ON raw_ev_telemetry (timestamp);
-- Таблица 2: очищенные данные + feature engineering
CREATE TABLE IF NOT EXISTS processed_ev_telemetry (
    id BIGSERIAL PRIMARY KEY,
    timestamp TIMESTAMPTZ NOT NULL,
    -- Сырые ключевые признаки
    tire_pressure NUMERIC(6, 3),
    tire_temperature NUMERIC(6, 2),
    driving_speed NUMERIC(6, 2),
    load_weight NUMERIC(8, 3),
    suspension_load NUMERIC(8, 3),
    ambient_temperature NUMERIC(6, 2),
    ambient_humidity NUMERIC(6, 2),
    route_roughness NUMERIC(6, 3),
    distance_traveled NUMERIC(12, 3),
    brake_pad_wear NUMERIC(6, 3),
    -- Производные фичи
    pressure_change NUMERIC(8, 4),
    temperature_change NUMERIC(8, 4),
    speed_change NUMERIC(8, 4),
    pressure_ma_30 NUMERIC(6, 3),
    temperature_ma_30 NUMERIC(6, 2),
    pressure_std_30 NUMERIC(8, 4),
    pressure_deviation NUMERIC(6, 3),
    pressure_temp_ratio NUMERIC(8, 4),
    -- Целевые переменные
    rul NUMERIC(12, 2),
    ttf NUMERIC(12, 2),
    failure INTEGER,
    -- Служебное
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_processed_timestamp ON processed_ev_telemetry (timestamp);
CREATE INDEX IF NOT EXISTS idx_processed_failure ON processed_ev_telemetry (failure);
-- Таблица 3: витрина для ML
CREATE TABLE IF NOT EXISTS ml_features (
    id BIGSERIAL PRIMARY KEY,
    timestamp TIMESTAMPTZ NOT NULL,
    tire_pressure NUMERIC(6, 3),
    tire_temperature NUMERIC(6, 2),
    driving_speed NUMERIC(6, 2),
    load_weight NUMERIC(8, 3),
    suspension_load NUMERIC(8, 3),
    ambient_temperature NUMERIC(6, 2),
    ambient_humidity NUMERIC(6, 2),
    route_roughness NUMERIC(6, 3),
    distance_traveled NUMERIC(12, 3),
    brake_pad_wear NUMERIC(6, 3),
    pressure_change NUMERIC(8, 4),
    temperature_change NUMERIC(8, 4),
    speed_change NUMERIC(8, 4),
    pressure_ma_30 NUMERIC(6, 3),
    temperature_ma_30 NUMERIC(6, 2),
    pressure_std_30 NUMERIC(8, 4),
    pressure_deviation NUMERIC(6, 3),
    pressure_temp_ratio NUMERIC(8, 4),
    target_ttf NUMERIC(12, 2),
    target_failure INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_ml_timestamp ON ml_features (timestamp);
CREATE INDEX IF NOT EXISTS idx_ml_failure ON ml_features (target_failure);
-- Комментарии
COMMENT ON TABLE raw_ev_telemetry IS 'Сырая телеметрия ЭМ с шагом 15 мин (2020–2025)';
COMMENT ON TABLE processed_ev_telemetry IS 'Очищенные данные + производные фичи';
COMMENT ON TABLE ml_features IS 'Витрина признаков и целевых для ML';