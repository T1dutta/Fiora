import sys
import os
import io
import contextlib

sys.path.append(os.getcwd())
from ai.pcos_model import PCOSModel
from ai.endometriosis_model import EndometriosisModel

with open("accuracies.txt", "w", encoding="utf-8") as f:
    # PCOS Accuracy
    f.write("--- PCOS MODEL ACCURACY ---\n")
    pcos = PCOSModel()
    
    # We capture stdout to avoid terminal unicode crashes and write to file correctly
    f.write(f"Training on combined medical datasets ({len(pcos.feature_names)} features)...\n")
    res_pcos = pcos.train_model()
    f.write(f"Final PCOS Accuracy: {res_pcos['accuracy']*100:.2f}%\n\n")

    # Endo Accuracy
    f.write("--- ENDOMETRIOSIS MODEL ACCURACY ---\n")
    endo = EndometriosisModel()
    res_endo = endo.train_model('structured_endometriosis_data.csv')
    f.write(f"Final Endometriosis Accuracy: {res_endo['accuracy']*100:.2f}%\n")
