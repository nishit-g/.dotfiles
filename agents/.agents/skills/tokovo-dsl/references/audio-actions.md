# Audio Actions Reference

Sound effects and music in Tokovo videos.

## Audio Track Setup

```typescript
ep.audio((audio) => {
  // Audio actions go here
});
```

## Sound Effects

### Play Sound at Time

```typescript
audio.at("0s").play("notification");
audio.at("5s").play("message_sent");
audio.at("10s").play("message_received");
```

### Available Sound IDs

| Category          | Sound ID                 | Description           |
| ----------------- | ------------------------ | --------------------- |
| **Notifications** | `notification`           | Standard notification |
|                   | `notification_whatsapp`  | WhatsApp specific     |
|                   | `notification_imessage`  | iMessage bubble       |
|                   | `notification_instagram` | Instagram DM          |
| **Messages**      | `message_sent`           | Outgoing message      |
|                   | `message_received`       | Incoming message      |
|                   | `typing_start`           | Typing indicator      |
| **UI**            | `keyboard_tap`           | Single key tap        |
|                   | `keyboard_delete`        | Backspace             |
|                   | `scroll`                 | Scroll sound          |
|                   | `button_tap`             | UI button             |
| **Drama**         | `dramatic_sting`         | Tension hit           |
|                   | `suspense`               | Building tension      |
|                   | `reveal`                 | Big moment            |
|                   | `heartbeat`              | Anxiety               |
| **Reactions**     | `gasp`                   | Surprise              |
|                   | `laugh`                  | Comedy                |
|                   | `crying`                 | Sad moment            |

### Sound Options

```typescript
audio.at("5s").play("notification", {
  volume: 0.8, // 0-1
  delay: "200ms", // Delay before playing
});
```

## Ambient Sounds

### Background Loops

```typescript
// Runs throughout video
audio.ambient("keyboard_clicks");
audio.ambient("room_tone");

// With options
audio.ambient("coffee_shop", {
  volume: 0.3,
  fadeIn: "2s",
});
```

### Stop Ambient

```typescript
audio.at("30s").stopAmbient("keyboard_clicks");
```

## Music

### Background Music

```typescript
audio.music("tension_bed", {
  volume: 0.4,
  fadeIn: "2s",
  loop: true,
});
```

### Music Changes

```typescript
// Fade out current, fade in new
audio.at("20s").crossfade("reveal_sting", {
  duration: "1s",
  volume: 0.6,
});
```

### Music Ducking

When messages appear, music automatically ducks (lowers volume).

```typescript
audio.music("background", {
  volume: 0.5,
  duckTo: 0.2, // Volume during sound effects
  duckDuration: "500ms",
});
```

## Voice Notes

Integrated with message system:

```typescript
// In beat:
b.receiveVoice("Contact", { duration: "5s", autoplay: true });

// Audio track auto-generates playback sound
```

## Volume Automation

### Volume at Time

```typescript
audio.at("10s").setVolume("music", 0.3);
audio.at("20s").setVolume("music", 0.6);
```

### Fade

```typescript
audio.at("25s").fade("music", {
  to: 0,
  duration: "2s",
});
```

## Silence

### Mute Everything

```typescript
audio.at("15s").mute();
audio.at("17s").unmute();
```

### Selective Mute

```typescript
audio.at("15s").mute("ambient");
audio.at("15s").mute("music");
// Sound effects still play
```

## Sync with Drama

### Tension Build Pattern

```typescript
ep.audio((audio) => {
  // Start quiet
  audio.ambient("room_tone", { volume: 0.2 });

  // Tension music starts
  audio.at("5s").play("suspense", { volume: 0.3 });

  // Build to reveal
  audio.at("14s").fade("suspense", { to: 0.6, duration: "1s" });

  // REVEAL - dramatic hit
  audio.at("15s").play("dramatic_sting", { volume: 0.8 });

  // Silence for impact
  audio.at("15.5s").mute("ambient");
  audio.at("15.5s").fade("suspense", { to: 0, duration: "500ms" });

  // Let it breathe
  audio.at("18s").unmute();
  audio.ambient("heartbeat", { volume: 0.4 });
});
```

### Message Rhythm Pattern

```typescript
ep.audio((audio) => {
  // Auto-sounds on messages (enabled by default)
  audio.autoSounds({
    receive: "message_received",
    send: "message_sent",
    typing: "typing_start",
    volume: 0.7,
  });
});
```

## Complete Example

```typescript
ep.audio((audio) => {
  // Ambient foundation
  audio.ambient("room_tone", { volume: 0.15 });

  // Opening notification
  audio.at("2s").play("notification_whatsapp");

  // Tension music
  audio.at("5s").music("tension_bed", {
    volume: 0.35,
    fadeIn: "2s",
  });

  // Message sounds (auto-duck music)
  // These happen automatically with message events

  // Building to reveal at 15s
  audio.at("13s").play("suspense", { volume: 0.4 });

  // The reveal
  audio.at("15s").play("dramatic_sting");
  audio.at("15s").fade("tension_bed", { to: 0.1, duration: "500ms" });

  // Aftermath
  audio.at("17s").ambient("heartbeat", { volume: 0.5 });
  audio.at("17s").fade("tension_bed", { to: 0.4, duration: "2s" });

  // End fade
  audio.at("28s").fade("ALL", { to: 0, duration: "2s" });
});
```

## Audio File Locations

Place custom audio in:

```
apps/video-runner/public/sounds/
  ├── notifications/
  ├── music/
  ├── effects/
  └── ambient/
```

Reference with:

```typescript
audio.at("0s").play("custom/my_sound"); // → public/sounds/custom/my_sound.mp3
```
