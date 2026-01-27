# Drama Patterns - Proven Content Formulas

Battle-tested story structures for viral phone screen content.

## The Hook Patterns

### Pattern 1: The Ominous Opener

Start with a message that demands explanation.

```typescript
d.beat("hook", (b) => {
  b.receive("Unknown Number", "I know what you did");
  b.wait("3s");
});
```

### Pattern 2: The Missed Messages

Open on a wall of unread chaos.

```typescript
d.beat("hook", (b) => {
  b.receive("Mom", "Call me NOW");
  b.receive("Mom", "Where are you??");
  b.receive("Mom", "I found something in your room");
  b.receive("Mom", "We need to talk when you get home");
  b.wait("4s");
});
```

### Pattern 3: The Late Night Text

Classic tension starter.

```typescript
d.beat("hook", (b) => {
  // Show timestamp: 2:47 AM
  b.receive("Ex", "hey");
  b.wait("2s");
  b.receive("Ex", "you up?");
  b.wait("3s");
});
```

---

## The Tension Builders

### The Typing Loop

They keep typing, stopping, typing again.

```typescript
d.beat("tension", (b) => {
  b.typing("Crush").for("2s");
  b.wait("1s"); // They stopped
  b.typing("Crush").for("3s");
  b.wait("500ms"); // Stopped again
  b.typing("Crush").for("1.5s");
  // Finally...
  b.receive("Crush", "nvm");
  b.wait("3s");
});
```

### The Read Receipt Silence

They saw it but aren't responding.

```typescript
d.beat("tension", (b) => {
  b.send("I really need to know where we stand");
  b.wait("2s");
  b.read("last"); // They read it
  b.wait("5s"); // But no response...
  b.send("hello??");
  b.wait("2s");
  b.read("last"); // Read again
  b.wait("4s"); // Still nothing
});
```

### The Voice Note Cliffhanger

Voice message = important.

```typescript
d.beat("tension", (b) => {
  b.receive("Best Friend", "I can't type this");
  b.wait("1s");
  b.receive("Best Friend", "listen to this");
  b.wait("500ms");
  b.receiveVoice("Best Friend", { duration: "47s" });
  b.wait("3s");
  // Don't play it - leave viewer wanting more
});
```

---

## The Reveal Patterns

### The Screenshot Drop

Evidence arrives.

```typescript
d.beat("reveal", (b) => {
  b.receive("Friend", "you need to see this");
  b.wait("1s");
  b.typing("Friend").for("500ms");
  b.receiveImage("Friend", { url: "screenshot_evidence.jpg" });
  b.wait("5s"); // Let it sink in
  b.send("WHAT THE FUCK");
  b.wait("1s");
  b.send("IS THIS REAL??");
});
```

### The Confession

They finally admit it.

```typescript
d.beat("reveal", (b) => {
  b.typing("Partner").for("4s"); // Long typing = big message
  b.receive("Partner", "I haven't been completely honest with you");
  b.wait("3s");
  b.receive("Partner", "There's someone else");
  b.wait("4s");
  // User reaction
  b.typing("Me").for("1s");
  b.wait("2s"); // Can't even finish typing
});
```

### The Wrong Person Text

Sent to wrong chat.

```typescript
d.beat("reveal", (b) => {
  b.receive("Partner", "I can't wait to see you tonight babe 😘");
  b.wait("2s");
  b.receive("Partner", "oh shit");
  b.wait("500ms");
  b.receive("Partner", "wrong person");
  b.wait("500ms");
  b.receive("Partner", "wait no I mean");
  b.wait("1s");
  // Message deleted
  b.deleteForEveryone("last");
  b.wait("3s");
});
```

---

## The Escalation Patterns

### The Double/Triple Text

Desperation visible.

```typescript
d.beat("desperation", (b) => {
  b.send("hey");
  b.wait("3s");
  b.send("you there?");
  b.wait("4s");
  b.send("???");
  b.wait("3s");
  b.send("ok I guess you're busy");
  b.wait("5s");
  b.send("actually no");
  b.send("we need to talk about this");
});
```

### The Group Chat Meltdown

Multiple people reacting.

```typescript
d.beat("meltdown", (b) => {
  b.receiveImage("Alice", { url: "evidence.jpg" });
  b.wait("2s");

  // Rapid reactions
  b.receive("Bob", "YOOO");
  b.wait("500ms");
  b.receive("Charlie", "💀💀💀");
  b.wait("500ms");
  b.receive("David", "no way");
  b.wait("500ms");
  b.receive("Alice", "@You explain this");
  b.wait("3s");

  // Everyone waiting
  b.concurrent([
    (b) => b.status("Bob", "online"),
    (b) => b.status("Charlie", "online"),
    (b) => b.status("David", "online"),
  ]);
  b.wait("4s");
});
```

---

## The Resolution Patterns

### The Cliffhanger End

Leave them wanting more.

```typescript
d.beat("cliffhanger", (b) => {
  b.send("Wait... are you saying what I think you're saying?");
  b.wait("2s");
  b.read("last");
  b.wait("1s");
  b.typing("Them").for("2s");
  // END - they never see the response
});
```

### The Twist End

Subvert expectations.

```typescript
d.beat("twist", (b) => {
  b.receive("Ex", "I've been thinking...");
  b.wait("2s");
  b.receive("Ex", "I want to get back together");
  b.wait("3s");
  // Expected: emotional response
  // Actual:
  b.send("lol no");
  b.wait("1s");
  b.send("I'm with someone better now");
  b.wait("2s");
  b.read("last"); // They saw it
  b.wait("3s"); // No response - they're stunned
});
```

### The Wholesome Subvert

Looks like drama, isn't.

```typescript
d.beat("subvert", (b) => {
  // Ominous setup
  b.receive("Mom", "We need to talk about what I found");
  b.wait("3s");
  b.send("What is it?");
  b.wait("2s");
  b.typing("Mom").for("2s");

  // Twist: it's wholesome
  b.receive("Mom", "Your acceptance letter came!");
  b.wait("1s");
  b.receive("Mom", "I'm so proud of you ❤️");
  b.wait("3s");
});
```

---

## Pacing Reference

### Tension Pacing

| Emotion    | Wait Duration       |
| ---------- | ------------------- |
| Shock      | 4-5s                |
| Processing | 3-4s                |
| Anxiety    | 2-3s between checks |
| Anger      | 0.5-1s (rapid fire) |

### Message Length → Typing Duration

| Length         | Typing Time |
| -------------- | ----------- |
| 1-3 words      | 0.5-1s      |
| Short sentence | 1-2s        |
| Long sentence  | 2-3s        |
| Paragraph      | 3-5s        |

### Read Time (how long to let viewer read)

| Content               | Wait After |
| --------------------- | ---------- |
| 1-5 words             | 1.5s       |
| Sentence              | 2-3s       |
| Long message          | 3-4s       |
| Image/Screenshot      | 4-6s       |
| Voice message preview | 2s         |

---

## Content Categories

### Relationship Drama

- Ex texts, cheating reveals, breakups, "we need to talk"
- High emotion, slower pacing, dramatic pauses

### Family Drama

- Parent discoveries, sibling fights, inheritance drama
- Mix of tension and guilt, medium pacing

### Friend Drama

- Betrayal reveals, group chat explosions, secrets exposed
- Fast pacing, lots of reactions, group dynamics

### Work Drama

- Boss texts, coworker conflicts, getting fired
- Professional tension, subtext-heavy, formal language

### Mystery/Horror

- Unknown numbers, creepy messages, threats
- Slow build, minimal messages, lots of silence
