import { createEpisode } from "@tokovo/dsl";

/**
 * Template: Toxic Ex Drama
 *
 * Classic format - ex reaches out late at night, drama ensues.
 * Customize: names, messages, revelation type
 */
export default createEpisode("toxic-ex-template", (ep) => {
  ep.config({ fps: 30, title: "When Your Ex Texts at 2AM" });

  ep.device("phone", "iphone16pro", (d) => {
    d.app("app_whatsapp");

    // Setup conversation
    d.conversation("ex-chat", {
      name: "Ex 🚫", // Customize name
      avatar: "ex-avatar.jpg",
    });

    // === ACT 1: The Hook (0-5s) ===
    d.beat("hook", (b) => {
      b.receive("Ex 🚫", "hey");
      b.wait("2s");
      b.receive("Ex 🚫", "you up?");
      b.wait("3s");
    });

    // === ACT 2: The Engagement (5-15s) ===
    d.beat("engage", (b) => {
      b.send("what do you want");
      b.wait("2s");

      b.typing("Ex 🚫").for("2s");
      b.receive("Ex 🚫", "I've been thinking about us");
      b.wait("3s");

      b.send("there is no us anymore");
      b.wait("2s");

      b.typing("Ex 🚫").for("3s");
      b.receive("Ex 🚫", "I made a mistake");
      b.wait("3s");
    });

    // === ACT 3: The Reveal (15-25s) ===
    d.beat("reveal", (b) => {
      b.send("what mistake");
      b.wait("2s");

      b.typing("Ex 🚫").for("4s"); // Long typing = big message
      b.receive("Ex 🚫", "I'm still in love with you");
      b.wait("5s"); // Let it sink in
    });

    // === ACT 4: The Response (25-30s) ===
    d.beat("response", (b) => {
      b.typing("Me").for("2s");
      b.wait("1s"); // Hesitation
      b.typing("Me").for("1.5s");
      b.send("I've moved on");
      b.wait("2s");
      b.read("last");
      b.wait("3s"); // They saw it, no response - end
    });
  });

  // Camera: slow zoom for tension
  ep.camera((cam) => {
    cam.at("0s").set({ scale: 1 });
    cam.at("15s").animate({ scale: 1.2, duration: "10s" });
  });

  // Audio: tension bed
  ep.audio((audio) => {
    audio.at("0s").play("notification");
    audio.at("5s").music("tension_bed", { volume: 0.3, fadeIn: "2s" });
  });
});
