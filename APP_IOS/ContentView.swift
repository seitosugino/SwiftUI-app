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
    var averageUserRating: Double
    var trackName: String?
    var formattedPrice: String?
    var artworkUrl100: String
}

struct ContentView: View {
    @State private var results = [Result]()
    @State private var seachTextField = ""
    
    var body: some View {
        NavigationView{
            List(results, id: \.trackId){item in
                VStack(alignment: .leading){
                    NavigationLink(destination: ShowDiteil(itemData: item)) {
                        Text(item.trackName ?? "").font(.headline)
                        Text(item.formattedPrice ?? "")
                    }
                }
            }.navigationTitle("appStoreアプリ")
                .navigationBarItems(leading: Button(action: {}, label: {
                    NavigationLink(destination: SeachView()){
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
        guard let URL = URL(string: "https://itunes.apple.com/search?term=game&country=jp&media=software")else{
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

struct SeachView: View {
    @State private var results = [Result]()
    @State var term = ""
    
    var body: some View {
        VStack{
            HStack{
                Text("検索").font(.largeTitle).padding(.leading)
                Spacer()
            }
            HStack{
                TextField("キーワードを入れてください", text: $term).textFieldStyle(RoundedBorderTextFieldStyle()).frame(width:300)
                Button(action: {
                    term = ""
                }){
                    ZStack {
                        RoundedRectangle(cornerRadius: 5).frame(width:50,height: 30)
                        NavigationLink(destination: SeachContentView(term: $term)){
                            Text("検索").foregroundColor(.white)
                        }
                    }
                }
            }
        }
    }
}

struct SeachContentView: View {
    @State private var results = [Result]()
    @Binding var term: String
    
    var body: some View {
        NavigationView{
            List(results, id: \.trackId){item in
                VStack(alignment: .leading){
                    NavigationLink(destination: ShowDiteil(itemData: item)) {
                        Text(item.trackName ?? "").font(.headline)
                        Text(item.formattedPrice ?? "")
                    }
                }
            }
        }.navigationTitle("検索結果").onAppear(perform: loadData)
    }
    
    func loadData(){
        guard let URL = URL(string: "https://itunes.apple.com/search?term=\(term)&country=jp&media=software")else{
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
    
    var itemData: Result
    var body: some View{
        Text(itemData.trackName ?? "")
        URLImage(url: "\(itemData.artworkUrl100)")
                        .aspectRatio(contentMode: .fit)
        Text(itemData.formattedPrice ?? "")
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

class ImageDownloader : ObservableObject{
    @Published var downloadData: Data? = nil
    func downloadImage(url: String){
        guard let imageURL = URL(string: url) else { return }
        DispatchQueue.global().async{
            let data = try? Data(contentsOf: imageURL)
            DispatchQueue.main.async{
                self.downloadData = data
            }
        }
    }
}

struct URLImage: View{
    let url: String
    @ObservedObject private var imageDownloader = ImageDownloader()
    init(url: String){
        self.url = url
        self.imageDownloader.downloadImage(url: self.url)
    }
    var body: some View{
        if let imageData = self.imageDownloader.downloadData{
            let img = UIImage(data: imageData)
            return VStack{
                Image(uiImage: img!).resizable()
            }
        } else {
            return VStack{
                Image(uiImage: UIImage(systemName: "icloud.and.arrow.down")!).resizable()
            }
        }
    }
}
