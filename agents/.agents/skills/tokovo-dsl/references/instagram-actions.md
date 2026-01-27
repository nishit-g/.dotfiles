# Instagram Actions Reference

Instagram DM simulations in Tokovo DSL.

## Setup

```typescript
ep.device("phone", "iphone16pro", (d) => {
  d.app("app_instagram");
  d.conversation("dm1", {
    name: "Username",
    avatar: "avatar.jpg",
    verified: false, // Blue checkmark
    followedBy: true, // "Follows you" badge
  });
});
```

## Message Actions

### Text Messages

```typescript
// Receive DM
b.receive("Username", "hey saw your story 👀");

// Send DM
b.send("thanks! just posted it");

// With options
b.receive("Username", "message", {
  delay: "500ms",
  seen: false, // Unseen indicator
});
```

### Photo/Video DMs

```typescript
// Receive photo
b.receiveImage("Username", {
  url: "photo.jpg",
  disappearing: false, // View once
});

// Disappearing photo
b.receiveImage("Username", {
  url: "selfie.jpg",
  disappearing: true,
});

// Video
b.receiveVideo("Username", {
  url: "video.mp4",
  duration: "10s",
});
```

### Voice Messages

```typescript
b.receiveVoice("Username", { duration: "5s" });
b.sendVoice({ duration: "3s" });
```

### Story Replies

```typescript
// Reply to their story
b.storyReply("Username", {
  storyImage: "their_story.jpg",
  text: "omg where is this??",
});

// They reply to your story
b.receiveStoryReply("Username", {
  storyImage: "your_story.jpg",
  text: "you look amazing!",
});
```

### Reel Shares

```typescript
// Share a reel
b.shareReel("Username", {
  thumbnail: "reel_thumb.jpg",
  caption: "this is so us 😂",
});

// Receive shared reel
b.receiveReel("Username", {
  thumbnail: "reel.jpg",
  message: "watch this lmao",
});
```

### Post Shares

```typescript
b.sharePost("Username", {
  image: "post.jpg",
  username: "@someaccount",
  caption: "look at this",
});
```

## Reactions

```typescript
// Heart react (double tap style)
b.react("last", "heart");

// Emoji reactions
b.react("msg_id", "😂");
b.react("msg_id", "🔥");
b.react("msg_id", "😮");
```

## Typing & Seen

```typescript
// Typing indicator
b.typing("Username").for("1.5s");

// Seen indicator
b.seen("last");
b.seen("msg_id");

// Active now status
b.status("Username", "Active now");
b.status("Username", "Active 2h ago");
```

## Instagram-Specific Features

### Message Requests

```typescript
// Show as message request (not follower)
d.conversation("request1", {
  name: "RandomUser",
  isRequest: true, // Shows in requests folder
});

d.beat("request", (b) => {
  b.receive("RandomUser", "hey beautiful");
  b.wait("2s");
  // Show accept/decline UI
  b.showRequestOptions();
});
```

### Unsend Message

```typescript
b.unsend("msg_id");
// Shows "Message unavailable" placeholder
```

### Group DMs

```typescript
d.conversation("group1", {
  name: "Squad 🔥",
  isGroup: true,
  members: ["Alice", "Bob", "Charlie"],
  avatar: "group_avatar.jpg",
});

d.beat("group-chat", (b) => {
  b.receive("Alice", "guys omg");
  b.receive("Bob", "what");
  b.receive("Alice", "look at this");
  b.receiveImage("Alice", { url: "screenshot.jpg" });
});
```

### Note Bubble

```typescript
// Show note above DM
b.setNote("Username", "feeling cute might delete later");
b.clearNote("Username");
```

## DM Conversation Patterns

### The Story Slide

Classic "reply to story" opener.

```typescript
d.beat("story-slide", (b) => {
  b.receiveStoryReply("Crush", {
    storyImage: "your_beach_pic.jpg",
    text: "where is this? 😍",
  });
  b.wait("3s");
  b.send("haha just a weekend trip");
  b.wait("2s");
  b.typing("Crush").for("1.5s");
  b.receive("Crush", "we should go together sometime 👀");
  b.wait("4s");
});
```

### The Reel React

Bonding over shared content.

```typescript
d.beat("reel-bond", (b) => {
  b.receiveReel("Friend", {
    thumbnail: "funny_reel.jpg",
    message: "THIS IS LITERALLY YOU",
  });
  b.wait("3s");
  b.send("STOPPP 😭😭");
  b.wait("1s");
  b.react("last", "😂");
});
```

### The Influencer DM

Verified account sliding in.

```typescript
d.conversation("celeb", {
  name: "Famous Person",
  verified: true,
  followedBy: false,
});

d.beat("celeb-dm", (b) => {
  b.receive("Famous Person", "hey love your content");
  b.wait("4s"); // Shock value
  b.send("omg is this real??");
  b.wait("2s");
  b.typing("Famous Person").for("1s");
  b.receive("Famous Person", "haha yes, check my page");
});
```

### The Creepy Request

Message request drama.

```typescript
d.conversation("creep", {
  name: "Anonymous",
  isRequest: true,
});

d.beat("creepy", (b) => {
  b.receive("Anonymous", "I've been watching your stories");
  b.wait("3s");
  b.receive("Anonymous", "You don't know me yet");
  b.wait("2s");
  b.receive("Anonymous", "But you will");
  b.wait("4s");
  // No response - just let it sit
});
```

## Visual Differences from WhatsApp

| Feature   | Instagram                  | WhatsApp         |
| --------- | -------------------------- | ---------------- |
| Bubbles   | Rounded, gradient for sent | Flat green/white |
| Reactions | Below message              | On message       |
| Seen      | Small text "Seen"          | Blue checkmarks  |
| Typing    | "typing..." text           | Animated dots    |
| Voice     | Waveform style             | Play button      |

## Complete Example

```typescript
export default createEpisode("instagram-drama", (ep) => {
  ep.config({ fps: 30, title: "The Story Reply" });

  ep.device("phone", "iphone16pro", (d) => {
    d.app("app_instagram");

    d.conversation("dm1", {
      name: "Alex",
      avatar: "alex.jpg",
      followedBy: true,
    });

    d.beat("opener", (b) => {
      // They reply to your story
      b.receiveStoryReply("Alex", {
        storyImage: "your_sunset.jpg",
        text: "this view though 😍",
      });
      b.wait("3s");

      b.send("thanks! the rooftop was amazing");
      b.wait("2s");

      b.typing("Alex").for("2s");
      b.receive("Alex", "we should go together next time");
      b.wait("3s");

      // The subtle escalation
      b.typing("Alex").for("1s");
      b.receive("Alex", "if you're free this weekend?");
      b.wait("4s");
    });

    d.beat("decision", (b) => {
      // Typing... thinking...
      b.typing("Me").for("2s");
      b.wait("1s");
      b.typing("Me").for("1.5s");

      // The response
      b.send("I'd like that :)");
      b.wait("2s");

      // Their reaction
      b.react("last", "heart");
    });
  });

  ep.camera((cam) => {
    cam.at("10s").animate({ scale: 1.2, duration: "2s" });
  });
});
```
