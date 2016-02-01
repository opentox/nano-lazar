.. |date| date::


=============================================================
Read across toxicity predictions with nano-lazar
=============================================================

.. class:: center

  Christoph Helma, Denis Gebele, Micha Rautenberg

  in silico toxicology gmbh

  .. image:: http://www.enanomapper.net/sites/all/themes/theme807/logo.png
    :align: center

Requirements for nanoparticle read-across
=========================================

.. class:: incremental

  - Nanoparticle characterisation
  - Toxicity measurements

eNanoMapper particle characterisation
=====================================

.. class:: incremental

  - Nanoparticles imported: 464 
  - Nanoparticles with particle characterisation: 394 
  - Nanoparticles with toxicity data: 167 
  - Nanoparticles with toxicity data and particle characterisation: 160


eNanoMapper toxicity endpoints
==============================

.. class:: incremental

  - Toxicity endpoints: 41
  - Toxicity endpoints with more than one measurement value: 22
  - Toxicity endpoints with more than 10 measurements: 2

Selected data
=============

Protein corona dataset Au particles (106 particles)
Toxicity endpoint: Net cell association (A549 cell line)

Read across procedure
=====================

.. class:: incremental

  - Identify relevant properties (statistically significant correlation with toxicity: 14 from 30 properties)
  - Calculate similarities (weighted cosine similarity with correlation coefficients as weights)
  - Identify neighbors (particles with similarity > 0.95)
  - Calculate prediction (weighted average from neighbors with similarities as weights)

  Algorithms for feature selection, similarity calculation and predictions may change in the future.

Future development (I)
======================

- Validation of predictions
- Applicability domain/reliability of predictions

- Accuracy improvements:

  - additional data
  - feature selection
  - similarity calculation
  - predictions (local regression models)

Future development (I)
======================

- Usability improvements:

  - additional data (extension of applicability domain, additional endpoints and chemistries)
  - inclusion of ontologies
  - inclusion of protein corona characterisation?
  - particle characterisation without experimental data

    - descriptor calculation from core and coating chemistries
    - ontological descriptors 

nano-lazar
=====================

:Webinterface: https://nano-lazar.in-silico.ch/predict
:Presentation: https://nano-lazar.in-silico.ch/predict/enm-workshop.html
:Source code: https://github.com/enanomapper/nano-lazar-gui
:Issues: https://github.com/enanomapper/nano-lazar-gui/issues

Your comments, ideas, recommendations?

