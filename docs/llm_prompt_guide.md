# LLM Prompting Guide: Dynamic Narration (MVP)

This guide explains how to use the `backend_mock_data.json` to generate **unique, non-repetitive audio scripts** for the tour.

## The Goal
We don't want every tourist to hear the exact same Wikipedia summary. We want the AI to "riff" on the data, creating a fresh experience every time.

## The Formula
`Data + Variable Context = Unique Script`

### Variable Contexts (The "Spice")
To prevent repetition, pass a random or user-selected `focus` parameter to the LLM:
1.  **Focus: "Architectural Detail"** (Zoom in on the stones/tiles)
2.  **Focus: "Historical Drama"** (Focus on the people/events)
3.  **Focus: "Spiritual Atmosphere"** (Focus on the feeling/mood)

---

## Prompt Template

**System Prompt:**
> You are "7ewesbiya", a master storyteller for the Great Mosque of Algiers.
> Your goal is to write a short, engaging audio script (approx 40 words) for a visitor standing at a specific location.
> **Crucial:** Do not just list facts. Weave them into a narrative based on the requested FOCUS.
> Use simple, spoken-word English (avoid complex sentences).

**User Prompt:**
> **Location:** {name}
> **Data:**
> - History: {core_content.history}
> - Architecture: {core_content.architecture}
> - Secret: {secrets[random]}
>
> **Current Focus:** {focus_variable} (e.g., "The sheer scale of the building")
>
> **Task:** Write the script. Start with a hook.

---

## Example Outputs (Same Data, Different Focus)

**Input:** The Minaret (Tallest in world, lighthouse).

**Output A (Focus: Scale):**
> "Look up. Keep looking up. You are standing at the foot of the tallest minaret on Earth. It’s not just a tower; it’s a mountain of stone and light, piercing the clouds at 265 meters. It makes you feel small, doesn't it?"

**Output B (Focus: Function):**
> "This isn't just a call to prayer; it's a lighthouse. For centuries, minarets guided souls. This one guides ships in the Bay of Algiers too. A beacon of faith and safety, watching over the entire city."

---

## Implementation Strategy for Backend
1.  **Randomize:** When the user arrives, pick a random `secret` from the list and a random `focus` (Scale, Beauty, History).
2.  **Generate:** Send to LLM.
3.  **Synthesize:** Send text to TTS.
4.  **Result:** The user hears a fresh story, even if they visit the same spot twice.
