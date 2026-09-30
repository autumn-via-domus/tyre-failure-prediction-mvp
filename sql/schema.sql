-- ============================================================
-- Tyre Failure Prediction MVP — Database Schema
-- ============================================================
-- Таблица 1: сырые данные из датасета
CREATE TABLE IF NOT EXISTS raw_tyre_data (
    id BIGSERIAL PRIMARY KEY,
    vehicle_id TEXT,
    tyre_id TEXT,
    timestamp TIMESTAMPTZ,
    pressure NUMERIC(6, 3),
    temperature NUMERIC(6, 2),
    speed NUMERIC(6, 2),
    load NUMERIC(8, 2),
    time_to_failure NUMERIC(10, 2),
    failure BOOLEAN,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
-- Таблица 2: очищенные и обогащённые данные
CREATE TABLE IF NOT EXISTS processed_tyre_data (
    id BIGSERIAL PRIMARY KEY,
    vehicle_id TEXT,
    tyre_id TEXT,
    timestamp TIMESTAMPTZ,
    pressure NUMERIC(6, 3),
    temperature NUMERIC(6, 2),
    speed NUMERIC(6, 2),
    load NUMERIC(8, 2),
    pressure_change NUMERIC(6, 3),
    temp_change NUMERIC(6, 2),
    pressure_ma_30 NUMERIC(6, 3),
    temp_ma_30 NUMERIC(6, 2),
    pressure_deviation NUMERIC(6, 3),
    time_to_failure NUMERIC(10, 2),
    failure BOOLEAN,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
-- Таблица 3: витрина для ML
CREATE TABLE IF NOT EXISTS ml_features (
    id BIGSERIAL PRIMARY KEY,
    vehicle_id TEXT,
    tyre_id TEXT,
    timestamp TIMESTAMPTZ,
    pressure NUMERIC(6, 3),
    temperature NUMERIC(6, 2),
    speed NUMERIC(6, 2),
    load NUMERIC(8, 2),
    pressure_change NUMERIC(6, 3),
    temp_change NUMERIC(6, 2),
    pressure_ma_30 NUMERIC(6, 3),
    temp_ma_30 NUMERIC(6, 2),
    pressure_deviation NUMERIC(6, 3),
    target_ttf NUMERIC(10, 2),
    target_failure BOOLEAN,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
-- Индексы
CREATE INDEX IF NOT EXISTS idx_raw_tyre_id ON raw_tyre_data (tyre_id);
CREATE INDEX IF NOT EXISTS idx_raw_timestamp ON raw_tyre_data (timestamp);
CREATE INDEX IF NOT EXISTS idx_processed_tyre_id ON processed_tyre_data (tyre_id);
CREATE INDEX IF NOT EXISTS idx_ml_features_tyre ON ml_features (tyre_id);
CREATE INDEX IF NOT EXISTS idx_ml_features_time ON ml_features (timestamp);
-- Комментарии
COMMENT ON TABLE raw_tyre_data IS 'Сырые данные из исходного датасета';
COMMENT ON TABLE processed_tyre_data IS 'Очищенные данные + feature engineering';
COMMENT ON TABLE ml_features IS 'Витрина признаков для ML-модели';