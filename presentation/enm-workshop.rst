# Nanoparticle read across toxicity predictions with nano-lazar

# Requirements

- Nanoparticle characterisation
- Toxicity measurements

# eNanoMapper data import

Nanoparticles imported: 464
Nanoparticles with particle characterisation: 394
Nanoparticles with toxicity data: 167
Nanoparticles with toxicity data and particle characterisation: 160

# eNanoMapper toxicity endpoints

.. alles ohne falsch? zugewiesene protein corona tox endpoints
Toxicity endpoints: 41
Toxicity endpoints with more than one measurement value: 22
Toxicity endpoints with more than 10 measurements: 2

# Selected data

Protein corona dataset Au particles (106 particles)
Toxicity endpoint: 

# Read across procedure

- Identify relevant fragments (significant correlation with toxicity)
  TODO list of fragments, number
- Calculate similarities (weighted cosine similarity, correlation coefficients = weights)
- Identify neighbors (particles with more than 0.95 similarity)
- Calculate prediction (weighted average from neighbors, similarities = weights)

# Future development

- Validation of predictions
- Applicability domain/reliability of predictions

- Accuracy improvements:
  - additional data
  - feature selection
  - similarity calculation
  - predictions (local regression models)

- Usability improvements:
  - additional data (extension of applicability domain, additional endpoints and chemistries)
  - inclusion of ontologies
  - Descriptor calculation directly from core and coating chemistries

# Webinterface

Your recommendations?

# Source code

https://github.com/opentox/nano-lazar
