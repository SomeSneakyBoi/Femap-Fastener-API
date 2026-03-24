# Femap API: Automated Fastener & Spring Stiffness Generator

This Femap API macro automates the creation of high-fidelity fastener representations between two structural bodies. It calculates equivalent spring stiffness based on local geometry and material properties using Huth formulation, then connects the bodies using a robust Rigid-CBush-Rigid architecture.

## 🚀 Features
* **Intelligent Geometry Detection**: Supports both **Solid-to-Solid** and **Surface-to-Surface (Shell)** connections.
* **Automatic Stiffness Calculation**: Computes 6-DOF spring constants including Axial ($K_a$), Shear ($K_s$), Torsional ($K_t$), and Bending ($K_b$).
* **Property Management**: Scans the model for existing "API Fastener" properties with matching dimensions to prevent redundant property creation.
* **Automated Rigid Spiders**: Automatically creates RBE2/Rigid elements with independent nodes at the geometric centers of selected holes.

## 🛠 Mathematical Basis
The script implements a Huth-based stiffness formulation for fastener modeling. The fastener is represented as a 6-DOF spring element with equivalent stiffness values derived from geometry and material properties.

The formulation follows the approach presented in:

> Huth, H. (1986). *Influence of fastener flexibility on the prediction of load transfer and fatigue life for multiple-row joints*.  
> In: Load Transfer and Fatigue in Bolted Joints.

---

### Stiffness Formulations

* **Axial Stiffness ($K_a$):**
    $$K_a = \frac{E_f \cdot A_f}{h}$$

* **Shear Stiffness ($K_s$):**
    $$K_s = \left[ \left( \frac{t_1 + t_2}{0.666 \cdot R} \right)^{0.666} \cdot \left( \frac{3}{t_1 E_1} + \frac{3}{t_2 E_2} + \frac{3}{2 t_1 E_1} + \frac{3}{2 t_2 E_2} \right) \right]^{-1}$$

* **Torsional Stiffness ($K_t$):**
    $$K_t = \frac{G_f \cdot J_f}{h}$$

* **Bending Stiffness ($K_b$):**
    $$K_b = \frac{1}{K_s} \cdot \frac{100 \cdot h^2}{4}$$

---

### 📐 Variable Definitions

| Symbol | Description |
|--------|------------|
| $E_f$ | Young’s modulus of fastener |
| $G_f$ | Shear modulus of fastener |
| $A_f$ | Cross-sectional area of fastener |
| $J_f$ | Polar moment of inertia of fastener |
| $h$ | Grip length (total thickness of connected parts) |
| $t_1, t_2$ | Thickness of connected plates |
| $E_1, E_2$ | Young’s modulus of connected plates |
| $R$ | Fastener radius |

---

### 📌 Assumptions

- Linear elastic material behavior  
- Small deformations  
- Fastener is represented as an equivalent beam-type connector  
- Load transfer between plates follows a Huth-type empirical relation  
- Plates remain in continuous contact (no separation or slip unless modeled separately)  
- All inputs must use a **consistent unit system**

---

### ⚠️ Notes

- The shear stiffness formulation is empirical and derived from Huth (1986); coefficients (e.g., 0.666) reflect calibrated joint behavior.
- The bending stiffness ($K_b$) is an approximate relation derived from shear compliance and is suitable for simplified connector representations.
- This formulation is intended for **global structural models**, not detailed local stress analysis around fastener holes.

## 📥 Installation
1. Download the `FastenerCreator.bas` file from this repository.
2. In Femap, navigate to **View** > **Toolbars** > **API Programming**.
3. Click the **Open** icon and select the `.bas` file.
4. *Optional:* Place the file in your `Program Files/Siemens/Femap/api` directory to access it via the **Custom Tools** menu.

## 📖 How to Use
1. **Activate Material**: Ensure the material for the fastener is the **Active Material** in your Femap model.
2. **Run the Macro**: Execute the script from the API window.
3. **Define Body 1**:
    * Confirm if the body is a **Solid** or **Shell** via the popup.
    * Select the surfaces (for solids) or curves (for shells) defining the fastener hole.
4. **Define Body 2**: Repeat the selection process for the second part of the joint.
5. **Result**:
    * Two **Rigid Elements** (RBE2) distributing load to the hole perimeters.
    * A **Spring/Bush Element** connecting the two hole centers with the calculated stiffness matrix.

## 📋 Requirements
* **Femap Version**: 12.0 or higher.
