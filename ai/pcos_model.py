import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import accuracy_score
import joblib
import os

class PCOSModel:
    """Machine learning model for PCOS risk prediction"""
    
    def __init__(self, model_path="data/pcos_model.pkl", scaler_path="data/pcos_scaler.pkl"):
        self.model_path = model_path
        self.scaler_path = scaler_path
        self.model = None
        self.scaler = None
        # Common user-friendly features between both datasets
        self.feature_names = [
            'Age', 'BMI', 'Menstrual_Irregularity', 'Hirsutism_or_Hair_Growth', 'Acne'
        ]
        
    def _prepare_csv_data(self, df):
        # CSV mapping
        processed = pd.DataFrame()
        processed['Age'] = df['Age']
        
        # Categorical BMI to numeric approximation
        bmi_map = {'Underweight': 17.5, 'Normal': 22.0, 'Overweight': 27.5, 'Obese': 32.5}
        processed['BMI'] = df['BMI'].map(bmi_map)
        
        processed['Menstrual_Irregularity'] = df['Menstrual Regularity'].map({'Irregular': 1, 'Regular': 0})
        processed['Hirsutism_or_Hair_Growth'] = df['Hirsutism'].map({'Yes': 1, 'No': 0})
        # Acne severity could be high/moderate/low, mapping conceptually
        processed['Acne'] = df['Acne Severity'].apply(lambda x: 1 if x in ['Severe', 'Moderate', 'Yes', 1] else 0)
        
        y = df['Diagnosis'].map({'Yes': 1, 'No': 0})
        return processed, y
        
    def _prepare_xlsx_data(self, df):
        # XLSX mapping
        processed = pd.DataFrame()
        processed['Age'] = df[' Age (yrs)']
        processed['BMI'] = df['BMI']
        processed['Menstrual_Irregularity'] = df['Cycle(R/I)'].apply(lambda x: 0 if x == 2 else 1) # 2 is regular, 4/5 irregular
        processed['Hirsutism_or_Hair_Growth'] = df['hair growth(Y/N)']
        processed['Acne'] = df['Pimples(Y/N)']
        
        y = df['PCOS (Y/N)']
        return processed, y

    def load_data(self, csv_path="pcos_prediction_dataset.csv", xlsx_path="PCOS_data_without_infertility (1).xlsx"):
        """Load and merge both PCOS datasets, filtering only user-collectable parameters"""
        X_all = pd.DataFrame()
        y_all = pd.Series(dtype=int)
        
        try:
            if os.path.exists(csv_path):
                df_csv = pd.read_csv(csv_path)
                X_csv, y_csv = self._prepare_csv_data(df_csv)
                X_all = pd.concat([X_all, X_csv], ignore_index=True)
                y_all = pd.concat([y_all, y_csv], ignore_index=True)
                print(f"✓ Loaded {len(df_csv)} records from CSV")
        except Exception as e:
            print(f"Error loading CSV data: {e}")
            
        try:
            if os.path.exists(xlsx_path):
                df_xlsx = pd.read_excel(xlsx_path, sheet_name='Full_new', engine='openpyxl')
                # Filter out obvious invalid rows
                df_xlsx = df_xlsx.dropna(subset=[' Age (yrs)', 'PCOS (Y/N)'])
                X_xlsx, y_xlsx = self._prepare_xlsx_data(df_xlsx)
                X_all = pd.concat([X_all, X_xlsx], ignore_index=True)
                y_all = pd.concat([y_all, y_xlsx], ignore_index=True)
                print(f"✓ Loaded {len(df_xlsx)} records from XLSX")
        except Exception as e:
            print(f"Error loading XLSX data: {e}")

        if len(X_all) == 0:
            raise ValueError("No data loaded. Check file paths.")
            
        # Clean data (drop rows with NaNs)
        combined = pd.concat([X_all, y_all.rename('Target')], axis=1)
        combined = combined.dropna()
        X = combined[self.feature_names]
        y = combined['Target']
        
        return X, y
    
    def train_model(self, test_size=0.2):
        """Train the model merging both datasets"""
        X, y = self.load_data()
        
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=test_size, random_state=42, stratify=y
        )
        
        self.scaler = StandardScaler()
        X_train_scaled = self.scaler.fit_transform(X_train)
        X_test_scaled = self.scaler.transform(X_test)
        
        self.model = RandomForestClassifier(n_estimators=100, max_depth=10, random_state=42, class_weight='balanced')
        
        print("\n🔄 Training PCOS Random Forest model combining both datasets...")
        self.model.fit(X_train_scaled, y_train)
        
        accuracy = accuracy_score(y_test, self.model.predict(X_test_scaled))
        print(f"✓ Model trained successfully! (Accuracy: {accuracy:.2%})")
        print(f"  - Total merged samples used: {len(X)}")
        
        self.save_model()
        return {'accuracy': accuracy}
    
    def save_model(self):
        os.makedirs(os.path.dirname(self.model_path) if os.path.dirname(self.model_path) else '.', exist_ok=True)
        joblib.dump(self.model, self.model_path)
        joblib.dump(self.scaler, self.scaler_path)
    
    def load_model(self):
        try:
            self.model = joblib.load(self.model_path)
            self.scaler = joblib.load(self.scaler_path)
            return True
        except Exception:
            return False
    
    def predict(self, features_dict):
        if self.model is None and not self.load_model():
             raise ValueError("Train model first.")
             
        features = [features_dict.get(n, 0) for n in self.feature_names]
        features_array = np.array(features).reshape(1, -1)
        scaled = self.scaler.transform(features_array)
        
        prediction = self.model.predict(scaled)[0]
        prob = self.model.predict_proba(scaled)[0][1]
        
        return {
            'prediction': int(prediction),
            'risk_level': 'High' if prob > 0.6 else ('Moderate' if prob > 0.3 else 'Low'),
            'probability': f"{prob * 100:.1f}%",
            'diagnosis': 'PCOS Risk' if prediction == 1 else 'Low Risk'
        }

if __name__ == "__main__":
    model = PCOSModel()
    model.train_model()
