# Lung Cancer Detection and Segmentation Based on Quantitative Analysis (FYP)

This repository contains the Final Year Project (FYP) titled **“Lung Cancer Detection and Segmentation Based on Quantitative Analysis.”**

The project aims to assist medical professionals by providing an automated system for lung cancer detection, segmentation, and classification from CT scan images using deep learning techniques.

---

## 📖 Project Description

Lung cancer is one of the most life-threatening diseases worldwide, where early and accurate diagnosis plays a crucial role in patient survival. This project presents an AI-based solution that analyses lung CT scan images to detect cancerous regions, perform segmentation, and classify the disease into multiple categories.

The system is implemented as a **mobile application developed in Flutter**, connected to a **Python Flask backend** hosted using **PythonAnywhere**. The backend performs all AI-related processing, while the mobile app provides a simple and user-friendly interface for interaction.

Authentication and user management are handled using **Firebase**, ensuring secure access to the system.

---

## 🚀 Key Features

* **Automated Detection:** Lung cancer detection from CT scan images.
* **Segmentation:** Lung tumor segmentation for clear visualization of affected regions.
* **Multi-class Classification:** Classifies the disease into specific cancer types.
* **Invalid Scan Support:** Intelligent detection of invalid or unclear CT scans.
* **Deep Learning:** AI model training and inference using advanced neural networks.
* **User-Friendly Interface:** Easy-to-use mobile application.
* **Secure Access:** Authentication handled via Firebase.
* **Cloud Backend:** Flask-based backend for robust image processing.

---

## 🧪 Dataset & Classification Details

The model is trained on a combination of publicly available and custom datasets.

### 🔹 1. Original Dataset
* **Name:** IQ-OTH/NCCD Lung Cancer Dataset
* **Details:** Contains three lung cancer classes.
* **Source:** [Kaggle - IQ-OTH/NCCD Dataset](https://www.kaggle.com/datasets/hamdallak/the-iqothnccd-lung-cancer-dataset)

### 🔹 2. Custom Dataset (Added by Author)
* **Name:** Invalid Class Dataset
* **Details:** Created to handle unclear, corrupted, or non-relevant images. This improves system robustness by preventing incorrect predictions on unsuitable input.
* **Source:** [Kaggle - Invalid Class Dataset](https://www.kaggle.com/datasets/quratulain79/invalid-class-dataset)

---

## 🧠 Model Training

The complete model training, evaluation, and experimentation process was performed using Kaggle notebooks.

* **Final Training Notebook:** [100% Final - Kaggle Code](https://www.kaggle.com/code/quratulain79/100-final)

The notebook includes preprocessing, model training, validation, and performance evaluation steps.

---

## 🏗️ System Architecture

The system consists of two main components:

### 📱 1. Frontend (Flutter)
* Developed using **Flutter**.
* Provides a mobile-based user interface.
* Allows users to upload CT scan images.
* Displays prediction, classification, and segmentation results.
* User authentication handled via **Firebase**.

### 🐍 2. Backend (Flask – Python)
* Developed using **Python Flask**.
* Hosted using **PythonAnywhere**.
* Handles AI model inference and image processing.
* Receives CT scan images from the Flutter app and returns results.

---

## ⚠️ Large Files Notice

To keep the GitHub repository lightweight and manageable, the following files are **not included** in this repository:
* CT scan datasets
* Trained AI model files (`.h5`, `.pth`, etc.)
* Virtual environments (`venv`, `env`)

---

## 🛠️ Technologies Used

* **Flutter:** Mobile application development
* **Python:** Backend and AI processing
* **Flask:** RESTful API development
* **Firebase:** Authentication and user management
* **Deep Learning:** Image classification and segmentation
* **Kaggle:** Model training and experimentation
* **PythonAnywhere:** Backend hosting

---

## 🎓 Academic Purpose

This project is developed strictly for **academic and research purposes** as part of the **Final Year Project (FYP)** requirement for the Bachelor of Computer Science degree.

### 👩‍💻 Authors

* **Qurat Ul Ain** (CS)
* **Tania Qayyum** (CS)
* **Sarina Amjad** (SE)

**COMSATS University Islamabad, Abbottabad Campus**

---

## ⚖️ Disclaimer

> This system is developed for academic and research purposes only. It is intended to support medical professionals and should **not** be used as a substitute for professional medical diagnosis or treatment.
