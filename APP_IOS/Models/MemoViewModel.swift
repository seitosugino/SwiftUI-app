//
//  MemoViewModel.swift
//  APP_IOS
//
//  Created by 杉野　星都 on 2021/12/21.
//

import Foundation
import Combine

class MemoViewModel: ObservableObject{
    @Published private(set) var memos: [Memo] = Array(Memo.findAll())
    @Published var memoTextField = ""
    @Published var deleteMemo: Memo?
    
    private var addMemoTask: AnyCancellable?
    private var deleteMemoTask: AnyCancellable?
    
    init(){
        addMemoTask = self.$memoTextField.sink(){text in
            guard !text.isEmpty else{
                return
            }
            let memo = Memo()
            memo.text = text
            self.memos.append(memo)
            Memo.add(memo)
        }
        deleteMemoTask = self.$deleteMemo.sink() { memo in
            guard let memo = memo else{
                return
            }
            if let index = self.memos.firstIndex(of: memo){
                self.memos.remove(at: index)
                Memo.delete(memo)
            }
        }
    }
}
