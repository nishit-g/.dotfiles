import { createEpisode } from "@tokovo/dsl";

/**
 * Template: Creepy Unknown Number
 *
 * Horror/thriller format - unknown person knows too much.
 * Slow burn, unsettling pacing.
 */
export default createEpisode("creepy-unknown-template", (ep) => {
  ep.config({ fps: 30, title: "A Random Number Texted Me This..." });

  ep.device("phone", "iphone16pro", (d) => {
    d.app("app_whatsapp");

    d.conversation("unknown", {
      name: "Unknown Number",
      avatar: null, // No avatar = creepier
    });

    // === HOOK: Innocent start (0-8s) ===
    d.beat("hook", (b) => {
      b.receive("Unknown Number", "Hi");
      b.wait("3s");
      b.send("who is this?");
      b.wait("2s");
      b.read("last");
      b.wait("3s"); // They read but don't respond immediately
    });

    // === UNSETTLE: They know things (8-20s) ===
    d.beat("unsettle", (b) => {
      b.typing("Unknown Number").for("2s");
      b.receive("Unknown Number", "I saw you today");
      b.wait("3s");

      b.send("what? where?");
      b.wait("2s");

      b.typing("Unknown Number").for("3s");
      b.receive("Unknown Number", "At the coffee shop");
      b.wait("2s");
      b.receive("Unknown Number", "You were wearing the blue jacket");
      b.wait("4s");

      b.send("who the fuck are you");
      b.wait("2s");
    });

    // === ESCALATE: Getting worse (20-35s) ===
    d.beat("escalate", (b) => {
      b.typing("Unknown Number").for("4s");
      b.receive("Unknown Number", "I've been watching for a while");
      b.wait("4s");

      b.send("I'm calling the police");
      b.wait("2s");

      b.typing("Unknown Number").for("2s");
      b.receive("Unknown Number", "That won't help");
      b.wait("3s");

      b.typing("Unknown Number").for("3s");
      b.receive("Unknown Number", "I know where you live");
      b.wait("4s");
    });

    // === CLIMAX: The image (35-45s) ===
    d.beat("climax", (b) => {
      b.typing("Unknown Number").for("1s");
      b.receiveImage("Unknown Number", {
        url: "photo_of_house.jpg", // Photo of their house
      });
      b.wait("6s");

      b.send("STOP");
      b.wait("1s");
      b.send("LEAVE ME ALONE");
      b.wait("3s");

      b.typing("Unknown Number").for("2s");
      b.receive("Unknown Number", "Look outside");
      b.wait("4s");
      // End on cliffhanger
    });
  });

  ep.camera((cam) => {
    // Slow creeping zoom throughout
    cam.at("0s").set({ scale: 1 });
    cam.at("0s").animate({ scale: 1.25, duration: "45s", easing: "linear" });

    // Shake on photo reveal
    cam.at("36s").shake({ intensityX: 0.015, duration: "600ms" });
  });

  ep.audio((audio) => {
    audio.ambient("room_tone", { volume: 0.1 });
    audio.at("8s").music("suspense", { volume: 0.2, fadeIn: "3s" });
    audio.at("35s").play("dramatic_sting", { volume: 0.5 });
    audio.at("42s").ambient("heartbeat", { volume: 0.4 });
  });
});
