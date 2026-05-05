

## 📋 Project Overview: The Gamified App

**Core Stack:** Flutter (Frontend) + Supabase (Database/Auth)

**Theme:** Task management meets monster collection (Pokémon-style).

### 1. Team Roles & Responsibilities

| **Member** | **Primary Focus**       | **Key Tasks**                                                                                              |
| ---------------- | ----------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| **Ranzel** | **Lead QA / Developer** | Figma to Flutter implementation, Browser AI/Sprints Agent, Backend support, and Social features (Parties/Clans). |
| **Lee**    | **Backend Lead**        | Database management (DB marked as started/done), Backend logic, and Home screen functionality.                   |
| **Carl**   | **Creative & Concept**  | Sprite design, Frontend conceptualization, and Shop UI.                                                          |
| **Mervin** | **UX & Logic**          | Wireframing, defining Habit/Daily task logic, Inventory, and low-priority AI tasks.                              |

---

### 2. The User Journey (Product Flow)

Based on your flow diagram, the "First Time User Experience" (FTUE) is:

1. **Authentication:** Login via Supabase (Email).
2. **Onboarding:** Choose Starter Pokémon.
3. **Education:** Tutorial.
4. **Main Loop:** Landing on `Home.dart`.

---

### 3. Immediate Action Items (The "To-Do" List)

#### **Phase 1: Infrastructure (High Priority)**

* **Database:** Finalize Supabase Email login logic.
* **Validation:** Ensure data values are correct (Aiming for 80% accuracy threshold).
* **Environment:** Ranzel to download and sync Android Studio.

#### **Phase 2: Feature Development**

* **Social (Party System):** Build the "Search" and "Group/Clan" functionality.
* **Task Engine:** Mervin to list and categorize daily habits and tasks.
* **Assets:** Carl to finalize sprites for the "Starter" selection.

#### **Phase 3: Program Testing**

Once the builds are ready, testing must be completed on these specific screens:

* [ ] Home Screen
* [ ] Inventory Screen
* [ ] Party/Social Screen
* [ ] Shop Screen

---

### 4. UI/UX Blueprint (`Home.dart`)

The wireframe indicates a clean, top-down layout:

* **Header:** Visual landscape (Sun/Mountains) with a **Streak Counter** and **Settings** icon.
* **Center Stage:** Featured Monster/Pokémon sprite.
* **Primary CTA:** Large buttons for **Tasks/Missions** and  **Events** .
* **Navigation:** Persistent bottom bar (Home, Inv, Party, Shop).

---

## 🚩 Product Owner’s Perspective (Risk & Friction)

> **Risk: The "Ranzel Bottleneck"**
>
> Ranzel is currently assigned to QA, Frontend, Backend, AI, and Social features. From a cost/velocity perspective, this is a high-risk dependency. If Ranzel gets stuck on the AI Sprints Agent, the entire frontend implementation (Figma -> Flutter) stalls.
>
> * **Recommendation:** Move the "Party/Social" feature to Lee or Mervin once DB tasks stabilize.

> **User Friction: The "Wala Pa" Logic**
>
> Mervin’s list of habits/dailies is the "engine" of the app. If the task logic isn't defined before the UI is built, you'll face heavy "re-work" costs. Ensure the **Daily Task List** is finalized before the Home Screen testing begins.

> **Technical Debt: AI Scope Creep**
>
> "Browser AI" and "Sprints Agent" are complex. Keep these as "v2" features to ensure the core loop (Task -> Reward -> Sprite) is functional first.

How would you like to handle the workload distribution? We could reassign some of Ranzel's secondary tasks to keep the momentum high.
