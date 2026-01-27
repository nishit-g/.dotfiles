import { createEpisode } from "@tokovo/dsl";

/**
 * Template: Screenshot Reveal
 *
 * Friend sends damning screenshot evidence.
 * High drama, strong reaction potential.
 */
export default createEpisode("screenshot-reveal-template", (ep) => {
  ep.config({ fps: 30, title: "My Friend Sent Me This..." });

  ep.device("phone", "iphone16pro", (d) => {
    d.app("app_whatsapp");

    d.conversation("bestie", {
      name: "Best Friend 💕",
      avatar: "bestie.jpg",
    });

    // === HOOK: Urgent opener (0-5s) ===
    d.beat("hook", (b) => {
      b.receive("Best Friend 💕", "OMG");
      b.wait("1s");
      b.receive("Best Friend 💕", "YOU NEED TO SEE THIS");
      b.wait("2s");
      b.receive("Best Friend 💕", "RIGHT NOW");
      b.wait("2s");
    });

    // === BUILD: What is it? (5-12s) ===
    d.beat("build", (b) => {
      b.send("what?? what happened");
      b.wait("2s");

      b.typing("Best Friend 💕").for("1s");
      b.receive("Best Friend 💕", "I'm so sorry");
      b.wait("2s");

      b.send("you're scaring me");
      b.wait("2s");
    });

    // === REVEAL: The screenshot (12-20s) ===
    d.beat("reveal", (b) => {
      b.typing("Best Friend 💕").for("1s");
      b.receiveImage("Best Friend 💕", {
        url: "screenshot_evidence.jpg",
        caption: "I found this on their phone",
      });
      b.wait("6s"); // Time to read screenshot
    });

    // === REACTION: Aftermath (20-30s) ===
    d.beat("reaction", (b) => {
      b.send("WHAT THE FUCK");
      b.wait("1s");
      b.send("IS THIS REAL??");
      b.wait("2s");

      b.typing("Best Friend 💕").for("1s");
      b.receive("Best Friend 💕", "I'm so sorry babe");
      b.wait("2s");

      b.send("I'm gonna kill them");
      b.wait("2s");

      b.receive("Best Friend 💕", "what are you gonna do?");
      b.wait("3s");
      // End on decision moment
    });
  });

  ep.camera((cam) => {
    cam.at("12s").shake({ intensityX: 0.02, duration: "400ms" });
    cam.at("13s").animate({ scale: 1.3, duration: "1s" });
    cam.at("20s").reset({ duration: "800ms" });
  });

  ep.audio((audio) => {
    audio.at("0s").play("notification");
    audio.at("12s").play("dramatic_sting");
  });
});
