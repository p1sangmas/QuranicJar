from transformers import BertTokenizer, BertForSequenceClassification
import torch
import pandas as pd

# Load the fine-tuned BERT model and tokenizer
model = BertForSequenceClassification.from_pretrained("./model/emotion_bert_model_1")
tokenizer = BertTokenizer.from_pretrained("./model/emotion_bert_tokenizer_1")

# Load the label map
label_map = {"anger": 0, "fear": 1, "joy": 2, "sadness": 3}  # Replace with your actual label map

# Load the dataset containing Quranic verses and emotions
def load_quran_dataset(file_path):
    df = pd.read_csv(file_path)
    return df

# Function to classify emotion
def classify_emotion(user_input):
    encoding = tokenizer.encode_plus(
        user_input,
        add_special_tokens=True,
        max_length=128,
        return_token_type_ids=False,
        padding="max_length",
        truncation=True,
        return_attention_mask=True,
        return_tensors="pt",
    )
    with torch.no_grad():
        output = model(encoding["input_ids"], attention_mask=encoding["attention_mask"])
    logits = output.logits
    predicted_label_id = torch.argmax(logits, dim=1).item()
    predicted_label = list(label_map.keys())[list(label_map.values()).index(predicted_label_id)]
    return predicted_label

# Function to get a Quranic verse based on the predicted emotion
def get_quranic_verse(predicted_emotion, df):
    # Filter the dataset for verses matching the predicted emotion
    filtered_verses = df[df['label'] == predicted_emotion]
    if filtered_verses.empty:
        return "No verse found for the predicted emotion."
    
    # Select the first verse from the filtered results (or randomize if needed)
    selected_row = filtered_verses.iloc[0]
    verse_with_details = f"{selected_row['ayah_en']} (Surah {selected_row['surah_no']}, Verse {selected_row['ayah_no_surah']})"
    return verse_with_details

# Example usage
if __name__ == "__main__":
    # Load the dataset
    quran_df = load_quran_dataset("./dataset/quran_emotions.csv")
    
    # User input
    user_input = "I feel so calm and peaceful."
    
    # Predict the emotion
    predicted_emotion = classify_emotion(user_input)
    print(f"Predicted Emotion: {predicted_emotion}")
    
    # Get a corresponding Quranic verse
    verse = get_quranic_verse(predicted_emotion, quran_df)
    print(f"Corresponding Quranic Verse: {verse}")