# Making a tiny personal benchmark dataset for vision-LLMs

New LLMs pop up every day it seems, so having a way to do a quick vibe check of each is important. This post introduces my small personal photo benchmark dataset that reflects images typically found in my smartphone's camera roll.

The use-case I have in mind is to get a vision-LLM to automatically describe all my photos and screenshots from 20 years of digital photography. Since that needs to happen using batch processing, there's no room for follow-up questions or other techniques to improve a description. Once I choose a model I'll do some additional prompt tuning to get the best possible results from that model, but it'll still be just one request per image.

## Dataset description

Each image serves a specific purpose in testing different aspects of vision LLMs' capabilities. There's currently a bit much from Pokemon Go here, but on the other hand I still play and document achievements by taking screenshots so those screenshots are easily half of my camera roll too.

For each vision-capable LLM, I'll post each image along with a small prompt, typically "Describe the photo or screenshot". Different prompts might tease out higher quality descriptions of course, but we're doing a vibe check here and the most important part of that is the ability to discard a model as not interesting quickly.

Below each image I'll include the output from each model I've tested. Plus a description of which models I still consider good or even best.

## Model summary

Scores are subjective from 0 to 10.

| Large Language Model          | Image 1 | Image 2 | Image 3 | Image 4 | Image 5 | Image 6 | **Average** |
|-------------------------------|---------|---------|---------|---------|---------|---------|-------------|
| Llama 3.2 11B vision-instruct |    3    |    8    |   10    |    8    |    0    |    2    |     5.2     |



# Detailed output

## 1. Pokemon Go collection challenge

The first image showcases a Pokémon GO collection challenge screenshot, testing the model's ability to interpret gaming interfaces and recognize specific game elements.

<img src="/assets/images/test1.png" alt="Pokemon Go Collection Challenge" style="max-width:300px;">

<details>
<summary>
Llama 3.2 11B Vision-Instruct: Not great - Did not mention Pokemon Go. Okay at OCR but not good at describing what the screenshot most likely represents.
</summary>
This image shows a screenshot of a screen display on an iPhone, with a green and blue gradient background featuring level lines of a bike path. At the top left are the time "14:06" in white, wireless data signal strength, and battery level. In the center, below the section saying "Congratulations!", is a gold ring around an image showing a medal with the number 77.

The slider bar is at the bottom, and the area is green at the top, transitioning to blue over a map or road and houses. There are lines that look like level bars on a road on the right and light green text on the right side, saying "5:05:30" and "SHARE". The bottom of the slider bar has a light green rounded rectangle with white "SHARE" text next to a light-green circle with a white outline to its right. Below it is a similar-looking blue button with white "SAVE IMAGE" text and the Save photo icon.

Additionally, there are two small-scale logos near the top on the left side. The image suggests that it may be a crossword puzzle game since the surrounding levels do not display any clues as to what game it is.
</details>

Tested using OpenRouter on 2024-11-02.


## 2. Photo of a natural, rural scene

A landscape photograph featuring power lines against a natural backdrop. What we want to see here is the ability to describe the scene, the objects included and the overall feel of it.

<img src="/assets/images/test2.jpg" alt="Field with Power Lines" style="max-width:300px;">

<details>
<summary>
Llama 3.2 11B Vision-Instruct: Okay - I've seen better descriptions than this, but it's certainly good enough.
</summary>
This serene landscape image captures a farmland landscape at dusk, with a row of power lines extending from the right to move background a row of trees, fading into the sky's warm hues of blue, pink, orange, and yellow. In the foreground, a tree is silhouetted in a field of green grass, which gradually transitions to dry fields. Beyond the row of power lines, trees line the far horizon, with a red building peeking through the silhouette of the towers and trees. The image exudes a sense of tranquility and peacefulness, conveying a feeling of time spent in rural solitude.
</details>

Tested using OpenRouter on 2024-11-02.

## 3. Pokemon Go catch scene

Finding rare pokemon is always fun and a common reason to take a screenshot. To catalogue them later and make them searchable, we at least need to know that it's Pokemon Go and the name of the pokemon.

<img src="/assets/images/test3.png" alt="Pokemon Go Catch Scene" style="max-width:300px;">

<details>
<summary>
Llama 3.2 11B Vision-Instruct: Great - Very detailed, possibly too detailed. But that's not a problem for search and embedding use-cases. 
</summary>
The image shows a screenshot of a phone screen with the Pokémon character Snorlax in the center, surrounded by trees and mountains. The overall atmosphere is peaceful and serene, suggesting a morning or daytime setting.

Here are the key elements of the image:
* **Snorlax:**
	+ Standing in the center of the image
	+ Blue and white fur
	+ Red eyes
	+ White belly
* **Trees:**
	+ Red and orange leaves
	+ Green leaves on some trees
	+ Varieties of trees, including deciduous and evergreen
* **Mountains:**
	+ Blue-gray color
	+ Faint outlines
	+ Blurred in the background
* **Sky:**
	+ Light blue color
	+ White clouds
	+ Sun or moon not visible
* **Text:**
	+ "Bonus Challenge!" written in white font
	+ "Catch Snorlax!" written below the first line

Overall, the image appears to be a screenshot from a Pokémon game, possibly a bonus challenge level where the player must catch Snorlax. The peaceful atmosphere and serene surroundings suggest a morning or daytime setting, but the exact time of day is not specified.
</details>

Tested using OpenRouter on 2024-11-02.

## 4. Text recognition in product snapshots

A detailed shot of a Gainomax product, specifically chosen to test OCR capabilities and product detail identification. Taking images of random products to remember their specs is something I often do. And I'm rarely able to find the images back later, hence why I need searchable descriptions.

<img src="/assets/images/test4.jpg" alt="Gainomax Product" style="max-width:300px;">

<details>
<summary>
Llama 3.2 11B Vision-Instruct: Almost great - First time seeing a LLM output a typo like "brpwn". The rest of the output ticks the boxes.
</summary>
This photograph depicts a container of Gainomax Choco Coffee High Protein drink. The white container features white cap, with the brand name "Gainomax" in upper case, and "Choco Coffee" in a larger, brown font accenting the "C". The packaging communicates nutritional information: "High Protein" alongside a white number 30 and "No Added Sugar", as well as its volume (250 ml).

The front of the carton features brpwn liquid splatters,  a partial view of a coffee bean, and an image of chocolate depicting the melting of a square cube of chocolate.

The container rests on a light brown wooden surface, with the wood displaying distinctive curly grain, some of which overtops the edges.

Overall, this image showcases a nutritional beverage product, highlighting its unique flavor and key features while emphasizing its health benefits, making it an attractive option for consumers seeking a convenient and nutritious drink.
</details>

Tested using OpenRouter on 2024-11-02.

## 5. Pokedex Recognition

A Pokémon GO Pokédex screenshot, testing the model's ability to interpret structured game information.

<img src="/assets/images/test5.png" alt="Pokemon Go Pokedex" style="max-width:300px;">

<details>
<summary>
Llama 3.2 11B Vision-Instruct: Failure - The LLM misunderstands, this is not a login screen.
</summary>
The image shows the top half of a cell phone screen displaying the Pokémon Go login screen, with the phone's battery life and signal strength visible. The screen features a pink and purple background with a 3D rendering of a Pokémon, a banner indicating that the user is registered to Pokédex, nine Pokémons in boxes, as well as a time and character selection

Overall, the image suggests that the user has just logged in to their Pokémon Go account and is now ready to play the game, with the top half of the screen displaying the login screen and the bottom half displaying the user's profile information.
</details>

Tested using OpenRouter on 2024-11-02.

## 6. Technical Documentation

An electrical saw with technical specifications, evaluating the model's capability to process and understand technical product information and do accurate OCR. I also ideally want it to understand the Norwegian name of the product and either refer to it as-is or translated to English.

<img src="/assets/images/test6.jpg" alt="Electrical Saw" style="max-width:300px;">

<details>
<summary>
Llama 3.2 11B Vision-Instruct: Quite bad - It only recognizes some of the specifications like the power rating and voltage. It completely misses the name of the product (it's a saw) and goes on too much about the wires and plates and whatnot.
</summary>
The image shows a close-up view of an electrical device with wires and cables attached to it. The device is black and has a yellow label on the front.

* A yellow label on the front of a black device:
	+ The label is rectangular in shape
	+ It has a yellow background with black text
	+ The text includes information about the device's specifications, such as its power rating (800W), voltage (230V/50Hz), and frequency (50Hz)
	+ There are also some symbols and markings on the label, including a circular symbol and a line drawing of a plug
* Black wires and cables attached to the device:
	+ The wires are thick and black in color
	+ They are attached to the top and sides of the device
	+ There are several wires, but they are all connected to each other in a single bundle
* A blue metal plate underneath the device:
	+ The plate is flat and rectangular in shape
	+ It is positioned directly underneath the device
	+ The plate has a slight curvature to it, suggesting that it may be a mounting surface for the device

Overall, the image suggests that the device is an electrical component, possibly a motor or generator, and that it is designed to be mounted on a surface or connected to external wires. The yellow label provides important information about the device's specifications and performance characteristics.
</details>

Tested using OpenRouter on 2024-11-02.

