# Timing & Pacing Guide

Master the rhythm of phone drama videos.

## Frame Math

```
FPS = 30 (default)
1 second = 30 frames
1 minute = 1800 frames
```

### Time Notation

```typescript
"500ms"; // 15 frames
"1s"; // 30 frames
"1.5s"; // 45 frames
"2s"; // 60 frames
"5s"; // 150 frames
"30s"; // 900 frames
"1m"; // 1800 frames
```

## Message Pacing

### Reading Speed

Average viewer reads ~250 words/minute = ~4 words/second.

| Message Length | Minimum Display Time |
| -------------- | -------------------- |
| 1-3 words      | 1.5s                 |
| 4-8 words      | 2s                   |
| 9-15 words     | 3s                   |
| 16-25 words    | 4s                   |
| 25+ words      | 5s+                  |

### Formula

```typescript
const readTime = Math.max(1.5, messageWords * 0.25 + 0.5);
// Minimum 1.5s, add 0.25s per word, plus 0.5s buffer
```

## Typing Duration

Realistic typing based on message length.

| Message         | Typing Duration |
| --------------- | --------------- |
| "ok"            | 0.3-0.5s        |
| "hey what's up" | 1-1.5s          |
| Short sentence  | 1.5-2.5s        |
| Long sentence   | 2.5-4s          |
| Paragraph       | 4-6s            |

### Formula

```typescript
const typingTime = Math.max(0.5, messageChars * 0.04);
// Minimum 0.5s, ~40ms per character
```

### Emotional Typing

```typescript
// Nervous/careful typing = longer
b.typing("Ex").for("4s");
b.receive("Ex", "we need to talk");

// Angry/rapid typing = shorter
b.typing("Ex").for("0.8s");
b.receive("Ex", "WHAT");
```

## Dramatic Pauses

| Moment            | Pause Duration |
| ----------------- | -------------- |
| After hook/opener | 3-4s           |
| Before reveal     | 2-3s           |
| After bombshell   | 4-6s           |
| Processing shock  | 3-5s           |
| Cliffhanger hold  | 3-4s           |

### The Golden Pause

After a major revelation, give viewers time to react:

```typescript
b.receive("Ex", "I cheated on you");
b.wait("5s"); // Let it sink in
// Then continue
```

## Rhythm Patterns

### Standard Conversation

```
Message → 2s → Response → 2s → Message → 2s
```

### Rapid Fire (argument)

```
Message → 0.5s → Response → 0.5s → Message → 0.5s
```

### Tension Build

```
Message → 3s → Typing → Stop → 2s → Typing → 4s → Message → 5s
```

### Slow Burn

```
Message → 4s → Read receipt → 3s → Typing... → 5s → Message
```

## Video Length Guidelines

| Platform       | Optimal Length | Frames @30fps |
| -------------- | -------------- | ------------- |
| TikTok (short) | 15-30s         | 450-900       |
| TikTok (mid)   | 30-60s         | 900-1800      |
| YT Shorts      | 30-60s         | 900-1800      |
| IG Reels       | 15-30s         | 450-900       |
| Long form      | 2-5m           | 3600-9000     |

### Content Per Length

| Length | Content             |
| ------ | ------------------- |
| 15s    | Single reveal/twist |
| 30s    | Setup + payoff      |
| 60s    | Full mini-story     |
| 2m+    | Multi-scene drama   |

## Beat Structure

### 15-Second Video

```typescript
d.beat("hook", (b) => {
  b.receive("Ex", "I need to tell you something"); // 0-2s
  b.wait("3s"); // 2-5s
  b.typing("Ex").for("2s"); // 5-7s
  b.receive("Ex", "I'm pregnant"); // 7-9s
  b.wait("4s"); // 9-13s
  b.send("Is it mine?"); // 13-15s
});
```

### 30-Second Video

```typescript
d.beat("setup", (b) => {
  // Hook: 0-5s
  b.receive("Unknown", "Is this [Name]?");
  b.wait("3s");
  b.send("Who is this?");
  b.wait("2s");
});

d.beat("tension", (b) => {
  // Build: 5-15s
  b.typing("Unknown").for("3s");
  b.receive("Unknown", "Someone who knows what you did");
  b.wait("4s");
  b.send("What are you talking about");
  b.wait("3s");
});

d.beat("payoff", (b) => {
  // Reveal: 15-25s
  b.typing("Unknown").for("2s");
  b.receiveImage("Unknown", { url: "evidence.jpg" });
  b.wait("5s");
});

d.beat("reaction", (b) => {
  // End: 25-30s
  b.send("How did you get this");
  b.wait("3s");
  // Cliffhanger - no response
});
```

### 60-Second Video

```
0-10s:   Hook - grab attention
10-25s:  Rising action - build tension
25-40s:  Climax - the reveal
40-50s:  Reaction - process impact
50-60s:  Resolution or cliffhanger
```

## Pacing Styles

### Fast Pacing

- Short waits (0.5-1.5s)
- Quick typing (0.5-1s)
- Rapid-fire messages
- Good for: Arguments, panic, excitement

```typescript
b.receive("A", "WTF");
b.wait("0.5s");
b.receive("A", "YOU TOLD HER??");
b.wait("0.5s");
b.send("I HAD TO");
b.wait("0.5s");
b.receive("A", "WE'RE DONE");
```

### Medium Pacing

- Standard waits (2-3s)
- Normal typing (1-2s)
- Good for: Normal conversation, reveals

### Slow Pacing

- Long waits (4-6s)
- Extended typing (3-5s)
- Good for: Tension, horror, emotional weight

```typescript
b.receive("Ex", "I still think about us");
b.wait("5s");
b.typing("Ex").for("4s");
b.wait("2s"); // Stopped typing
b.typing("Ex").for("3s");
b.receive("Ex", "Do you?");
b.wait("6s"); // No response - tension
```

## Sync Points

Align camera/audio with message timing:

```typescript
// Message at 15s
d.beat("reveal", (b) => {
  b.wait("15s");
  b.receive("Ex", "I saw you with them");
});

// Camera + Audio match
ep.camera((cam) => {
  cam.at("15s").shake({ duration: "400ms" });
});

ep.audio((audio) => {
  audio.at("15s").play("dramatic_sting");
});
```

## Testing Pacing

1. **Read aloud test**: Read messages at your video's pace. If you can't keep up, slow down.

2. **Blink test**: Major reveals should land when viewer has "reset" attention (after 2-3s pause).

3. **Skip test**: Watch at 2x speed. If story still makes sense, pacing is too slow.
