//
//  ContentView.swift
//  Word Scramble
//
//  Created by dominator on 02/11/19.
//  Copyright © 2019 dominator. All rights reserved.
//

import SwiftUI
extension View{
    func calColor(_ geo: GeometryProxy, _ innerGeo: GeometryProxy)->some View{
        let value = (innerGeo.frame(in: .global).minY - geo.frame(in: .global).minY)/geo.frame(in: .global).maxY
        return self.hueRotation(Angle(degrees: Double(360 * value)))
    }
}
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
                GeometryReader{geo in
                    List{
                        ForEach(self.usedWords, id: \.self){ word in
                            VStack{
                                GeometryReader{ innerGeo in
                                    HStack{
                                        Image(systemName: "\(word.count).circle.fill")
                                            .foregroundColor(Color.orange)
                                            .calColor(geo, innerGeo)
                                        Text(word)
                                        Spacer()
                                    }
                                    .addBackgroundStyle()
                                    .opacity(Double(1 - (self.calculateMul(geo, innerGeo)*2)))
                                    .offset(CGSize(width: innerGeo.frame(in: .global).width * self.calculateMul(geo, innerGeo), height: 0))
                                    .scaleEffect( 1 - self.calculateMul(geo, innerGeo))
                                }
                                .frame(height: 50)
                            }
                        }
                    }
                    .coordinateSpace(name: "Custom")


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
    
    func calculateMul(_ geo: GeometryProxy, _ innerGeo: GeometryProxy)->CGFloat{
        let value = (innerGeo.frame(in: .global).minY - geo.frame(in: .global).minY)/geo.frame(in: .global).maxY
        if ((innerGeo.frame(in: .global).minY - geo.frame(in: .global).minY) >=  geo.frame(in: .global).height * 0.7){
            return value - 0.5168195718654435
        }//0.5168195718654435

        return 0
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
