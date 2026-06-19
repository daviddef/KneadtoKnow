import Foundation

/// One milestone on the prep timeline.
struct ScheduleStep: Identifiable, Hashable {
    let id = UUID()
    let icon: String        // SF Symbol
    let title: String
    let detail: String
    let time: Date
    /// Hours from this step until the next (0 for the final serve step).
    let leadHours: Double
    /// Where the rest after this step happens.
    let restLocation: StepLocation
    /// A hands-on task (vs. a passive rest or the final bake).
    let isActive: Bool
    /// A hands-on task that lands in the middle of the night.
    let awkward: Bool
    /// A "typical gotcha" for this step.
    let gotcha: String
}

/// A full bake plan, worked backward from the serve time.
struct Schedule {
    let serve: Date
    let start: Date
    let totalHours: Double
    let leadHours: Double            // serve − now
    let prefermentRestHours: Double
    let yeastHours: Double           // time used for the yeast dose
    let yeastTemp: Double            // temperature used for the yeast dose
    let steps: [ScheduleStep]
    let isTight: Bool
    /// The plan was auto-adjusted (warmer proof + more yeast) to fit the time.
    let autoAdjusted: Bool
}

enum Scheduler {

    static let fridgeTemp = 4.0
    static let quickTemp = 32.0
    private static let coldRoomBulk = 1.5   // h at room before the fridge
    private static let coldWarmUp = 2.0     // h to come back to room temp
    private static let autolyseHours = 0.5  // flour + water rest

    private static func tempFactor(_ tempC: Double) -> Double {
        pow(2.0, (20.0 - tempC) / 10.0)
    }

    private static func prefermentRest(_ input: DoughInput) -> Double {
        guard input.prefermentActive else { return 0 }
        return clamp(input.preferment.restBaseHours * tempFactor(input.temperatureC), 6, 24)
    }

    /// Total time the dough wants, uncompressed — the earliest sensible serve.
    static func idealTotalHours(input: DoughInput) -> Double {
        let tf = tempFactor(input.temperatureC)
        let pref = prefermentRest(input)
        let auto = input.autolyseActive ? autolyseHours : 0
        switch input.ferment {
        case .sameDay: return pref + auto + clamp(8 * tf, 2, 48) + clamp(3 * tf, 1, 10)
        case .cold:    return pref + auto + coldRoomBulk + 24 + coldWarmUp
        case .quick:   return pref + auto + 1.0 + 0.5
        }
    }

    // MARK: Build

    private struct Seg {
        let icon: String, title: String, detail: String
        let rest: Double, loc: StepLocation, active: Bool
    }

    static func build(input: DoughInput, now: Date) -> Schedule {
        let serve = input.serveDate
        let available = max(0, serve.timeIntervalSince(now) / 3600.0)
        let tf = tempFactor(input.temperatureC)
        let pref = input.prefermentActive
        var prefRest = prefermentRest(input)

        let count = max(input.ballCount, 1)
        let noun = input.style.shape.nounPlural
        let isRound = input.style.shape == .round
        let isFocaccia = input.style.id == "focaccia"
        let divideTitle = isFocaccia ? "Into the Pan" : (isRound ? "Ball Roll" : "Into Pans")

        // Mix-step detail (varies by quick / pre-ferment).
        let mixTitle = "The Dough"
        let mixDetail: String
        if isFocaccia {
            mixDetail = "Mix the flour, water, salt, yeast and oil into a wet, sticky dough — no real kneading needed. You'll build the strength with a few stretch-and-folds instead, so just bring it together, cover and rest."
        } else if input.autolyseActive {
            if pref {
                mixDetail = "Bring the two big pieces together: add the whole \(input.preferment.name.lowercased()) and the salt (plus any oil or honey) to the autolyse — your rested bowl of flour and water. Knead it all until smooth and elastic, then lightly oil the bowl, cover and leave to rise."
            } else {
                mixDetail = "Add the salt and yeast (plus any oil or honey) to the autolyse — your rested bowl of flour and water — and knead until smooth and elastic. Lightly oil the bowl, cover and leave to rise."
            }
        } else if input.ferment == .quick {
            mixDetail = "Use warm water (~40 °C) and the honey to wake the yeast. Knead until smooth, lightly oil the bowl, cover, and keep somewhere warm."
        } else if pref {
            mixDetail = "Combine the \(input.preferment.name.lowercased()) with the rest of the flour, water and salt. Knead until smooth, lightly oil the bowl and cover."
        } else {
            mixDetail = "Combine flour, water, salt and yeast; knead until smooth and elastic. Lightly oil the bowl, cover, and leave to rise."
        }

        var segs: [Seg] = []
        if pref {
            segs.append(Seg(icon: "drop.fill",
                            title: "The \(input.preferment.name)",
                            detail: input.preferment.mixDetail,
                            rest: prefRest, loc: .room, active: true))
        }
        if input.autolyseActive {
            segs.append(Seg(icon: "timer", title: "Autolyse",
                            detail: "Mix just the flour and water (no salt or yeast) into a shaggy mass. Cover and rest — the flour hydrates fully and the dough becomes far easier to stretch.",
                            rest: autolyseHours, loc: .room, active: true))
        }

        var yeastHours: Double
        var yeastTemp: Double
        var isTight = false
        var autoAdjusted = false

        switch input.ferment {
        case .sameDay:
            // Fit the plan into the available time by warming the proof (which
            // also raises the yeast) before resorting to a rushed, compressed one.
            let userTemp = input.temperatureC
            func sameDayIdeal(at t: Double) -> Double {
                let f = tempFactor(t)
                let pf = input.prefermentActive ? clamp(input.preferment.restBaseHours * f, 6, 24) : 0
                let a = input.autolyseActive ? autolyseHours : 0
                return pf + a + clamp(8 * f, 2, 48) + clamp(3 * f, 1, 10)
            }
            var proofTemp = userTemp
            if available + 0.5 < sameDayIdeal(at: userTemp) {
                var t = userTemp
                while t < 30 && available + 0.5 < sameDayIdeal(at: t) { t += 0.5 }
                proofTemp = min(t, 30)
            }
            let warmed = proofTemp > userTemp + 0.01
            let f = tempFactor(proofTemp)
            var bulk = clamp(8 * f, 2, 48)
            var proof = clamp(3 * f, 1, 10)
            prefRest = input.prefermentActive ? clamp(input.preferment.restBaseHours * f, 6, 24) : 0
            let idealWarm = prefRest + (input.autolyseActive ? autolyseHours : 0) + bulk + proof
            if available + 0.5 < idealWarm && idealWarm > 0 {
                isTight = true
                let s = max(available, 0.5) / idealWarm
                prefRest *= s; bulk *= s; proof *= s
            }
            if pref { segs[0] = Seg(icon: segs[0].icon, title: segs[0].title, detail: segs[0].detail, rest: prefRest, loc: .room, active: true) }
            let proofLoc: StepLocation = warmed ? .warm : .room
            segs.append(Seg(icon: "fork.knife", title: mixTitle, detail: mixDetail, rest: bulk, loc: proofLoc, active: true))
            segs.append(Seg(icon: "circle.grid.2x2", title: divideTitle,
                            detail: divideDetail(isRound: isRound, count: count, noun: noun, cold: false, styleID: input.style.id),
                            rest: proof, loc: proofLoc, active: true))
            yeastHours = bulk + proof
            yeastTemp = proofTemp
            autoAdjusted = warmed && !isTight

        case .cold:
            let coldHours = clamp(available - prefRest - coldRoomBulk - coldWarmUp, 6, 72)
            isTight = coldHours < 24
            segs.append(Seg(icon: "fork.knife", title: mixTitle, detail: mixDetail, rest: coldRoomBulk, loc: .room, active: true))
            segs.append(Seg(icon: "circle.grid.2x2", title: divideTitle,
                            detail: divideDetail(isRound: isRound, count: count, noun: noun, cold: true, styleID: input.style.id),
                            rest: coldHours, loc: .fridge, active: true))
            segs.append(Seg(icon: "sun.max.fill", title: "Ready It",
                            detail: "Bring the dough out of the fridge so it comes back to room temperature before shaping.",
                            rest: coldWarmUp, loc: .room, active: true))
            yeastHours = coldHours
            yeastTemp = fridgeTemp

        case .quick:
            // Fit autolyse + rise + proof inside the available window so the
            // start never lands in the past.
            let auto = input.autolyseActive ? autolyseHours : 0
            let pool = max(available - auto, 0.75)
            let rise = clamp(pool * 0.6, 0.5, 3)
            let proof = clamp(pool * 0.4, 0.25, 1)
            segs.append(Seg(icon: "fork.knife", title: mixTitle, detail: mixDetail, rest: rise, loc: .warm, active: true))
            segs.append(Seg(icon: "circle.grid.2x2", title: divideTitle,
                            detail: divideDetail(isRound: isRound, count: count, noun: noun, cold: false, styleID: input.style.id),
                            rest: proof, loc: .warm, active: true))
            yeastHours = rise + proof
            yeastTemp = quickTemp
        }

        // Focaccia builds strength with stretch-and-folds during the early bulk,
        // then a long undisturbed rise — split the single bulk step accordingly.
        if isFocaccia, let i = segs.firstIndex(where: { $0.title == mixTitle }) {
            let bulk = segs[i].rest
            let foldWindow = min(2.0, max(0, bulk - 0.5) * 0.6)
            if foldWindow >= 0.5 {
                let leadIn = 0.25
                let mix = segs[i]
                // One step per stretch-and-fold, ~30 min apart, then the long rise.
                let nFolds = max(2, min(4, Int((foldWindow / 0.5).rounded())))
                let foldRest = foldWindow / Double(nFolds)
                let after = max(0, bulk - foldWindow - leadIn)
                segs[i] = Seg(icon: mix.icon, title: mixTitle, detail: mix.detail,
                              rest: leadIn, loc: mix.loc, active: true)
                var inserts: [Seg] = []
                for k in 1...nFolds {
                    let tail = k == nFolds
                        ? "Last set — the dough should feel noticeably smoother and stronger now."
                        : "It firms up and traps a little more air each time."
                    inserts.append(Seg(icon: "hands.and.sparkles.fill",
                                       title: "Fold \(k) of \(nFolds)",
                                       detail: "With a wet hand, grab one side of the dough, stretch it up and fold it over to the middle; turn the bowl a quarter-turn and repeat all the way round. \(tail)",
                                       rest: foldRest, loc: mix.loc, active: true))
                }
                inserts.append(Seg(icon: "wind", title: "Bulk Rise",
                                   detail: "Now leave the dough undisturbed and covered until puffy and well risen — almost doubled and full of bubbles.",
                                   rest: after, loc: mix.loc, active: false))
                segs.insert(contentsOf: inserts, at: i + 1)
            }
        }

        let total = segs.reduce(0) { $0 + $1.rest }
        let start = serve.addingTimeInterval(-total * 3600)

        // Assign times.
        var steps: [ScheduleStep] = []
        var cursor = start
        for seg in segs {
            steps.append(ScheduleStep(
                icon: seg.icon, title: seg.title, detail: seg.detail, time: cursor,
                leadHours: seg.rest, restLocation: seg.loc,
                isActive: seg.active, awkward: seg.active && isSleepHour(cursor),
                gotcha: gotchaFor(seg.title)))
            cursor = cursor.addingTimeInterval(seg.rest * 3600)
        }
        let shapeTitle: String
        let shapeIcon: String
        let shapeDetail: String
        if isFocaccia {
            shapeTitle = "Dimple & Brine"
            shapeIcon = "circle.dotted"
            shapeDetail = "Now that it's risen in the pan, stretch it gently to the corners if it hasn't filled out. With well-oiled fingers, dimple the dough all over — press right down to the base to make deep dips. Whisk a little olive oil, water and salt into a brine and drizzle it over so it pools in the dimples."
        } else if isRound {
            shapeTitle = "Shape It"
            shapeIcon = "hand.draw.fill"
            shapeDetail = "Gently stretch each ball by hand, dusting the bench with fine semolina (not flour) so it slides cleanly off the peel."
        } else {
            shapeTitle = "Shape It"
            shapeIcon = "hand.draw.fill"
            shapeDetail = "Press the dough out to the corners of the oiled pan and dimple it."
        }
        steps.append(ScheduleStep(
            icon: shapeIcon, title: shapeTitle, detail: shapeDetail,
            time: serve, leadHours: 0, restLocation: .room, isActive: true, awkward: false,
            gotcha: gotchaFor(shapeTitle)))
        steps.append(ScheduleStep(
            icon: "fork.knife.circle.fill", title: "Top It",
            detail: "Topping order: \(input.style.assembly)",
            time: serve, leadHours: 0, restLocation: .room, isActive: true, awkward: false,
            gotcha: gotchaFor("Top It")))
        steps.append(ScheduleStep(
            icon: "flame.fill", title: "Bake It",
            detail: "\(input.oven.bakeAdvice(for: input.style)) Buon appetito!",
            time: serve, leadHours: 0, restLocation: .room, isActive: false, awkward: false,
            gotcha: gotchaFor("Bake It")))

        return Schedule(
            serve: serve, start: start, totalHours: total, leadHours: available,
            prefermentRestHours: prefRest, yeastHours: yeastHours, yeastTemp: yeastTemp,
            steps: steps, isTight: isTight, autoAdjusted: autoAdjusted
        )
    }

    private static func divideDetail(isRound: Bool, count: Int, noun: String, cold: Bool, styleID: String = "") -> String {
        if styleID == "focaccia" {
            return cold
                ? "Tip the dough into a well-oiled pan and gently coax it toward the edges (it needn't reach them yet). Cover and refrigerate."
                : "Tip the dough into a well-oiled pan and gently coax it toward the edges (it needn't reach them yet). Cover and leave to proof until pillowy."
        }
        if !isRound {
            return cold
                ? "Divide into \(count) oiled \(noun), cover and refrigerate."
                : "Divide into \(count) oiled \(noun) and leave to proof."
        }
        return cold
            ? "Cut into \(count) pieces, ball them up, coat lightly with olive oil, cover and refrigerate."
            : "Cut into \(count) pieces, ball them up, coat lightly with olive oil, then cover and leave to proof."
    }

    /// A "typical gotcha" for each timeline step (matched by title prefix).
    private static func gotchaFor(_ title: String) -> String {
        switch title {
        case "Autolyse":
            return "Don't add salt or yeast yet — salt tightens the gluten and slows hydration. 20–60 minutes is plenty; much longer and it can slacken too far."
        case "The Poolish", "The Biga":
            return "If the pre-ferment smells sharply of alcohol or has sunk, it's over-fermented — use it domed and bubbly."
        case "The Dough":
            return "Under-kneaded dough can't hold gas, so knead until smooth and stretchy. Water hotter than ~50 °C kills the yeast."
        case "Ball Roll", "Into Pans":
            return "Dust with semolina, not flour (flour gets absorbed and sticks). Ball them tight and smooth so they hold shape, not spread."
        case "Into the Pan":
            return "Use a properly oiled pan — focaccia sticks fiercely otherwise. Don't force it to the edges yet; it'll relax and spread as it proofs."
        case let t where t.hasPrefix("Fold "):
            return "Wet your hand so the dough doesn't stick, and be gentle — you're building strength, not knocking the air out. If it's already smooth and elastic, you can stop early."
        case "Bulk Rise":
            return "Go by the look, not the clock — it's ready when puffy and bubbly. A cold kitchen takes longer; a warm one races ahead."
        case "Dimple & Brine":
            return "Oil your fingers well and commit — timid dimples puff flat in the oven. Dimple just before baking, not long before, or they'll fade."
        case "Ready It":
            return "Shape it cold and it tears — let the dough come fully back to room temperature first (~2 h)."
        case "Shape It":
            return "Stretch from the centre outwards with your fingertips — never a rolling pin (it knocks out the air). If it springs back, rest it 10 minutes."
        case "Top It":
            return "Go light. Too much sauce or wet mozzarella floods the base and makes a soggy middle. Drain fresh cheese first."
        case "Bake It":
            return "An under-heated oven gives a pale, bready crust — preheat the stone or steel fully before the pizza goes in."
        default:
            return "Trust your dough and adjust to taste."
        }
    }

    private static func isSleepHour(_ date: Date) -> Bool {
        let h = Calendar.current.component(.hour, from: date)
        return h >= 23 || h < 6
    }

    private static func clamp(_ x: Double, _ lo: Double, _ hi: Double) -> Double {
        min(max(x, lo), hi)
    }

    // MARK: Formatting helpers

    static func clock(_ date: Date, now: Date) -> String {
        let cal = Calendar.current
        let timeFmt = DateFormatter()
        timeFmt.locale = Locale(identifier: "en_GB")
        timeFmt.dateFormat = "HH:mm"
        let time = timeFmt.string(from: date)

        if cal.isDate(date, inSameDayAs: now) { return "Today \(time)" }
        if let tomorrow = cal.date(byAdding: .day, value: 1, to: now),
           cal.isDate(date, inSameDayAs: tomorrow) { return "Tomorrow \(time)" }

        let dayFmt = DateFormatter()
        dayFmt.locale = Locale(identifier: "en_GB")
        dayFmt.dateFormat = "EEE d"
        return "\(dayFmt.string(from: date)) \(time)"
    }

    /// Just the time, e.g. "18:30" (no day word).
    static func timeOnly(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_GB")
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }

    /// Just the day, e.g. "Today" / "Tomorrow" / "Wed 19" — for a day divider.
    static func dayLabel(_ date: Date, now: Date) -> String {
        let cal = Calendar.current
        if cal.isDate(date, inSameDayAs: now) { return "Today" }
        if let tomorrow = cal.date(byAdding: .day, value: 1, to: now),
           cal.isDate(date, inSameDayAs: tomorrow) { return "Tomorrow" }
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_GB")
        f.dateFormat = "EEE d"
        return f.string(from: date)
    }

    static func duration(_ hours: Double) -> String {
        let totalMinutes = Int((hours * 60).rounded())
        let h = totalMinutes / 60
        let m = totalMinutes % 60
        if h == 0 { return "\(m) m" }
        if m == 0 { return "\(h) h" }
        return "\(h) h \(m) m"
    }

    /// A tight form for cramped spaces, e.g. "30h16", "45m", "8h".
    static func durationShort(_ hours: Double) -> String {
        let totalMinutes = Int((hours * 60).rounded())
        let h = totalMinutes / 60
        let m = totalMinutes % 60
        if h == 0 { return "\(m)m" }
        if m == 0 { return "\(h)h" }
        return "\(h)h\(String(format: "%02d", m))"
    }
}
