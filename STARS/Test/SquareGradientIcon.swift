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

#Preview {
    SquareGradientIcon()
}
