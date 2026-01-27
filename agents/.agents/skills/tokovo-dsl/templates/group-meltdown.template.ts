import { createEpisode } from "@tokovo/dsl";

/**
 * Template: Group Chat Meltdown
 *
 * Drama explodes in the group chat.
 * Multiple participants, rapid reactions.
 */
export default createEpisode("group-meltdown-template", (ep) => {
  ep.config({ fps: 30, title: "The Group Chat Went OFF" });

  ep.device("phone", "iphone16pro", (d) => {
    d.app("app_whatsapp");

    d.conversation("squad", {
      name: "The Squad 🔥",
      isGroup: true,
      members: ["Alex", "Jordan", "Sam", "Taylor"],
      avatar: "group.jpg",
    });

    // === SPARK: Someone drops a bomb (0-8s) ===
    d.beat("spark", (b) => {
      b.receive("Alex", "I need to tell you all something");
      b.wait("2s");
      b.receive("Jordan", "what's up");
      b.wait("1s");
      b.receive("Sam", "👀");
      b.wait("2s");

      b.typing("Alex").for("3s");
      b.receive("Alex", "Taylor has been talking shit about all of us");
      b.wait("3s");
    });

    // === EXPLOSION: Reactions pour in (8-18s) ===
    d.beat("explosion", (b) => {
      b.receive("Jordan", "WHAT");
      b.wait("0.5s");
      b.receive("Sam", "excuse me???");
      b.wait("1s");

      b.typing("Taylor").for("1s");
      b.receive("Taylor", "that's not true wtf");
      b.wait("1.5s");

      b.typing("Alex").for("1s");
      b.receive("Alex", "I have screenshots");
      b.wait("2s");

      b.receive("Jordan", "POST THEM");
      b.wait("1s");
      b.receive("Sam", "👆👆👆");
      b.wait("2s");
    });

    // === EVIDENCE: Screenshots drop (18-28s) ===
    d.beat("evidence", (b) => {
      b.receiveImage("Alex", { url: "screenshot1.jpg" });
      b.wait("4s");
      b.receiveImage("Alex", { url: "screenshot2.jpg" });
      b.wait("4s");

      b.receive("Jordan", "oh my god");
      b.wait("1s");
      b.receive("Sam", "Taylor what the fuck");
      b.wait("2s");
    });

    // === FALLOUT: Taylor responds (28-35s) ===
    d.beat("fallout", (b) => {
      b.typing("Taylor").for("3s");
      b.receive("Taylor", "I can explain");
      b.wait("2s");

      b.receive("Jordan", "there's nothing to explain");
      b.wait("1s");
      b.receive("Jordan", "we're done");
      b.wait("2s");

      // Taylor leaves/removed
      b.receive("System", "Taylor left the group");
      b.wait("3s");
    });
  });

  ep.audio((audio) => {
    audio.at("0s").play("notification");
    audio.at("8s").music("tension_bed", { volume: 0.25 });
    audio.at("18s").play("dramatic_sting");
  });
});
