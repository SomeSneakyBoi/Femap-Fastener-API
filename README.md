# Femap API: Automated Fastener & Spring Stiffness Generator

This Femap API macro automates the creation of high-fidelity fastener representations between two structural bodies. It calculates equivalent spring stiffness based on local geometry and material properties using Huth formulation, then connects the bodies using a robust Rigid-CBush-Rigid architecture.

## 🚀 Features
* [cite_start]**Intelligent Geometry Detection**: Supports both **Solid-to-Solid** and **Surface-to-Surface (Shell)** connections[cite: 116, 289].
* [cite_start]**Automatic Stiffness Calculation**: Computes 6-DOF spring constants including Axial ($K_a$), Shear ($K_s$), Torsional ($K_t$), and Bending ($K_b$) [cite: 468-479].
* **Property Management**: Scans the model for existing "API Fastener" properties with matching dimensions to prevent redundant property creation.
* [cite_start]**Automated Rigid Spiders**: Automatically creates RBE2/Rigid elements with independent nodes at the geometric centers of selected holes [cite: 173-181, 335-347].

## 🛠 Mathematical Basis
The script implements Huth stiffness formulation for fastener modeling:

* **Axial Stiffness ($K_a$):**
    [cite_start]$$K_a = \frac{E_f \cdot A_f}{h}$$ [cite: 476]
* **Shear Stiffness ($K_s$):** Based on the empirical Huth-type formulation for joint compliance:
    [cite_start]$$K_s = \left[ \left( \frac{t_1 + t_2}{0.666 \cdot R} \right)^{0.666} \cdot \left( \frac{3}{t_1 E_1} + \frac{3}{t_2 E_2} + \frac{3}{2 t_1 E_1} + \frac{3}{2 t_2 E_2} \right) \right]^{-1}$$ [cite: 477]
* **Bending Stiffness ($K_b$):**
    [cite_start]$$K_b = \frac{1}{K_s} \cdot \frac{100 \cdot h^2}{4}$$ [cite: 479]

## 📥 Installation
1.  Download the `FastenerCreator.bas` file from this repository.
2.  In Femap, navigate to **View** > **Toolbars** > **API Programming**.
3.  Click the **Open** icon and select the `.bas` file.
4.  *Optional:* Place the file in your `Program Files/Siemens/Femap/api` directory to access it via the **Custom Tools** menu.

## 📖 How to Use
1.  [cite_start]**Activate Material**: Ensure the material for the fastener is the **Active Material** in your Femap model [cite: 99-101].
2.  **Run the Macro**: Execute the script from the API window.
3.  **Define Body 1**:
    * Confirm if the body is a **Solid** or **Shell** via the popup[cite: 116].
    * [cite_start]Select the surfaces (for solids) or curves (for shells) defining the fastener hole[cite: 123, 129].
4.  [cite_start]**Define Body 2**: Repeat the selection process for the second part of the joint[cite: 289, 292, 299].
5.  **Result**: The script generates:
    * Two **Rigid Elements** (RBE2) distributing load to the hole perimeters[cite: 181, 347].
    * A **Spring/Bush Element** connecting the two hole centers with the calculated stiffness matrix.

## 📋 Requirements
* **Femap Version**: 12.0 or higher.
* **License**: MIT License.

---
*Developed for automated structural analysis workflows in Femap.*
