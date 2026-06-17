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
        let auto = input.useAutolyse ? autolyseHours : 0
        switch input.ferment {
        case .sameDay: return pref + auto + clamp(14 * tf, 3, 60) + clamp(4 * tf, 1, 12)
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
        let divideTitle = isRound ? "Ball Roll" : "Into Pans"

        // Mix-step detail (varies by quick / pre-ferment).
        let mixTitle = "The Dough"
        let mixDetail: String
        if input.useAutolyse {
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
        if input.useAutolyse {
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
                let a = input.useAutolyse ? autolyseHours : 0
                return pf + a + clamp(14 * f, 3, 60) + clamp(4 * f, 1, 12)
            }
            var proofTemp = userTemp
            if available + 0.5 < sameDayIdeal(at: userTemp) {
                var t = userTemp
                while t < 30 && available + 0.5 < sameDayIdeal(at: t) { t += 0.5 }
                proofTemp = min(t, 30)
            }
            let warmed = proofTemp > userTemp + 0.01
            let f = tempFactor(proofTemp)
            var bulk = clamp(14 * f, 3, 60)
            var proof = clamp(4 * f, 1, 12)
            prefRest = input.prefermentActive ? clamp(input.preferment.restBaseHours * f, 6, 24) : 0
            let idealWarm = prefRest + (input.useAutolyse ? autolyseHours : 0) + bulk + proof
            if available + 0.5 < idealWarm && idealWarm > 0 {
                isTight = true
                let s = max(available, 0.5) / idealWarm
                prefRest *= s; bulk *= s; proof *= s
            }
            if pref { segs[0] = Seg(icon: segs[0].icon, title: segs[0].title, detail: segs[0].detail, rest: prefRest, loc: .room, active: true) }
            let proofLoc: StepLocation = warmed ? .warm : .room
            segs.append(Seg(icon: "fork.knife", title: mixTitle, detail: mixDetail, rest: bulk, loc: proofLoc, active: true))
            segs.append(Seg(icon: "circle.grid.2x2", title: divideTitle,
                            detail: divideDetail(isRound: isRound, count: count, noun: noun, cold: false),
                            rest: proof, loc: proofLoc, active: true))
            yeastHours = bulk + proof
            yeastTemp = proofTemp
            autoAdjusted = warmed && !isTight

        case .cold:
            let coldHours = clamp(available - prefRest - coldRoomBulk - coldWarmUp, 6, 72)
            isTight = coldHours < 24
            segs.append(Seg(icon: "fork.knife", title: mixTitle, detail: mixDetail, rest: coldRoomBulk, loc: .room, active: true))
            segs.append(Seg(icon: "circle.grid.2x2", title: divideTitle,
                            detail: divideDetail(isRound: isRound, count: count, noun: noun, cold: true),
                            rest: coldHours, loc: .fridge, active: true))
            segs.append(Seg(icon: "sun.max.fill", title: "Ready It",
                            detail: "Bring the dough out of the fridge so it comes back to room temperature before shaping.",
                            rest: coldWarmUp, loc: .room, active: true))
            yeastHours = coldHours
            yeastTemp = fridgeTemp

        case .quick:
            // Fit autolyse + rise + proof inside the available window so the
            // start never lands in the past.
            let auto = input.useAutolyse ? autolyseHours : 0
            let pool = max(available - auto, 0.75)
            let rise = clamp(pool * 0.6, 0.5, 3)
            let proof = clamp(pool * 0.4, 0.25, 1)
            segs.append(Seg(icon: "fork.knife", title: mixTitle, detail: mixDetail, rest: rise, loc: .warm, active: true))
            segs.append(Seg(icon: "circle.grid.2x2", title: divideTitle,
                            detail: divideDetail(isRound: isRound, count: count, noun: noun, cold: false),
                            rest: proof, loc: .warm, active: true))
            yeastHours = rise + proof
            yeastTemp = quickTemp
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
        let shapeDetail: String
        if isRound {
            shapeDetail = "Gently stretch each ball by hand, dusting the bench with fine semolina (not flour) so it slides cleanly off the peel."
        } else if input.style.id == "focaccia" {
            shapeDetail = "Stretch the dough to fill the oiled pan, then dimple all over with well-oiled fingers."
        } else {
            shapeDetail = "Press the dough out to the corners of the oiled pan and dimple it."
        }
        steps.append(ScheduleStep(
            icon: "hand.draw.fill", title: "Shape It", detail: shapeDetail,
            time: serve, leadHours: 0, restLocation: .room, isActive: true, awkward: false,
            gotcha: gotchaFor("Shape It")))
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

    private static func divideDetail(isRound: Bool, count: Int, noun: String, cold: Bool) -> String {
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
