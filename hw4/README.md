# README.md

## Геномный анализ с использованием Nextflow и Docker

Этот проект реализует пайплайн для анализа геномных данных, включая процессы **FastQC**, **SPAdes**, **Quast**, **Prokka** и **Abricate**. Пайплайн управляется с помощью Nextflow и использует контейнеры Docker для обеспечения воспроизводимости.

---

## Содержание

1. [Предварительные требования](#предварительные-требования)
2. [Установка](#установка)
3. [Структура входных данных](#структура-входных-данных)
4. [Запуск пайплайна](#запуск-пайплайна)
5. [Описание работы пайплайна](#описание-работы-пайплайна)
6. [Результаты](#результаты)
7. [Диагностика ошибок](#диагностика-ошибок)

---

## Предварительные требования

Перед началом работы убедитесь, что ваш компьютер имеет установленный Linux с доступом в интернет. Требуются следующие компоненты:

- **Git** для клонирования репозитория.
- **Docker** для работы с контейнерами.
- **Nextflow** для запуска пайплайна.

---

## Установка

### Шаг 1: Установите Git
Если Git ещё не установлен:
```bash
sudo apt update
sudo apt install git -y
```

### Шаг 2: Установите Docker
1. Установите зависимости:
   ```bash
   sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
   ```
2. Добавьте официальный Docker репозиторий:
   ```bash
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
   echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   ```
3. Установите Docker:
   ```bash
   sudo apt update
   sudo apt install docker-ce -y
   ```

4. Проверьте установку:
   ```bash
   docker --version
   ```

5. (Опционально) Добавьте текущего пользователя в группу Docker:
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```

### Шаг 3: Установите Nextflow
1. Загрузите и установите Nextflow:
   ```bash
   curl -s https://get.nextflow.io | bash
   ```

2. Переместите Nextflow в директорию `/usr/local/bin` для глобального использования:
   ```bash
   sudo mv nextflow /usr/local/bin
   ```

3. Проверьте установку:
   ```bash
   nextflow -v
   ```

### Шаг 4: Клонируйте репозиторий проекта
Клонируйте этот репозиторий:
```bash
git clone git@github.com:VadimG2/DD_2024_private.git
cd DD_2024_private
```

---

## Структура входных данных

Ожидается следующая структура данных в директории `test_input`:

- `samples.csv`: CSV-файл с колонками:
  - `sample_id`: Идентификатор образца.
  - `read_1`: Имя файла с прямым чтением (FASTQ).
  - `read_2`: Имя файла с обратным чтением (FASTQ).
  - `assembly`: (опционально) Путь к предварительно собранной сборке (FASTA).
  
Пример:
```csv
sample_id,read_1,read_2,assembly
sample1,reads1_1.fastq,reads1_2.fastq,
sample2,reads2_1.fastq,reads2_2.fastq,
sample3,reads3_1.fastq,reads3_2.fastq,assembly_sample3.fasta
```

- FASTQ файлы (`reads1_1.fastq`, `reads1_2.fastq`, и т.д.) и опциональные сборки (`assembly_sample3.fasta`) должны находиться в папке `test_input`.

---

## Запуск пайплайна

1. Проверьте, что вы находитесь в корневой директории проекта (`DD_2024_private`).
2. Запустите пайплайн:
   ```bash
   nextflow run main.nf --with-docker
   ```

---

## Описание работы пайплайна

### Этапы анализа:

1. **FastQC**:
   - Анализ качества FASTQ файлов.
   - Результаты сохраняются в `test_output/fastqc`.

2. **SPAdes**:
   - Сборка генома для образцов без предварительно собранной сборки.
   - Результаты сохраняются в `test_output/spades/{sample_id}`.

3. **Quast**:
   - Оценка качества сборок.
   - Результаты сохраняются в `test_output/quast/{sample_id}`.

4. **Prokka**:
   - Аннотирование геномных сборок.
   - Результаты сохраняются в `test_output/prokka/{sample_id}`.

5. **Abricate**:
   - Анализ аннотированных сборок с использованием баз данных `ncbi` и `resfinder`.
   - Результаты сохраняются в `test_output/abricate/{sample_id}`.

---

## Результаты

После завершения пайплайна результаты будут находиться в папке `test_output`. Подкаталоги включают:

- **`fastqc`**: Качество чтений.
- **`spades`**: Собранные геномы.
- **`quast`**: Оценка качества сборок.
- **`prokka`**: Аннотации.
- **`abricate`**: Результаты поиска генов устойчивости.

---

## Диагностика ошибок

1. Если Nextflow выдаёт сообщение об ошибке, проверьте лог-файлы:
   ```bash
   cat .nextflow.log
   ```

2. Для диагностики отдельного процесса выполните команды из его рабочей директории:
   ```bash
   cd <work_dir>
   bash .command.run
   ```

3. Убедитесь, что все входные файлы находятся в директории `test_input`, и формат CSV соответствует ожиданиям.

