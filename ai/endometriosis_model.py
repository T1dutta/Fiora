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

    def _resolve_data_paths(self, csv_path=None):
        """Return the first existing CSV paths to use for training."""
        candidate_paths = []

        if csv_path:
            if isinstance(csv_path, (list, tuple, set)):
                candidate_paths.extend(csv_path)
            else:
                candidate_paths.append(csv_path)

        candidate_paths.extend([
            "data/endometriosis_synthetic.pkl",
            "endometriosis_synthetic.csv",
            "goldstein2023_endometriosis_synthetic.csv",
            "structured_endometriosis_data.csv",
        ])

        resolved_paths = []
        seen_paths = set()
        for path in candidate_paths:
            if not path:
                continue
            if os.path.exists(path):
                resolved = path
            else:
                resolved = os.path.join(os.path.dirname(__file__), "..", path)
                resolved = os.path.normpath(resolved)
            if os.path.exists(resolved) and resolved not in seen_paths:
                resolved_paths.append(resolved)
                seen_paths.add(resolved)

        return resolved_paths

    def _read_dataset(self, path):
        """Read either a CSV or pickled dataframe from disk."""
        if path.lower().endswith('.pkl'):
            return pd.read_pickle(path)
        return pd.read_csv(path)

    def _prepare_structured_data(self, df):
        """Normalize the structured dataset to the model's feature layout."""
        missing_columns = [col for col in self.feature_names + ['Diagnosis'] if col not in df.columns]
        if missing_columns:
            raise ValueError(f"Structured dataset missing columns: {', '.join(missing_columns)}")

        X = df[self.feature_names].copy()
        y = df['Diagnosis'].copy()
        return X, y

    def _prepare_synthetic_data(self, df):
        """Map the symptom-heavy synthetic dataset onto the model's feature layout."""
        required_columns = ['endometriosis_diagnosis']
        if not all(column in df.columns for column in required_columns):
            raise ValueError("Synthetic dataset missing diagnosis column")

        menstrual_irregularity_cols = [
            'irregular_missed_periods',
            'long_menstruation',
            'abnormal_uterine_bleeding',
            'heavy_extreme_menstrual_bleeding',
        ]
        pain_cols = [
            'menstrual_pain_dysmenorrhea',
            'cramping',
            'painful_cramps_during_period',
            'fatigue_chronic_fatigue',
            'heavy_extreme_menstrual_bleeding',
            'pelvic_pain',
            'abdominal_pain_pressure',
            'painful_burning_pain_during_intercourse_dyspareunia',
            'back_pain',
            'bloating',
            'lower_back_pain',
            'sharp_stabbing_pain',
            'painful_bowel_movements',
            'pain_chronic_pain',
            'decreased_energy_exhaustion',
            'stomach_cramping',
            'menstrual_clots',
            'ovarian_cysts',
            'painful_ovulation',
            'nausea',
            'extreme_severe_pain',
            'pain_after_intercourse',
            'anxiety',
            'cysts_unspecified',
            'constipation_chronic_constipation',
            'ibs_like_symptoms',
            'vaginal_pain_pressure',
            'mood_swings',
            'abdominal_cramps_during_intercourse',
            'digestive_gi_problems',
            'long_menstruation',
            'depression',
            'acne_pimples',
            'infertility',
            'diarrhea',
            'anaemia_iron_deficiency',
            'feeling_sick',
            'painful_urination',
            'leg_pain',
            'irritable_bowel_syndrome_ibs',
            'hip_pain',
            'insomnia_sleeplessness',
            'headaches',
            'dizziness',
            'bowel_pain',
            'fertility_issues',
            'migraines',
            'vomiting_constant_vomiting',
            'loss_of_appetite',
            'constant_bleeding',
            'syncope_fainting_passing_out',
            'fever',
            'abnormal_uterine_bleeding',
            'malaise_sickness',
        ]

        processed = pd.DataFrame(index=df.index)
        if 'age' in df.columns:
            processed['Age'] = pd.to_numeric(df['age'], errors='coerce')
        elif 'Age' in df.columns:
            processed['Age'] = pd.to_numeric(df['Age'], errors='coerce')
        else:
            processed['Age'] = 32.0

        if 'bmi' in df.columns:
            processed['BMI'] = pd.to_numeric(df['bmi'], errors='coerce')
        elif 'BMI' in df.columns:
            processed['BMI'] = pd.to_numeric(df['BMI'], errors='coerce')
        else:
            processed['BMI'] = 24.0

        menstrual_irregularity_frame = df.reindex(columns=menstrual_irregularity_cols, fill_value=0)
        processed['Menstrual_Irregularity'] = (menstrual_irregularity_frame.sum(axis=1) > 0).astype(int)

        pain_frame = df.reindex(columns=pain_cols, fill_value=0)
        pain_count = pain_frame.sum(axis=1)
        processed['Chronic_Pain_Level'] = (pain_count / max(len(pain_cols), 1)) * 10.0

        hormonal_indicators = [col for col in ['hormonal_problems', 'hormone_level_abnormality'] if col in df.columns]
        if hormonal_indicators:
            processed['Hormone_Level_Abnormality'] = (df[hormonal_indicators].sum(axis=1) > 0).astype(int)
        else:
            processed['Hormone_Level_Abnormality'] = 0

        infertility_indicators = [col for col in ['infertility', 'fertility_issues'] if col in df.columns]
        if infertility_indicators:
            processed['Infertility'] = (df[infertility_indicators].sum(axis=1) > 0).astype(int)
        else:
            processed['Infertility'] = 0

        target = pd.to_numeric(df['endometriosis_diagnosis'], errors='coerce')
        target = target.fillna(0).astype(int)

        return processed[self.feature_names], target
        
    def load_data(self, csv_path="structured_endometriosis_data.csv"):
        """Load and prepare the endometriosis dataset"""
        try:
            data_paths = self._resolve_data_paths(csv_path)
            if not data_paths:
                raise FileNotFoundError(f"No endometriosis dataset found for: {csv_path}")

            feature_frames = []
            target_frames = []
            loaded_sources = []

            for path in data_paths:
                df = self._read_dataset(path)
                if 'Diagnosis' in df.columns:
                    X, y = self._prepare_structured_data(df)
                elif 'endometriosis_diagnosis' in df.columns:
                    X, y = self._prepare_synthetic_data(df)
                else:
                    raise ValueError(f"Unsupported endometriosis dataset schema: {path}")

                feature_frames.append(X)
                target_frames.append(y)
                loaded_sources.append(f"{os.path.basename(path)} ({len(df)} rows)")

            X = pd.concat(feature_frames, ignore_index=True)
            y = pd.concat(target_frames, ignore_index=True)
            df = pd.concat([X, y.rename('Diagnosis')], axis=1)

            print(f"✓ Loaded endometriosis data from: {', '.join(loaded_sources)}")
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
