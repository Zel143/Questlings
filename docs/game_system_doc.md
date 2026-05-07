This document consolidates the game design mechanics and technical specifications for the **Questlings** gamified productivity tool. It outlines the interaction between real-world habits, the "Bond" system, and the progression path for your digital companions.

## ---

**I. Core Gameplay Mechanics**

At the start of the journey, users select from **four Questlings** to accompany them. These companions act as the primary interface for task management and habit tracking.

### **1\. Task Classification**

Every task created by the user is mapped to one of four hobby categories. This ensures that progress is specialized and that specific Questlings grow based on relevant real-world actions:

* **Sport:** Physical activity and health.  
* **Study:** Learning and academic growth.  
* **Art:** Creative endeavors and hobbies.  
* **Tech:** Coding, building, and technical skills.

### **2\. The "Boss Level" (System-Generated Task)**

To increase engagement through unpredictability, the system generates a **random task per week** designated as a "Boss Level."

* **Function:** Gamifies the experience by forcing the user to step outside their standard routine.  
* **Reward:** Completion yields higher EXP and unique customization drops compared to standard dailies.

### **3\. Customization & Unlocks**

As users accumulate EXP, they unlock the ability to modify their experience:

* **Outfits:** Change the "fit" of the Questlings.  
* **New Characters:** Reaching milestone levels in a specific hobby class (e.g., Level 20 in "Art") unlocks specialized characters for that category.

## ---

**II. The Bond System (Health & Maintenance)**

Questlings do not use traditional HP. Instead, they utilize a **Bond Meter**, which represents the strength of the relationship between the user and the companion.

### **1\. Bond Decay Logic**

Consistency is the primary driver of the Bond Meter. When "Dailies" (habit-based tasks) are missed, the bond decays.

**Glitched State:** If the Bond Meter falls too low, the Questling becomes "glitched" or "unhappy." In this state, they may refuse tasks until the user completes specific **Care Tasks** (non-productive, relationship-focused actions) to restore the bond.

### **2\. The Decay Formula**

To maintain a "right and just" penalty system, bond loss is calculated using linear decay with scaling multipliers.

$$B\_{new} \= B\_{current} \- (L \+ (M \\times D))$$  
**Variable Definitions:**

* **$L$ (Base Loss):** A fixed penalty for the first missed day. (Standard: **5 points**).  
* **$M$ (Multiplier):** The "Abandonment Penalty" that scales with the Questling's maturity.  
* **$D$ (Consecutive Days Missed):** The count of days without a completed task.  
* **$B$ (Bond Meter):** Total value, capped at **100** and floored at **0**.

## ---

**III. Evolution & Leveling**

Progression is divided into two tracks: **Leveling** (Standard) and **Evolution** (Streak-based).

### **1\. Evolution Stages**

Evolution is a high-tier reward for discipline. A Questling only evolves when a specific streak is maintained (e.g., the Sports Bird evolves after a 7-day workout streak).

| Evolution Stage | Multiplier (M) | Difficulty Context |
| :---- | :---- | :---- |
| **Hatchling / Egg** | *0.5* | High forgiveness for onboarding new users. |
| **Rookie (Mini)** | *1.0* | Standard baseline for early-game habits. |
| **Champion (Adult)** | *1.2* | Increased maintenance for consistent users. |
| **Mega (Expert)** | *1.5* | High-stakes consistency for master-level habits. |

**Note on Lite Version:** The "Lite" version of the app will focus exclusively on **Leveling Up**. Evolution mechanics and the associated $M$ scaling are reserved for future full-version updates.

## ---

**IV. Impact & Restoration**

### **1\. Bond States**

* **Inspired (80–100%):** Grants **1.5x EXP** and higher "Critical Hit" rates for gold/items.  
* **Languishing (1–20%):** Questling may refuse tasks; applies a **0.5x EXP** penalty.  
* **Broken (0%):** Questling may de-evolve or remain glitched until significant Care Tasks are performed.

### **2\. Restoration Rates**

* **Daily Task Completion:** $+10$ Bond points.  
* **Positive Habit (+):** $+2$ Bond points.

## ---

**V. Technical Implementation (Python)**

The following logic should be used to calculate the decay penalty based on the Questling's current stage:

Python

def get\_bond\_penalty(days\_missed, evolution\_stage):  
    if days\_missed \== 0:  
        return 0  
          
    \# Set M based on Evolution Stage  
    multipliers \= {  
        "Hatchling": 0.5,  
        "Rookie": 1.0,  
        "Champion": 1.2,  
        "Mega": 1.5  
    }  
      
    m \= multipliers.get(evolution\_stage, 1.0)  
    base\_loss \= 5  
      
    \# Formula: L \+ (M \* (D-1))  
    \# Multiplier applies starting on the 2nd consecutive missed day.  
    total\_decay \= base\_loss \+ (m \* (days\_missed \- 1))  
    return total\_decay  
