import pandas as pd
import re

# Function to convert text to small-capital and remove symbols
def clean_text(text):
    # Convert to small-capital
    text = text.lower()
    # Remove symbols using regex
    text = re.sub(r"[^a-zA-Z\s]", "", text)
    return text

# Load the CSV files
csv1 = pd.read_csv('./dataset/csv1.csv')
csv2 = pd.read_csv('./dataset/csv2.csv')

# Apply the cleaning function to the 'ayah_en' column in csv1
csv1['ayah_en'] = csv1['ayah_en'].apply(clean_text)

# Merge the two dataframes on 'surah_no' and 'ayah_no_surah'
merged_df = pd.merge(csv2, csv1[['surah_no', 'ayah_no_surah', 'ayah_en']], 
                     on=['surah_no', 'ayah_no_surah'], 
                     how='left')

# Save the updated dataframe to a new CSV file or overwrite the existing csv2.csv
merged_df.to_csv('updated_csv2.csv', index=False)

print("Updated CSV2 has been saved as 'updated_csv2.csv'")
