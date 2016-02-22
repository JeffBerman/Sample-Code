//
//  CharadesGame.swift
//  Charades
//
//  Created by Jeff Berman on 8/13/15.
//  Copyright © 2015 Jeff Berman. All rights reserved.
//

import Foundation

struct Question {
    let text: String
    let category: String
    var played: Bool = false
    var guessedCorrectly: Bool = false
}

class CharadesGame {
    
    // The master list of game questions, sorted by category
    var masterQuestionList = [String: [Question]]()
    
    // Array of questions actually used in game
    var questions = [Question]()
    
    var score: Int {
        var theScore = 0
        for question in questions {
            theScore += question.guessedCorrectly ? 1 : 0
        }
        print("Score: \(theScore)")
        return theScore
    }
    
    var masterCategoryList: [String] {
        get { return [String](masterQuestionList.keys) }
    }
    
    /// The category filter for a new (unstarted) game.  Game questions will only be drawn from categories
    /// in the filter.  A filter of nil equals all categories included.
    var categoryFilter: [String]? {
        didSet {
            if gameInProcess {
                categoryFilter = oldValue
            } else {
                loadGameQuestionList(masterQuestionList)
            }
        }
    }
    
    private var currentQuestionIndex = -1
    var gameInProcess = false

    init() {
        // Load master list of questions, grouped by category
        loadMasterQuestionList()
       
        // Load list of questions to be used in this game
        loadGameQuestionList(masterQuestionList)
        print("\(masterQuestionList.count) categories loaded into master question list")
        print("\(questions.count) questions loaded into game array.")
    }
    
    
    // MARK: - Private methods
    
    // Loads master list of questions from every category, sorted by category.
    // Will eventually load from server, cache locally, then grab any updates from server.
     private func loadMasterQuestionList() {
        let people = ["Abraham Lincoln", "John F Kennedy", "Harrison Ford", "Anne Boleyn", "Tom Hanks", "Martha Stewart", "Jerry Springer",
            "Bill Clinton", "Ronald Reagan", "Ozzy Osbourne", "Mohammad Ali", "Robin Williams", "Popeye", "Stephen Hawking", "Yoda",
            "Thomas Edison", "Socrates", "Neil Armstrong", "Indiana Jones", "Spider Man", "Sherlock Holmes", "Albert Einstein",
            "Winnie the Pooh", "Shakespeare", "Christopher Columbus", "Paul McCartney", "Voldemort", "King Arthur", "Sigmund Freud",
            "Elvis Presley", "Dr. Seuss", "Barbie", "Vincent Van Gogh", "Henry Ford", "Thomas Jefferson", "Harry Houdini", "Mozart", "Superman",
            "Gandhi", "Babe Ruth", "Tarzan", "Bono", "Leonardo Da Vinci", "Luke Skywalker", "Robin Hood"]
        let professions = ["Clown", "Quarterback", "Astronaut", "Dancer", "Taxi Driver", "Artist", "Carpenter", "Chef", "Auto Mechanic",
            "Train Conductor", "Architect", "Dental Hygenist", "Journalist", "Sous Chef", "Legal Secretary", "Meteorologist",
            "Nursery School Teacher", "Psychiatrist", "Speech Therapist", "Archeologist", "Bailiff", "Crossing Guard", "Fire Inspector",
            "Paralegal", "Private Detective", "Probation Officer", "Security Guard", "Mortician", "Fitness Trainer", "Pedicurist",
            "Massage Therapist", "Nanny", "Cobbler", "Anesthesiologist", "Midwife", "Opthalmologist", "Actuary", "Loan Officer",
            "Bank Teller", "Choreographer", "Copy Writer", "Poet", "Arborist", "Zoologist", "Animal Trainer", "Bellhop", "Barista",
            "Concierge", "Short Order Cook", "Travel Agent", "Umpire", "Usher", "Seamstress", "Air Traffic Controller", "Administrative Assistant",
            "Auditor", "Chief Executive", "Court Reporter"]
        let books = ["Harry Potter and the Sorcerer's Stone", "The Hitchhiker's Guide to the Galaxy", "The Very Hungry Caterpillar", "The Cat in the Hat",
             "The Da Vinci Code", "The Hobbit", "A Tale of Two Cities", "To Kill a Mockingbird", "Where the Wild Things Are",
            "Moby Dick", "Frankenstein", "The Lion, the Witch, and the Wardrobe", "Huckleberry Finn", "The Great Gatsby", "Catch-22",
            "Lord of the Flies", "War and Peace", "Of Mice and Men", "Gulliver's Travels", "Watership Down", "Dune", "A Wrinkle in Time",
            "Fahrenheit 451", "On the Origin of Species", "James and the Giant Peach", "The Hunger Games", "Don Quixote"]
        let tvShows = ["The Simpsons", "South Park", "Game of Thrones", "Frasier", "Friends", "Sex and the City",
            "Dexter", "Arrested Development", "Modern Family", "Veronica Mars", "That '70s Show", "House", "The West Wing",
            "Breaking Bad", "Family Guy", "Curb Your Enthusiasm", "The Amazing Race", "Star Trek", "Entourage", "Fawlty Towers",
            "Seinfeld", "How I Met Your Mother", "Dora the Explorer", "The Big Bang Theory", "Homeland", "Scrubs", "Grey's Anatomy",
            "The Office", "Futurama", "Lost", "Downton Abbey", "I Love Lucy", "Smallville", "Doctor Who", "Mythbusters", "The X-Files",
            "My Three Sons", "Sanford and Son", "Kojak", "Bonanza", "The Wild Wild West", "Burn Notice"]
        let movies = ["Vertigo", "Titanic", "Gremlins", "The Shawshank Redemption", "Shrek", "The Godfather", "The Devil Wears Prada",
            "Ghostbusters", "Saw", "Fight Club", "Amelie", "Bridget Jones' Diary", "The Dark Knight", "Goodfellas", "Fried Green Tomatoes",
            "Pulp Fiction", "Alien", "Black Swan", "Inception", "Argo", "The Lion King", "Kung-Fu Panda", "The Matrix", "Home Alone",
            "Black Beauty", "Click", "Twilight", "Clueless", "X-Men", "The Empire Strikes Back", "Psycho", "Iron Man", "Jaws", "Braveheart",
            "The Little Mermaid", "The Wizard of Oz", "Mrs. Doubtfire", "Forrest Gump", "American Beauty"]
        
        var questions = [String: [Question]]()
        questions["People"] = people.map({ Question(text: $0, category: "People", played: false, guessedCorrectly: false) })
        questions["Professions"] = professions.map({ Question(text: $0, category: "Professions", played: false, guessedCorrectly: false) })
        questions["Books"] = books.map({ Question(text: $0, category: "Books", played: false, guessedCorrectly: false) })
        questions["TV Shows"] = tvShows.map({ Question(text: $0, category: "TV Shows", played: false, guessedCorrectly: false) })
        questions["Movies"] = movies.map({ Question(text: $0, category: "Movies", played: false, guessedCorrectly: false) })

        masterQuestionList = questions
    }
    
    // Returns a flattened array of questions drawn from a master list and
    // filtered by desired category.
    private func loadGameQuestionList(questionPool: [String: [Question]]) {
        var questionList = [Question]()
        let categories = categoryFilter ?? masterCategoryList
        
        for (category, questions) in questionPool {
            if categories.contains(category) {
                questionList += questions
            }
        }
        
        questions = randomize(questionList)
    }
    
    // Returns a randomized copy of the passed-in array
    func randomize(var array: [Question]) -> [Question] {
        var result = [Question]()
        
        while !array.isEmpty {
            let i = Int(arc4random_uniform(UInt32(array.count)))
            result.append(array[i])
            array.removeAtIndex(i)
        }
        return result
    }
    
    
    // MARK: - Public methods

    /// Called to return the next question in the deck
    func nextQuestion() -> Question? {
        gameInProcess = true
        if ++currentQuestionIndex < questions.count {
            print("Current question = \(questions[currentQuestionIndex].text)")
            return questions[currentQuestionIndex]
        }
        return nil
    }

    /// Call this to update current question's metadata
    func updateCurrentQuestion(played: Bool? = true, guessed: Bool?) {
        if currentQuestionIndex < questions.count {
            if let p = played {
                questions[currentQuestionIndex].played = p
            }
            if let g = guessed {
                questions[currentQuestionIndex].guessedCorrectly = g
            }
        }
    }
    
    
    /// Returns the nth Question from a list containing only played questions.
    // Note: this method is somewhat vestigial, and could probably be replaced by a `questionAtIndex()` function that merely returns questions[i] now.
    func playedQuestionAtIndex(index: Int) -> Question? {
        var i = 0
        for question in questions {
            if !question.played { continue }
            if i == index { return question }
            ++i
        }
        return nil
    }
    
    
    /// Returns the number of questions that were actually played.
    func playedQuestions() -> Int {
        var i = 0
        for question in questions {
            if !question.played { continue }
            ++i
        }
        return i
    }
}
