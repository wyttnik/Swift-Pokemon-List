//
//  DetailsView.swift
//  PokemonList
//
//  Created by Deev Ilyas on 19.11.2023.
//

import SwiftUI

struct DetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var detailsViewModel = PersistenceController.shared.contentViewModel
    @State var uiImage: UIImage?
    @State var isLoading = false
    private var fetchRequest: FetchRequest<PokemonDetails>
    private var pokemonDetails: FetchedResults<PokemonDetails> {
        fetchRequest.wrappedValue
    }

    init(id: String){
        self.fetchRequest = FetchRequest(sortDescriptors: [],
                                           predicate: NSPredicate(format: "id == %@", "\(id)"))
    }
    
    var body: some View {
        GeometryReader {geo in
            VStack{
                ForEach(pokemonDetails,  id: \.id) {details in
                    if let uiImage = uiImage {
                        Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: geo.size.width/1.5, height: geo.size.width/1.5)
                    }
                    else {
                        ProgressView()
                            .frame(width: geo.size.width/1.5, height: geo.size.width/1.5)
                            .task {
                                do {
                                    self.uiImage = try await PokeApi.apiManager
                                        .loadPokemonImage(name: details.name ?? "",id: details.id ?? "",
                                                                                                 for: .details)
                                } catch {
                                    print("No image folder")
                                }
                            }
                    }
                    ZStack{
                        RoundedRectangle(cornerRadius: 50).frame(width: geo.size.width, height: geo.size.height)
                            .foregroundColor(.white)

                        ScrollView{
                            VStack(spacing: 10){
                                HStack{
                                    Text("Weight").foregroundColor(.gray)
                                    Spacer()
                                    Text("\(details.weight ?? "")kg")
                                }
                                HStack{
                                    Text("Height").foregroundColor(.gray)
                                    Spacer()
                                    Text("\(details.height ?? "")m")
                                }
                                ForEach(details.statArray , id: \.name) {stat in
                                    HStack{
                                        Text("\(stat.wrappedName.capitalized)").foregroundColor(.gray)
                                        Spacer()
                                        Text("\(stat.wrappedValue)")
                                    }
                                }
                            }
                        }.padding(.top).padding(.horizontal,20)
                    }
                }
                
            }.background(.mint).padding(.top, 1)
        }
        .navigationBarTitle(pokemonDetails.first?.name?.capitalized ?? "Pokemon Details")
        .navigationBarItems(trailing: Button(action: {
            Task{
                await fetchPokemonDetails(id: pokemonDetails.first?.id ?? "", name: pokemonDetails.first?.name ?? "")
            }
        }) {
            Image(systemName: "arrow.2.circlepath")}.disabled(isLoading)
        )
        .alert(item: $detailsViewModel.alertItem) { alertItem in
            Alert(title: alertItem.title, message: alertItem.message, dismissButton: .default(alertItem.buttonTitle){dismiss()})
        }
    }

}

extension DetailsView {
    private func fetchPokemonDetails(id: String, name:String) async {
        isLoading = true
        do {
            try await PersistenceController.shared.fetchPokemonDetails(id: id, name: name, update: true)
        } catch {}
        isLoading = false
    }
}
