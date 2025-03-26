import pandas as pd

# Step 1: Load the dataset
file_path = './dataset/quran_emotions.csv'  # Replace with the actual file path
df = pd.read_csv(file_path)

# Step 2: Define the columns to check
columns_to_check = ['label', 'ayah_en']

# Step 3: Check for NaN values
nan_rows = df[df[columns_to_check].isna().any(axis=1)]
print("Rows with NaN values in 'label' or 'ayah_en':")
print(nan_rows)

# Step 4: Check for rows where 'label' or 'ayah_en' contain only whitespaces
def has_only_whitespaces(value):
    return isinstance(value, str) and value.strip() == ''

whitespace_rows = df[df[columns_to_check].map(has_only_whitespaces).any(axis=1)]
print("\nRows with only whitespaces in 'label' or 'ayah_en':")
print(whitespace_rows)
