# Kneady Pizza — App Store submission pack

App: **Kneady Pizza** · Bundle ID `com.daviddefranceski.kneadypizza` · Team `L9SAXP2E2W`
Version **1.2** · Build **41** (iPhone-only) · Primary language: English (Australia or US — pick one below)

> ⚠️ **1.1 is closed to new builds** — it was approved and released, and App Store Connect
> won't accept further submissions under that version number. This release is **1.2**.

---

## 1. App information (set once, under "App Information")

| Field | Value |
|---|---|
| **Name** (max 30) | `Kneady Pizza` |
| **Subtitle** (max 30) | `Pizza dough, perfectly timed` |
| **Primary category** | Food & Drink |
| **Secondary category** (optional) | Lifestyle |
| **Content rights** | Does not use third-party content |
| **Age rating** | 4+ (answer "None" to every content question) |

---

## 2. Version metadata (under the 1.2 version, "App Store" tab)

### Promotional text (max 170 — editable any time without review)
```
Tell the app when you want to eat and it counts backwards — every step, time and gram worked out for you. Now with a Live Activity, a flour picker, and a pizza history quiz!
```

### Description (max 4000)
```
Great pizza is mostly about timing — and Kneady Pizza does the timing for you.

Tell it the style you're making and when you want to eat. It works backwards to a clear, step-by-step plan: when to mix, when it rises, when to shape, and exactly how much flour, water, salt and yeast to weigh — all from proper baker's percentages.

NO MORE GUESSWORK
• Pick a style — Neapolitan, New York, Roman, Detroit, Sicilian, focaccia and more — and the recipe is seeded for you.
• Set your serve time; the app plans the whole rise around it.
• Yeast and timings adjust to your kitchen's temperature (fetch it automatically or set it by hand).
• Tight on time? It warms the proof and nudges the yeast to fit your window before ever suggesting a quick dough.

A PLAN THAT FITS REAL LIFE
• Quick, Cold or Warm proof — choose your pace.
• Sleep-aware scheduling shifts hands-on steps out of the middle of the night.
• "Start baking now" locks your times so they never drift when you reopen the app.
• A Currently Cooking banner brings you back to the exact step you're on.

COOK FROM YOUR PHONE
• Landscape cooking mode: one step per screen, swipe to move on, double-tap to tick it off.
• Tap any step to read it full-screen, with a big clock pill for its timing notes.
• Each step explains what to do, the kit you'll need, what to watch out for, and the why behind it.

FOR THE SERIOUS BAKER
• A water temperature (DDT) calculator works out exactly what to mix your water at — with friction presets for hand kneading, a stand mixer or a spiral mixer.
• Seven real flour presets — Caputo Pizzeria, King Arthur Bread Flour, All Trumps and more — each nudging hydration to suit.
• Every slider now doubles as a typed exact number.
• An illustrated poke-test guide appears right on the final proof step: underproofed, ready, or past its best.
• Check on a bake from the Lock Screen or Dynamic Island — no need to reopen the app to see how much longer the rise has left.
• A real, sourced pizza history quiz — 21 questions on where every style actually comes from, with myths clearly flagged as myths.

KID MODE — MAKE PIZZA TOGETHER
• A big, fun, mess-and-giggles mode for little chefs, with huge fonts, jokes and confetti.
• Pick a pizza — Hawaiian, Margherita, Dino Pepperoni and more — or build your own and save it.
• Choose the dough: "Right now!" (ready in about 30 minutes) or "Puffy & bouncy".
• One giant animated step at a time, in kid words, with a grown-up hand-off for the hot oven.
• The chef reacts to what you actually made, and finishing a pizza earns a real sticker for your collection.
• A silly six-question pizza trivia round of its own.
• Four modes to match your household — Kid, Villager, Pizzaiolo or Roman — from playful to full control.

PLAN THE WHOLE NIGHT
• Choose classic pizzas — Margherita, Marinara, Diavola, Capricciosa, Prosciutto and more.
• Get a scaled shopping list for dough and toppings, with rough cost estimates.

MADE TO ENJOY
• Two looks: calm Classic or bold Vibrant.
• Gluten-free mode with the right hydration and binders.
• Friendly tips, facts and the odd terrible pizza joke along the way.

Works offline. No account, no ads, no tracking. Just better pizza.

Yeast amounts and timings are well-grounded estimates, not laws — trust your dough and adjust to taste.
```

### Keywords (max 100 chars, comma-separated, no spaces)
```
pizza,dough,baker,hydration,poolish,kids,fermentation,proof,neapolitan,sourdough,recipe,timer,knead
```

### What's New in This Version (release notes)
```
A big one — new tools for serious bakers, and new reasons for kids to come back:

• Live Activity — check on your dough from the Lock Screen or Dynamic Island, no need to reopen the app.
• Water temperature (DDT) calculator — work out exactly what to mix your water at, with presets for hand kneading, a stand mixer or a spiral mixer.
• A flour picker — seven real presets (Caputo Pizzeria, King Arthur Bread Flour, All Trumps and more), each nudging hydration to suit.
• Every calculator field now accepts a typed exact number, not just a slider.
• An illustrated poke-test guide shows up right when you need it, on the final proof step.
• A correctness fix: preferment percentage is now capped to what your recipe's own hydration can actually supply, so what you see always matches the real dough.
• A pizza history quiz — 21 questions on where every style really comes from, with myths clearly flagged as myths.
• Kid Mode: the chef now reacts to what you actually made, there's a real sticker collection to fill up, and a silly pizza trivia round of its own.

Also included: Villager mode simplified to always be a Cold Proof with no clock times, focaccia's own instructions and kit list, and a Dark Mode contrast fix in landscape cooking.

Buon appetito! 🍕
```

### URLs
| Field | Value |
|---|---|
| **Support URL** (required) | `https://daviddef.github.io/KneadtoKnow/#support` |
| **Marketing URL** (optional) | `https://daviddef.github.io/KneadtoKnow/` |
| **Privacy Policy URL** (required) | `https://daviddef.github.io/KneadtoKnow/#privacy` |
| **Copyright** | `© 2026 David DeFranceski` |

> These URLs are served by the `docs/index.html` page in this repo via GitHub Pages.
> **Enable it once:** repo **Settings → Pages → Build and deployment → Source: Deploy from a branch → Branch: `main`, folder: `/docs` → Save.** Give it ~1 minute, then the URLs above resolve.
> ⚠️ GitHub Pages on a **private** repo needs a paid plan (Pro/Team). If this repo is private and on the free plan, either make it public, or paste `PRIVACY.md` into a public Gist and use that URL instead.

---

## 3. App Privacy ("App Privacy" section → "Get Started")

**Data collection: minimal.** The app stores everything on-device. The only thing that leaves the device is your coordinate, sent once to the free Open-Meteo weather API to read the current temperature. No accounts, analytics, ads or third-party trackers.

Answer the questionnaire:

- **Do you collect data?** → Yes (because location is sent to a third-party API).
- **Location → Precise Location**
  - Used for: **App Functionality**
  - Linked to the user's identity? **No**
  - Used for tracking? **No**
- **Everything else:** not collected.

(If you prefer, you can also note that location is optional — the user can type the temperature by hand.)

---

## 4. Build, pricing, availability

- **Build:** **1.2 (41)** — archived and uploaded via CLI on 8 Jul 2026 (no Organizer needed — see the
  release-workflow memory for the full archive → export → `xcrun altool --upload-app` pipeline). Contains
  everything in builds 39–41: the Villager/focaccia/Dark Mode fixes, a preferment-hydration correctness
  fix, direct numeric entry, the DDT (water temperature) calculator, an illustrated poke-test guide, a
  Live Activity for the active bake (new "Kneady Pizza Widgets" extension — see note below), a
  seven-preset flour-type picker, a pizza history quiz, and Kid Mode's new mascot reactions, sticker
  board and trivia round. Select **1.2 (41)** here once it finishes processing (watch for the email).
- **Note on the widget extension:** this build adds a small App Extension (`Kneady Pizza Widgets`,
  bundle ID `com.daviddefranceski.kneadypizza.widgets`) purely to power the Live Activity — it has no
  Home Screen widget, no separate UI of its own, and needs no extra App Store Connect setup beyond the
  main app record.
- **Price:** Free (Tier 0) unless you intend to charge.
- **Availability:** all territories (or restrict if you like).
- **Export compliance:** the app sets `ITSAppUsesNonExemptEncryption = NO`, so you won't be asked the encryption questions.

---

## 5. App Review information

| Field | Value |
|---|---|
| Sign-in required? | **No** |
| Demo account | Not needed |
| Contact | your name, email, phone |
| **Notes** | "No login required. The app works fully offline. Location and notifications are both optional and only enhance the experience: Location fetches the current temperature from the free Open-Meteo API (no key) to time the dough; Notifications give optional step reminders and only fire while a bake is actively in progress. To see the full flow: complete the short onboarding. Picking 'I am a Villager' gives the simplest experience — always a Cold Proof, no need to set a serve time. 'Sunday Pizzaiolo' or 'Roman Soldier' let you pick the proof style and an exact serve time. Then open Cooking Directions. Rotate to landscape for the step-by-step cooking mode (swipe between steps, double-tap to complete), or tap a step to read it full-screen. **NEW IN THIS BUILD** — Several additions on top of 1.2's initial release: (1) A Live Activity — tap 'Start baking now' on the Cooking Directions screen to begin a bake, and a Lock Screen / Dynamic Island activity appears showing the current step and a live countdown to the next one; it ends automatically once every step is ticked off or the bake is cancelled. This is powered by a small bundled App Extension (no separate UI, no Home Screen widget) and needs no account or setup. (2) Under the menu's 'Guides & Info', two new entries: a water-temperature (DDT) calculator, and a 21-question pizza history quiz. (3) A flour-type picker in the 'Yeast or starter' section (only shown outside Simple mode). (4) In Kid Mode: a sticker board and a short trivia round, both reachable from the 'Pick your pizza!' screen header. None of this adds any data collection, accounts, or external links. **NEW IN 1.2** — Quality and clarity fixes: Villager mode is now genuinely simpler (always Cold Proof, no serve-time question, and every step shows how far into the plan you are — e.g. '+18h' — instead of a clock time). Focaccia's instructions and kit list now speak to focaccia specifically instead of generic pizza wording, and call out the exact pan size needed so the wrong pan doesn't spoil the bake. Fixed a Dark Mode contrast issue in the landscape cooking view where some card text was hard to read. **NEW IN 1.1** — Kid Mode: turn it on from the menu (top-left ≡ icon → MODE → 'Kid') or during first-run onboarding ('I am a Kid'). It's an optional, playful mode for cooking pizza with children — big text, short looping video demonstrations of each step, jokes and confetti. It collects no data, has no ads, no in-app purchases and no external links or social features. The final 'into the oven' step is explicitly labelled for a grown-up and includes a prominent 'Grown-ups' button back to the full app. This is a general Food & Drink app with an optional kid-friendly sub-mode, not an app primarily directed at children." |

---

## 6. Screenshots

**Required:** at least one iPhone size — 6.9" (1320 × 2868, e.g. iPhone 17 Pro Max) or 6.7" (1290 × 2796). 6.5" (1242 × 2688) is also accepted. Up to 10 per size. The app is now **iPhone-only**, so **no iPad screenshots are required**.

**Suggested set (7–8 shots), in order:**
1. Main screen — style + summary (the "what you're making" hero).
2. Cooking Directions — the timeline with times and steps.
3. Landscape cooking mode — one big step (the standout feature).
4. Pizza & topping planner — the shopping list.
5. A proof choice / setup screen (Quick / Cold / Warm).
6. Kid Mode — the "Pick your pizza!" screen. → `appstore/screenshots/kid-1-pick.png`
7. Kid Mode — "How quickly do you need it?" dough choice. → `appstore/screenshots/kid-2-choose-dough.png`
8. Kid Mode — a big animated step (with video). → `appstore/screenshots/kid-3-mix.png`

> `appstore/screenshots/kid-4-mode-picker.png` (the MODE tile picker in the menu) is also available as
> a bonus/optional 9th shot. All four were recaptured 2 Jul 2026 at 1242×2688 against build 38 — kept
> as-is for build 41 by choice. Note: the "Pick your pizza!" screen (`kid-1-pick.png`) now also shows
> two small new header buttons (a trivia icon and a sticker-count pill) not visible in that screenshot
> — cosmetic only, doesn't misrepresent the app, so it wasn't recaptured. Update it whenever convenient.

**How to capture (easiest, correct resolution):**
1. Open the project in Xcode → run on **iPhone 17 Pro Max** simulator (6.9"). The app is iPhone-only, so no iPad capture is needed.
2. Navigate to each screen above.
3. In the Simulator: **File ▸ Save Screen** (⌘S) — saves a correctly-sized PNG to your Desktop.
4. For landscape: **Device ▸ Rotate Left** (⌘←), then ⌘S.
5. Drag the PNGs into the matching size slot in App Store Connect.

Ask Claude to drive the simulator and capture the full set if you'd rather not do it by hand.

---

## 7. Step-by-step in App Store Connect

1. **appstoreconnect.com → My Apps → Kneady Pizza** (the record already exists from TestFlight).
2. If there's no 1.2 version yet: **(＋) next to "iOS App" → create version 1.2** (not 1.1 — that train is closed).
3. Fill **App Information** (section 1) — name, subtitle, categories, content rights (unchanged since 1.0, but check they're still correct).
4. In the **1.2 version page** fill: promotional text, description, keywords, what's new, support/marketing/privacy URLs, copyright (section 2).
5. Upload **screenshots** (section 6) to each required size slot — `appstore/screenshots/kid-*.png` are ready.
6. **Build:** already uploaded via CLI (section 4) — scroll to "Build", click **(＋)**, choose **1.2 (41)** once it's finished processing. (Answer export-compliance if prompted — it won't be, given the plist flag.)
7. **App Privacy** (section 3) — re-check the questionnaire is still accurate (no new data collection in 1.2) and **Publish**.
8. Set **Pricing and Availability** (section 4).
9. **App Review Information** (section 5) — make sure the 1.2 and Kid Mode notes are both included.
10. **Version Release:** "Automatically release after approval" (or manual).
11. Click **Add for Review → Submit**.

Then it goes to "Waiting for Review" → "In Review" → "Pending Developer Release"/"Ready for Sale". First reviews are usually 24–48 h.
