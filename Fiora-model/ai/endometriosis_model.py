import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
import joblib
import os

class EndometriosisModel:
    """Machine learning model for endometriosis risk prediction"""
    
    def __init__(self, model_path="data/endometriosis_model.pkl", scaler_path="data/scaler.pkl"):
        self.model_path = model_path
        self.scaler_path = scaler_path
        self.model = None
        self.scaler = None
        self.feature_names = [
            'Age', 'Menstrual_Irregularity', 'Chronic_Pain_Level',
            'Hormone_Level_Abnormality', 'Infertility', 'BMI'
        ]
        
    def load_data(self, csv_path="structured_endometriosis_data.csv"):
        """Load and prepare the endometriosis dataset"""
        try:
            df = pd.read_csv(csv_path)
            print(f"✓ Loaded {len(df)} records from {csv_path}")
            
            # Separate features and target
            X = df[self.feature_names]
            y = df['Diagnosis']
            
            return X, y, df
        except Exception as e:
            print(f"Error loading data: {e}")
            raise
    
    def train_model(self, csv_path="structured_endometriosis_data.csv", test_size=0.2):
        """Train the Random Forest model on endometriosis data"""
        X, y, df = self.load_data(csv_path)
        
        # Split data
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=test_size, random_state=42, stratify=y
        )
        
        # Scale features
        self.scaler = StandardScaler()
        X_train_scaled = self.scaler.fit_transform(X_train)
        X_test_scaled = self.scaler.transform(X_test)
        
        # Train Random Forest
        self.model = RandomForestClassifier(
            n_estimators=100,
            max_depth=10,
            min_samples_split=5,
            min_samples_leaf=2,
            random_state=42,
            class_weight='balanced'
        )
        
        print("\n🔄 Training Random Forest model...")
        self.model.fit(X_train_scaled, y_train)
        
        # Evaluate
        y_pred = self.model.predict(X_test_scaled)
        accuracy = accuracy_score(y_test, y_pred)
        
        print(f"✓ Model trained successfully!")
        print(f"  - Accuracy: {accuracy:.2%}")
        print(f"  - Training samples: {len(X_train)}")
        print(f"  - Test samples: {len(X_test)}")
        
        print("\n📊 Classification Report:")
        print(classification_report(y_test, y_pred, target_names=['No Diagnosis', 'Endometriosis']))
        
        print("\n🔍 Confusion Matrix:")
        cm = confusion_matrix(y_test, y_pred)
        print(f"True Negatives: {cm[0][0]}, False Positives: {cm[0][1]}")
        print(f"False Negatives: {cm[1][0]}, True Positives: {cm[1][1]}")
        
        # Feature importance
        feature_importance = pd.DataFrame({
            'feature': self.feature_names,
            'importance': self.model.feature_importances_
        }).sort_values('importance', ascending=False)
        
        print("\n⭐ Feature Importance:")
        for _, row in feature_importance.iterrows():
            print(f"  - {row['feature']}: {row['importance']:.4f}")
        
        # Save model and scaler
        self.save_model()
        
        return {
            'accuracy': accuracy,
            'classification_report': classification_report(y_test, y_pred, output_dict=True),
            'feature_importance': feature_importance.to_dict('records')
        }
    
    def save_model(self):
        """Save trained model and scaler to disk"""
        os.makedirs(os.path.dirname(self.model_path) if os.path.dirname(self.model_path) else '.', exist_ok=True)
        
        joblib.dump(self.model, self.model_path)
        joblib.dump(self.scaler, self.scaler_path)
        print(f"\n💾 Model saved to {self.model_path}")
        print(f"💾 Scaler saved to {self.scaler_path}")
    
    def load_model(self):
        """Load trained model and scaler from disk"""
        try:
            self.model = joblib.load(self.model_path)
            self.scaler = joblib.load(self.scaler_path)
            print(f"✓ Model loaded from {self.model_path}")
            return True
        except Exception as e:
            print(f"⚠ Could not load model: {e}")
            return False
    
    def predict(self, features_dict):
        """
        Predict endometriosis risk for a single patient
        
        Args:
            features_dict: Dictionary with keys matching self.feature_names
        
        Returns:
            Dictionary with prediction, probability, and risk level
        """
        if self.model is None:
            if not self.load_model():
                raise ValueError("No trained model available. Train the model first.")
        
        # Prepare input
        features = [features_dict.get(name, 0) for name in self.feature_names]
        features_array = np.array(features).reshape(1, -1)
        
        # Scale and predict
        features_scaled = self.scaler.transform(features_array)
        prediction = self.model.predict(features_scaled)[0]
        probability = self.model.predict_proba(features_scaled)[0]
        
        # Risk level interpretation
        risk_prob = probability[1]  # Probability of endometriosis
        if risk_prob < 0.3:
            risk_level = "Low"
        elif risk_prob < 0.6:
            risk_level = "Moderate"
        else:
            risk_level = "High"
        
        return {
            'prediction': int(prediction),
            'diagnosis': 'Endometriosis Risk' if prediction == 1 else 'No Significant Risk',
            'probability_no_risk': float(probability[0]),
            'probability_endometriosis': float(probability[1]),
            'risk_level': risk_level,
            'risk_percentage': f"{risk_prob * 100:.1f}%"
        }
    
    def get_personalized_advice(self, prediction_result, features_dict):
        """Generate personalized health advice based on prediction"""
        advice = []
        
        risk_level = prediction_result['risk_level']
        risk_prob = prediction_result['probability_endometriosis']
        
        # General advice based on risk level
        if risk_level == "High":
            advice.append("⚠️ Your symptoms suggest a higher risk for endometriosis.")
            advice.append("We strongly recommend consulting a gynecologist for proper evaluation.")
        elif risk_level == "Moderate":
            advice.append("ℹ️ You have some risk factors for endometriosis.")
            advice.append("Consider scheduling a check-up with your healthcare provider.")
        else:
            advice.append("✓ Your current health indicators show lower endometriosis risk.")
            advice.append("Continue monitoring your symptoms and maintain healthy habits.")
        
        # Specific advice based on individual features
        pain_level = features_dict.get('Chronic_Pain_Level', 0)
        if pain_level > 6:
            advice.append(f"🩺 Your pain level ({pain_level}/10) is significant. Track pain patterns and discuss with your doctor.")
        
        bmi = features_dict.get('BMI', 0)
        if bmi < 18.5:
            advice.append("🍎 Consider consulting a nutritionist - low BMI may affect hormonal balance.")
        elif bmi > 30:
            advice.append("🏃 Regular exercise and balanced nutrition can help manage hormonal health.")
        
        if features_dict.get('Menstrual_Irregularity', 0) == 1:
            advice.append("📅 Track your menstrual cycle patterns - this data helps healthcare providers.")
        
        if features_dict.get('Infertility', 0) == 1:
            advice.append("👨‍⚕️ If you're experiencing fertility concerns, a reproductive endocrinologist can help.")
        
        advice.append("\n💡 Remember: This is a screening tool, not a diagnosis. Always consult healthcare professionals.")
        
        return "\n".join(advice)


def train_endometriosis_model():
    """Standalone function to train the model"""
    model = EndometriosisModel()
    results = model.train_model()
    return model, results


if __name__ == "__main__":
    print("🌸 Shakti AI - Endometriosis Risk Model Training\n")
    model, results = train_endometriosis_model()
    
    # Test prediction
    print("\n" + "="*60)
    print("📝 Testing with sample patient data:")
    sample_patient = {
        'Age': 32,
        'Menstrual_Irregularity': 1,
        'Chronic_Pain_Level': 7.5,
        'Hormone_Level_Abnormality': 1,
        'Infertility': 0,
        'BMI': 23.5
    }
    
    prediction = model.predict(sample_patient)
    print(f"\nPatient Profile: {sample_patient}")
    print(f"\nPrediction Results:")
    print(f"  - Diagnosis: {prediction['diagnosis']}")
    print(f"  - Risk Level: {prediction['risk_level']}")
    print(f"  - Endometriosis Probability: {prediction['risk_percentage']}")
    
    print(f"\nPersonalized Advice:")
    advice = model.get_personalized_advice(prediction, sample_patient)
    print(advice)
