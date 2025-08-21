import SwiftUI

struct SquareGradientIcon: View {
    var body: some View {
        ZStack {
            if #available(iOS 18.0, *) {
                ZStack {
                    Rectangle()
                        .fill(
                            AngularGradient(
                                colors: [.blue, .pink, .grayGreen, .blue], // Repeat the first color for a smooth loop
                                center: .center,
                                startAngle: .degrees(0),
                                endAngle: .degrees(360)
                            )
                        )
                        .frame(width: 1024, height: 1024)
                    
                    /*Image(systemName: "star.fill")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .bold()*/
                }
            } else {
                Text("Requires iOS 18+")
            }
        }
    }
}

// Custom colors defined for clarity
extension Color {
    static let blue = Color(red: 44/255, green: 155/255, blue: 185/255)
    static let grayGreen = Color(red: 134/255, green: 219/255, blue: 169/255)
    static let pink = Color(red: 221/255, green: 158/255, blue: 240/255)
}

#Preview {
    SquareGradientIcon()
}
