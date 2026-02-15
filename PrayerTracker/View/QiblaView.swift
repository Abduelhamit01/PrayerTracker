//
//  QiblaView.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 08.02.26.
//

import SwiftUI
import CoreMotion

struct QiblaView: View {
    @ObservedObject var qiblaManager : QiblaManager
    
    var size: CGFloat = 30
    
    private var glassDiameter: CGFloat { size * 2.8 }
    
    var body: some View {
        ZStack{
            if #available(iOS 26.0, *) {
                Circle()
                    .frame(width: glassDiameter, height: glassDiameter)
                    .glassEffect()

                // Progress-Ring: leicht eingerückt, damit der Stroke nicht am Rand abgeschnitten wird
                Circle()
                    .inset(by: 2) // kleiner Puffer, z.B. 2pt
                    .trim(from: 0, to: qiblaManager.progress)
                    .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: glassDiameter, height: glassDiameter)
                    .foregroundStyle(.islamicGreen)
                    .glassEffect()

                // Füllfarbe, wenn ausgerichtet
                Circle()
                    .foregroundStyle(qiblaManager.lookingToMekkah ? .islamicGreen : .clear)
                    .frame(width: glassDiameter, height: glassDiameter)
                    .glassEffect()
            } else {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: glassDiameter, height: glassDiameter)
            }
            if qiblaManager.locationDenied {
                Image(systemName: "location.slash")
                    .font(.system(size: size * 1.4, weight: .bold, design: .rounded))
            } else {
                Image(systemName: "arrow.up")
                    .font(.system(size: size * 1.4, weight: .bold, design: .rounded))
                    .foregroundStyle(qiblaManager.lookingToMekkah ? .white : .islamicGreen)
                    .rotationEffect(Angle(degrees: qiblaManager.winkelPfeil))
                    .sensoryFeedback(.success, trigger: qiblaManager.lookingToMekkah)
            }
        }
    }
}

#Preview {
    QiblaView(qiblaManager: QiblaManager())
}
