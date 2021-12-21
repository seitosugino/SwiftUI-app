//
//  ContentView.swift
//  APP_IOS
//
//  Created by 杉野　星都 on 2021/12/21.
//

import SwiftUI

struct Response: Codable {
    var results: [Result]
}

struct Result: Codable {
    var trackId: Int
    var trackName: String?
    var formattedPrice: String?
}

struct ContentView: View {
    @State private var results = [Result]()
    
    var body: some View {
        NavigationView{
            List(results, id: \.trackId){item in
                VStack(alignment: .leading){
                    NavigationLink(destination: ShowDiteil()) {
                        Text(item.trackName ?? "").font(.headline)
                        Text(item.formattedPrice ?? "")
                    }
                }
            }.navigationTitle("appStoreアプリ")
                .navigationBarItems(leading: Button(action: {}, label: {
                    NavigationLink(destination: MemoView()){
                        Text("検索")
                    }
                }), trailing: HStack {
                    Button(action: {}, label: {
                        NavigationLink(destination: MemoView()){
                            Text("メモ")
                        }
                    })
                })
        }.onAppear(perform: loadData)
    }
    
    func loadData(){
        guard let URL = URL(string: "https://itunes.apple.com/search?term=swiftui&country=jp&media=software")else{
            return
        }
        
        let request = URLRequest(url: URL)
        
        URLSession.shared.dataTask(with: request){data, response, error in
            if let data = data{
                let decoder = JSONDecoder()
                guard let decodedResponse = try? decoder.decode(Response.self, from: data)else{
                    print("JSON decode エラー")
                    return
                }
                
                DispatchQueue.main.async {
                    results = decodedResponse.results
                }
            }else{
                print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
    }
}

struct ShowDiteil: View{
    
    var body: some View{
        Text("1")
    }
}

struct MemoView: View{
    @ObservedObject var viewModel = MemoViewModel()
    @State private var isDeleteAlertPresented = false
    @State private var memoTextField = ""
    
    var body: some View {
        VStack{
            HStack{
                Text("メモの追加").font(.largeTitle).padding(.leading)
                Spacer()
            }
            HStack{
                TextField("メモを入れてください", text: $memoTextField).textFieldStyle(RoundedBorderTextFieldStyle()).frame(width:300)
                Button(action: {
                    viewModel.memoTextField = memoTextField
                    memoTextField = ""
                }){
                    ZStack {
                        RoundedRectangle(cornerRadius: 5).frame(width:50,height: 30)
                        Text("保存").foregroundColor(.white)
                    }
                }
            }
            
            HStack{
                Text("メモの一覧").font(.largeTitle).padding(.leading)
                Spacer()
            }
            List{
                ForEach(viewModel.memos.sorted{
                    $0.postedDate > $1.postedDate
                }){memo in
                    HStack{
                        MemoListView(memo: memo)
                        Text("削除").onTapGesture{
                            isDeleteAlertPresented.toggle()
                        }.padding().foregroundColor(.white).background(Color.red)
                    }
                    .alert(isPresented: $isDeleteAlertPresented){
                        Alert(title: Text("警告"),
                              message: Text("メモを削除します。\nよろしいですか？"),
                              primaryButton: .cancel(Text("いいえ")),
                              secondaryButton: .destructive(Text("はい")){
                            viewModel.deleteMemo = memo
                        }
                        )}
                }
            }
            
            Spacer()
        }
    }
}
    
struct MemoListView: View{
    var memo: Memo
    var body: some View{
        VStack(alignment: .leading){
            Text(formatDate(memo.postedDate))
            Text(memo.text)
        }
    }
    func formatDate(_ date : Date) -> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
.previewInterfaceOrientation(.portraitUpsideDown)
    }
}
