---
name: tokovo-dsl
description: Generate phone UI simulation videos (WhatsApp, Instagram, iMessage drama) using Tokovo's TypeScript DSL. Use when asked to create text story videos, phone conversation simulations, "texting my crush/ex/boss" content, or any fake phone screen drama video.
---

# Tokovo DSL - Phone Story Video Generator

Generate phone UI simulation videos using a declarative TypeScript DSL that compiles to Remotion videos.

## Quick Start Template

```typescript
import { createEpisode } from "@tokovo/dsl";

export default createEpisode("episode-id", (ep) => {
  ep.config({ fps: 30, title: "Episode Title" });

  ep.device("phone", "iphone16pro", (d) => {
    d.app("app_whatsapp");
    d.conversation("chat1", { name: "Alex", avatar: "alex.jpg" });

    d.beat("intro", (b) => {
      b.wait("2s");
      b.typing("Alex").for("1.5s");
      b.receive("Alex", "hey are you free tonight?");
      b.wait("3s");
      b.send("yeah what's up");
    });

    d.beat("tension", (b) => {
      b.typing("Alex").for("2s");
      b.receive("Alex", "we need to talk...");
      b.wait("4s"); // Dramatic pause
    });
  });
});
```

## Core Concepts

### Episode Structure

```
Episode
  └── Device(s)
        ├── App (whatsapp, instagram, imessage)
        ├── Conversation(s)
        └── Beat(s) - sequential story segments
              └── Actions (typing, receive, send, wait, etc.)
```

### Time Notation

- Strings: `"2s"`, `"500ms"`, `"1.5s"`
- Frames: raw numbers (at 30fps: 30 = 1 second)

### Device Profiles

- `iphone16pro` - iPhone 16 Pro (default)
- `iphone15` - iPhone 15
- `pixel8` - Google Pixel 8

## Beat Actions Reference

### Timing

```typescript
b.wait("2s"); // Pause for 2 seconds
b.wait(60); // Pause for 60 frames
```

### Typing Indicators

```typescript
b.typing("ContactName").for("1.5s"); // Show typing for 1.5s
b.typing("ContactName").for(45); // Show typing for 45 frames
```

### Messages

```typescript
// Receive message from contact
b.receive("Alex", "message text");
b.receive("Alex", "message text", { delay: "500ms" });

// Send message (from "you")
b.send("your reply");
b.send("your reply", { delay: "1s" });

// Voice message
b.receiveVoice("Alex", { duration: "5s" });
b.sendVoice({ duration: "3s" });

// Images
b.receiveImage("Alex", { url: "photo.jpg", caption: "look at this" });
b.sendImage({ url: "selfie.jpg" });
```

### Reactions

```typescript
b.react("messageRef", "heart"); // React to a message
b.react("last", "laugh"); // React to last message
```

### Read Receipts

```typescript
b.read("messageRef"); // Show read receipt
b.read("last"); // Mark last message as read
```

### Concurrent Actions

```typescript
b.concurrent([
  (b) => b.typing("Alex").for("2s"),
  (b) => b.wait("1s").then(() => b.receive("Mom", "call me")),
]);
```

## Pacing Guidelines

### Standard Pacing (comfortable reading)

| Action                 | Duration                     |
| ---------------------- | ---------------------------- |
| Short message appears  | 1-1.5s wait after            |
| Medium message appears | 2-3s wait after              |
| Long message appears   | 3-4s wait after              |
| Typing indicator       | 1-3s based on message length |
| Dramatic pause         | 3-5s                         |
| Scene transition       | 2s                           |

### Fast Pacing (rapid-fire drama)

Reduce all waits by 50%

### Slow Pacing (tension building)

Increase waits by 50-100%

## Drama Patterns

### The Reveal

```typescript
d.beat("reveal", (b) => {
  b.typing("Ex").for("3s"); // Long typing = anticipation
  b.receive("Ex", "I saw you with them last night");
  b.wait("5s"); // Let it sink in
});
```

### The Cliffhanger

```typescript
d.beat("cliffhanger", (b) => {
  b.receive("Boss", "We need to discuss your future here");
  b.wait("2s");
  b.typing("Boss").for("2s");
  // Episode ends mid-typing
});
```

### The Double Text

```typescript
d.beat("double-text", (b) => {
  b.send("hey");
  b.wait("3s");
  b.send("you there?");
  b.wait("2s");
  b.send("???");
  // Shows desperation
});
```

### The Screenshot Moment

```typescript
d.beat("screenshot", (b) => {
  b.receive("Friend", "omg look what they said");
  b.receiveImage("Friend", { url: "screenshot.jpg" });
  b.wait("5s"); // Time to read screenshot
  b.send("NO WAY");
});
```

## Camera Integration

```typescript
ep.camera((cam) => {
  cam.at("0s").focus("phone");
  cam.at("10s").shake({ intensity: 0.02, duration: "500ms" }); // Shock moment
  cam.at("20s").animate({ scale: 1.2, duration: "1s" }); // Zoom for tension
});
```

## Audio Integration

```typescript
ep.audio((audio) => {
  audio.at("0s").play("notification");
  audio.at("10s").play("dramatic_sting");
  audio.ambient("keyboard_clicks"); // Background typing sounds
});
```

## Multi-Device Stories

```typescript
ep.device("phone1", "iphone16pro", (d) => {
  d.conversation("chat", { name: "Alex", avatar: "alex.jpg" });
  // Alex's perspective
});

ep.device("phone2", "iphone16pro", (d) => {
  d.conversation("chat", { name: "Jordan", avatar: "jordan.jpg" });
  // Jordan's perspective (same conversation, other side)
});
```

## Common Mistakes to Avoid

1. **No wait after messages** - Viewers can't read

   ```typescript
   // BAD
   b.receive("A", "long message here");
   b.receive("A", "another one");

   // GOOD
   b.receive("A", "long message here");
   b.wait("3s");
   b.receive("A", "another one");
   ```

2. **Unrealistic typing duration**

   ```typescript
   // BAD - 10 second typing for "ok"
   b.typing("A").for("10s");
   b.receive("A", "ok");

   // GOOD - proportional to message length
   b.typing("A").for("500ms");
   b.receive("A", "ok");
   ```

3. **Missing conversation setup**

   ```typescript
   // BAD - will error
   b.receive("Alex", "hi"); // Who is Alex?

   // GOOD
   d.conversation("chat1", { name: "Alex", avatar: "alex.jpg" });
   // Now Alex exists in this conversation
   ```

## Resources

- `references/whatsapp-actions.md` - Full WhatsApp API
- `references/instagram-actions.md` - Instagram DM API
- `references/camera-actions.md` - Camera system
- `references/audio-actions.md` - Sound system
- `references/drama-patterns.md` - Proven content formulas
