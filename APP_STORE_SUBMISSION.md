# Kneady Pizza — App Store submission pack

App: **Kneady Pizza** · Bundle ID `com.daviddefranceski.kneadypizza` · Team `L9SAXP2E2W`
Version **1.1** · Build **38+** (iPhone-only, bump past 37 before archiving — see §4) · Primary language: English (Australia or US — pick one below)

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

## 2. Version metadata (under the 1.1 version, "App Store" tab)

### Promotional text (max 170 — editable any time without review)
```
Tell the app when you want to eat and it counts backwards — every step, time and gram worked out for you. Now with Kid Mode: a big, fun way to make pizza together!
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

KID MODE — MAKE PIZZA TOGETHER
• A big, fun, mess-and-giggles mode for little chefs, with huge fonts, jokes and confetti.
• Pick a pizza — Hawaiian, Margherita, Dino Pepperoni and more — or build your own and save it.
• Choose the dough: "Right now!" (ready in about 30 minutes) or "Puffy & bouncy".
• One giant animated step at a time, in kid words, with a grown-up hand-off for the hot oven.
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
Introducing Kid Mode — a big, fun, mess-and-giggles way to make pizza together!

• Pick a pizza (Hawaiian, Margherita, Dino Pepperoni and more) or build your own and save it.
• Choose your dough: "Right now!" (ready in about 30 minutes) or "Puffy & bouncy".
• One giant, animated step at a time in kid words — cups and spoons, with grams for grown-ups.
• Jokes, confetti and cheering the whole way, with a grown-up hand-off for the hot oven.

Also in this update:
• A fresh MODE picker — Kid, Villager, Pizzaiolo or Roman — sets how simple or detailed the app feels.
• Reminders now only ping once you've actually started baking.
• The style picker locks while a bake is underway, so you don't lose your place.
• Tap any cooking step to read it full-screen, swipe between steps, and see timing notes in a big clock pill.

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

- **Build:** the last CLI archive/upload was **1.1 (37)** — but several commits landed *after* that
  (mini-tile mode picker, video loop cap, mushroom/nutella/banana/peppers topping videos) that build 37
  doesn't contain, and TestFlight rejects re-uploading a duplicate build number anyway. **Bump
  `CURRENT_PROJECT_VERSION` to 38**, re-run the CLI archive (see the workflow doc in memory, or ask
  Claude — same command as every prior build), upload it, then select **1.1 (38)** here once it finishes
  processing (watch for the email).
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
| **Notes** | "No login required. The app works fully offline. Location and notifications are both optional and only enhance the experience: Location fetches the current temperature from the free Open-Meteo API (no key) to time the dough; Notifications give optional step reminders and only fire while a bake is actively in progress. To see the full flow: complete the short onboarding, pick a style and serve time, then open Cooking Directions. Rotate to landscape for the step-by-step cooking mode (swipe between steps, double-tap to complete), or tap a step to read it full-screen. **NEW IN 1.1** — Kid Mode: turn it on from the menu (top-left ≡ icon → MODE → 'Kid') or during first-run onboarding ('I am a Kid'). It's an optional, playful mode for cooking pizza with children — big text, short looping video demonstrations of each step, jokes and confetti. It collects no data, has no ads, no in-app purchases and no external links or social features. The final 'into the oven' step is explicitly labelled for a grown-up and includes a prominent 'Grown-ups' button back to the full app. This is a general Food & Drink app with an optional kid-friendly sub-mode, not an app primarily directed at children." |

---

## 6. Screenshots

**Required:** at least one iPhone size — 6.9" (1320 × 2868, e.g. iPhone 17 Pro Max) or 6.7" (1290 × 2796). 6.5" (1242 × 2688) is also accepted. Up to 10 per size. The app is now **iPhone-only**, so **no iPad screenshots are required**.

**Suggested set (7–8 shots), in order:**
1. Main screen — style + summary (the "what you're making" hero).
2. Cooking Directions — the timeline with times and steps.
3. Landscape cooking mode — one big step (the standout feature).
4. Pizza & topping planner — the shopping list.
5. A proof choice / setup screen (Quick / Cold / Warm).
6. Kid Mode — the "Pick your pizza!" screen.
7. Kid Mode — a big animated step (with video).
8. The MODE picker in the menu (Kid / Villager / Pizzaiolo / Roman tiles).

> `appstore/screenshots/kid-1-pick.png`, `kid-2-choose-dough.png`, `kid-3-mix.png` were captured 28 Jun
> and are now stale — the UI has since changed (bigger dough cards, step videos, mini-tile mode
> picker). Recapture before uploading.

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
2. If there's no 1.1 version yet: **(＋) next to "iOS App" → create version 1.1**.
3. Fill **App Information** (section 1) — name, subtitle, categories, content rights (unchanged since 1.0, but check they're still correct).
4. In the **1.1 version page** fill: promotional text, description, keywords, what's new, support/marketing/privacy URLs, copyright (section 2).
5. Upload **screenshots** (section 6) to each required size slot — including fresh Kid Mode shots.
6. **Build:** cut a fresh build first (see the ⚠️ note in section 4 — build 37 is stale), then scroll to "Build", click **(＋)**, choose **1.1 (38)** once it's finished processing. (Answer export-compliance if prompted — it won't be, given the plist flag.)
7. **App Privacy** (section 3) — re-check the questionnaire is still accurate (no new data collection in 1.1) and **Publish**.
8. Set **Pricing and Availability** (section 4).
9. **App Review Information** (section 5) — make sure the Kid Mode note is included.
10. **Version Release:** "Automatically release after approval" (or manual).
11. Click **Add for Review → Submit**.

Then it goes to "Waiting for Review" → "In Review" → "Pending Developer Release"/"Ready for Sale". First reviews are usually 24–48 h.
