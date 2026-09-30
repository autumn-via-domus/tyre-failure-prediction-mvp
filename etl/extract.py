"""
Модуль Extract: скачивание и чтение сырых данных.

Функции:
- download_dataset(): скачивает датасет с Kaggle через kagglehub.
- read_raw_data(): читает CSV в pandas DataFrame.
- get_dataset_info(): выводит базовую информацию о датасете.
"""

import logging
from pathlib import Path

import kagglehub
import pandas as pd

# Настройка логирования
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)
logger = logging.getLogger(__name__)

# Константы
DATASET_HANDLE = "datasetengineer/eviot-predictivemaint-dataset"
RAW_DATA_DIR = Path("data/raw")
RAW_DATA_FILE = RAW_DATA_DIR / "EV_Predictive_Maintenance_Dataset_15min.csv"


def download_dataset() -> Path:
    """
    Скачивает датасет с Kaggle и копирует его в data/raw/.

    Returns:
        Path: путь к скачанному CSV-файлу.
    """
    logger.info("Скачивание датасета: %s", DATASET_HANDLE)
    cache_path = Path(kagglehub.dataset_download(DATASET_HANDLE))
    logger.info("Датасет скачан в кэш: %s", cache_path)

    # Ищем CSV-файл в кэше
    csv_files = list(cache_path.glob("*.csv"))
    if not csv_files:
        raise FileNotFoundError(f"CSV-файл не найден в {cache_path}")

    source_csv = csv_files[0]
    logger.info("Найден CSV: %s", source_csv.name)

    # Копируем в data/raw/
    RAW_DATA_DIR.mkdir(parents=True, exist_ok=True)
    import shutil

    shutil.copy(source_csv, RAW_DATA_FILE)
    logger.info("Файл скопирован в: %s", RAW_DATA_FILE)

    return RAW_DATA_FILE


def read_raw_data(file_path: Path = RAW_DATA_FILE) -> pd.DataFrame:
    """
    Читает CSV-файл в pandas DataFrame.

    Args:
        file_path: путь к CSV-файлу.

    Returns:
        pd.DataFrame: сырые данные.
    """
    if not file_path.exists():
        raise FileNotFoundError(
            f"Файл не найден: {file_path}. Сначала запустите download_dataset()."
        )

    logger.info("Чтение данных из: %s", file_path)
    df = pd.read_csv(file_path)
    logger.info("Загружено %d строк, %d колонок", len(df), len(df.columns))

    return df


def get_dataset_info(df: pd.DataFrame) -> None:
    """
    Выводит базовую информацию о датасете.

    Args:
        df: DataFrame с данными.
    """
    print("=" * 60)
    print("ИНФОРМАЦИЯ О ДАТАСЕТЕ")
    print("=" * 60)

    print(f"\nРазмер: {df.shape[0]:,} строк × {df.shape[1]} колонок")

    print("\n--- Колонки ---")
    for i, col in enumerate(df.columns, 1):
        print(f"{i:2d}. {col} ({df[col].dtype})")

    print("\n--- Пропуски ---")
    missing = df.isnull().sum()
    missing = missing[missing > 0]
    if len(missing) > 0:
        for col, count in missing.items():
            print(f"{col}: {count} ({count / len(df) * 100:.1f}%)")
    else:
        print("Пропусков нет")

    print("\n--- Первые 5 строк ---")
    print(df.head())

    print("\n" + "=" * 60)


if __name__ == "__main__":
    # Скачиваем, если файла ещё нет
    if not RAW_DATA_FILE.exists():
        download_dataset()

    # Читаем и выводим информацию
    df = read_raw_data()
    get_dataset_info(df)