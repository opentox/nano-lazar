.. |date| date::



=============================================================
Read across toxicity predictions with nano-lazar
=============================================================

.. class:: center

  Christoph Helma

  in silico toxicology gmbh

  .. image:: http://www.enanomapper.net/sites/all/themes/theme807/logo.png
    :align: center

Requirements
============

- Nanoparticle characterisation
- Toxicity measurements


eNanoMapper data import
=======================

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
Toxicity endpoint:

Read across procedure
=====================

.. class:: incremental

- Identify relevant fragments (significant correlation with toxicity)
  TODO list of fragments, number
- Calculate similarities (weighted cosine similarity, correlation coefficients = weights)
- Identify neighbors (particles with more than 0.95 similarity)
- Calculate prediction (weighted average from neighbors, similarities = weights)

Future development
==================

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
  - descriptor calculation directly from core and coating chemistries

Webinterface
============

https://nano-lazar.in-silico.ch/predict

Your recommendations?

Source code
===========

https://github.com/opentox/nano-lazar
