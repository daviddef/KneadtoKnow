# Kneady Pizza — App Store submission pack

App: **Kneady Pizza** · Bundle ID `com.daviddefranceski.kneadypizza` · Team `L9SAXP2E2W`
Version **1.0** · Build **23** (iPhone-only) · Primary language: English (Australia or US — pick one below)

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

## 2. Version metadata (under the 1.0 version, "App Store" tab)

### Promotional text (max 170 — editable any time without review)
```
Tell the app when you want to eat and it counts backwards — every step, time and gram worked out for you. Now with a landscape cooking mode you can follow at the bench.
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
• Each step explains what to do, the kit you'll need, what to watch out for, and the why behind it.

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
pizza,dough,baker,hydration,poolish,biga,fermentation,proof,neapolitan,sourdough,recipe,timer,knead
```

### What's New in This Version (release notes)
```
The first release of Kneady Pizza. Plan any pizza dough from baker's percentages, timed around when you want to eat — with a hands-free landscape cooking mode, a topping & shopping planner, and gluten-free support. Buon appetito!
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

- **Build:** select **1.0 (23)** (the one you uploaded from the Organizer). If it's still "Processing," wait for the email, then attach it.
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
| **Notes** | "No login required. The app works fully offline. Location and notifications are both optional and only enhance the experience: Location fetches the current temperature from the free Open-Meteo API (no key) to time the dough; Notifications give optional step reminders. To see the full flow: complete the short onboarding, pick a style and serve time, then open Cooking Directions. Rotate to landscape for the step-by-step cooking mode (swipe between steps, double-tap to complete)." |

---

## 6. Screenshots

**Required:** at least one iPhone size — 6.9" (1320 × 2868, e.g. iPhone 17 Pro Max) or 6.7" (1290 × 2796). 6.5" (1242 × 2688) is also accepted. Up to 10 per size. The app is now **iPhone-only**, so **no iPad screenshots are required**.

**Suggested set (5–6 shots), in order:**
1. Main screen — style + summary (the "what you're making" hero).
2. Cooking Directions — the timeline with times and steps.
3. Landscape cooking mode — one big step (the standout feature).
4. Pizza & topping planner — the shopping list.
5. A proof choice / setup screen (Quick / Cold / Warm).
6. The walkthrough "A few handy tricks" card (optional).

**How to capture (easiest, correct resolution):**
1. Open the project in Xcode → run on **iPhone 17 Pro Max** simulator (6.9") and an iPad if Universal.
2. Navigate to each screen above.
3. In the Simulator: **File ▸ Save Screen** (⌘S) — saves a correctly-sized PNG to your Desktop.
4. For landscape: **Device ▸ Rotate Left** (⌘←), then ⌘S.
5. Drag the PNGs into the matching size slot in App Store Connect.

(I captured a starter shot at 6.5" from the running simulator — see `/tmp/kp_appstore_portrait.png` — but capturing the full set needs the navigation/rotation that this environment can't drive reliably.)

---

## 7. Step-by-step in App Store Connect

1. **appstoreconnect.com → My Apps → Kneady Pizza** (the record already exists from TestFlight).
2. If there's no 1.0 version yet: **(＋) next to "iOS App" → create version 1.0**.
3. Fill **App Information** (section 1) — name, subtitle, categories, content rights.
4. In the **1.0 version page** fill: promotional text, description, keywords, what's new, support/marketing/privacy URLs, copyright (section 2).
5. Upload **screenshots** (section 6) to each required size slot.
6. **Build:** scroll to "Build", click **(＋)**, choose **1.0 (23)**. (Answer export-compliance if prompted — it won't be, given the plist flag.)
7. **App Privacy** (section 3) — complete the questionnaire and **Publish**.
8. Set **Pricing and Availability** (section 4).
9. **App Review Information** (section 5).
10. **Version Release:** "Automatically release after approval" (or manual).
11. Click **Add for Review → Submit**.

Then it goes to "Waiting for Review" → "In Review" → "Pending Developer Release"/"Ready for Sale". First reviews are usually 24–48 h.
```
