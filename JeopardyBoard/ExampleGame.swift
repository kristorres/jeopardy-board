#if DEBUG
import Foundation

fileprivate let jsonData = """
{
    "jeopardyRoundCategories": [
        {
            "title": "Artists in Europe",
            "clues": [
                {
                    "pointValue": 200,
                    "answer": "Here’s this artist with a tropical vibe going on at his home in Figueres, Spain.",
                    "correctResponse": "Who is Salvador Dalí?",
                    "isDailyDouble": false,
                    "isDone": false
                },
                {
                    "pointValue": 400,
                    "answer": "In the 1860s, after this American artist settled in England, his mother moved in with him and sat for his most famous painting.",
                    "correctResponse": "Who is James Abbott McNeill Whistler?",
                    "isDailyDouble": false,
                    "isDone": false
                },
                {
                    "pointValue": 600,
                    "answer": "Here’s this artist and his wife Alice enjoying some time away from Giverny in Venice’s St. Mark’s Square.",
                    "correctResponse": "Who is Claude Monet?",
                    "isDailyDouble": false,
                    "isDone": false
                },
                {
                    "pointValue": 800,
                    "answer": "Well-established in 1639, he paid the hefty price of 13,000 guilders for a house in Amsterdam that today houses his museum.",
                    "correctResponse": "Who is Rembrandt?",
                    "isDailyDouble": true,
                    "isDone": false
                },
                {
                    "pointValue": 1000,
                    "answer": "While visiting van Gogh at Arles, this painter did his own take on The Night Café and Madame Ginoux all in one.",
                    "correctResponse": "Who is Paul Gauguin?",
                    "isDailyDouble": false,
                    "isDone": false
                }
            ]
        },
        {
            "title": "It’s the Little Things",
            "clues": [
                {
                    "pointValue": 200,
                    "answer": "Founded in Pennsylvania in 1939, this sports program revised its rules in the 1970s so girls could play too.",
                    "correctResponse": "What is Little League Baseball?",
                    "isDailyDouble": false,
                    "isDone": false
                },
                {
                    "pointValue": 400,
                    "answer": "Originating in Asia, it’s the art of growing miniature trees, like the one see here.",
                    "correctResponse": "What is bonsai?",
                    "isDailyDouble": false,
                    "isDone": false
                },
                {
                    "pointValue": 600,
                    "answer": "These smallest blood vessels connect arteries with veins.",
                    "correctResponse": "What are capillaries?",
                    "isDailyDouble": false,
                    "isDone": false
                },
                {
                    "pointValue": 800,
                    "answer": "Proverbially, they “fell great oaks.”",
                    "correctResponse": "What are little strokes?",
                    "isDailyDouble": false,
                    "isDone": false
                },
                {
                    "pointValue": 1000,
                    "answer": "A satoshi is the smallest unit in this currency system.",
                    "correctResponse": "What is Bitcoin?",
                    "isDailyDouble": false,
                    "isDone": false
                }
            ]
        },
        {
            "title": "Christmas Movies",
            "clues": [
                {
                    "pointValue": 200,
                    "answer": "In 2018, Benedict Cumberbatch voiced this Seussian title guy who wasn’t as into Christmas as the Whos were.",
                    "correctResponse": "Who is the Grinch?",
                    "isDailyDouble": false,
                    "isDone": false
                },
                {
                    "pointValue": 400,
                    "answer": "Alastair Sim is among those who have played this Dickensian man but unlike Michael Caine, did so without Muppets.",
                    "correctResponse": "Who is Ebenezer Scrooge?",
                    "isDailyDouble": false,
                    "isDone": false
                },
                {
                    "pointValue": 600,
                    "answer": "Basically, this heartwarming Frank Capra classic is about a disgraced financier having an incredibly rough Christmas Eve.",
                    "correctResponse": "What is It's a Wonderful Life?",
                    "isDailyDouble": false,
                    "isDone": false
                },
                {
                    "pointValue": 800,
                    "answer": "In this film, Santa tells Buddy there are 30 Ray’s Pizzas in NYC; “They all claim to be the original, but the real one’s on 11th.”",
                    "correctResponse": "What is Elf?",
                    "isDailyDouble": false,
                    "isDone": false
                },
                {
                    "pointValue": 1000,
                    "answer": "2 memorable bits from this 1983 classic: the leg lamp and “You’ll shoot your eye out!”",
                    "correctResponse": "What is A Christmas Story?",
                    "isDailyDouble": false,
                    "isDone": false
                }
            ]
        },
        {
            "title": "Wearable Tech",
            "clues": [
                {
                    "pointValue": 200,
                    "answer": "Friendship bracelets inspired Kim Shui’s designs for this rhyming brand of high-tech trackers.",
                    "correctResponse": "What is Fitbit?",
                    "isDailyDouble": false,
                    "isDone": false
                },
                {
                    "pointValue": 400,
                    "answer": "Shhh…in 2014, this lingerie retailer sold a $75 sports bra with electrodes that hooked up to a heart rate monitor.",
                    "correctResponse": "What is Victoria’s Secret?",
                    "isDailyDouble": false,
                    "isDone": false
                },
                {
                    "pointValue": 600,
                    "answer": "It’s just a blue T to me, but the men’s UA Tech 2.0 vibe print short sleeve by this sports brand somehow has “anti-odor technology.”",
                    "correctResponse": "What is Under Armour?",
                    "isDailyDouble": false,
                    "isDone": false
                },
                {
                    "pointValue": 800,
                    "answer": "A 2014 BBC review called this alliterative eyewear from a search engine company “promising, sometimes brilliant…but a failure.”",
                    "correctResponse": "What is Google Glass?",
                    "isDailyDouble": false,
                    "isDone": false
                },
                {
                    "pointValue": 1000,
                    "answer": "An experimental tattoo ink developed in Germany for diabetics changes color in response to the levels of this sugar.",
                    "correctResponse": "What is glucose?",
                    "isDailyDouble": false,
                    "isDone": false
                }
            ]
        },
        {
            "title": "Brooklyn '99",
            "clues": [
                {
                    "pointValue": 200,
                    "answer": "In 1899, this gangster-to-be was born in Brooklyn’s Navy Yard section; no reports of any scars on his face.",
                    "correctResponse": "Who is Al Capone?",
                    "isDailyDouble": false,
                    "isDone": false
                },
                {
                    "pointValue": 400,
                    "answer": "As it was shedding concrete, this alliterative structure was “Falling Down” in the subject of a 1999 article.",
                    "correctResponse": "What is the Brooklyn Bridge?",
                    "isDailyDouble": false,
                    "isDone": false
                },
                {
                    "pointValue": 600,
                    "answer": "This sitting president visited Brooklyn in 1899 and cabled Admiral Dewey on the anniversary of his triumph in the Philippines.",
                    "correctResponse": "Who is William McKinley?",
                    "isDailyDouble": false,
                    "isDone": false
                },
                {
                    "pointValue": 800,
                    "answer": "In 1899, the Brooklyn Superbas won the National League Pennant; 100 years later, they’d have moved far away and become this team.",
                    "correctResponse": "Who are the Los Angeles Dodgers?",
                    "isDailyDouble": false,
                    "isDone": false
                },
                {
                    "pointValue": 1000,
                    "answer": "This 1999 novel about a detective with Tourette’s by Brooklyn native Jonathan Lethem was the basis of a 2019 Edward Norton film.",
                    "correctResponse": "What is Motherless Brooklyn?",
                    "isDailyDouble": true,
                    "isDone": false
                }
            ]
        },
        {
            "title": "\\"Bing\\" Pot",
            "clues": [
                {
                    "pointValue": 200,
                    "answer": "It would cause Pinocchio’s nose to increase in size.",
                    "correctResponse": "What is fibbing?",
                    "isDailyDouble": false,
                    "isDone": false
                },
                {
                    "pointValue": 400,
                    "answer": "Like what a stenographer does, making a copy of something in writing.",
                    "correctResponse": "What is transcribing?",
                    "isDailyDouble": false,
                    "isDone": false
                },
                {
                    "pointValue": 600,
                    "answer": "The act of offering someone hush money.",
                    "correctResponse": "What is bribing?",
                    "isDailyDouble": false,
                    "isDone": false
                },
                {
                    "pointValue": 800,
                    "answer": "At the beach, this word refers to a tide that is going out.",
                    "correctResponse": "What is ebbing?",
                    "isDailyDouble": false,
                    "isDone": false
                },
                {
                    "pointValue": 1000,
                    "answer": "Raising a number to the third power.",
                    "correctResponse": "What is cubing?",
                    "isDailyDouble": false,
                    "isDone": false
                }
            ]
        }
    ],
    "finalJeopardyClue": {
        "categoryTitle": "Women & Science",
        "answer": "Dr. Margaret Todd gave science this word for different forms of one basic substance; it’s from the Greek for “equal” and “place.”",
        "correctResponse": "What is isotope?"
    }
}
""".data(using: .utf8)!

fileprivate let decoder = JSONDecoder()

fileprivate let clueSet = try! decoder.decode(ClueSet.self, from: jsonData)

fileprivate let players = [
    Player(name: "Ken Jennings"),
    Player(name: "James Holzhauer"),
    Player(name: "Brad Rutter")
]

let exampleGame = JeopardyGame(clueSet: clueSet, players: players)
#endif
