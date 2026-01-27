# Camera Actions Reference

Control camera movement, zoom, and effects in Tokovo videos.

## Camera Track Setup

```typescript
ep.camera((cam) => {
  // Camera actions go here
});
```

## Point-Based Actions (at specific time)

### Focus on Element

```typescript
cam.at("0s").focus("phone"); // Focus on device
cam.at("5s").focus("message_bubble"); // Focus on specific anchor
```

### Set Camera Position

```typescript
cam.at("0s").set({
  x: 0, // Horizontal offset (-1 to 1)
  y: 0, // Vertical offset (-1 to 1)
  scale: 1, // Zoom level (1 = default, 2 = 2x zoom)
  rotation: 0, // Degrees
});
```

### Animated Camera Move

```typescript
cam.at("5s").animate({
  x: 0.1,
  y: -0.2,
  scale: 1.3,
  duration: "1s",
  easing: "easeInOut", // "linear" | "easeIn" | "easeOut" | "easeInOut"
});
```

### Camera Shake

```typescript
// Shock/impact moment
cam.at("10s").shake({
  intensityX: 0.02, // Horizontal shake amount
  intensityY: 0.02, // Vertical shake amount
  frequency: 15, // Shakes per second
  decay: 0.8, // How quickly it fades (0-1)
  duration: "500ms",
});

// Subtle tension shake
cam.at("15s").shake({
  intensityX: 0.005,
  intensityY: 0.005,
  frequency: 8,
  decay: 0.9,
  duration: "2s",
});
```

### Reset Camera

```typescript
cam.at("20s").reset(); // Return to default position
cam.at("20s").reset({ duration: "1s" }); // Animated reset
```

## Span-Based Actions (over time range)

### Track an Anchor

```typescript
// Follow a moving element
cam.span("10s", "30s").track("active_message", {
  scale: 1.2,
  lag: 0.1, // Smooth follow delay
});
```

### Hold Position

```typescript
// Lock camera during a scene
cam.span("5s", "15s").hold({
  x: 0,
  y: 0.1,
  scale: 1.1,
});
```

## Presets for Common Shots

### Conversation View

```typescript
// Standard chat view
cam.at("0s").set({ x: 0, y: 0, scale: 1 });
```

### Dramatic Zoom

```typescript
// Slow zoom on reveal
cam.at("10s").animate({
  scale: 1.4,
  duration: "3s",
  easing: "easeInOut",
});
```

### Message Focus

```typescript
// Zoom to specific message
cam.at("15s").focus("bombshell_message", {
  scale: 1.5,
  duration: "500ms",
});
```

### Pull Back

```typescript
// Reveal full screen after focus
cam.at("20s").animate({
  scale: 1,
  duration: "1s",
  easing: "easeOut",
});
```

## Cinematic Patterns

### The Creeping Zoom

Slowly zoom during tension build.

```typescript
cam.span("0s", "30s").animate({
  fromScale: 1,
  toScale: 1.3,
  easing: "linear",
});
```

### The Impact Shake

Shake on dramatic reveal.

```typescript
// At the moment of reveal
cam.at("15s").shake({
  intensityX: 0.03,
  intensityY: 0.02,
  frequency: 20,
  decay: 0.7,
  duration: "400ms",
});
```

### The Focus Pull

Draw attention to specific message.

```typescript
cam.at("10s").focus("important_msg", {
  scale: 1.4,
  duration: "600ms",
  easing: "easeOut",
});
// Hold for reading
cam.at("14s").reset({ duration: "800ms" });
```

### Multi-Device Switch

When showing multiple phones.

```typescript
// Start on phone1
cam.at("0s").focus("phone1");

// Transition to phone2
cam.at("10s").animate({
  x: 0.5, // Pan to right device
  duration: "800ms",
});
cam.at("10.8s").focus("phone2");
```

## Anchor System

Anchors are auto-generated for key elements:

| Anchor ID          | Element                |
| ------------------ | ---------------------- |
| `phone`            | Main device            |
| `phone1`, `phone2` | Multi-device           |
| `header`           | App header             |
| `input_area`       | Message input          |
| `last_message`     | Most recent message    |
| `{messageId}`      | Specific message by ID |

### Custom Anchors

```typescript
// In beat, create named anchor
const reveal = b.receive("Ex", "I'm leaving you");
// Reference in camera
cam.at("15s").focus(reveal, { scale: 1.5 });
```

## Easing Functions

| Easing      | Use Case                  |
| ----------- | ------------------------- |
| `linear`    | Steady movement, tracking |
| `easeIn`    | Starting movement         |
| `easeOut`   | Stopping movement         |
| `easeInOut` | Smooth transitions        |
| `spring`    | Bouncy, energetic         |

## Complete Example

```typescript
ep.camera((cam) => {
  // Start neutral
  cam.at("0s").set({ scale: 1 });

  // Slow creep during tension
  cam.at("5s").animate({
    scale: 1.15,
    duration: "10s",
    easing: "linear",
  });

  // Shake on reveal
  cam.at("15s").shake({
    intensityX: 0.025,
    intensityY: 0.02,
    duration: "400ms",
  });

  // Zoom to the message
  cam.at("15.5s").focus("reveal_message", {
    scale: 1.4,
    duration: "600ms",
  });

  // Hold for reading
  // (no action = holds position)

  // Pull back for reaction
  cam.at("20s").reset({ duration: "1s" });
});
```
