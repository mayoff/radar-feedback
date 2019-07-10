import SwiftUI

enum Frequency {
    case weekly(on: Int)
    case monthly(on: Int)
}

struct ContentView : View {
    @Binding var frequency: Frequency

    var body: some View {
        VStack {
            SegmentedControl(selection: segmentBinding) {
                Text("Weekly").tag(Segment.weekly)
                Text("Monthly").tag(Segment.monthly)
            }.padding()
            if segmentBinding.value == .weekly {
                VStack {
                    Text("Day of Week")
                    Picker("Day of Week", selection: weekDayBinding) {
                        ForEach(0 ... 6) {
                            Text("Day \($0)").tag($0)
                        }
                    }
                }
            } else {
                VStack {
                    Text("Day of Month")
                    Picker("Day of Month", selection: monthDayBinding) {
                        ForEach(0 ... 29) {
                            Text("Day \($0)").tag($0)
                        }
                    }
                }
            }
        }
    }

    @State private var dayForOtherFrequencyUnit = 0

    private var segmentBinding: Binding<Segment> {
        return Binding<Segment>(
            getValue: { self.frequency.segment },
            setValue: { segment in
                if segment == self.frequency.segment { return }
                let day = self.dayForOtherFrequencyUnit
                self.dayForOtherFrequencyUnit = self.frequency.dayValue
                self.frequency = .init(segment: segment, day: day)
        })
    }

    private var weekDayBinding: Binding<Int> {
        return Binding<Int>(
            getValue: { () -> Int in
                switch self.frequency {
                    case .weekly(on: let day): return day
                    case .monthly(on: _): return self.dayForOtherFrequencyUnit
                } },
            setValue: { newValue -> Void in
                switch self.frequency {
                case .weekly(on: _): self.frequency = .weekly(on: newValue)
                case .monthly(on: _): self.dayForOtherFrequencyUnit = newValue
                } })
    }

    private var monthDayBinding: Binding<Int> {
        return Binding<Int>(
            getValue: { () -> Int in
                switch self.frequency {
                    case .weekly(on: _): return self.dayForOtherFrequencyUnit
                    case .monthly(on: let day): return day
                } },
            setValue: { newValue -> Void in
                switch self.frequency {
                case .weekly(on: _): self.dayForOtherFrequencyUnit = newValue
                case .monthly(on: _): self.frequency = .monthly(on: newValue)
                } })
    }

    fileprivate enum Segment: Int, Hashable {
        case weekly
        case monthly
    }
}

extension Frequency {
    fileprivate var segment: ContentView.Segment {
        switch self {
        case .weekly(on: _): return .weekly
        case .monthly(on: _): return .monthly
        }
    }

    var dayValue: Int {
        switch self {
        case .weekly(on: let day), .monthly(on: let day): return day
        }
    }

    fileprivate init(segment: ContentView.Segment, day: Int) {
        switch segment {
        case .weekly: self = .weekly(on: day)
        case .monthly: self = .monthly(on: day)
        }
    }
}

struct FrequencyViewState {
    enum CalendarUnit {
        case weekly
        case monthly
    }
    var unit: CalendarUnit
    var weekDay: Int
    var monthDay: Int

    init(_ frequency: Frequency) {
        switch frequency {
        case .weekly(on: let day):
            unit = .weekly
            weekDay = day
            monthDay = 0
        case .monthly(on: let day):
            unit = .monthly
            weekDay = 0
            monthDay = day
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider, View {
    static var previews: some View {
        Self()
    }

    @State var frequency: Frequency = .weekly(on: 0)

    var body: some View {
        ContentView(frequency: $frequency)
    }
}
#endif
