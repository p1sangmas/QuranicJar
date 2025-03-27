from transformers import BertTokenizer, BertForSequenceClassification
from transformers import RobertaTokenizer, RobertaForSequenceClassification
# from transformers import AutoTokenizer, DistilBertForSequenceClassification
import torch
import pandas as pd

# Load the fine-tuned BERT model and tokenizer
bert_model = BertForSequenceClassification.from_pretrained("./model/emotion_bert_model_1", num_labels=4)
bert_tokenizer = BertTokenizer.from_pretrained("./model/emotion_bert_tokenizer_1")

# Load the pre-trained RoBERTa model and tokenizer
roberta_model = RobertaForSequenceClassification.from_pretrained("./model/emotion_roberta_model_1", num_labels=4)  # Adjust num_labels
roberta_tokenizer = RobertaTokenizer.from_pretrained("./model/emotion_roberta_tokenizer_1")

# Load the label map
label_map = {"anger": 0, "fear": 1, "joy": 2, "sadness": 3}  # Replace with your actual label map

# Load the dataset containing Quranic verses and emotions
def load_quran_dataset(file_path):
    df = pd.read_csv(file_path)
    return df

# Function to classify emotion using BERT
def classify_emotion_bert(user_input):
    encoding = bert_tokenizer.encode_plus(
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
        output = bert_model(encoding["input_ids"], attention_mask=encoding["attention_mask"])
    logits = output.logits
    probabilities = torch.softmax(logits, dim=1).numpy()[0]  # Convert logits to probabilities
    return probabilities

# Function to classify emotion using RoBERTa
def classify_emotion_roberta(user_input):
    encoding = roberta_tokenizer.encode_plus(
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
        output = roberta_model(encoding["input_ids"], attention_mask=encoding["attention_mask"])
    logits = output.logits
    probabilities = torch.softmax(logits, dim=1).numpy()[0]  # Convert logits to probabilities
    return probabilities

# Ensemble function to combine predictions
def classify_emotion_ensemble(user_input):
    # Get predictions from both models
    bert_probabilities = classify_emotion_bert(user_input)
    print(f"BERT Probability: {bert_probabilities}")
    roberta_probabilities = classify_emotion_roberta(user_input)
    print(f"RoBERTa Probability: {roberta_probabilities}")
    
    # Combine predictions (average probabilities)
    combined_probabilities = (bert_probabilities + roberta_probabilities) / 2
    
    # Get the predicted label ID with the highest probability
    predicted_label_id = combined_probabilities.argmax()
    
    # Map the label ID to the corresponding emotion
    predicted_label = list(label_map.keys())[list(label_map.values()).index(predicted_label_id)]
    return predicted_label, combined_probabilities

# Function to get a Quranic verse based on the predicted emotion
def get_quranic_verse(predicted_emotion, df):
    # Filter the dataset for verses matching the predicted emotion
    filtered_verses = df[df['label'] == predicted_emotion]
    if filtered_verses.empty:
        return "No verse found for the predicted emotion."
    
    # Select the from the filtered results
    selected_row = filtered_verses.sample(n=1).iloc[0]
    verse_with_details = f"{selected_row['ayah_en']} (Surah {selected_row['surah_no']}, Verse {selected_row['ayah_no_surah']})"
    return verse_with_details

# Example usage
if __name__ == "__main__":
    # Load the dataset
    quran_df = load_quran_dataset("./dataset/quran_emotions.csv")
    
    # User input
    user_input = "I feel down lately."

    predicted_emotion = classify_emotion_ensemble(user_input)
    
    # Predict the emotion
    predicted_emotion, probabilities = classify_emotion_ensemble(user_input)
    print(f"Predicted Emotion: {predicted_emotion}")
    print(f"Probabilities: {probabilities}")
    print(f"Predicted Emotion: {predicted_emotion}")
    
    # Get a corresponding Quranic verse
    verse = get_quranic_verse(predicted_emotion, quran_df)
    print(f"Corresponding Quranic Verse: {verse}")