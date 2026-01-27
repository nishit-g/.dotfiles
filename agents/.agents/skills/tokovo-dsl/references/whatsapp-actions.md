# WhatsApp Actions Reference

Complete API for WhatsApp message simulations in Tokovo DSL.

## Setup

### Conversation Definition

```typescript
d.conversation("conversationId", {
  name: "Contact Name", // Display name
  avatar: "avatar.jpg", // Avatar image (optional)
  isGroup: false, // Group chat (optional)
  members: ["Alice", "Bob"], // Group members if isGroup (optional)
});
```

### Multiple Conversations

```typescript
d.conversation("chat1", { name: "Mom" });
d.conversation("chat2", { name: "Best Friend" });
d.conversation("work-group", {
  name: "Work Team",
  isGroup: true,
  members: ["Boss", "Coworker1", "Coworker2"],
});
```

## Message Actions

### Text Messages

```typescript
// Receive from contact
b.receive("ContactName", "message text");
b.receive("ContactName", "message text", {
  delay: "500ms", // Delay before appearing
  silent: true, // No notification sound
});

// Send (from user perspective)
b.send("your message");
b.send("your message", { delay: "1s" });

// In group chats, specify sender
b.receive("Alice", "hey everyone!"); // Alice sends to group
b.receive("Bob", "what's up"); // Bob responds
```

### Voice Messages

```typescript
// Receive voice note
b.receiveVoice("ContactName", {
  duration: "5s", // Playback duration shown
  played: false, // Whether it shows as played
});

// Send voice note
b.sendVoice({ duration: "3s" });
```

### Image Messages

```typescript
// Receive image
b.receiveImage("ContactName", {
  url: "photo.jpg", // Image URL or path
  caption: "look at this!", // Optional caption
});

// Send image
b.sendImage({
  url: "selfie.jpg",
  caption: "me rn",
});
```

### Video Messages

```typescript
b.receiveVideo("ContactName", {
  url: "video.mp4",
  duration: "10s",
  caption: "watch this",
});

b.sendVideo({
  url: "reaction.mp4",
  duration: "5s",
});
```

### Location Messages

```typescript
b.receiveLocation("ContactName", {
  name: "Central Park",
  address: "New York, NY",
});
```

### Document Messages

```typescript
b.receiveDocument("ContactName", {
  name: "contract.pdf",
  size: "2.4 MB",
});
```

## Typing Indicators

```typescript
// Basic typing
b.typing("ContactName").for("1.5s");

// Typing with callback (for complex sequences)
b.typing("ContactName")
  .for("2s")
  .then(() => {
    b.receive("ContactName", "sorry was typing a lot");
  });

// Realistic typing duration formula:
// ~50ms per character for short messages
// ~30ms per character for longer messages
// Add 500ms-1s base time
```

## Reactions

```typescript
// React to specific message
b.react("msg_id", "heart");

// React to last message
b.react("last", "laugh");

// Available reactions:
// "heart" | "laugh" | "wow" | "sad" | "angry" | "thumbsup" | "thumbsdown"
```

## Read Receipts

```typescript
// Mark specific message as read
b.read("msg_id");

// Mark last message as read
b.read("last");

// Mark all messages as read
b.readAll();
```

## Status Indicators

```typescript
// Online status
b.status("ContactName", "online");
b.status("ContactName", "typing...");
b.status("ContactName", "last seen today at 3:45 PM");

// For groups
b.status("Alice", "online"); // Shows "Alice is online"
```

## Message References

When you need to reference a specific message later:

```typescript
const importantMsg = b.receive("Ex", "I need to tell you something");
// ... later ...
b.react(importantMsg, "wow");
b.read(importantMsg);
```

## Deletion & Editing

```typescript
// Delete message
b.delete("msg_id");
b.delete("last");

// "This message was deleted" placeholder
b.deleteForEveryone("msg_id");
```

## Complete Example

```typescript
d.beat("confrontation", (b) => {
  // Setup the tension
  b.wait("1s");

  // They start typing...
  b.typing("Ex").for("3s");

  // The message lands
  const bombshell = b.receive(
    "Ex",
    "We need to talk about what happened last night",
  );
  b.wait("4s"); // Let viewer read

  // User is nervous, starts typing, stops
  b.typing("Me").for("1s");
  b.wait("500ms"); // Hesitation

  // Finally responds
  b.send("What do you mean?");
  b.wait("2s");

  // Read receipt appears
  b.read("last");
  b.wait("1s");

  // They're typing again...
  b.typing("Ex").for("4s"); // Long = ominous

  // Screenshot drop
  b.receiveImage("Ex", { url: "screenshot.jpg" });
  b.wait("5s"); // Time to process

  // React to the bombshell
  b.send("I can explain");
  b.wait("1s");

  // They react dismissively
  b.react("last", "laugh");
});
```

## Group Chat Dynamics

```typescript
d.conversation("drama-group", {
  name: "The Squad",
  isGroup: true,
  members: ["Alice", "Bob", "Charlie"],
});

d.beat("group-drama", (b) => {
  b.receive("Alice", "did you guys see what happened?");
  b.wait("2s");

  // Multiple people typing
  b.concurrent([
    (b) => b.typing("Bob").for("1.5s"),
    (b) => b.typing("Charlie").for("2s"),
  ]);

  b.receive("Bob", "omg yes");
  b.wait("500ms");
  b.receive("Charlie", "I'm shook");
  b.wait("2s");

  // User enters
  b.send("wait what happened??");
});
```
