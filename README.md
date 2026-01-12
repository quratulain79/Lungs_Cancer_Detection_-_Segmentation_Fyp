# Lung Cancer Detection and Segmentation Based on Quantitative Analysis (FYP)

This repository contains the Final Year Project (FYP) titled  
**“Lung Cancer Detection and Segmentation Based on Quantitative Analysis.”**  
The project aims to assist medical professionals by providing an automated system for lung cancer detection, segmentation, and classification from CT scan images using deep learning techniques.

---

## 📖 Project Description

Lung cancer is one of the most life-threatening diseases worldwide, where early and accurate diagnosis plays a crucial role in patient survival. This project presents an AI-based solution that analyzes lung CT scan images to detect cancerous regions, perform segmentation, and classify the disease into multiple categories.

The system is implemented as a **mobile application developed in Flutter**, connected to a **Python Flask backend** hosted using **PythonAnywhere**. The backend performs all AI-related processing, while the mobile app provides a simple and user-friendly interface for interaction.

Authentication and user management are handled using **Firebase**, ensuring secure access to the system.

---

## 🧠 Key Features

- Automated lung cancer detection from CT scan images  
- Lung tumor segmentation for clear visualization of affected regions  
- Multi-class classification of lung cancer  
- Support for **Invalid / Unclear CT scan detection**  
- AI model training and inference using deep learning  
- User-friendly mobile application interface  
- Secure authentication using Firebase  
- Flask-based backend for image processing and predictions  

---

## 🧪 Dataset & Classification Details

The model is trained on a combination of publicly available and custom datasets:

### 🔹 Original Dataset
- **IQ-OTH/NCCD Lung Cancer Dataset**
- Contains **three lung cancer classes**
- Source: Kaggle  
  https://www.kaggle.com/datasets/hamdallak/the-iqothnccd-lung-cancer-dataset

### 🔹 Custom Dataset (Added by Author)
- **Invalid Class Dataset**
- Created to handle unclear, corrupted, or non-relevant CT scan images
- Source: Kaggle  
  https://www.kaggle.com/datasets/quratulain79/invalid-class-dataset

This additional class improves system robustness by preventing incorrect predictions on unsuitable input images.

---

## 🧠 Model Training

The complete model training, evaluation, and experimentation process was performed using Kaggle notebooks.

- **Final Training Notebook:**  
  https://www.kaggle.com/code/quratulain79/100-final

The notebook includes preprocessing, model training, validation, and performance evaluation steps.

---

## 🏗️ System Architecture

The system consists of two main components:

### 1️⃣ Frontend (Flutter)
- Developed using **Flutter**
- Provides a mobile-based user interface
- Allows users to upload CT scan images
- Displays prediction, classification, and segmentation results
- User authentication handled via **Firebase**

### 2️⃣ Backend (Flask – Python)
- Developed using **Python Flask**
- Hosted using **PythonAnywhere**
- Handles AI model inference and image processing
- Receives CT scan images from the Flutter app
- Returns classification and segmentation results

---

## 🚫 Large Files Notice

To keep the GitHub repository lightweight and manageable, the following files are **not included** in this repository:

- CT scan datasets  
- Trained AI model files  
- Virtual environments  

These resources are provided separately for academic review and evaluation purposes.

---

## 🛠️ Technologies Used

- **Flutter** – Mobile application development  
- **Python** – Backend and AI processing  
- **Flask** – RESTful API development  
- **Firebase** – Authentication and user management  
- **Deep Learning** – Image classification and segmentation  
- **Kaggle** – Model training and experimentation  
- **PythonAnywhere** – Backend hosting  

---

## 🎓 Academic Purpose

This project is developed strictly for **academic and research purposes** as part of the **Final Year Project (FYP)** requirement for the Bachelor of Computer Science degree.

---

## 👩‍💻 Author

**Qurat Ul Ain**  
**Tania Qayyum**  
**Sarina Amjad**  

Bachelor of Computer Science  
COMSATS University Islamabad, Abbottabad Campus  

---

## ⚠️ Disclaimer

This system is developed for academic and research purposes only.  
It is intended to support medical professionals and should **not** be used as a substitute for professional medical diagnosis or treatment.
