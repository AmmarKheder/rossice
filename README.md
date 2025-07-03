<p align="center">
  <img src="logo.png" width="300px">
</p>

[![Documentation](https://img.shields.io/badge/docs-in%20progress-yellow)](#)
[![Previous Work](https://img.shields.io/badge/arXiv-2502.11941-blue)](https://arxiv.org/abs/2502.11941)

# Rossice: Fine-tuning ClimaX for High-Resolution Air Pollution Reanalysis

**Rossice** is a customized fork of [ClimaX](https://arxiv.org/abs/2301.10343), designed to integrate and fine-tune foundation weather models on high-resolution air pollution reanalysis data from the [CAQRA](https://www.scidb.cn/en/detail?dataSetId=696756084735475712) dataset (China Air Quality Reanalysis).  
This project aims to adapt ClimaX to pollution-specific variables such as **PM₂.₅**, **O₃**, **NO₂**, and more, using a spatial resolution of **0.1° (~10 km)**.

---

## 🎯 Project Objective

> *Fine-tune a general-purpose climate model (ClimaX) on high-resolution atmospheric pollutant fields over China using CAQRA, with a focus on prediction and representation of urban-scale pollution dynamics.*

Goals:
- Evaluate the adaptability of ClimaX on environmental pollutant data
- Incorporate pollutant-specific variables as model targets (e.g. PM₂.₅, NO₂, O₃)
- Enable training on finer spatial resolutions (0.1°) not originally used in ClimaX

---

## 📝 Reference

This project builds upon:

> **Huang et al. (2024)**  
> *A High-Resolution Reanalysis Dataset of Air Pollutants over China.*  

---

## 📖 Overview

- 📂 Data format: NetCDF / `xarray.Dataset`
- 🧠 Backbone: ClimaX (ViT-based climate foundation model)
- 🌍 Spatial resolution: 0.1° x 0.1° (~10 km)
- 🧪 Target variables: PM₂.₅, PM₁₀, NO₂, SO₂, O₃, CO, meteorological fields
- 🛠️ Training: Fine-tuning on pollutant-specific prediction tasks

Documentation will be expanded soon.

---

## 🚀 Usage

Coming soon:
- How to preprocess CAQRA
- How to configure `caqra.yaml` for training
- Custom dataloader for CAQRA
- Training & evaluation scripts

---

## 🙏 Acknowledgements

Special thanks to [Microsoft Research](https://github.com/microsoft/ClimaX) for releasing ClimaX, and to the open-source community advancing climate and weather AI research.

---

## 📄 License

This project follows the original ClimaX [MIT License](https://github.com/microsoft/ClimaX/blob/main/LICENSE).  
The name "Rossice" is used to identify this experimental fork.

---

## 💬 Contributions

Contributions, bug reports, and ideas are welcome!  
Please open an [issue](https://github.com/AmmarKheder/rossice/issues) or submit a [pull request](https://github.com/AmmarKheder/rossice/pulls).

---
