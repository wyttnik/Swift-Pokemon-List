//
//  DetailsView.swift
//  PokemonList
//
//  Created by Deev Ilyas on 19.11.2023.
//

import SwiftUI

struct DetailsView: View {
    let name: String
    @EnvironmentObject var detailsViewModel: PokemonDetailsViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader {geo in
            VStack{
                AsyncImage(url: URL(string: detailsViewModel.pokemonDetails?.imgUrl ?? "")) { phase in
                    switch phase {
                    case .failure: Image(systemName: "photo").frame(width: geo.size.width/1.5, height: geo.size.width/1.5)
                    case .success(let image): image
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width/1.5, height: geo.size.width/1.5)
                    default: ProgressView()
                            .frame(width: geo.size.width/1.5, height: geo.size.width/1.5)
                    }}
                ZStack{
                    RoundedRectangle(cornerRadius: 50).frame(width: geo.size.width, height: geo.size.height)
                        .foregroundColor(.white)
                    
                    ScrollView{
                        VStack(spacing: 10){
                            HStack{
                                Text("Weight").foregroundColor(.gray)
                                Spacer()
                                Text("\(detailsViewModel.pokemonDetails?.weight ?? 0)kg")
                            }
                            HStack{
                                Text("Height").foregroundColor(.gray)
                                Spacer()
                                Text("\(detailsViewModel.pokemonDetails?.height ?? 0)m")
                            }
                            ForEach(detailsViewModel.pokemonDetails?.stats ?? [], id: \.name) {stat in
                                HStack{
                                    Text("\(stat.name.capitalized)").foregroundColor(.gray)
                                    Spacer()
                                    Text("\(stat.value)")
                                }
                            }
                        }
                    }.padding(.top).padding(.horizontal,20)
                }
            }.background(.mint).padding(.top, 1)
        }
        .navigationTitle(detailsViewModel.pokemonDetails?.name.capitalized ?? "Pokemon Details")
        .alert(item: $detailsViewModel.alertItem) { alertItem in
            Alert(title: alertItem.title, message: alertItem.message, dismissButton: .default(alertItem.buttonTitle){dismiss()})
        }
        .task{
            await detailsViewModel.getPokemonInfo(name)
        }
    }
    
}
