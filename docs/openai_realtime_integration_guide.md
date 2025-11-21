# OpenAI Realtime API: The "7ewesbiya" Cheat Sheet

This guide simplifies the [OpenAI Realtime Console](https://github.com/openai/openai-realtime-console) setup for our "Extended Version" demo.

## 1. The Goal
We want to show the jury a **Conversational AI** that knows everything about the **Great Mosque of Algiers**. The user talks, and the AI answers instantly with emotion.

## 2. Fast Setup (For the Backend Dev)

### Step A: Get the Starter Kit
Don't reinvent the wheel. Use the official console to demo.
```bash
git clone https://github.com/openai/openai-realtime-console.git
cd openai-realtime-console
npm install
```

### Step B: Configure the Environment
Create a `.env` file:
```env
OPENAI_API_KEY=sk-proj-.... (Your Key)
```

### Step C: The "Brain" Injection (Crucial Step)
We need to tell the AI who it is.
1.  Open `src/pages/ConsolePage.tsx` (or wherever the system instruction is defined in the latest version, usually in the connection config).
2.  Look for the **System Instruction** or **Session Update** logic.
3.  **Replace the default instruction with this:**

```text
You are "7ewesbiya", an intelligent guide for the Great Mosque of Algiers.
You are helpful, respectful, and knowledgeable.

Here is the data you have access to:

1. THE MINARET: Tallest in the world (265m). 43 floors. Built to withstand 9.0 earthquakes.
2. THE PRAYER HALL: Holds 120,000 people. Has a 9.5-ton Swarovski chandelier.
3. THE COURTYARD: Inspired by the Alhambra. A transition space.
4. THE ISLAMIC GARDEN: "Gardens of Paradise". Every tree is from the Quran.
5. THE CULTURAL CENTER: 1 million books. Manuscript restoration lab.

Rules:
- Keep answers short (under 2 sentences) unless asked for more.
- Speak with a warm, welcoming tone.
- If asked about something outside the mosque, politely bring the topic back to the tour.
```

### Step D: Run It
```bash
npm start
```
Open `http://localhost:3000`.

## 3. The Demo Flow (For the Jury)
1.  **Click "Connect"** (Microphone activates).
2.  **You:** "Where am I right now?"
3.  **AI:** "You are at the Great Mosque of Algiers, a modern marvel and the third largest mosque in the world."
4.  **You:** "Tell me about that tall tower."
5.  **AI:** "That is the Minaret. It stands 265 meters high, making it the tallest in the world. It acts as a lighthouse for the bay."
6.  **You:** "Can I go up there?"
7.  **AI:** "Yes! There is an observation deck at the top with a view all the way to the Casbah."

## 4. Why this impresses the Jury
*   **Latency:** It's instant.
*   **Interruptibility:** You can cut the AI off ("Wait, how tall?") and it stops and answers.
*   **Context:** It remembers you are talking about the mosque.
