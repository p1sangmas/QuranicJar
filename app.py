from flask import Flask, request, jsonify
from transformers import BertTokenizer, BertForSequenceClassification
from transformers import RobertaTokenizer, RobertaForSequenceClassification
import torch
import pandas as pd

# Initialize Flask app
app = Flask(__name__)

# Load the fine-tuned BERT model and tokenizer
bert_model = BertForSequenceClassification.from_pretrained("./model/emotion_bert_model_1", num_labels=4)
bert_tokenizer = BertTokenizer.from_pretrained("./model/emotion_bert_tokenizer_1")

# Load the pre-trained RoBERTa model and tokenizer
roberta_model = RobertaForSequenceClassification.from_pretrained("./model/emotion_roberta_model_1", num_labels=4)
roberta_tokenizer = RobertaTokenizer.from_pretrained("./model/emotion_roberta_tokenizer_1")

# Load the label map
label_map = {"anger": 0, "fear": 1, "joy": 2, "sadness": 3}

# Load the dataset containing Quranic verses and emotions
def load_quran_dataset(file_path):
    df = pd.read_csv(file_path)
    return df

quran_df = load_quran_dataset("./dataset/quran_emotions.csv")

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
    probabilities = torch.softmax(logits, dim=1).numpy()[0]
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
    probabilities = torch.softmax(logits, dim=1).numpy()[0]
    return probabilities

# Ensemble function to combine predictions
def classify_emotion_ensemble(user_input):
    bert_probabilities = classify_emotion_bert(user_input)
    roberta_probabilities = classify_emotion_roberta(user_input)
    combined_probabilities = (bert_probabilities + roberta_probabilities) / 2
    predicted_label_id = combined_probabilities.argmax()
    predicted_label = list(label_map.keys())[list(label_map.values()).index(predicted_label_id)]
    return predicted_label, combined_probabilities

# Function to get a Quranic verse based on the predicted emotion
def get_quranic_verse(predicted_emotion, df):
    filtered_verses = df[df['label'] == predicted_emotion]
    if filtered_verses.empty:
        return "No verse found for the predicted emotion."
    selected_row = filtered_verses.sample(n=1).iloc[0]
    verse_with_details = f"{selected_row['ayah_en']} (Surah {selected_row['surah_no']}, Verse {selected_row['ayah_no_surah']})"
    return verse_with_details

# Define API endpoint
@app.route("/predict", methods=["POST"])
def predict():
    data = request.json
    user_input = data.get("text", "")
    if not user_input:
        return jsonify({"error": "Input text is required"}), 400

    # Predict emotion and get Quranic verse
    predicted_emotion, probabilities = classify_emotion_ensemble(user_input)
    verse = get_quranic_verse(predicted_emotion, quran_df)
    print(f"Predicted Emotion: {predicted_emotion}")
    print(f"Probabilities: {probabilities}")
    print(f"Quranic Verse: {verse}")

    # Return response
    response = {
        "predicted_emotion": predicted_emotion,
        "probabilities": probabilities.tolist(),
        "quranic_verse": verse,
    }
    return jsonify(response)

# Run the app
if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=3000)