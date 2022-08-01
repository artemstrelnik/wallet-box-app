//
//  widget_app.swift
//  widget_app
//
//  Created by Sergey Dimitriev on 08.04.2022.
//

import WidgetKit
import SwiftUI

private let widgetGroupId = "group.walletbox.app"

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> ExampleEntry {
        ExampleEntry(date: Date(), title: "Placeholder Title", message: "Placeholder Message")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ExampleEntry) -> ()) {
        let data = UserDefaults.init(suiteName:widgetGroupId)
        let entry = ExampleEntry(date: Date(), title: data?.string(forKey: "title") ?? "No Title Set", message: data?.string(forKey: "message") ?? "No Message Set")
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        getSnapshot(in: context) { (entry) in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}

struct ExampleEntry: TimelineEntry {
    let date: Date
    let title: String
    let message: String
}

struct widget_appEntryView : View {
    var entry: Provider.Entry
    let data = UserDefaults.init(suiteName:widgetGroupId)
    
//    var body: some View {
//
//            Text("Быстрые транзакции").bold().font(.body)
//            .widgetURL(URL(string: "https://google.com"))
//            .foregroundColor(.white)
//                .background(Color(hex: "0x181623"))
//    }
    
    var body: some View {
        HStack {
                 Link(destination: URL(string: "customscheme://walletbox.app/addOperation?type=qr")!) {
                     Image(systemName: "qr")
                         .resizable()
                         .aspectRatio(1, contentMode: .fit).background(Color(hex: "0xEFF3F8")).frame(width: 50, height: 50).padding()
                         .overlay(
                             RoundedRectangle(cornerRadius: 15)
                                 .stroke(Color.purple, lineWidth: 1)
                         )
                         }
                 Link(destination: URL(string: "customscheme://walletbox.app/addOperation?type=hand")!) {
                     Image(systemName: "plus")
                         .resizable()
                         .aspectRatio(1, contentMode: .fit).background(Color(hex: "0xEFF3F8")).frame(width: 50, height: 50).padding()
                         .overlay(
                             RoundedRectangle(cornerRadius: 15)
                                 .stroke(Color.purple, lineWidth: 1)
                         )
                         }
                            
            
        }
        
    }
    
}

@main
struct widget_app: Widget {
    let kind: String = "widget_app"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            widget_appEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemMedium])
    }
}

struct widget_app_Previews: PreviewProvider {
    static var previews: some View {
        widget_appEntryView(entry: ExampleEntry(date: Date(), title: "Example Title", message: "Example Message"))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
