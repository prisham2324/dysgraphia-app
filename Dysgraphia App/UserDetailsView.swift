//
//  UserDetailsView.swift
//  Dysgraphia App
//
//  Created by Prisha Mishra on 9/27/26.
//

import SwiftUI

struct UserDetailsView: View {
    @State private var name = ""
    @State private var age = ""
    @State private var gender = ""
    @State private var notes = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("User Details")
                .font(.largeTitle)
                .fontWeight(.bold)

            TextField("Name", text: $name)
                .textFieldStyle(.roundedBorder)

            TextField("Age", text: $age)
                .textFieldStyle(.roundedBorder)

            TextField("Gender", text: $gender)
                .textFieldStyle(.roundedBorder)

            TextField("Additional Notes (Optional)", text: $notes)
                .textFieldStyle(.roundedBorder)

            NavigationLink(destination: HandwritingTestView()) {
                Text("Continue")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("User Details")
    }
}

#Preview {
    NavigationStack {
        UserDetailsView()
    }
}


