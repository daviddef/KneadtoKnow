import SwiftUI

/// A calm vertical timeline of the bake plan, worked backward from serve time.
struct TimelineView: View {
    let schedule: Schedule
    let now: Date
    var onInfo: (ScheduleStep) -> Void = { _ in }
    var itemsFor: (ScheduleStep) -> [Ingredient] = { _ in [] }
    var toppingPlan: [PizzaToppingPlan] = []
    var toppingAdvice: String = ""
    var metric: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(schedule.steps.enumerated()), id: \.element.id) { idx, step in
                let isLast = idx == schedule.steps.count - 1
                HStack(alignment: .top, spacing: 14) {
                    // Node + connecting line
                    VStack(spacing: 0) {
                        ZStack {
                            Circle()
                                .fill(isLast ? Palette.accent : Palette.surface)
                                .frame(width: 38, height: 38)
                                .shadow(color: Palette.shadowDark, radius: 4, x: 3, y: 3)
                                .shadow(color: Palette.shadowLight, radius: 4, x: -3, y: -3)
                            Image(systemName: step.icon)
                                .font(.rounded(15, weight: .semibold))
                                .foregroundStyle(isLast ? Color.white : Palette.accent)
                        }
                        if !isLast {
                            Rectangle()
                                .fill(Palette.textSoft.opacity(0.25))
                                .frame(width: 2)
                                .frame(minHeight: 40)
                        }
                    }

                    // Text
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text(step.title)
                                .font(.rounded(16, weight: .semibold))
                                .foregroundStyle(Palette.text)
                            Button { onInfo(step); Haptics.tap() } label: {
                                Image(systemName: "info.circle")
                                    .font(.rounded(13, weight: .medium))
                                    .foregroundStyle(Palette.accent)
                                    .frame(width: 28, height: 28)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            Spacer()
                            Text(Scheduler.clock(step.time, now: now))
                                .font(.rounded(13, weight: .medium))
                                .foregroundStyle(Palette.accent)
                        }
                        Text(step.detail)
                            .font(.rounded(12))
                            .foregroundStyle(Palette.textSoft)
                            .fixedSize(horizontal: false, vertical: true)
                        let items = itemsFor(step)
                        if !items.isEmpty {
                            VStack(alignment: .leading, spacing: 3) {
                                ForEach(items) { item in
                                    HStack(alignment: .firstTextBaseline) {
                                        Text(item.name)
                                            .foregroundStyle(Palette.text)
                                        Spacer()
                                        Text(Units.weight(item.grams, metric: metric))
                                            .foregroundStyle(Palette.accent)
                                    }
                                    .font(.rounded(12, weight: .medium))
                                }
                                if items.count > 1 {
                                    Divider().overlay(Palette.textSoft.opacity(0.25))
                                    HStack(alignment: .firstTextBaseline) {
                                        Text("Total")
                                            .foregroundStyle(Palette.textSoft)
                                        Spacer()
                                        Text(Units.weight(items.reduce(0) { $0 + $1.grams }, metric: metric))
                                            .foregroundStyle(Palette.accent)
                                    }
                                    .font(.rounded(12, weight: .bold))
                                }
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Palette.well))
                            .padding(.top, 5)
                        }
                        if step.title == "Top It" && !toppingPlan.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(toppingPlan) { plan in
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(plan.title)
                                            .font(.rounded(12, weight: .bold))
                                            .foregroundStyle(Palette.accent)
                                        ForEach(Array(plan.layers.enumerated()), id: \.element.id) { idx, layer in
                                            HStack(alignment: .firstTextBaseline, spacing: 6) {
                                                Text("\(idx + 1).")
                                                    .foregroundStyle(Palette.textSoft)
                                                Text(layer.name)
                                                    .foregroundStyle(Palette.text)
                                                Spacer()
                                                Text(Units.weight(layer.grams, metric: metric))
                                                    .foregroundStyle(Palette.textSoft)
                                            }
                                            .font(.rounded(12, weight: .medium))
                                        }
                                    }
                                }
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Palette.well))
                            .padding(.top, 5)
                        }
                        if step.title == "Top It" && !toppingAdvice.isEmpty {
                            HStack(alignment: .top, spacing: 6) {
                                Image(systemName: "lightbulb.fill")
                                Text(toppingAdvice)
                            }
                            .font(.rounded(11, weight: .medium))
                            .foregroundStyle(Palette.sage)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 6)
                        }
                        if step.awkward {
                            HStack(spacing: 5) {
                                Image(systemName: "moon.zzz.fill")
                                Text("Lands overnight — set an alarm, or shift your serve time.")
                            }
                            .font(.rounded(11, weight: .medium))
                            .foregroundStyle(Palette.amber)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 3)
                        }
                        if step.leadHours > 0 {
                            HStack(spacing: 5) {
                                Image(systemName: step.restLocation.icon)
                                Text(leadLabel(for: step))
                            }
                            .font(.rounded(11, weight: .medium))
                            .foregroundStyle(locationColor(step.restLocation))
                            .padding(.top, 4)
                        }
                    }
                    .padding(.bottom, isLast ? 0 : 14)
                }
            }
        }
    }

    /// Labels a rest with where it happens, and whether it spans the night.
    private func leadLabel(for step: ScheduleStep) -> String {
        var label = "\(Scheduler.duration(step.leadHours)) \(step.restLocation.phrase)"
        if spansNight(from: step.time, hours: step.leadHours) {
            label += " · overnight (you sleep)"
        }
        return label
    }

    /// Red for warm rests, blue for the fridge, sage at room temperature —
    /// so it's obvious at a glance when the dough is in or out of the cold.
    private func locationColor(_ loc: StepLocation) -> Color {
        switch loc {
        case .room:   return Palette.sage
        case .fridge: return Palette.cool
        case .warm:   return Palette.warm
        }
    }

    /// True if the interval covers ~3 am — i.e. it passes through the night.
    private func spansNight(from start: Date, hours: Double) -> Bool {
        guard hours > 0 else { return false }
        let cal = Calendar.current
        let end = start.addingTimeInterval(hours * 3600)
        var day = cal.startOfDay(for: start)
        while day <= end {
            if let threeAM = cal.date(byAdding: .hour, value: 3, to: day),
               threeAM >= start, threeAM <= end {
                return true
            }
            guard let next = cal.date(byAdding: .day, value: 1, to: day) else { break }
            day = next
        }
        return false
    }
}
