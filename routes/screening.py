from fastapi import APIRouter, HTTPException
from schemas import EndometriosisScreeningRequest, PCOSScreeningRequest
from ai.endometriosis_model import EndometriosisModel
from ai.pcos_model import PCOSModel


router = APIRouter()


@router.post("/train-endometriosis-model")
async def train_endometriosis_model_endpoint():
    """Train the endometriosis risk prediction model using the CSV data"""
    try:
        model = EndometriosisModel()
        results = model.train_model()
        return {
            "status": "success",
            "message": "Model trained successfully",
            "accuracy": results['accuracy'],
            "feature_importance": results['feature_importance']
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Training failed: {str(e)}")


@router.post("/endometriosis-screening")
async def endometriosis_screening(req: EndometriosisScreeningRequest):
    """
    Screen for endometriosis risk based on patient symptoms and characteristics
    """
    try:
        # Initialize model and load pre-trained weights
        model = EndometriosisModel()
        
        # Prepare features
        features = {
            'Age': req.age,
            'Menstrual_Irregularity': req.menstrual_irregularity,
            'Chronic_Pain_Level': req.chronic_pain_level,
            'Hormone_Level_Abnormality': req.hormone_level_abnormality,
            'Infertility': req.infertility,
            'BMI': req.bmi
        }
        
        # Get prediction
        prediction = model.predict(features)
        
        # Get personalized advice
        advice = model.get_personalized_advice(prediction, features)
        
        return {
            "prediction": prediction,
            "personalized_advice": advice,
            "disclaimer": "This is a screening tool, not a medical diagnosis. Always consult with healthcare professionals."
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Screening failed: {str(e)}")


@router.get("/model-status")
async def model_status():
    """Check if the endometriosis model is trained and ready"""
    model = EndometriosisModel()
    is_loaded = model.load_model()
    
    if is_loaded:
        return {
            "status": "ready",
            "message": "Endometriosis model is loaded and ready for predictions",
            "features": model.feature_names
        }
    else:
        return {
            "status": "not_trained",
            "message": "Model needs to be trained. Call /train-endometriosis-model first",
            "features": model.feature_names
        }


@router.post("/train-pcos-model")
async def train_pcos_model_endpoint():
    """Train the PCOS risk prediction model"""
    try:
        model = PCOSModel()
        results = model.train_model()
        return {
            "status": "success",
            "message": "PCOS Model trained successfully",
            "accuracy": results['accuracy']
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Training failed: {str(e)}")


@router.post("/pcos-screening")
async def pcos_screening(req: PCOSScreeningRequest):
    """Screen for PCOS risk based on patient characteristics"""
    try:
        model = PCOSModel()
        
        # Mapped to feature_names in PCOSModel: ['Age', 'BMI', 'Menstrual_Irregularity', 'Hirsutism_or_Hair_Growth', 'Acne']
        features = {
            'Age': req.age,
            'BMI': req.bmi,
            'Menstrual_Irregularity': req.menstrual_irregularity,
            'Hirsutism_or_Hair_Growth': req.hirsutism,
            'Acne': req.acne
        }
        
        prediction = model.predict(features)
        
        return {
            "prediction": prediction,
            "disclaimer": "This is a machine learning screening tool, not a medical diagnosis. Always consult with healthcare professionals."
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"PCOS Screening failed: {str(e)}")
