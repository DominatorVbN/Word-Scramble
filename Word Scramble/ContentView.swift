//
//  ContentView.swift
//  Word Scramble
//
//  Created by dominator on 02/11/19.
//  Copyright © 2019 dominator. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var usedWords = [String]()
    @State var rootWord = ""
    @State var newWord = ""
    
    
    @State var errorTitle = ""
    @State var errorMessage = ""
    @State var isShowingAlert = false
    
    @State var currentScore = 0
    
    var scoreText: some View{
        Text("Your current score is ")
                           .font(.title)
                           +
        Text("\(currentScore)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(UIColor.systemOrange))
    }
    
    var body: some View {
        NavigationView{
            VStack{
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()
                List(usedWords, id: \.self){ word in
                    HStack{
                        Image(systemName: "\(word.count).circle.fill")
                            .foregroundColor(Color(UIColor.systemOrange))
                        Text(word)
                        Spacer()
                    }
                    .addBackgroundStyle()
                }
               scoreText
            }
            .navigationBarTitle(rootWord)
            .navigationBarItems(trailing: Button(action: startGame){
                HStack{
                    Text("Restart")
                    Image(systemName: "arrow.clockwise.circle")
                }})
                .onAppear(perform: startGame)
                .alert(isPresented: $isShowingAlert) {
                    Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func addNewWord(){
        // lowercase and trim the word, to make sure we don't add duplicate words with case differences
        let awnser = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard awnser.count > 0 else{
            return
        }
        
        // will add extra validations
        guard isOriginal(word: awnser)else{
            wordError(title: "Duplicate word", message: "Be more original!")
            return
        }
        
        guard isPossible(word: awnser)else{
            wordError(title: "Impossible word", message: "You can not just make it up, you know.")
            return
        }
        
        guard isReal(word: awnser)else{
            wordError(title: "Not a real word", message: "Now your are just typing gibberise or word is less then three characers")
            return
        }
        currentScore += awnser.count
        usedWords.insert(awnser, at: 0)
        newWord = ""
    }
    
    func startGame(){
        if let url = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startString = try? String(contentsOf: url){
                let allWords =  startString.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "Nahi mila"
                currentScore = 0
                usedWords = [String]()
                return
            }
        }
        fatalError("Unable to load start.txt from bundle.")
    }
    
    func isOriginal(word: String)-> Bool{
        guard word != rootWord else {
            return false
        }
        return !usedWords.contains(word)
    }
    
    func isPossible(word: String)-> Bool{
        var tempRoot = rootWord
        for letter in word{
            if let pos = tempRoot.firstIndex(of: letter){
                tempRoot.remove(at: pos)
            }else{
                return false
            }
        }
        return true
    }
    
    func isReal(word: String)->Bool{
        guard word.count>=3 else{
            return false
        }
        let textChecker = UITextChecker()
        let range = NSRange(location: 0, length: word.count)
        let misspelledRange = textChecker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    
    
    func wordError(title: String, message: String){
        errorTitle = title
        errorMessage = message
        isShowingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
