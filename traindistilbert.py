import pandas as pd
from transformers import AutoTokenizer, DistilBertForSequenceClassification, Trainer, TrainingArguments
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, precision_recall_fscore_support, confusion_matrix
import torch
from torch.utils.data import Dataset
import matplotlib.pyplot as plt
import seaborn as sns
import os

# Step 1: Load the dataset
def load_dataset(file_path):
    df = pd.read_csv(file_path)
    print(f"Dataset loaded with {len(df)} rows.")
    # print("First few rows of the dataset:")
    # print(df.head()) # Display the first few rows of the dataset
    # print("Unique values in the 'label' column:")
    # print(df['label'].unique())  # Display unique values in the 'label' column
    # print("Data types of columns:")
    # print(df.dtypes)  # Print data types of all columns

    
    # Check for missing values in the entire dataset
    if df.isnull().values.any():
        print("Warning: Missing values found in the dataset. Dropping rows with missing values.")
        df = df.dropna()  # Drop rows with any missing values
    
    df = df.reset_index(drop=True)  # Reset the index after dropping rows
    return df

# Step 2: Prepare the dataset for BERT
class EmotionDataset(Dataset):
    def __init__(self, texts, labels, tokenizer, max_len):
        # Convert texts and labels to lists if they are not already
        self.texts = texts.tolist() if hasattr(texts, 'tolist') else list(texts)
        self.labels = labels.tolist() if hasattr(labels, 'tolist') else list(labels)
        self.tokenizer = tokenizer
        self.max_len = max_len

    def __len__(self):
        return len(self.texts)

    def __getitem__(self, idx):
        text = self.texts[idx]
        label = self.labels[idx]
        encoding = self.tokenizer.encode_plus(
            text,
            add_special_tokens=True,
            max_length=self.max_len,
            return_token_type_ids=False,
            padding="max_length",
            truncation=True,
            return_attention_mask=True,
            return_tensors="pt",
        )
        return {
            "input_ids": encoding["input_ids"].flatten(),
            "attention_mask": encoding["attention_mask"].flatten(),
            "labels": torch.tensor(label, dtype=torch.long),
        }

# Step 3: Fine-tune BERT
def fine_tune_bert(train_texts, train_labels, val_texts, val_labels):
    # Combine train and validation labels to ensure all unique labels are included
    all_labels = list(train_labels) + list(val_labels)
    print("Combined labels:", all_labels[:10])  # Print the first 10 combined labels
    if any(pd.isnull(label) for label in all_labels):
        raise ValueError("Found NaN values in the combined labels. Please check the dataset and preprocessing steps.")
    unique_labels = sorted(list(set(all_labels)))
    print(f"Unique labels: {unique_labels}")

    # Debugging: Print unique labels
    print(f"Unique labels: {unique_labels}")

    # Create a mapping from label to index
    label_map = {label: idx for idx, label in enumerate(unique_labels)}
    print(f"Label map: {label_map}")  # Debugging: Print the label map

    # Convert labels to numerical values using the label_map
    train_labels = [label_map[label] for label in train_labels]
    val_labels = [label_map[label] for label in val_labels]

    # Load BERT tokenizer and model
    tokenizer = AutoTokenizer.from_pretrained("distilbert-base-uncased")
    model = DistilBertForSequenceClassification.from_pretrained("distilbert-base-uncased", num_labels=len(unique_labels))

    # Create datasets
    train_dataset = EmotionDataset(train_texts, train_labels, tokenizer, max_len=128)
    val_dataset = EmotionDataset(val_texts, val_labels, tokenizer, max_len=128)

    def compute_metrics(pred):
        labels = pred.label_ids
        preds = pred.predictions.argmax(-1)
        
        # Calculate metrics
        accuracy = accuracy_score(labels, preds)
        precision, recall, f1, _ = precision_recall_fscore_support(labels, preds, average='weighted')
        
        return {
            "accuracy": accuracy,
            "precision": precision,
            "recall": recall,
            "f1": f1,
        }
    

    # Define training arguments
    training_args = TrainingArguments(
        output_dir="./results_distilbert",
        num_train_epochs=3,
        per_device_train_batch_size=8,
        per_device_eval_batch_size=8,
        warmup_steps=500,
        weight_decay=0.01,
        logging_dir="./logs_distilbert",
        logging_steps=10,
        eval_strategy="epoch",
    )

    # Initialize Trainer
    trainer = Trainer(
        model=model,
        args=training_args,
        train_dataset=train_dataset,
        eval_dataset=val_dataset,
        compute_metrics=compute_metrics,
    )

    # Train the model
    trainer.train()

    # Display training on device
    print(f"Training on device: {trainer.args.device}")

    # Save the model and tokenizer
    model.save_pretrained("./model/emotion_distilbert_model_1")
    tokenizer.save_pretrained("./model/emotion_distilbert_tokenizer_1")
    # Evaluate the model on the validation set
    eval_results = trainer.evaluate()
    print(f"Evaluation Results: {eval_results}")

    # Extract metrics from eval_results
    metrics = {
        "Accuracy": eval_results["eval_accuracy"],
        "Precision": eval_results["eval_precision"],
        "Recall": eval_results["eval_recall"],
        "F1-Score": eval_results["eval_f1"],
    }

    # Create a bar plot for the metrics
    plt.figure(figsize=(8, 6))
    sns.barplot(x=list(metrics.keys()), y=list(metrics.values()), palette="viridis")
    plt.title("Model Evaluation Metrics", fontsize=16)
    plt.ylabel("Score", fontsize=14)
    plt.xlabel("Metric", fontsize=14)
    plt.ylim(0, 1)  # Scores range from 0 to 1
    plt.show()

    plt.show()

    
    output_dir = "./eval_metrics"
    os.makedirs(output_dir, exist_ok=True)  # Create the directory if it doesn't exist
    metrics_file_path = os.path.join(output_dir, "evaluation_metrics_1_distilbert.txt")
    
    with open(metrics_file_path, "w") as f:
        # Save metrics
        for metric, value in metrics.items():
            f.write(f"{metric}: {value:.4f}\n")
        
        # Save training parameters
        f.write("\nTraining Parameters:\n")
        f.write(f"Number of Epochs: {training_args.num_train_epochs}\n")
        f.write(f"Train Batch Size: {training_args.per_device_train_batch_size}\n")
        f.write(f"Eval Batch Size: {training_args.per_device_eval_batch_size}\n")
        f.write(f"Warmup Steps: {training_args.warmup_steps}\n")
        f.write(f"Weight Decay: {training_args.weight_decay}\n")
        f.write(f"Logging Steps: {training_args.logging_steps}\n")
        f.write(f"Evaluation Strategy: {training_args.eval_strategy}\n")

    print(f"Metrics and training parameters saved to '{metrics_file_path}'")

    # Display confusion matrix
    preds = trainer.predict(val_dataset)
    cm = confusion_matrix(preds.label_ids, preds.predictions.argmax(-1))
    sns.heatmap(cm, annot=True, fmt="d", cmap="Blues")
    plt.xlabel("Predicted")
    plt.ylabel("True")
    plt.show()

    return model, tokenizer, label_map

# Step 4: Main function
def main():
    # Load the dataset
    df = load_dataset("./dataset/quran_emotions.csv")

    # Ensure the label column is treated as strings
    df['label'] = df['label'].astype(str)

    # Split the dataset into training and validation sets
    train_texts, val_texts, train_labels, val_labels = train_test_split(
        df["ayah_en"].values, df["label"].values, test_size=0.2, random_state=42
    )
    print("Training labels (first 5):", train_labels[:5])
    print("Validation labels (first 5):", val_labels[:5])

    # Fine-tune BERT
    model, tokenizer, label_map = fine_tune_bert(train_texts, train_labels, val_texts, val_labels)
    print("DistilBERT model fine-tuned and saved!")

if __name__ == "__main__":
    main()