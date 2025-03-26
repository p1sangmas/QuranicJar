import pandas as pd

# Load the dataset
file_path = './dataset/quran_emotions.csv'  # Replace with your CSV file path
df = pd.read_csv(file_path)

# Check if the dataset contains a 'label' column
if 'label' not in df.columns:
    raise ValueError("The dataset must contain a 'label' column.")

# Count the occurrences of each class
class_counts = df['label'].value_counts()

# Display the class distribution
print("Class Distribution:")
print(class_counts)

# Check for imbalance
threshold = 0.1  # Define a threshold for imbalance (e.g., 10%)
total = class_counts.sum()
imbalanced_classes = class_counts[class_counts / total < threshold]

if not imbalanced_classes.empty:
    print("\nImbalanced Classes Detected:")
    print(imbalanced_classes)
else:
    print("\nNo significant imbalance detected.")