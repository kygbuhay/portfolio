"""
Model pipeline utilities for the TikTok Claims Classification project.
"""

from sklearn.ensemble import RandomForestClassifier
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler

def build_pipeline() -> Pipeline:
    """Construct a baseline Random Forest classification pipeline.

    The pipeline includes:
        - Standardization of features
        - Random Forest classifier with fixed random state

    Returns:
        Pipeline: A scikit-learn Pipeline object configured with preprocessing
        and classification steps.
    """
    pipeline = Pipeline([
        ("scaler", StandardScaler(with_mean=False)),
        ("clf", RandomForestClassifier(random_state=42))
    ])
    return pipeline
