
# NoBrakes! - 8086 Assembly Racing Game 🏎️

**NoBrakes!** is a retro-style vertical racing game built entirely in **8086 Assembly Language**. The project demonstrates low-level programming concepts including direct video memory manipulation (VGA Mode 13h), hardware interrupts for background music, and sprite collision logic.

---

## 🎮 Game Description

The player controls a racing car speeding down a three-lane highway. The goal is simple: survive as long as possible! You must dodge incoming traffic, collect coins for a high score, and grab fuel cans to keep your engine running. 

The game features a complete lifecycle:
1. **Loading Screen:** Custom animated loading bar.
2. **Main Menu:** Animated car preview and developers' credits.
3. **Player Input:** Enter your Name and Roll Number.
4. **Instruction Screen:** Learn the controls before you drive.
5. **Gameplay:** Infinite runner mechanics with increasing difficulty.
6. **Game Over:** Detailed summary screen with score and restart options.

---

## ✨ Key Features

* **VGA Graphics (Mode 13h):** Direct writing to video memory (`0A000h`) for fast rendering of the road, grass, and sky.
* **Background Music Engine:** Uses a custom Interrupt Service Routine (ISR) on `INT 1Ch` to play background music without freezing the game loop.
* **Sound Effects:** Custom PC Speaker effects for crashing and picking up items.
* **Dynamic Obstacles:** Cars spawn randomly in different lanes.
* **Fuel System:** A visual fuel bar decreases over time; the game ends if it hits zero.
* **Collision Detection:** Precise hitbox logic for obstacles, coins, and fuel.
* **Pause Menu:** Press `ESC` to pause the game and decide whether to resume or quit.

---

## 🕹️ Controls

| Key | Action |
| :--- | :--- |
| **⬅️ Left Arrow** | Switch to the Left Lane |
| **➡️ Right Arrow** | Switch to the Right Lane |
| **⬆️ Up Arrow** | Move Car Forward (Up) |
| **⬇️ Down Arrow** | Move Car Backward (Down) |
| **ESC** | Pause Game / Exit |
| **SPACE** | Restart (on Game Over screen) |

---

## 🛠️ Technical Implementation

### Architecture
* **Language:** Assembly x86 (8086)
* **Assembler:** NASM
* **Format:** `.COM` (Tiny Model, `ORG 100h`)

### Data Structures
* **Sprites:** Custom pixel arrays defined for the Player Car, Enemy Cars, Coins, and Fuel Cans.
* **Music Data:** Frequency and duration arrays processed by the system timer.

---

## 🚀 How to Run

To run this game, you will need **DOSBox** (an x86 emulator) and **NASM**.

1.  **Clone the Repository:**
    ```bash
    git clone [https://github.com/YourUsername/YourRepoName.git](https://github.com/YourUsername/YourRepoName.git)
    ```

2.  **Open DOSBox** and mount your directory:
    ```bash
    mount c c:\path\to\your\project
    c:
    ```

3.  **Assemble the Code:**
    Use NASM to compile the assembly file into a `.com` executable.
    ```bash
    nasm racing.asm -o game.com
    ```
    *(Note: Replace `racing.asm` with your actual filename)*

4.  **Run the Game:**
    ```bash
    game.com
    ```

---

## 👥 Credits & Team

**Developed by:**
* **Rahmeen Nabeel** (24L-0868)
* **Eliza Nadeem** (24L-0655)



---

*Project created for Computer Organization and Assembly Language (COAL) Course.*
